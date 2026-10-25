#!/usr/bin/env python3
"""Prune complete routine backup sets; default to a read-only plan."""
import argparse
import datetime as dt
import fcntl
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import tarfile
import time


class RetentionError(Exception):
    pass


def regular(path):
    try:
        return stat.S_ISREG(path.lstat().st_mode)
    except FileNotFoundError:
        return False


def fingerprint(path):
    s = path.lstat()
    return (s.st_dev, s.st_ino, s.st_size, s.st_mtime_ns, s.st_mode)


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def scan(root, database, days, now):
    if not 1 <= days <= 3650 or not re.fullmatch(r'[A-Za-z0-9_]+', database):
        raise RetentionError('Invalid retention period or database name.')
    if not root.is_absolute() or root.resolve() != root or root == Path('/'):
        raise RetentionError('Backup root must be a canonical absolute directory.')
    for directory in [root, root / 'db', root / 'app_state', root / 'meta']:
        if directory.is_symlink() or not directory.is_dir():
            raise RetentionError('Missing or linked backup directory.')
    sets, skipped = [], []
    for manifest in sorted((root / 'meta').iterdir()):
        match = re.fullmatch(r'backup_(\d{8}_\d{6})\.sha256', manifest.name)
        if not match:
            continue
        stamp = match[1]
        try:
            created = dt.datetime.strptime(stamp, '%Y%m%d_%H%M%S').replace(tzinfo=dt.timezone.utc).timestamp()
        except ValueError as error:
            raise RetentionError('Invalid backup timestamp.') from error
        db = root / 'db' / f'{database}_{stamp}.sql.gz'
        app = root / 'app_state' / f'splyto_app_{stamp}.tar.gz'
        paths = [db, app, manifest]
        if any(p.is_symlink() for p in paths):
            raise RetentionError('Linked backup file; cleanup refused.')
        if not all(regular(p) for p in paths):
            skipped.append(stamp)
            continue
        hashes = {}
        for line in manifest.read_text().splitlines():
            record = re.fullmatch(r'([0-9a-f]{64})  (.+)', line)
            if not record or record[2] in hashes:
                raise RetentionError('Invalid checksum manifest.')
            hashes[record[2]] = record[1]
        if set(hashes) != {str(db), str(app)}:
            raise RetentionError('Checksum manifest contains unexpected paths.')
        newest_time = max(created, *(p.stat().st_mtime for p in paths))
        if newest_time > now + 300:
            raise RetentionError('Backup timestamp is in the future.')
        sets.append(dict(stamp=stamp, paths=paths, hashes=hashes, created=created,
                         newest_time=newest_time, fingerprints=[fingerprint(p) for p in paths]))
    if not sets:
        raise RetentionError('No complete backup set; nothing may be deleted.')
    latest = max(sets, key=lambda s: s['created'])
    if now - latest['created'] > 48 * 3600:
        raise RetentionError('No complete backup from the last 48 hours; cleanup refused.')
    for path in latest['paths'][:2]:
        if digest(path) != latest['hashes'][str(path)]:
            raise RetentionError('Latest backup checksum verification failed.')
        # Reading the entire stream checks gzip integrity without extracting data.
        with gzip.open(path, 'rb') as stream:
            while stream.read(1024 * 1024):
                pass
    with tarfile.open(latest['paths'][1], 'r:gz') as archive:
        if not any(member.isfile() for member in archive):
            raise RetentionError('Latest app-state archive has no files.')
    if any(fingerprint(p) != fp for p, fp in zip(latest['paths'], latest['fingerprints'])):
        raise RetentionError('Latest backup changed during verification.')
    cutoff = now - days * 86400
    expired = [s for s in sets if s is not latest and s['newest_time'] < cutoff]
    return latest, expired, skipped


def cleanup(root, database, days, apply=False, now=None):
    now = time.time() if now is None else now
    latest, expired, skipped = scan(root, database, days, now)
    report = dict(mode='apply' if apply else 'dry-run', retention_days=days,
                  verified_latest=latest['stamp'], expired_sets=[s['stamp'] for s in expired],
                  candidate_files=sum(len(s['paths']) for s in expired),
                  candidate_bytes=sum(p.stat().st_size for s in expired for p in s['paths']),
                  incomplete_sets=skipped, deleted_files=0)
    if apply:
        # Preflight all identities before the first unlink. Never recurse or glob-delete.
        for s in [latest, *expired]:
            if any(fingerprint(p) != fp for p, fp in zip(s['paths'], s['fingerprints'])):
                raise RetentionError('Backup files changed; cleanup refused.')
        for s in expired:
            for path, expected in zip(s['paths'], s['fingerprints']):
                if fingerprint(path) != expected or not regular(path):
                    raise RetentionError('Backup file changed; cleanup stopped.')
                path.unlink()
                report['deleted_files'] += 1
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--database', required=True)
    parser.add_argument('--days', type=int, required=True)
    parser.add_argument('--apply', action='store_true', help='Delete only the expired complete sets in the plan.')
    args = parser.parse_args()
    try:
        if args.apply:
            # Serialize cleanup invocations. The daily job also has its existing cron lock.
            if (not args.root.is_absolute() or args.root.resolve() != args.root
                    or args.root == Path('/') or not args.root.is_dir()):
                raise RetentionError('Invalid backup root.')
            lock = args.root / '.retention.lock'
            fd = os.open(lock, os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
            with os.fdopen(fd, 'w') as handle:
                fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
                report = cleanup(args.root, args.database, args.days, apply=True)
        else:
            report = cleanup(args.root, args.database, args.days)
        print(json.dumps(report, sort_keys=True))
    except (RetentionError, OSError, ValueError, tarfile.TarError, EOFError):
        # No archive contents, credentials or exception payloads in logs.
        print(json.dumps({'error': 'Backup retention refused or stopped; verify paths, recent backup integrity and lock before retrying.'}))
        raise SystemExit(1)


if __name__ == '__main__':
    main()
