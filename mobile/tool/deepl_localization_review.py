#!/usr/bin/env python3
"""Create cached DeepL comparison candidates; never edit app catalogs.

Only public UI strings are sent. Credentials stay in the ignored root env file.
Default is a cost estimate; --translate explicitly enables API requests.
"""
import argparse
import hashlib
import html
import json
import re
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET
from collections import Counter
from pathlib import Path

from build_localization_review import CATALOGS, NAMES, ROOT, cell, flags

OUTPUT = ROOT / 'output/localization-review/deepl'
TARGETS = {code: code.upper() for code in NAMES if code != 'en'}
TARGETS['pt'] = 'PT-PT'
KEYS = [
    'paymentShareDetailsConsent', 'confirmReceivedAction', 'summaryYouOwe',
    'workspacePaymentSToMarkAsSentToConfirmAsReceived', 'analyticsYouGetBack',
    'analyticsYouOwe', 'profilePaymentSharingDescription', 'liveConsent',
    'livePermissionError',
]
CONTEXT = (
    'Splyto is a travel expense sharing app. These are concise app UI messages. '
    'A trip is a travel workspace with expenses. You owe means the current user '
    'must pay another member; you get back means the current user will receive '
    'money from other members. Confirm received means confirming receipt of a '
    'payment, not a receipt document. Splyto records external payments and does '
    'not transfer money. Sharing payment details grants access to saved bank or '
    'payment identifiers, not consent to make payments. Accepted members are '
    'confirmed participants, not everyone invited. Live location is precise, '
    'shared only with accepted trip members for the selected duration, continues '
    'in the background and may be stopped at any time. Use a friendly direct '
    'voice and preserve the exact scope of every permission and negation.'
)
ARGUMENT = re.compile(r'\{\w+\}')


def xml_source(source):
    # Plural/select messages need target-language plural rules and manual review.
    remainder = ARGUMENT.sub('', source)
    if '{' in remainder or '}' in remainder:
        raise ValueError('Complex ICU messages are not supported by this tool.')
    escaped = html.escape(source, quote=False)
    return '<text>' + ARGUMENT.sub(lambda m: '<x>' + m[0] + '</x>', escaped) + '</text>'


def plain_translation(xml, source):
    root = ET.fromstring(xml)
    if root.tag != 'text' or any(node.tag not in ('text', 'x') for node in root.iter()):
        raise ValueError('Unexpected XML structure in translation.')
    text = ''.join(root.itertext())
    if Counter(ARGUMENT.findall(source)) != Counter(ARGUMENT.findall(text)):
        raise ValueError('Translation changed placeholders.')
    if '{' in ARGUMENT.sub('', text) or '}' in ARGUMENT.sub('', text):
        raise ValueError('Translation introduced ICU syntax.')
    return text


def candidate_or_rejection(xml, source):
    try:
        return plain_translation(xml, source), None
    except (ValueError, ET.ParseError) as error:
        # Cache and quarantine unusable provider output, never apply it.
        return '', str(error)


class Client:
    def __init__(self):
        values = {}
        for line in (ROOT / '.env.deepl.local').read_text().splitlines():
            if '=' in line and not line.lstrip().startswith('#'):
                name, value = line.split('=', 1)
                values[name.strip()] = value.strip().strip('\"\'')
        self.key = values.get('DEEPL_AUTH_KEY', '')
        if not self.key or any(c.isspace() for c in self.key):
            raise ValueError('Missing or malformed DEEPL_AUTH_KEY; value not displayed.')
        self.base = ('https://api-free.deepl.com' if self.key.endswith(':fx')
                     else 'https://api.deepl.com')

    def request(self, path, payload=None):
        data = None if payload is None else json.dumps(payload).encode()
        if data is not None and len(data) > 128 * 1024:
            raise ValueError('Request exceeds DeepL payload limit.')
        headers = {'Authorization': 'DeepL-Auth-Key ' + self.key}
        if data is not None:
            headers['Content-Type'] = 'application/json'
        request = urllib.request.Request(self.base + path, data=data, headers=headers)
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                return json.load(response)
        except urllib.error.HTTPError as error:
            # Never print response bodies, headers or request objects.
            raise RuntimeError(f'DeepL HTTP {error.code}; request not retried.') from None
        except (urllib.error.URLError, TimeoutError, OSError):
            raise RuntimeError('DeepL connection failed; request not retried.') from None


