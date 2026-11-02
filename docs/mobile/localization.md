# Splyto app languages

The app offers English (`en`), German (`de`), Spanish (`es`), French (`fr`),
Italian (`it`), Portuguese (`pt`, intended for Portugal), Polish (`pl`),
Dutch (`nl`), Swedish (`sv`), Danish (`da`), Norwegian Bokmål (`nb`),
Finnish (`fi`), Czech (`cs`), Ukrainian (`uk`) and Latvian (`lv`).

New installations follow the primary device language. Regional variants match
the language; legacy Norwegian `no` maps to `nb`. An unsupported primary
language falls back to English. An explicit selection is saved locally and
wins over device changes until System is selected again. Appearance is an
independent preference, with the same System / manual-override behavior.

## Editing translations

`mobile/lib/l10n/app_en.arb` is the message/placeholder schema. Edit the ARB
catalogs, then run `flutter gen-l10n` from `mobile`. Do not edit the generated
`app_localizations_*.dart` implementations. Every catalog must contain every
message and preserve the interpolation arguments. Use ICU plurals for counts,
including few/many forms where the language needs them. Preserve product names,
payment identifiers and URLs.

Push catalogs are generated from those same messages. Run
`python3 mobile/tool/export_push_locales.py` from the repository root after
changing notification strings. Deploy `api/lib/helpers/push/push_localization.php`
and the complete `api/lib/helpers/push/locales/` directory together. The new
server catalogs are not deployed by generating them. The app re-registers its
push locale when language changes even if the push token stays the same.

## Translation review status

The complete UI-catalog comparison was completed on 2 November 2026: 1,312
English source messages and 18,368 translated entries across 14 target languages.
DeepL forward comparison and back-translation covered every simple message;
ICU plurals were reviewed separately. Contextual AI revisions addressed financial
terminology, payer/recipient direction, permission scope, short labels, count
forms and date-format literals. The pass changed 10,539 translated entries.

The ledger distinguishes 1,279 individually AI-reviewed entries from 17,089
entries covered by automated engine comparison and structural checks. No entries
remain untracked or stale in this pass. This is not native-speaker certification;
engine agreement and passing tests do not guarantee linguistic accuracy.
Portuguese uses DeepL's Portugal variant plus contextual terminology corrections.
No translation service or models are bundled with the app or used at runtime.

The privacy policy retains the existing English, Latvian and Spanish texts.
Other app languages explicitly explain that the policy is displayed in English;
unreviewed machine-translated legal paragraphs are not shipped. Map place names
are supplied by the map provider/offline map dataset independently of the app's
message catalogs. Native OS permission descriptions have separate iOS/Android
resource localization and are not generated from ARB files.

## Traceable AI review

See [the review workflow](localization-review/README.md),
[the full audit](localization-review/full-audit-2026-11-02.md), and the generated
`output/localization-review/index.md`. The ledger records exact source/final
wording, review method and history. The report marks checks stale if either text
changes. API credentials remain in ignored local configuration. Comparison tools
cache candidates and do not edit catalogs automatically.
