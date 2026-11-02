# Translation review workflow

Run `python3 mobile/tool/build_localization_review.py` from the repository root.
Open `output/localization-review/index.md`; each language has a table with the
English source, current translation, screen/context hints, actual code usages,
priority, review status and automated warning flags. The JSON export contains
previous text for entries that have a recorded review.

The full 2 November 2026 pass covers all 14 translation languages and the
English source catalog. See [the audit results](full-audit-2026-11-02.md).
The 127 entries reviewed in earlier partial passes retain their history.

`ai_reviewed` records individual contextual AI review; `automated_reviewed`
records full-catalog engine comparison and technical validation, not individual
proofreading. Both statuses become `stale` when source or target wording changes.

## Review sequence

1. Read the English source and the actual screen usage. Clarify ambiguous source
   text before translating. Translate coherent feature batches, not isolated
   words without context.
2. Review the target wording against the source for meaning, payment direction,
   negation, consent scope, precision, background operation, duration and ability
   to stop. Review spelling, grammar, consistent voice and short-button wording.
3. Optionally compare a second translation engine. DeepL supports extra context
   and glossaries; LanguageTool provides grammar/spelling checks for its supported
   languages. Neither service was called for the initial recorded pass. Both
   need a configured integration; do not assume uniform language coverage or
   quality. Do not upload account records, private trip data or credentials.
4. Back-translation can expose a changed meaning, but agreement is not proof:
   engines can repeat the same mistake. Keep uncertain rows pending.
5. Edit the ARB source. Record the exact English source and resulting translation
   in `reviews.json`, the reviewer type, reason and checks. `ai_reviewed` never
   means human-approved or a guarantee of linguistic correctness. Rerunning the
   exporter invalidates the status if either text has changed.
6. Run `flutter gen-l10n`, catalog tests and relevant screen tests. Regenerate
   push catalogs only if their source messages changed. Do not deploy or release
   as a side effect of reviewing translations.

## Splyto terminology and meaning

| Term | Meaning in this app | Avoid |
| --- | --- | --- |
| Trip | A shared or solo travel expense workspace | A single taxi ride unless the context explicitly says so |
| Share (noun) | A person's portion of an expense | The action of sharing information |
| Share (verb) | Make information accessible to the stated recipients | Ownership or a financial share |
| You owe | Money the current user must pay someone else | Reversing payer and recipient |
| You get back | Money the current user is to receive | Returning to an earlier screen |
| Settlement | Recording and confirming payments between members | Claiming Splyto transfers money itself |
| Receipt | A document/photo supporting an expense | Confirmation that another member received a payment |
| Payment details | Bank/payment identifiers shared under the stated permission | Consent to perform a payment |
| Accepted members | Participants whose trip membership has been accepted | Every invited or unrelated account |
| Live location | Precise position, shared for the selected time, including background updates | Implying foreground-only operation or unlimited duration |

Automated flags are inspection prompts, not confirmed defects. For example,
writing “one” instead of “1” can legitimately trigger CHECK_NUMBERS. A file with
zero flags may still contain semantic mistakes. Public-release confidence needs
linguistic review beyond technical validation, especially legal texts. The
privacy-policy fallback documented in `docs/mobile/localization.md` stays in place.

References for optional services:
- DeepL official SDK: https://github.com/DeepL/deepl-python
- LanguageTool API: https://languagetool.org/lp/api

## DeepL comparison (2 November 2026)

DeepL is now configured for local translation tooling. The API key is read from
the ignored `.env.deepl.local` file at the repository root. It is never bundled
with the app or included in comparison files. Only public English UI strings
and explanatory product context are sent, not user records or private trip data.

Estimate the first batch without calling the API:

```sh
python3 mobile/tool/deepl_localization_review.py
```

Generate candidates explicitly:

```sh
python3 mobile/tool/deepl_localization_review.py --translate
```

The tool accepts `--locales`, `--keys` and a conservative `--max-characters`
per-run cap (30,000 by default). It checks remaining quota, preserves placeholders
using ignored XML tags and refuses complex ICU messages. Plural forms must be
reviewed separately. Successful translations are cached by source, target and
context so rerunning a completed batch does not translate the same text again.
Requests are not automatically retried after failure; a network timeout may
still have consumed provider quota. The estimate includes XML markup, while
provider usage can be lower and can take time to update.

The initial nine-key batch covered 126 rows. The later full audit covered
18,256 simple messages, plus 112 existing ICU messages reviewed separately.
`analyticsExpenseCount` was then converted to ICU in all catalogs, including
English, so the final catalogs contain nine plural messages each.

For a complete cached forward estimate (no service request):

```sh
python3 mobile/tool/deepl_localization_review.py --all
```

`backtranslate_localization_review.py` reads the immutable pre-review catalogs in
`output/localization-review/full-audit/before/`. Its default is also a dry run;
`--translate` explicitly enables service calls after checking available quota.
It back-translates the original target wording, not necessarily the final edits.
An additional 606 changed messages received a second back-translation. Invalid
provider XML or missing arguments are quarantined rather than applied.

The full audit's generated tables and raw comparisons live in
`output/localization-review/`; durable decisions are in `reviews.json` and the
contextual terminology corrections in `full-audit-overrides.json`. The main
tables show final app text; raw comparisons preserve the original audit inputs.
Only UI strings and product context were sent to DeepL, including target-language
UI text for back-translation. No user/account data was sent. Last reported usage:
964,039 of 1,000,000 characters. LanguageTool was not called.

## Verification of the initial review pass

- `flutter gen-l10n`: completed.
- Catalog and profile widget tests: 44 passed, including all 15 languages in
  narrow light/dark settings layouts with 200% text scaling.
- Review status invalidation and argument/number warning checks: passed.
- Whole-mobile static analysis reported existing warnings/information in other
  files not edited in this review pass (unused elements, async BuildContext
  usage and style lints). No localization errors were reported.
- No service translation API, server deployment or release/archive was run.