def save_json(path, data):
    temporary = path.with_suffix('.tmp')
    temporary.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
    temporary.replace(path)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--translate', action='store_true')
    parser.add_argument('--locales', nargs='+', choices=list(TARGETS), default=list(TARGETS))
    parser.add_argument('--keys', nargs='+', default=KEYS)
    parser.add_argument('--all', action='store_true', help='Compare every simple message; list ICU messages for separate review.')
    parser.add_argument('--max-characters', type=int, default=30000,
                        help='Conservative per-run cap including XML markup.')
    args = parser.parse_args()
    source = json.loads((CATALOGS / 'app_en.arb').read_text())
    keys = ([k for k in source if not k.startswith('@')] if args.all
            else list(dict.fromkeys(args.keys)))
    if any(k.startswith('@') or k not in source for k in keys):
        raise ValueError('Unknown or metadata key requested.')
    skipped = []
    texts = {}
    for key in keys:
        try:
            texts[key] = xml_source(source[key])
        except ValueError:
            if not args.all:
                raise
            skipped.append(key)
    keys = list(texts)
    OUTPUT.mkdir(parents=True, exist_ok=True)
    if args.all:
        save_json(OUTPUT / 'icu-review-keys.json', skipped)
    cache_dir = OUTPUT / 'cache'
    cache_dir.mkdir(exist_ok=True)
    jobs = []
    rows = []
    for locale in dict.fromkeys(args.locales):
        catalog = json.loads((CATALOGS / f'app_{locale}.arb').read_text())
        pending = {}
        for key in keys:
            fingerprint = hashlib.sha256(json.dumps(
                [texts[key], TARGETS[locale], CONTEXT, 'xml-v2'], ensure_ascii=False
            ).encode()).hexdigest()
            path = cache_dir / (fingerprint + '.json')
            row = {'locale': locale, 'key': key, 'source': source[key],
                   'current': catalog[key], 'status': 'candidate_not_reviewed',
                   'fingerprint': fingerprint}
            rows.append(row)
            if path.exists():
                cached = json.loads(path.read_text())
                row['candidate'], row['rejected_reason'] = candidate_or_rejection(cached['xml'], source[key])
            else:
                # Identical source/context/target consumes characters only once.
                pending.setdefault(fingerprint, {'path': path, 'text': texts[key],
                                                'source': source[key], 'rows': []})['rows'].append(row)
        values = list(pending.values())
        for offset in range(0, len(values), 50):
            jobs.append((locale, values[offset:offset + 50]))
    estimate = sum(len(item['text']) for _, batch in jobs for item in batch)
    print(json.dumps({'candidate_rows': len(rows), 'uncached_requests': len(jobs),
                      'icu_keys_for_separate_review': skipped,
                      'maximum_source_characters_including_markup': estimate}), flush=True)
    if not args.translate:
        return
    if estimate > args.max_characters:
        raise ValueError('Estimated request exceeds the explicit character cap.')
    client = Client()
    usage = client.request('/v2/usage')
    remaining = usage['character_limit'] - usage['character_count']
    if 'api_key_character_limit' in usage:
        remaining = min(remaining, usage['api_key_character_limit'] - usage['api_key_character_count'])
    if estimate > remaining:
        raise ValueError('Insufficient remaining DeepL quota.')
    supported = {v['language'] for v in client.request('/v2/languages?type=target')}
    if any(TARGETS[locale] not in supported for locale, _ in jobs):
        raise ValueError('Requested language not supported by this DeepL account.')
    for locale, batch in jobs:
        result = client.request('/v2/translate', {
            'text': [item['text'] for item in batch], 'source_lang': 'EN',
            'target_lang': TARGETS[locale], 'context': CONTEXT,
            'tag_handling': 'xml', 'tag_handling_version': 'v2',
            'ignore_tags': ['x'], 'preserve_formatting': True,
        })
        translated = result.get('translations', [])
        if len(translated) != len(batch):
            raise ValueError('Unexpected translation count; stopping.')
        for item, translation in zip(batch, translated):
            candidate, rejection = candidate_or_rejection(translation['text'], item['source'])
            save_json(item['path'], {'xml': translation['text']})
            for row in item['rows']:
                row['candidate'] = candidate
                row['rejected_reason'] = rejection
        print(f'{locale}: {len(batch)} unique messages cached.', flush=True)
    for row in rows:
        row['flags'] = flags(row['source'], row['candidate'])
    save_json(OUTPUT / 'comparison.json', rows)
    for locale in dict.fromkeys(args.locales):
        lines = [f'# DeepL comparison — {NAMES[locale]}', '',
                 'Candidates only. No app catalog changes or linguistic approval.', '',
                 '| Key | English | Current | DeepL candidate | Flags |',
                 '| --- | --- | --- | --- | --- |']
        for row in rows:
            if row['locale'] == locale:
                lines.append('| ' + ' | '.join(cell(value) for value in (
                    row['key'], row['source'], row['current'], row['candidate'],
                    ', '.join(row['flags']))) + ' |')
        (OUTPUT / f'{locale}.md').write_text('\n'.join(lines) + '\n')
    after = client.request('/v2/usage')
    summary = {'candidate_rows': len(rows), 'different_from_current': sum(
        row['current'] != row['candidate'] for row in rows),
        'flagged': sum(bool(row['flags']) for row in rows),
        'usage_before': usage['character_count'], 'usage_after': after['character_count'],
        'character_limit': after['character_limit'],
        'note': 'Usage may be delayed. Candidates are not automatically approved.'}
    save_json(OUTPUT / 'summary.json', summary)
    print(json.dumps(summary), flush=True)


if __name__ == '__main__':
    try:
        main()
    except (ValueError, RuntimeError, OSError, ET.ParseError) as error:
        raise SystemExit(str(error)) from None
