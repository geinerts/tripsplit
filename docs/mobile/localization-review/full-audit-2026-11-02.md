# Full UI localization audit — 2 November 2026

## Result

1,312 English source messages; 18,368 translations across all 14 target languages.
10,539 target entries corrected or revised, plus an English ICU plural fix for the analytics expense count.
1,279 entries individually reviewed by AI; 17,089 covered by automated engine comparison and technical validation.
No untracked/stale entries or unresolved structural flags remain in this audit. These statuses are not native-speaker certification.

| Language | Entries | Changed | Contextual AI review | Automated comparison |
| --- | ---: | ---: | ---: | ---: |
| Deutsch | 1312 | 884 | 95 | 1217 |
| Español | 1312 | 59 | 91 | 1221 |
| Français | 1312 | 825 | 89 | 1223 |
| Italiano | 1312 | 864 | 90 | 1222 |
| Português (Portugal) | 1312 | 811 | 94 | 1218 |
| Polski | 1312 | 932 | 90 | 1222 |
| Nederlands | 1312 | 859 | 89 | 1223 |
| Svenska | 1312 | 883 | 89 | 1223 |
| Dansk | 1312 | 818 | 90 | 1222 |
| Norsk bokmål | 1312 | 804 | 88 | 1224 |
| Suomi | 1312 | 815 | 94 | 1218 |
| Čeština | 1312 | 899 | 92 | 1220 |
| Українська | 1312 | 1030 | 93 | 1219 |
| Latviešu | 1312 | 56 | 95 | 1217 |

## Method and corrections

- Reviewed the English source catalog and compared all 18,256 simple target entries with DeepL candidates; used PT-PT for Portuguese.
- Back-translated the original target entries into English to expose omissions and semantic changes. Five invalid responses were quarantined and their final messages checked individually.
- Back-translated a further 606 revised messages, focusing on longer permissions, payment text and discrepancies. Later contextual revisions are recorded separately; the ledger only claims a final-wording back-check when the wording matches that response.
- Reviewed 112 original ICU target messages separately. Added correct ICU forms for analytics expense counts in all 15 catalogs. Fixed Latvian zero forms and counts such as 21/101 incorrectly displayed as 1.
- Corrected debt/payment direction, amounts mistaken for people, settlement terminology, expense shares, receipt documents, common trips, payment cancellation records, date-format literals, relative times and counts.
- Retained existing reviewed navigation/category terminology and appropriate Latvian/Spanish wording instead of replacing them indiscriminately.
- Preserved source arguments, their multiplicity for plain messages, literal values, product names and technical identifiers. Finnish “one” instead of “1” is an explicitly resolved numeric flag.
- Regenerated all Flutter localization classes and 15 backend push catalogs from the ARBs. No runtime translation service was added.

## Validation

- `flutter gen-l10n`: passed.
- Dart MCP: 51 tests passed across localization catalogs, appearance preferences, profile settings and push locale registration.
- Tests exercise every locale at counts 0, 1, 2, 5, 11, 21 and 101, and settings at 320 px / 200% text scaling in light and dark themes.
- PHP push localization: 2 tests, 1,069 assertions passed.
- Whole-mobile Dart MCP analysis: no errors; the same 21 existing warnings/info findings in unrelated files.
- XML roundtrip and invalid-output quarantine, argument multiplicity, report invalidation, numeric checks and `git diff --check`: passed.

## Scope and evidence

Coverage is the app UI message catalogs and generated push text. Existing privacy policies remain EN/LV/ES with the explicit English fallback in other languages. Map-provider place names, user-entered content and native OS permission resources are separate from ARB catalogs.

`reviews.json` stores exact final wording and previous review history. `full-audit-overrides.json` preserves contextual terminology corrections. Regenerate language-by-language tables with `python3 mobile/tool/build_localization_review.py`; the current report is `output/localization-review/index.md`.

Raw forward/back-translation evidence, immutable original catalogs, final checksums and counts are under `output/localization-review/full-audit/` and `output/localization-review/deepl/`. Temporary proposed catalogs/decisions are pre-final drafts; the main report and ledger are authoritative for shipped wording.

DeepL last reported 964,039 / 1,000,000 characters, including earlier diagnostic calls. The key stays in ignored local configuration; only UI copy and product context were submitted. LanguageTool was not used.

No server deployment, GitHub push, version bump, archive or TestFlight upload was performed in this pass.
