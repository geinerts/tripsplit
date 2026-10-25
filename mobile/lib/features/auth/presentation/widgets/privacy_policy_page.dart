import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/responsive.dart';

/// Bundled content keeps the policy readable offline and in the app's language.
class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String? _language;
  late Future<Map<String, dynamic>> _policy;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final code = Localizations.localeOf(context).languageCode;
    final language = const ['en', 'lv', 'es'].contains(code) ? code : 'en';
    if (_language != language) {
      _language = language;
      _policy = _load();
    }
  }

  Future<Map<String, dynamic>> _load() async {
    final text = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/legal/privacy_$_language.json');
    return jsonDecode(text) as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AppFormScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 20, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BackButton(),
                const SizedBox(width: 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Semantics(
                      header: true,
                      child: Text(
                        t.profilePrivacyPolicy,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _policy,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(t.privacyLoadFailed),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => setState(() => _policy = _load()),
                            child: Text(t.retryAction),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final policy = snapshot.data!;
                final sections = (policy['sections'] as List)
                    .cast<Map<String, dynamic>>();
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.responsive.pageMaxWidth,
                    ),
                    child: SelectionArea(
                      child: ListView(
                        key: const ValueKey('privacy-policy-content'),
                        padding: EdgeInsets.fromLTRB(
                          context.responsive.pageHorizontalPadding,
                          8,
                          context.responsive.pageHorizontalPadding,
                          32,
                        ),
                        children: [
                          Text(
                            policy['updated'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (policy['status'] == 'draft') ...[
                            const SizedBox(height: 16),
                            Text(
                              policy['reviewNotice'] as String,
                              key: const ValueKey('privacy-draft-notice'),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Text(policy['intro'] as String),
                          for (final section in sections) ...[
                            const SizedBox(height: 24),
                            Semantics(
                              header: true,
                              child: Text(
                                section['title'] as String,
                                key: ValueKey('privacy-${section['id']}'),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            for (final paragraph
                                in section['paragraphs'] as List) ...[
                              const SizedBox(height: 10),
                              Text(paragraph as String),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
