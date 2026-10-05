import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/user_profile_payment_section.dart';
import '../../domain/entities/payment_details.dart';

class PaymentRequestDetailsSheet extends StatefulWidget {
  const PaymentRequestDetailsSheet({super.key, required this.load});

  final Future<PaymentDetails> Function() load;

  @override
  State<PaymentRequestDetailsSheet> createState() =>
      _PaymentRequestDetailsSheetState();
}

class _PaymentRequestDetailsSheetState
    extends State<PaymentRequestDetailsSheet> {
  late Future<PaymentDetails> _details;

  @override
  void initState() {
    super.initState();
    _details = widget.load();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<PaymentDetails>(
        future: _details,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final details = snapshot.data;
          if (snapshot.hasError || details == null) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.paymentDetailsUnavailable),
                IconButton(
                  tooltip: context.l10n.paymentDetailsRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => setState(() {
                    _details = widget.load();
                  }),
                ),
              ],
            );
          }
          return UserProfilePaymentDetailsSection(
            sectionTitle: context.l10n.workspacePaymentDetails,
            emptyText:
                context.l10n.workspaceThisMemberHasNotAddedPayoutDetailsYet,
            bankTransferTitle: context.l10n.workspaceBankTransfer,
            bankHolderLabel: context.l10n.workspaceHolder,
            bankHolderName: details.bankAccountHolder ?? '',
            bankIban: details.bankIban,
            bankBic: details.bankBic,
            revolutTitle: 'Revolut',
            revolutHandle: details.revolutHandle,
            revolutMeLink: details.revolutMeLink,
            paypalTitle: 'PayPal.me',
            paypalMeLink: details.paypalMeLink,
            wiseTitle: 'Wise',
            wisePayLink: details.wisePayLink,
            openLinkFailedText: context.l10n.workspaceCouldNotOpenPaymentLink,
            onErrorMessage: (message) => ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message))),
          );
        },
      ),
    ),
  );
}
