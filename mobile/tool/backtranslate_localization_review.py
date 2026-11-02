#!/usr/bin/env python3
"""Back-translate the pre-audit catalogs for semantic comparison, without edits."""
import argparse
import hashlib
import json
from difflib import SequenceMatcher

from deepl_localization_review import (
    Client, ROOT, TARGETS, xml_source, candidate_or_rejection, save_json,
)

OUTPUT = ROOT / 'output/localization-review/full-audit'
CONTEXT = (
    'These are UI messages from Splyto, a travel expense sharing app. '
    'Translate the text faithfully into English for a translation quality audit. '
    'Preserve the meaning actually expressed, including who pays or receives '
    'money, conditions, negation, permissions, sharing duration and quantities. '
    'Do not repair a meaning error by guessing the intended English original. '
    'A trip is a travel workspace; balances and settlements describe debts and '
    'payments between members, and the app does not itself transfer money.'
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--translate', action='store_true')
    args = parser.parse_args()
    source = json.loads((OUTPUT / 'before/app_en.arb').read_text())
    keys = [k for k in source if not k.startswith('@') and ', plural,' not in source[k]]
    cache = OUTPUT / 'back-cache'
    cache.mkdir(exist_ok=True)
    rows, jobs = [], []
    for locale in TARGETS:
        catalog = json.loads((OUTPUT / f'before/app_{locale}.arb').read_text())
        pending = {}
        for key in keys:
            original = catalog[key]
            xml = xml_source(original)
            fingerprint = hashlib.sha256(json.dumps([locale, xml, CONTEXT]).encode()).hexdigest()
            path = cache / (fingerprint + '.json')
            row = {'locale': locale, 'key': key, 'source': source[key], 'translation': original}
            rows.append(row)
            if path.exists():
                row['backtranslation'], row['rejected_reason'] = candidate_or_rejection(json.loads(path.read_text())['xml'], original)
            else:
                pending.setdefault(fingerprint, {'path': path, 'xml': xml,
                    'original': original, 'rows': []})['rows'].append(row)
        batch = list(pending.values())
        jobs.extend((locale, batch[i:i+50]) for i in range(0, len(batch), 50))
    # XML markup is excluded from billing; count visible source text conservatively.
    estimate = sum(len(v['original']) for _, batch in jobs for v in batch)
    print(json.dumps({'rows': len(rows), 'requests': len(jobs), 'source_characters': estimate}), flush=True)
    if not args.translate:
        return
    client = Client()
    usage = client.request('/v2/usage')
    if estimate > usage['character_limit'] - usage['character_count']:
        raise ValueError('Insufficient DeepL quota for the back-translation audit.')
    for locale, batch in jobs:
        result = client.request('/v2/translate', {
            'text': [v['xml'] for v in batch], 'source_lang': locale.upper(),
            'target_lang': 'EN-GB', 'context': CONTEXT,
            'tag_handling': 'xml', 'tag_handling_version': 'v2', 'ignore_tags': ['x'],
            'preserve_formatting': True,
        })
        translations = result.get('translations', [])
        if len(translations) != len(batch):
            raise ValueError('Unexpected response count.')
        for item, translated in zip(batch, translations):
            value, rejection = candidate_or_rejection(translated['text'], item['original'])
            save_json(item['path'], {'xml': translated['text']})
            for row in item['rows']:
                row['backtranslation'] = value
                row['rejected_reason'] = rejection
        print(f'{locale}: {len(batch)} back-translations cached.', flush=True)
    for row in rows:
        row['similarity'] = round(SequenceMatcher(
            None, row['source'].lower(), row['backtranslation'].lower()).ratio(), 3)
    save_json(OUTPUT / 'backtranslation.json', rows)
    print(json.dumps({'completed': len(rows), 'usage': client.request('/v2/usage')['character_count']}), flush=True)


if __name__ == '__main__':
    try:
        main()
    except (ValueError, RuntimeError, OSError) as error:
        raise SystemExit(str(error)) from None
