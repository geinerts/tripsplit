import datetime as dt
import gzip
import hashlib
import importlib.util
import io
import os
from pathlib import Path
import tarfile
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('retention', Path(__file__).parents[1] / 'backup_retention.py')
r = importlib.util.module_from_spec(spec)
spec.loader.exec_module(r)
NOW = dt.datetime(2026, 10, 23, 12, tzinfo=dt.timezone.utc).timestamp()


class RetentionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        for name in ['db', 'app_state', 'meta']:
            (self.root / name).mkdir()
        self.latest = self.make_set(3600)

    def make_set(self, age):
        epoch = NOW - age
        stamp = dt.datetime.fromtimestamp(epoch, dt.timezone.utc).strftime('%Y%m%d_%H%M%S')
        db = self.root / 'db' / f'splyto_{stamp}.sql.gz'
        db.write_bytes(gzip.compress(b'CREATE TABLE example (id INT);\n'))
        app = self.root / 'app_state' / f'splyto_app_{stamp}.tar.gz'
        with tarfile.open(app, 'w:gz') as archive:
            entry = tarfile.TarInfo('uploads/example.txt')
            entry.size = 7
            archive.addfile(entry, io.BytesIO(b'fixture'))
        manifest = self.root / 'meta' / f'backup_{stamp}.sha256'
        paths = [db, app, manifest]
        self.rehash(paths)
        for p in paths:
            os.utime(p, (epoch, epoch))
        return paths

    def rehash(self, paths):
        paths[2].write_text(''.join(f'{hashlib.sha256(p.read_bytes()).hexdigest()}  {p}\n' for p in paths[:2]))

    def run_cleanup(self, apply=False, days=14):
        return r.cleanup(self.root, 'splyto', days, apply=apply, now=NOW)

    def test_dry_run_never_deletes_or_creates_lock(self):
        old = self.make_set(15 * 86400)
        report = self.run_cleanup()
        self.assertEqual(report['candidate_files'], 3)
        self.assertEqual(report['deleted_files'], 0)
        self.assertTrue(all(p.exists() for p in old))
        self.assertFalse((self.root / '.retention.lock').exists())

    def test_exact_cutoff_and_recent_copy_are_preserved(self):
        old = self.make_set(14 * 86400 + 1)
        boundary = self.make_set(14 * 86400)
        report = self.run_cleanup(apply=True)
        self.assertEqual(report['deleted_files'], 3)
        self.assertTrue(all(not p.exists() for p in old))
        self.assertTrue(all(p.exists() for p in boundary + self.latest))

    def test_newest_file_age_prevents_deletion_of_updated_set(self):
        old = self.make_set(20 * 86400)
        os.utime(old[1], (NOW - 60, NOW - 60))
        self.assertEqual(self.run_cleanup(apply=True)['deleted_files'], 0)

    def test_corrupt_latest_stops_all_deletion(self):
        old = self.make_set(20 * 86400)
        self.latest[0].write_bytes(b'corrupt')
        with self.assertRaises(r.RetentionError):
            self.run_cleanup(apply=True)
        self.assertTrue(all(p.exists() for p in old))

    def test_checksum_match_does_not_replace_gzip_integrity_check(self):
        self.latest[0].write_bytes(b'not gzip')
        self.rehash(self.latest)
        for p in self.latest: os.utime(p, (NOW - 60, NOW - 60))
        with self.assertRaises(OSError): self.run_cleanup()

    def test_app_archive_must_be_readable_tar(self):
        self.latest[1].write_bytes(gzip.compress(b'not tar'))
        self.rehash(self.latest)
        for p in self.latest: os.utime(p, (NOW - 60, NOW - 60))
        with self.assertRaises(tarfile.TarError): self.run_cleanup()

    def test_stale_only_backup_is_never_deleted(self):
        for p in self.latest: p.unlink()
        old = self.make_set(30 * 86400)
        with self.assertRaises(r.RetentionError): self.run_cleanup(apply=True)
        self.assertTrue(all(p.exists() for p in old))

    def test_manual_partial_and_incomplete_sets_not_deleted(self):
        old = self.make_set(20 * 86400)
        old[1].unlink()
        manual = self.root / 'manual-recovery'
        manual.mkdir()
        (manual / 'db.sql.gz').write_bytes(b'manual')
        partial = self.root / 'db' / 'splyto_old.sql.gz.partial'
        partial.write_bytes(b'partial')
        report = self.run_cleanup(apply=True)
        self.assertEqual(report['deleted_files'], 0)
        self.assertEqual(len(report['incomplete_sets']), 1)
        self.assertTrue(partial.exists() and (manual / 'db.sql.gz').exists() and old[0].exists())

    def test_manifest_cannot_select_outside_files(self):
        old = self.make_set(20 * 86400)
        old[2].write_text('0' * 64 + '  /tmp/not-a-backup\n')
        with self.assertRaises(r.RetentionError): self.run_cleanup(apply=True)
        self.assertTrue(old[0].exists())

    def test_symlink_backup_is_rejected(self):
        old = self.make_set(20 * 86400)
        old[0].unlink()
        old[0].symlink_to(self.latest[0])
        with self.assertRaises(r.RetentionError): self.run_cleanup(apply=True)
        self.assertTrue(self.latest[0].exists())

    def test_symlink_directory_is_rejected(self):
        directory = self.root / 'db'
        directory.rename(self.root / 'elsewhere')
        directory.symlink_to(self.root / 'elsewhere')
        with self.assertRaises(r.RetentionError): self.run_cleanup(apply=True)

    def test_invalid_periods_database_and_root_rejected(self):
        for days in [0, -1, 3651]:
            with self.subTest(days=days), self.assertRaises(r.RetentionError):
                self.run_cleanup(apply=True, days=days)
        with self.assertRaises(r.RetentionError): r.cleanup(self.root, '../db', 14, now=NOW)
        with self.assertRaises(r.RetentionError): r.cleanup(Path('/'), 'splyto', 14, now=NOW)

    def test_backup_changed_during_verification_stops_deletion(self):
        old = self.make_set(20 * 86400)
        original = r.digest
        def mutate(path):
            value = original(path)
            if path == self.latest[0]:
                os.utime(path, (NOW - 1, NOW - 1))
            return value
        with patch.object(r, 'digest', side_effect=mutate), self.assertRaises(r.RetentionError):
            self.run_cleanup(apply=True)
        self.assertTrue(all(p.exists() for p in old))


if __name__ == '__main__':
    unittest.main()
