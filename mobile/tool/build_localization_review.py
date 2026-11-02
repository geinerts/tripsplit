#!/usr/bin/env python3
"""Build per-language review tables. No service calls and no catalog mutations."""
import html
import json
import re
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOGS = ROOT / 'mobile/lib/l10n'
LEDGER = ROOT / 'docs/mobile/localization-review/reviews.json'
OUTPUT = ROOT / 'output/localization-review'
NAMES = {'en': 'English', 'de': 'Deutsch', 'es': 'Español', 'fr': 'Français',
         'it': 'Italiano', 'pt': 'Português (Portugal)', 'pl': 'Polski',
         'nl': 'Nederlands', 'sv': 'Svenska', 'da': 'Dansk', 'nb': 'Norsk bokmål',
         'fi': 'Suomi', 'cs': 'Čeština', 'uk': 'Українська', 'lv': 'Latviešu'}


def review_status(source, translation, record):
    if not record:
        return 'needs_review'
    if record.get('source') != source or record.get('translation') != translation:
        return 'stale'
    return record.get('status', 'needs_review')


def flags(source, translation):
    found = []
    has_plural = 'plural,' in source or 'plural,' in translation
    if not translation.strip():
        found.append('EMPTY')
    # ICU plurals legitimately repeat arguments, so compare sets here.
    arguments = lambda text: set(re.findall(r'\{(\w+)(?:\}|,)', text))
    if arguments(source) != arguments(translation):
        found.append('ARGUMENTS')
    if source == translation and len(source) > 40:
        found.append('SAME_AS_ENGLISH')
    if not has_plural and len(translation) > max(100, len(source) * 3):
        found.append('UNUSUAL_LENGTH')
    words = translation.lower().split()
    if not has_plural and any(n > 6 for n in Counter(words).values()):
        found.append('REPETITION')
    if re.search(r'&\s*#\d', translation):
        found.append('HTML_ENTITY')
    if re.search(r'https?://|www\.', translation) and not re.search(r'https?://|www\.', source):
        found.append('UNEXPECTED_URL')
    if not has_plural:
        def numbers(text):
            literal = re.sub(r'\{[^}]+\}', '', text)
            # Grouped thousands use ordinary or non-breaking spaces in several locales.
            literal = re.sub(r'(?<=\d)[ \u00a0\u202f](?=\d{3}(?:\D|$))', '', literal)
            return {re.sub(r'[.,]', '', n) for n in re.findall(r'\d+(?:[.,]\d+)*', literal)}
        if numbers(source) != numbers(translation):
            found.append('CHECK_NUMBERS')
    for brand in ('Splyto', 'Mapbox', 'Google', 'Apple', 'Revolut', 'PayPal', 'IBAN', 'SWIFT'):
        if brand.lower() in source.lower() and brand.lower() not in translation.lower():
            found.append('CHECK_BRAND:' + brand)
    return found


def priority(key):
    value = key.lower()
    if any(word in value for word in ('consent', 'sharing', 'permission', 'payment', 'password', 'delete', 'settle', 'balance', 'owe')):
        return 'high'
    if any(word in value for word in ('error', 'failed', 'invalid', 'budget', 'split', 'auth', 'live')):
        return 'medium'
    return 'normal'


def context_for(key):
    lower = key.lower()
    groups = [('notification', 'Notification'), ('live', 'Trip live location'),
              ('travel', 'Personal travel map / destinations'), ('payment', 'Payment flow'),
              ('settle', 'Settlement'), ('balance', 'Balance'), ('profile', 'Profile / settings'),
              ('auth', 'Sign in / onboarding'), ('expense', 'Expense form / details'),
              ('analytics', 'Analytics'), ('friend', 'Friends'), ('home', 'Home'),
              ('trip', 'Trip'), ('activityevent', 'Trip activity history'), ('workspace', 'Trip workspace')]
    return next((label for prefix, label in groups if lower.startswith(prefix)), 'Shared UI / inspect usage')


def cell(value):
    return html.escape(str(value), quote=False).replace('|', '&#124;').replace('\n', '<br>')


