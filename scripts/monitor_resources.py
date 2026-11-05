#!/usr/bin/env python3
"""Linux CPU/RAM monitor. Run as root once per minute; no third-party packages."""
import argparse
import fcntl
import json
import os
from pathlib import Path
import socket
import time
import urllib.parse
import urllib.request

THRESHOLDS = {'cpu': 90, 'ram': 85}
DURATION = 300
MAX_GAP = 150


def cpu_percent(previous, current):
    if previous is None:
        return None
    total = current[0] - previous[0]
    idle = current[1] - previous[1]
    if total <= 0 or idle < 0 or idle > total:
        return None
    return 100 * (total - idle) / total


def read_metrics():
    # guest/guest_nice are already counted in user/nice; do not double count.
    fields = list(map(int, Path('/proc/stat').read_text().splitlines()[0].split()[1:9]))
    counters = [sum(fields), fields[3] + fields[4]]  # idle + iowait
    memory = dict(line.split(':', 1) for line in Path('/proc/meminfo').read_text().splitlines())
    total = int(memory['MemTotal'].split()[0])
    available = int(memory['MemAvailable'].split()[0])
    return counters, 100 * (total - available) / total


def evaluate(state, now, boot_id, counters, ram):
    """Update timers and return events; caller acknowledges successful delivery."""
    previous_time = state.get('time')
    continuous = (state.get('boot') == boot_id and previous_time is not None
                  and 0 < now - previous_time <= MAX_GAP)
    cpu = cpu_percent(state.get('counters'), counters) if continuous else None
    events = []
    for key, value in [('cpu', cpu), ('ram', ram)]:
        metric = state.setdefault(key, {'since': None, 'notified': False})
        if not continuous:
            metric['since'] = None
        if value is None:
            metric['since'] = None
            continue
        if value > THRESHOLDS[key]:
            if metric['since'] is None:
                metric['since'] = now
            if not metric['notified'] and now - metric['since'] >= DURATION:
                events.append((key, 'alert', value))
        else:
            metric['since'] = None
            if metric['notified']:
                events.append((key, 'recovery', value))
    state.update(time=now, boot=boot_id, counters=counters)
    return events, cpu


def load_telegram(path):
    config = {}
    for line in path.read_text().splitlines():
        if '=' in line and not line.lstrip().startswith('#'):
            key, value = line.split('=', 1)
            config[key.strip()] = value.strip().strip('\"\'')
    token = config.get('TRIP_ALERT_TELEGRAM_BOT_TOKEN', '')
    chat = config.get('TRIP_ALERT_TELEGRAM_CHAT_ID', '')
    if not token or not chat:
        raise ValueError('Telegram configuration missing')
    return token, chat


def send_telegram(token, chat, message):
    payload = urllib.parse.urlencode({'chat_id': chat, 'text': message}).encode()
    request = urllib.request.Request(
        'https://api.telegram.org/bot' + token + '/sendMessage', data=payload)
    with urllib.request.urlopen(request, timeout=12) as response:
        if json.load(response).get('ok') is not True:
            raise RuntimeError('Telegram rejected delivery')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Read metrics/config only; no state writes or messages')
    args = parser.parse_args()
    os.umask(0o077)
    token, chat = load_telegram(Path('/etc/splyto/splyto.env'))
    counters, ram = read_metrics()
    if args.check:
        print(f'Configuration OK; RAM={ram:.1f}%; CPU counters readable; thresholds CPU>90%, RAM>85%, duration=300s')
        return
    directory = Path('/var/lib/splyto-resource-monitor')
    directory.mkdir(mode=0o700, exist_ok=True)
    with (directory / 'lock').open('a') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        path = directory / 'state.json'
        try:
            state = json.loads(path.read_text())
        except FileNotFoundError:
            state = {}
        now = time.monotonic()
        boot = Path('/proc/sys/kernel/random/boot_id').read_text().strip()
        events, cpu = evaluate(state, now, boot, counters, ram)
        failed = False
        for key, kind, value in events:
            if kind == 'alert':
                detail = f'{key.upper()} noslodze pārsniedz {THRESHOLDS[key]}% vismaz 5 minūtes.'
            else:
                detail = f'{key.upper()} noslodze atkal ir normas robežās.'
            message = f'SPLYTO — {"slodzes brīdinājums" if kind == "alert" else "slodze normalizējusies"}\nServeris: {socket.gethostname()}\n{detail}\nPašreiz: {value:.1f}%'
            try:
                send_telegram(token, chat, message)
            except Exception:
                # Never print exceptions containing the token-bearing request URL.
                print(f'Telegram delivery failed for {key}/{kind}; retry on next run', flush=True)
                failed = True
            else:
                state[key]['notified'] = kind == 'alert'
                print(f'Telegram delivered: {key}/{kind}', flush=True)
        temporary = directory / 'state.tmp'
        temporary.write_text(json.dumps(state))
        temporary.replace(path)
        print(f'CPU={f"{cpu:.1f}%" if cpu is not None else "baseline"} RAM={ram:.1f}%', flush=True)
        if failed:
            raise SystemExit(1)


if __name__ == '__main__':
    try:
        main()
    except Exception:
        print('Resource monitor failed; check configuration, permissions and state file (details suppressed for credential safety)', flush=True)
        raise SystemExit(1)
