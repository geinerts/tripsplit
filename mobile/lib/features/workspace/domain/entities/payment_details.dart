/// Ephemeral, request-scoped details. Never part of a cached workspace/profile.
class PaymentDetails {
  const PaymentDetails({
    this.bankAccountHolder,
    this.bankIban,
    this.bankBic,
    this.revolutHandle,
    this.revolutMeLink,
    this.paypalMeLink,
    this.wisePayLink,
  });

  final String? bankAccountHolder;
  final String? bankIban;
  final String? bankBic;
  final String? revolutHandle;
  final String? revolutMeLink;
  final String? paypalMeLink;
  final String? wisePayLink;
}