def build():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    source = json.loads((CATALOGS / 'app_en.arb').read_text())
    keys = [key for key in source if not key.startswith('@')]
    ledger = json.loads(LEDGER.read_text()) if LEDGER.exists() else {}
    usages = defaultdict(list)
    pattern = re.compile(r'\b(' + '|'.join(map(re.escape, keys)) + r')\b')
    for path in sorted((ROOT / 'mobile/lib').rglob('*.dart')):
        if 'l10n' in path.parts:
            continue
        for number, line in enumerate(path.read_text().splitlines(), 1):
            for key in set(pattern.findall(line)):
                if len(usages[key]) < 3:
                    usages[key].append(f'{path.relative_to(ROOT)}:{number}')
    summary, all_rows = [], []
    for code, name in NAMES.items():
        if code == 'en':
            continue
        catalog = json.loads((CATALOGS / f'app_{code}.arb').read_text())
        rows = []
        for key in keys:
            translation = catalog.get(key, '')
            record = ledger.get(f'{code}:{key}')
            rows.append({'locale': code, 'key': key, 'source': source[key],
                         'translation': translation, 'context': context_for(key),
                         'usage': usages[key], 'priority': priority(key),
                         'status': review_status(source[key], translation, record),
                         'flags': flags(source[key], translation),
                         'resolved_flags': record.get('resolved_flags', {}) if record else {},
                         'note': record.get('note', '') if record else '',
                         'previous_translation': record.get('before', '') if record else ''})
        rows.sort(key=lambda row: ({'high': 0, 'medium': 1, 'normal': 2}[row['priority']], row['key']))
        counts = Counter(row['status'] for row in rows)
        issues = sum(bool(set(row['flags']) - row['resolved_flags'].keys()) for row in rows)
        summary.append({'locale': code, 'name': name, 'messages': len(rows),
                        'ai_reviewed': counts['ai_reviewed'],
                        'automated_reviewed': counts['automated_reviewed'],
                        'pending': counts['needs_review'],
                        'stale': counts['stale'], 'flagged': issues})
        lines = [f'# {name} — translation review', '',
                 'AI review is not native-speaker certification. Technical checks do not verify meaning.',
                 'Context labels are inferred; Usage points to actual code references where found.',
                 'Flags are prompts to inspect, not confirmed translation errors.', '',
                 f"Messages: {len(rows)}. Contextually AI reviewed: {counts['ai_reviewed']}. Automated comparison: {counts['automated_reviewed']}. Pending: {counts['needs_review']}. Stale: {counts['stale']}.", '',
                 '| Key / priority | English source | Current translation | Context / usage | Review status | Flags / notes |',
                 '| --- | --- | --- | --- | --- | --- |']
        for row in rows:
            lines.append('| ' + ' | '.join(cell(value) for value in [
                row['key'] + '\n' + row['priority'], row['source'], row['translation'],
                row['context'] + '\n' + '\n'.join(row['usage']), row['status'],
                ', '.join(row['flags']) + '\n' + row['note'] + '\n' +
                '; '.join(f'{flag}: {reason}' for flag, reason in row['resolved_flags'].items())]) + ' |')
        (OUTPUT / f'{code}.md').write_text('\n'.join(lines) + '\n')
        all_rows.extend(rows)
    (OUTPUT / 'review-data.json').write_text(json.dumps(all_rows, ensure_ascii=False, indent=2) + '\n')
    (OUTPUT / 'summary.json').write_text(json.dumps(summary, ensure_ascii=False, indent=2) + '\n')
    lines = ['# Splyto tulkojumu pārskatīšana', '',
             'Atsevišķa tabula katrai no 14 tulkojuma valodām; angļu teksts ir salīdzināšanas pamats.',
             'Statuss `ai_reviewed` nozīmē konkrēta teksta pārbaudi ar AI, nevis cilvēka redaktora apstiprinājumu.',
             '`automated_reviewed` nozīmē pilna kataloga DeepL salīdzinājumu, sākotnējā teksta atpakaļtulkojumu un tehniskās pārbaudes; tas nav individuālas redaktūras apliecinājums.',
             '`needs_review` vēl nav pārskatīts šajā uzskaitē; `stale` nozīmē, ka teksts kopš pārbaudes mainījies.', '',
             '| Valoda | Teksti | AI pārskatīti | Automātiski salīdzināti | Vēl jāpārskata | Novecojusi pārbaude | Neatrisināti karodziņi |',
             '| --- | ---: | ---: | ---: | ---: | ---: | ---: |']
    for row in summary:
        lines.append(f"| [{row['name']}]({row['locale']}.md) | {row['messages']} | {row['ai_reviewed']} | {row['automated_reviewed']} | {row['pending']} | {row['stale']} | {row['flagged']} |")
    lines += ['', 'Atkārtota ģenerēšana: `python3 mobile/tool/build_localization_review.py`.',
              'Labojumi jāveic ARB failos; šīs tabulas ir ģenerēts pārskats. Pārbaudes pieraksti atrodas `docs/mobile/localization-review/reviews.json`.']
    (OUTPUT / 'index.md').write_text('\n'.join(lines) + '\n')
    print(json.dumps({'tables': len(summary), 'messages': len(all_rows),
                      'ai_reviewed': sum(r['ai_reviewed'] for r in summary),
                      'automated_reviewed': sum(r['automated_reviewed'] for r in summary),
                      'flagged': sum(r['flagged'] for r in summary)}, indent=2))


if __name__ == '__main__':
    build()
