// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get homeFirstTrip => 'Ensimmäinen matkasi';

  @override
  String get homeYourShareAllTrips => 'Oma osuutesi kaikista matkoista';

  @override
  String get homeAllTime => 'Koko ajalta';

  @override
  String get homeSolo => 'Yksin';

  @override
  String homePeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count henkilöä',
      one: '$count henkilö',
    );
    return '$_temp0';
  }

  @override
  String homeTripActions(String name) {
    return 'Matkan toiminnot: $name';
  }

  @override
  String get homeNoActiveTrips => 'Ei aktiivisia matkoja';

  @override
  String get homeNoArchivedTrips => 'Ei arkistoituja matkoja';

  @override
  String get homeLoadingTrips => 'Matkojen lataaminen';

  @override
  String get homeLoadErrorTitle => 'Matkojasi ei voitu ladata';

  @override
  String get homeLoadErrorBody => 'Yritä uudelleen hetken kuluttua.';

  @override
  String get homeOfflineTitle => 'Olet offline-tilassa';

  @override
  String get homeOfflineNoData => 'Matkojasi ei ole vielä saatavilla tällä laitteella.';

  @override
  String get homeOfflineCached => 'Offline-tilassa. Tallennettujen matkojen näyttäminen.';

  @override
  String get homeRefreshError => 'Päivitystä ei voitu suorittaa. Näytetään aiemmin ladatut matkat.';

  @override
  String paymentShareDetailsConsent(Object arg1) {
    return 'Jaa tallennetut maksutietoni henkilölle $arg1';
  }

  @override
  String get paymentShareDetailsScope => 'Vain niin kauan kuin tämä pyyntö odottaa maksua. Pyynnön peruuttaminen lopettaa käyttöoikeuden.';

  @override
  String get paymentDetailsUnavailable => 'Maksutietoja ei ole saatavilla. Yhdistä internetiin ja tarkista, onko pyyntö edelleen avoinna.';

  @override
  String get paymentDetailsRetry => 'Yritä uudelleen';

  @override
  String get tripModeSolo => 'Vain minä';

  @override
  String get tripModeGroup => 'Muiden kanssa';

  @override
  String get premiumFree => 'Ilmainen';

  @override
  String get premiumStatusUnavailable => 'Suunnitelman tila ei saatavilla';

  @override
  String premiumGrantedUntil(String date) {
    return 'Premium-oikeudet myönnetty päivään $date asti';
  }

  @override
  String get premiumBillingNotActive => 'Ei aktiivista tilausta';

  @override
  String get premiumRefreshStatus => 'Päivitä suunnitelman tila';

  @override
  String get accountSectionTitle => 'Tili';

  @override
  String get activeStatus => 'Aktiivinen';

  @override
  String get activeTripPlural => 'aktiiviset matkat';

  @override
  String get activeTripSingle => 'aktiivinen matka';

  @override
  String get activeTrips => 'Aktiiviset matkat';

  @override
  String get activitiesComingSoon => 'Toiminto-osio tulossa pian.';

  @override
  String get addAction => 'Lisää';

  @override
  String get addExpenseTitle => 'Lisää kulu';

  @override
  String get addExpensesAction => 'Lisää kuluja';

  @override
  String get addMembersAction => 'Lisää jäseniä';

  @override
  String get addTripMembersTitle => 'Kutsu matkan jäseniä';

  @override
  String addedMembersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lähetettyä kutsua',
      one: '$count lähetetty kutsu',
    );
    return '$_temp0.';
  }

  @override
  String get tripInvitationDeclined => 'Matkakutsu hylätty.';

  @override
  String get tripInviteAction => 'Kutsu';

  @override
  String get tripInvitationsPending => 'Odotan vastausta';

  @override
  String get tripInvitationsRetry => 'Kutsuja ei ole saatavilla. Yritä uudelleen';

  @override
  String get tripInvitationRevoke => 'Peruuta kutsu';

  @override
  String get tripInvitationRevokeFailed => 'Kutsua ei voitu peruuttaa. Yritä uudelleen.';

  @override
  String get tripInvitationBody => 'Sinut on kutsuttu matkalle. Avaa kutsu vastataksesi siihen.';

  @override
  String get allCaughtUp => 'Kaikki ajan tasalla';

  @override
  String get allFilter => 'Kaikki';

  @override
  String get allMembersLabel => 'Kaikki jäsenet';

  @override
  String get allPaymentsConfirmed => 'Kaikki maksut vahvistetaan.';

  @override
  String get allTrips => 'Kaikki matkat';

  @override
  String get amountHint => '12.50';

  @override
  String get amountLabel => 'Summa';

  @override
  String get amountMustBeGreaterThanZero => 'Summan on oltava suurempi kuin 0.';

  @override
  String get appearance => 'Ulkoasu';

  @override
  String get archivedStatus => 'Arkistoitu';

  @override
  String get authSubtitleLogin => 'Jaa matkakulut ystävien kanssa';

  @override
  String get authSubtitleRegister => 'Luo tili ja aloita matkojen jakaminen';

  @override
  String breakdownConfirmedCount(Object count) {
    return 'vahvistettu: $count';
  }

  @override
  String breakdownPendingCount(Object count) {
    return 'odottaa hyväksyntää: $count';
  }

  @override
  String breakdownSentCount(Object count) {
    return 'lähetetty: $count';
  }

  @override
  String breakdownSuggestedCount(Object count) {
    return 'ehdotus: $count';
  }

  @override
  String get cancelAction => 'Peruuta';

  @override
  String get changeEmailWithPasswordHelper => 'Syötä salasanasi vaihtaaksesi sähköpostiosoitetta.';

  @override
  String get chooseReceiptFile => 'Valitse kuittitiedosto';

  @override
  String get completeAccountSetupDescription => 'Määritä sähköpostiosoitteesi ja salasanasi tilisi luomiseksi.';

  @override
  String get completeAccountSetupTitle => 'Tilin perustaminen valmis';

  @override
  String get confirmReceivedAction => 'Vahvista vastaanotto';

  @override
  String get confirmedAllSettlementsArchived => 'Kaikki maksut vahvistettu. Matka arkistoitu.';

  @override
  String get confirmedAsReceived => 'Vahvistettu vastaanotetuksi.';

  @override
  String get confirmedLabel => 'Vahvistettu';

  @override
  String get couldNotOpenReceiptLink => 'Kuitin linkkiä ei voitu avata.';

  @override
  String get createAction => 'Luo';

  @override
  String get createFirstTripHint => 'Luo ensimmäinen matkasi päästäksesi alkuun.';

  @override
  String get createNewTripTitle => 'Luo uusi matka';

  @override
  String get createTripAction => 'Luo matka';

  @override
  String get createTripFirst => 'Luo ensin matka.';

  @override
  String createdByLine(Object creator, Object date) {
    return '$date -  Luonut $creator';
  }

  @override
  String get creatorMustFinishTripFirst => 'Matkan luojan on saatava matka päätökseen, jotta maksujen vahvistaminen voi alkaa.';

  @override
  String currentEmailLabel(Object email) {
    return 'Nykyinen sähköpostiosoite: $email';
  }

  @override
  String get currentReceiptAttached => 'Liitteenä on nykyinen kuitti.';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get dateLabel => 'Päivämäärä';

  @override
  String get dateMustMatchFormat => 'Päivämäärän on oltava muodossa YYYY-MM-DD.';

  @override
  String get dateUnknown => 'Päivämäärä tuntematon';

  @override
  String get deleteAction => 'Poista';

  @override
  String get deleteExpenseConfirmQuestion => 'Poistetaanko tämä kulu?';

  @override
  String get deleteExpenseTitle => 'Poista kulu';

  @override
  String get editExpenseConfirmTitle => 'Tallennetaanko kulujen muutokset?';

  @override
  String get editExpenseConfirmText => 'Tämä päivittää kaikkien matkan osallistujien saldot.';

  @override
  String directlyExplainedByExpenses(Object amount) {
    return 'Selitetään suoraan kuluilla: $amount';
  }

  @override
  String get doneStatus => 'Valmis';

  @override
  String get editAction => 'Muokkaa';

  @override
  String get editExpenseTitle => 'Muokkaa kuluja';

  @override
  String get emailAddressLabel => 'Sähköpostiosoite';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get emailLabel => 'Sähköposti';

  @override
  String get emailRequired => 'Sähköpostiosoite on pakollinen.';

  @override
  String get enterValidExactAmounts => 'Syötä kaikkien osallistujien osalta voimassa olevat ja tarkat summat.';

  @override
  String get enterValidPercentages => 'Syötä kelvolliset prosenttiosuudet kaikille osallistujille.';

  @override
  String get equalSplitLabel => 'Jaa tasan';

  @override
  String exactAmountWithValue(Object value) {
    return 'Tarkka: $value';
  }

  @override
  String get exactAmountsLabel => 'Tarkat summat';

  @override
  String exactSplitMustMatchTotal(Object amount) {
    return 'Tarkka jakosumman on oltava yhteensä $amount.';
  }

  @override
  String get expenseAdded => 'Kulu lisätty.';

  @override
  String get expenseBreakdownSubtitle => 'Miten kukin kulu vaikuttaa tähän jäseneen.';

  @override
  String get expenseBreakdownTitle => 'Kulujen erittely';

  @override
  String get expenseDeleted => 'Kulu poistettu.';

  @override
  String expenseIdDate(Object date, Object id) {
    return 'Kulu nro $id  -  $date';
  }

  @override
  String expenseImpactLine(Object date, Object owes, Object paid) {
    return '$date  -  Maksettu $paid  -  Velkaa $owes';
  }

  @override
  String get expenseReactionsTitle => 'Reaktiot';

  @override
  String get expenseCommentsTitle => 'Kommentit';

  @override
  String get expenseNoComments => 'Ei vielä kommentteja.';

  @override
  String get expenseAddCommentHint => 'Lisää kommentti...';

  @override
  String get expenseCommentSend => 'Lähetä';

  @override
  String get expenseDeleteCommentTitle => 'Poista kommentti?';

  @override
  String get expenseUpdated => 'Kulut päivitetty.';

  @override
  String expenseWithId(Object id) {
    return 'Kulu nro $id';
  }

  @override
  String expensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kulua',
      one: '$count kulu',
    );
    return '$_temp0';
  }

  @override
  String get expensesLabel => 'Kulut';

  @override
  String get failedToCreateTrip => 'Matkan luominen epäonnistui.';

  @override
  String get failedToLoadUsersDirectory => 'Käyttäjähakemiston lataaminen epäonnistui.';

  @override
  String get filterSettlementByMemberSubtitle => 'Suodata maksut jäsenittäin';

  @override
  String get finishSoloTripConfirmationText => 'Haluatko lopettaa tämän matkan ja siirtää sen arkistoosi? Kulusi pysyvät näkyvissä.';

  @override
  String get soloTripArchived => 'Matka on päättynyt ja arkistoitu.';

  @override
  String get finishTripSyncPending => 'Synkronoi odottavat muutokset ennen tämän matkan päättymistä.';

  @override
  String get finishTripAction => 'Lopeta matka';

  @override
  String get finishTripConfirmationText => 'Lopetetaanko tämä matka ja aloitetaanko maksujen selvitys?';

  @override
  String get finishTripStartSettlementsAction => 'Lopeta ja aloita tilitykset';

  @override
  String get finishTripTitle => 'Lopeta matka';

  @override
  String forParticipants(Object participants) {
    return 'Vastaanottajat: $participants';
  }

  @override
  String get forgotPassword => 'Unohditko salasanasi?';

  @override
  String get profileSetPassword => 'Aseta salasana';

  @override
  String get profileManagePassword => 'Aseta tai vaihda salasana';

  @override
  String get profilePasswordByEmail => 'Aseta salasana sähköpostitse';

  @override
  String get passwordEmailBackToProfile => 'Takaisin profiiliin';

  @override
  String get forgotPasswordSubtitle => 'Syötä sähköpostiosoitteesi, niin lähetämme sinulle linkin salasanan nollaamiseen.';

  @override
  String get forgotPasswordSuccessMessage => 'Jos tällä sähköpostiosoitteella on tili, olemme lähettäneet salasanan nollauslinkin.';

  @override
  String get passwordResetSentTitle => 'Tarkista saapuneet';

  @override
  String get passwordResetSentHint => 'Linkki on voimassa 1 tunnin. Jos et näe viestiä, tarkista roskapostikansio.';

  @override
  String get forgotPasswordTitle => 'Nollaa salasana';

  @override
  String get friendsProgressSubtitle => 'Jokainen jäsen ja hänen vahvistustilansa.';

  @override
  String get friendsProgressTitle => 'Ystävien edistyminen';

  @override
  String get friendsSectionComingSoon => 'Ystävät-osio tulossa pian.';

  @override
  String fromDirection(Object name) {
    return 'Lähettäjä: $name';
  }

  @override
  String fromToLine(Object from, Object to) {
    return '$from to $to';
  }

  @override
  String get generateTurnAction => 'Arvo seuraava henkilö';

  @override
  String get hasAccountQuestion => 'Onko sinulla jo tili?';

  @override
  String helloUser(Object name) {
    return 'Hei, $name!';
  }

  @override
  String get iSentAction => 'Lähetin';

  @override
  String get invalidEmailFormat => 'Sähköpostiosoitteen muoto on virheellinen.';

  @override
  String get languageAction => 'Kieli';

  @override
  String get languageEnglish => 'Englanti';

  @override
  String get languageLatvian => 'Latvia';

  @override
  String get languageSpanish => 'Espanja';

  @override
  String get languageSystem => 'Järjestelmä';

  @override
  String get languageSystemSubtitle => 'Käytä laitteen kieltä';

  @override
  String get leaveEmptyKeepPasswordHelper => 'Jätä kenttä tyhjäksi, jos haluat säilyttää nykyisen salasanan.';

  @override
  String get logInButton => 'Kirjaudu sisään';

  @override
  String get logOutButton => 'Kirjaudu ulos';

  @override
  String get logoutFromDeviceQuestion => 'Kirjaudutko ulos tästä laitteesta?';

  @override
  String get logoutRevocationUnconfirmed => 'Kirjautuminen tältä laitteelta on päättynyt. Palvelimen istunnon peruuttamista ei voitu vahvistaa.';

  @override
  String get markedAsSent => 'Merkitty lähetetyksi.';

  @override
  String get markSettlementSentConfirmTitle => 'Merkitäänkö siirto lähetetyksi?';

  @override
  String get markSettlementSentConfirmText => 'Käytä tätä vasta, kun olet tosiasiallisesti lähettänyt maksun. Vastaanottajaa pyydetään vahvistamaan se.';

  @override
  String get settlementCancelSentAction => 'Merkitse lähettämättömäksi';

  @override
  String get settlementCancelSentConfirmTitle => 'Peruuta lähetetty tila?';

  @override
  String get settlementCancelSentConfirmText => 'Tämä siirtää siirron takaisin odottavaan tilaan ja ilmoittaa asiasta vastaanottajalle.';

  @override
  String get settlementSentCancelled => 'Siirto palautettiin odottavaan tilaan.';

  @override
  String get settlementNotReceivedAction => 'En ole saanut tätä';

  @override
  String get settlementNotReceivedConfirmTitle => 'Ilmoitetaanko puuttuvasta maksusta?';

  @override
  String get settlementNotReceivedConfirmText => 'Tämä siirtää siirron takaisin odottavaan tilaan ja ilmoittaa asiasta maksajalle.';

  @override
  String get settlementMarkedNotReceived => 'Merkitty vastaanottamattomaksi.';

  @override
  String get confirmSettlementReceivedConfirmTitle => 'Onko vastaanotto vahvistettu?';

  @override
  String get confirmSettlementReceivedConfirmText => 'Vahvista vasta, kun rahat näkyvät tililläsi. Tämä toiminto saattaa saattaa maksun loppuun.';

  @override
  String get memberSummariesSubtitle => 'Kummankin osapuolen nykyinen saldotilanne.';

  @override
  String get memberSummariesTitle => 'Jäsenten yhteenvedot';

  @override
  String memberToPaySummary(Object confirmed, Object total, Object waiting) {
    return 'Maksettava summa $total  -  vahvistettu $confirmed  -  odottaa $waiting';
  }

  @override
  String get membersImpactSubtitle => 'Arvioitu maksun vaikutus jäsentä kohden.';

  @override
  String get membersImpactTitle => 'Jäsenten vaikutus';

  @override
  String get membersIncludedInExpense => 'Mukana olevat jäsenet';

  @override
  String get membersLabel => 'Jäsenet';

  @override
  String moreCount(Object count) {
    return '+ $count lisää';
  }

  @override
  String get myFilter => 'Oma';

  @override
  String get myImpactTitle => 'Vaikutukseni';

  @override
  String get firstNameHint => 'Etunimesi';

  @override
  String get firstNameLabel => 'Etunimi';

  @override
  String get firstNameLengthValidation => 'Etunimen on oltava 2–64 merkkiä pitkä.';

  @override
  String get fullNameHelper => 'Käytä etu- ja sukunimeä yhdessä kentässä.';

  @override
  String get fullNameHint => 'esim. Anna Ozolina';

  @override
  String get fullNameLabel => 'Koko nimi';

  @override
  String get fullNameValidation => 'Syötä etu- ja sukunimi (vähintään 2 merkkiä kumpikin).';

  @override
  String get lastNameHint => 'Sukunimesi';

  @override
  String get lastNameLabel => 'Sukunimi';

  @override
  String get lastNameLengthValidation => 'Sukunimen on oltava 2–64 merkkiä pitkä.';

  @override
  String get nameHint => 'Nimesi';

  @override
  String get nameLabel => 'Nimi';

  @override
  String get nameLengthValidation => 'Nimen on oltava vähintään 2 merkkiä pitkä.';

  @override
  String get navActivities => 'Tilastot';

  @override
  String get navAddTrip => 'Lisää matka';

  @override
  String get navBalances => 'Saldot';

  @override
  String get navExpenses => 'Kulut';

  @override
  String get navFriends => 'Ystävät';

  @override
  String get navHome => 'Koti';

  @override
  String get navProfile => 'Profiili';

  @override
  String get navRandom => 'Satunnainen';

  @override
  String get netLabel => 'Nettosaldo';

  @override
  String get newPasswordLabel => 'Uusi salasana';

  @override
  String get nicknameHint => 'Miten ystävät näkevät sinut';

  @override
  String get nicknameLabel => 'Lempinimi';

  @override
  String get nicknameLengthValidation => 'Lempinimen on oltava vähintään 2 merkkiä pitkä.';

  @override
  String get noAccountQuestion => 'Eikö sinulla ole vielä tiliä?';

  @override
  String get noBalancesYet => 'Saldoja ei ole vielä.';

  @override
  String get noChangesToSave => 'Ei muutoksia tallennettavaksi.';

  @override
  String get noDirectExpenseLink => 'Suoraa yksittäisen kulun linkkiä ei löytynyt. Tämä maksu lasketaan matkan kokonaissaldosta.';

  @override
  String get noExpenseImpactForMember => 'Tästä ei aiheudu kustannuksia kyseiselle jäsenelle.';

  @override
  String noExpensesByUserYet(Object name) {
    return '$name:lle ei ole vielä kuluja.';
  }

  @override
  String get noExpensesYet => 'Kuluja ei ole vielä.';

  @override
  String get noExtraUsersToAdd => 'Lisäkäyttäjiä ei tarvitse lisätä.';

  @override
  String get noInternetDeleteQueued => 'Ei internetiä. Poista jonosta.';

  @override
  String get noInternetExpenseQueued => 'Ei internetiä. Kulu jonossa.';

  @override
  String get noInternetUpdateQueued => 'Ei internet-yhteyttä. Päivitys jonossa.';

  @override
  String get noMatchingRows => 'Ei vastaavia rivejä.';

  @override
  String get noMembersFound => 'Jäseniä ei löytynyt.';

  @override
  String get noNewMembersAdded => 'Nämä henkilöt ovat jo jäseniä tai heillä on odottavia kutsuja.';

  @override
  String get noNotePlaceholder => 'Ei huomautuksia';

  @override
  String get notificationsToday => 'Tänään';

  @override
  String get notificationsEmptyBody => 'Täältä näkyvät päivitykset matkoista, kuluista ja ystävistä.';

  @override
  String get notificationsCached => 'Offline — tallennettujen ilmoitusten näyttäminen.';

  @override
  String get notificationsRefreshFailed => 'Päivitystä ei voitu suorittaa. Näytetään aiemmin ladatut ilmoitukset.';

  @override
  String get notificationsJustNow => 'Juuri nyt';

  @override
  String notificationsMinutesAgo(int count) {
    return '$count min sitten';
  }

  @override
  String notificationsHoursAgo(int count) {
    return '$count h sitten';
  }

  @override
  String get notificationsUnread => 'Lukematon';

  @override
  String get noNotificationsYet => 'Ilmoituksia ei ole vielä.';

  @override
  String get noParticipantData => 'Ei osallistujatietoja.';

  @override
  String get noParticipantsSelected => 'Osallistujia ei ole valittu.';

  @override
  String get noPaymentRowsInTrip => 'Tällä matkalla ei ole maksurivejä.';

  @override
  String get noPaymentsNeeded => 'Maksuja ei tarvita.';

  @override
  String get noPicksYet => 'Ei valintoja vielä.';

  @override
  String get noSettlementActivityForMember => 'Tälle jäsenelle ei ole maksutapahtumia.';

  @override
  String get noSettlementRowsYet => 'Maksurivejä ei ole vielä.';

  @override
  String get noSettlements => 'Ei velkojen tasauksia';

  @override
  String get noTransferNeededForFilter => 'Valitulle suodattimelle ei tarvita siirtoa.';

  @override
  String get noTransferRowsToShow => 'Näytettäviä tilisiirtoja ei ole.';

  @override
  String get noTripDataLoaded => 'Matkan tietoja ei ole ladattu.';

  @override
  String get noTripsYet => 'Matkanne eivät ole vielä alkaneet.';

  @override
  String get noUsersFoundYet => 'Käyttäjiä ei vielä löytynyt.';

  @override
  String get notSetValue => 'Ei määritetty';

  @override
  String get notYetConfirmedTitle => 'Ei vielä vahvistettu';

  @override
  String get noteHint => 'Illallinen, taksi, liput...';

  @override
  String get noteLabel => 'Huomautus';

  @override
  String noteMustBeMaxChars(Object max) {
    return 'Muistiinpanon pituus saa olla enintään $max merkkiä.';
  }

  @override
  String get notificationFallbackTitle => 'Ilmoitus';

  @override
  String get notificationsTitle => 'Ilmoitukset';

  @override
  String get notificationFriendInviteTitle => 'Kaveripyyntö';

  @override
  String notificationFriendInviteBody(Object name) {
    return '$name on lähettänyt sinulle ystäväkutsun.';
  }

  @override
  String get notificationFriendInviteBodyGeneric => 'Olet saanut ystäväkutsun.';

  @override
  String get notificationFriendInviteAcceptedTitle => 'Kutsu hyväksytty';

  @override
  String notificationFriendInviteAcceptedBody(Object name) {
    return '$name on hyväksynyt ystäväkutsusi.';
  }

  @override
  String get notificationFriendInviteAcceptedBodyGeneric => 'Ystäväsi kutsu on hyväksytty.';

  @override
  String get notificationFriendInviteRejectedTitle => 'Kutsu hylätty';

  @override
  String notificationFriendInviteRejectedBody(Object name) {
    return '$name on hylännyt ystäväkutsusi.';
  }

  @override
  String get notificationFriendInviteRejectedBodyGeneric => 'Ystäväsi kutsu hylättiin.';

  @override
  String get notificationTripAddedTitle => 'Lisätty matkaan';

  @override
  String notificationTripAddedBody(Object name, Object trip) {
    return '$name lisäsi sinut matkalle ”$trip”.';
  }

  @override
  String notificationTripAddedBodyNoActor(Object trip) {
    return 'Sinut on lisätty matkalle ”$trip”.';
  }

  @override
  String get notificationTripAddedBodyGeneric => 'Sinut on lisätty matkalle.';

  @override
  String get notificationExpenseAddedTitle => 'Uusi kulu lisätty';

  @override
  String notificationExpenseAddedBodyWithTrip(Object amount, Object name, Object trip) {
    return '$name lisäsi $amount:n suuruisen kulun matkaan ”$trip”.';
  }

  @override
  String notificationExpenseAddedBodyWithNote(Object amount, Object name, Object note) {
    return '$name lisäsi kulun, jonka summa on $amount: $note';
  }

  @override
  String get notificationExpenseAddedBodyGeneric => 'Uusi kulu on lisätty.';

  @override
  String get notificationTripFinishedTitle => 'Matka päättynyt';

  @override
  String notificationTripFinishedBodySettlementsReady(Object name, Object trip) {
    return '$name on suorittanut matkan ”$trip”. Maksut ovat valmiina.';
  }

  @override
  String notificationTripFinishedBodyArchived(Object name, Object trip) {
    return '$name on suorittanut matkan ”$trip”. Matka on arkistoitu.';
  }

  @override
  String notificationTripFinishedBodyNoActor(Object trip) {
    return '”$trip” on valmis.';
  }

  @override
  String get notificationTripFinishedBodyGeneric => 'Matkan tila on päivitetty.';

  @override
  String get notificationMemberReadyToSettleTitle => 'Jäsen merkitty valmiiksi';

  @override
  String notificationMemberReadyToSettleBody(Object name, Object trip) {
    return '$name on valmis osallistumaan matkaan ”$trip”.';
  }

  @override
  String notificationMemberReadyToSettleBodyNoActor(Object trip) {
    return 'Jäsen on valmis osallistumaan matkaan ”$trip”.';
  }

  @override
  String get notificationMemberReadyToSettleBodyGeneric => 'Jäsen on valmis suorittamaan maksun.';

  @override
  String get notificationTripReadyToSettleTitle => 'Kaikki jäsenet ovat valmiina';

  @override
  String notificationTripReadyToSettleBody(Object trip) {
    return 'Kaikki jäsenet on merkitty valmiiksi matkassa ”$trip”. Voit aloittaa maksujen selvityksen.';
  }

  @override
  String get notificationTripReadyToSettleBodyGeneric => 'Kaikki jäsenet ovat valmiina. Voit aloittaa maksujen käsittelyn.';

  @override
  String get notificationSettlementReminderTitle => 'Maksumuistutus';

  @override
  String notificationSettlementReminderBodyMarkSent(Object actor, Object amount, Object target) {
    return '$actor muistutti $target:ta merkitsemään $amount lähetetyksi.';
  }

  @override
  String notificationSettlementReminderBodyConfirm(Object actor, Object amount, Object target) {
    return '$actor muistutti $target:ta vahvistamaan $amount:n vastaanottamisen.';
  }

  @override
  String get notificationSettlementReminderBodyGeneric => 'Olet saanut maksumuistutuksen.';

  @override
  String get notificationPaymentReminderTitle => 'Maksumuistutus';

  @override
  String notificationPaymentReminderBody(Object amount, Object target, Object trip) {
    return 'Muistutus: merkitse $amount lähetetyksi kohteeseen $target kohdassa ”$trip”.';
  }

  @override
  String get notificationPaymentReminderBodyGeneric => 'Muistutus: merkitse maksu lähetetyksi.';

  @override
  String get notificationConfirmationReminderTitle => 'Vahvistusmuistutus';

  @override
  String notificationConfirmationReminderBody(Object amount, Object payer, Object trip) {
    return 'Muistutus: vahvista, että olet vastaanottanut $amount summan $payer:ltä matkan ”$trip” yhteydessä.';
  }

  @override
  String get notificationConfirmationReminderBodyGeneric => 'Muistutus: vahvista maksun vastaanottaminen.';

  @override
  String get notificationSettlementSentTitle => 'Tilisiirto merkitty lähetetyksi';

  @override
  String notificationSettlementSentBody(Object amount, Object name) {
    return '$name merkitsi $amount:n sinulle lähetetyksi.';
  }

  @override
  String get notificationSettlementSentBodyGeneric => 'Siirto merkittiin lähetetyksi.';

  @override
  String get notificationSettlementConfirmedTitle => 'Tilisiirto vahvistettu';

  @override
  String notificationSettlementConfirmedBody(Object amount, Object name) {
    return '$name on vahvistanut vastaanottaneensa sinulta $amount.';
  }

  @override
  String get notificationSettlementConfirmedBodyGeneric => 'Siirto on vahvistettu.';

  @override
  String offlineQueuePendingChanges(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count odottavaa muutosta',
      one: '$count odottava muutos',
    );
    return 'Offline-jono: $_temp0';
  }

  @override
  String get syncAllSynced => 'Kaikki synkronoitu';

  @override
  String syncChangesWaiting(Object count) {
    return '$count odottaa synkronointia';
  }

  @override
  String get syncFailedTapToRetry => 'Synkronointi epäonnistui, napauta yrittääksesi uudelleen';

  @override
  String get offlineQueueStatus => 'Offline-jono';

  @override
  String get offlineStatus => 'Offline';

  @override
  String get onlineStatus => 'Verkossa';

  @override
  String get onlyCreatorCanFinishTrip => 'Vain matkan luoja voi päättää matkan.';

  @override
  String get openLabel => 'Avaa';

  @override
  String get openReceiptAction => 'Avaa kuitti';

  @override
  String get openSettlements => 'Avaa velkojen tasaukset';

  @override
  String get overviewTitle => 'Yleiskatsaus';

  @override
  String get owesLabel => 'Velkaa';

  @override
  String get paidByLabel => 'Maksaja';

  @override
  String get paidLabel => 'Maksettu';

  @override
  String paidOwesLine(Object owes, Object paid) {
    return 'Maksettu $paid  -  Velkaa $owes';
  }

  @override
  String get participantsEmptyMeansAll => 'Osallistujat (tyhjä = kaikki jäsenet)';

  @override
  String get participantsTitle => 'Osallistujat';

  @override
  String get passwordLabel => 'Salasana';

  @override
  String get passwordComplexityHelper => 'Käytä vähintään yhtä isoa kirjainta, yhtä numeroa ja yhtä symbolia.';

  @override
  String get passwordComplexityValidation => 'Salasanan on sisällettävä 1 iso kirjain, 1 numero ja 1 erikoismerkki.';

  @override
  String get passwordMinLength => 'Salasanan on oltava vähintään 8 merkkiä pitkä.';

  @override
  String get passwordMinLengthShort => 'Salasanan on oltava vähintään 6 merkkiä pitkä.';

  @override
  String get passwordResetComingSoon => 'Salasanan nollaus tulossa pian.';

  @override
  String get passwordsDoNotMatch => 'Salasanat eivät täsmää.';

  @override
  String payerName(Object name) {
    return '$name (maksaja)';
  }

  @override
  String get pendingLabel => 'Odottaa';

  @override
  String get pendingPaymentsSubtitle => 'Maksut odottavat edelleen lopullista vahvistusta.';

  @override
  String get percentLabel => 'Prosentti';

  @override
  String get percentSplitMustBe100 => 'Jakosuhteiden summan on oltava tarkalleen 100 %.';

  @override
  String percentWithValue(Object value) {
    return '$value';
  }

  @override
  String get percentagesLabel => 'Prosenttiosuudet';

  @override
  String get pickAtLeastOneParticipant => 'Valitse vähintään yksi osallistuja.';

  @override
  String get pickMembersGenerateTurn => 'Valitse osallistujat ja arvo seuraava henkilö.';

  @override
  String pickedCycleCompleted(Object name) {
    return '$name valittu. Sykli valmis.';
  }

  @override
  String pickedUser(Object name) {
    return '$name valittu.';
  }

  @override
  String get profileRefreshCachedData => 'Profiilia ei voitu päivittää. Näytetään välimuistissa olevia tietoja.';

  @override
  String get profileTitle => 'Profiili';

  @override
  String get profileUpdated => 'Profiili päivitetty.';

  @override
  String get uploadAvatarAction => 'Lataa avatar';

  @override
  String get takePhotoAction => 'Ota kuva';

  @override
  String get chooseFromLibraryAction => 'Valitse kirjastosta';

  @override
  String get removeAvatarAction => 'Poista avatar';

  @override
  String get avatarUpdatedMessage => 'Avatar päivitetty.';

  @override
  String get avatarRemovedMessage => 'Avatar poistettu.';

  @override
  String get avatarFileTooLarge => 'Avatar-tiedosto on liian suuri (enintään 5 Mt).';

  @override
  String get avatarPickFailed => 'Avatar-kuvaa ei voitu ladata.';

  @override
  String get queueAddExpense => 'Lisää kulu';

  @override
  String queueAddExpenseAmount(Object amount) {
    return 'Jonossa: lisää kulu $amount';
  }

  @override
  String get queueDeleteExpense => 'Poista kulu';

  @override
  String queueDeleteExpenseWithId(Object id) {
    return 'Jonossa: poista kulu #$id';
  }

  @override
  String get queuePendingStatus => 'Jono odottaa';

  @override
  String get queueUpdateExpense => 'Päivitä kulut';

  @override
  String queueUpdateExpenseWithId(Object id) {
    return 'Jonossa: päivitä kulu #$id';
  }

  @override
  String get queuedChange => 'Jonossa oleva muutos';

  @override
  String queuedChangesTitle(Object count) {
    return 'Jonossa olevat muutokset ($count)';
  }

  @override
  String queuedCountLabel(Object count) {
    return 'Jonossa ($count)';
  }

  @override
  String randomCycleDrawLeft(Object cycleNo, Object drawNo, Object remaining) {
    return 'Sykli $cycleNo, piirrä $drawNo – jäljellä $remaining';
  }

  @override
  String get receiptFallbackName => 'kuitti';

  @override
  String get receiptLinkInvalid => 'Kuitilinkki on virheellinen.';

  @override
  String get receiptOptionalLabel => 'Kuitti (valinnainen)';

  @override
  String get recentPicksTitle => 'Viimeisimmät arvonnat';

  @override
  String get reloadProfile => 'Päivitä profiili';

  @override
  String get rememberMe => 'Muista minut';

  @override
  String get removeCurrentReceipt => 'Poista nykyinen kuitti';

  @override
  String get repeatNewPasswordLabel => 'Toista uusi salasana';

  @override
  String get repeatPasswordLabel => 'Toista salasana';

  @override
  String get requestFailedTryAgain => 'Pyyntö epäonnistui. Yritä uudelleen.';

  @override
  String get retryAction => 'Yritä uudelleen';

  @override
  String get rowsLabel => 'Rivit';

  @override
  String get backToLoginAction => 'Takaisin kirjautumissivulle';

  @override
  String get saveAction => 'Tallenna';

  @override
  String get saveCredentialsButton => 'Tallenna tunnistetiedot';

  @override
  String get saveProfileButton => 'Tallenna profiili';

  @override
  String get sendResetLinkButton => 'Lähetä nollauslinkki';

  @override
  String get searchUsersHint => 'Hae henkilöitä nimen tai sähköpostiosoitteen perusteella';

  @override
  String get selectedPeopleLabel => 'Valitut henkilöt';

  @override
  String get noSearchMatches => 'Vastaavia käyttäjiä ei löytynyt.';

  @override
  String get savingButton => 'Tallennetaan...';

  @override
  String get selectAtLeastTwoMembers => 'Valitse vähintään kaksi jäsentä.';

  @override
  String get selectMembersHint => 'Valitse jäsenet';

  @override
  String selectedFileLabel(Object name) {
    return 'Valittu: $name';
  }

  @override
  String get selectedLabel => 'Valittu';

  @override
  String get selectedUserFallback => 'Valittu käyttäjä';

  @override
  String get settings => 'Asetukset';

  @override
  String get settleUpAction => 'Tasaa velat';

  @override
  String get settledLabel => 'Tasattu';

  @override
  String get settledStatus => 'Tasattu';

  @override
  String get settlementActivitySubtitle => 'Tähän jäseneen liittyvät siirrot.';

  @override
  String get settlementActivityTitle => 'Maksujen käsittely';

  @override
  String get settlementCompletedTitle => 'Maksu suoritettu';

  @override
  String settlementConfirmedProgress(Object confirmed, Object total) {
    return '$confirmed / $total vahvistettu';
  }

  @override
  String settlementCountLabel(Object count) {
    return 'Velkojen tasaukset: $count';
  }

  @override
  String get settlementImpactTitle => 'Vaikutus maksuliikenteeseen';

  @override
  String settlementImpactWithFilter(Object name) {
    return 'Vaikutus sovitteluun: $name';
  }

  @override
  String get settlementInProgress => 'Maksun käsittely käynnissä';

  @override
  String get settlementInProgressTitle => 'Maksun käsittely käynnissä';

  @override
  String get settlementLabel => 'Velkojen tasaus';

  @override
  String get settlementOverviewArchivedSubtitle => 'Matka on arkistoitu. Kaikki maksut on suoritettu.';

  @override
  String get settlementOverviewInProgressSubtitle => 'Seuraa maksuvahvistuksia.';

  @override
  String get settlementOverviewPreviewSubtitle => 'Esikatsele siirrot matkan päättymistä varten.';

  @override
  String get settlementPreview => 'Maksun ennakkonäkymä';

  @override
  String get settlementPreviewTitle => 'Maksun ennakkonäkymä';

  @override
  String get settlementProgressTripArchived => 'Matka arkistoitu';

  @override
  String settlementWithId(Object id) {
    return 'Maksutapahtuma nro $id';
  }

  @override
  String get settlements => 'Velkojen tasaukset';

  @override
  String get settlementsAlreadyCompletedSubtitle => 'Maksut on jo suoritettu.';

  @override
  String get settlementsDone => 'Maksut suoritettu';

  @override
  String get settlingStatus => 'Maksujen selvittäminen';

  @override
  String get shareUnit => 'osuus';

  @override
  String get sharesLabel => 'Osuudet';

  @override
  String get sharesMustBePositiveIntegers => 'Osuuksien määrän on oltava positiivinen kokonaisluku.';

  @override
  String sharesWithValue(Object value) {
    return 'Osuudet: $value';
  }

  @override
  String get showActiveTrips => 'Näytä aktiiviset matkat';

  @override
  String get signUpButton => 'Rekisteröidy';

  @override
  String get splitBreakdownSubtitle => 'Kulujen jakautuminen';

  @override
  String get splitBreakdownTitle => 'Jakautumisen erittely';

  @override
  String get splitHintEqual => 'Jaa summa tasan valittujen osallistujien kesken.';

  @override
  String get splitHintExact => 'Syötä jokaiselle osallistujalle tarkka summa. Summan on vastattava kokonaissummaa.';

  @override
  String get splitHintPercent => 'Syötä prosenttiosuus jokaiselle osallistujalle. Summan on oltava 100 %.';

  @override
  String get splitHintShares => 'Syötä jakoyksiköt (1, 2, 3...). Kustannukset jaetaan suhteellisesti.';

  @override
  String get splitLabel => 'Jaa';

  @override
  String splitLabelValue(Object value) {
    return 'Split: $value';
  }

  @override
  String splitModeEqual(Object target) {
    return 'Tasa-arvoinen jako ($target)';
  }

  @override
  String splitModeExact(Object target) {
    return 'Tarkat summat ($target)';
  }

  @override
  String get splitModeLabel => 'Jaettu tila';

  @override
  String splitModePercent(Object target) {
    return 'Prosenttiosuudet ($target)';
  }

  @override
  String splitModeShares(Object target) {
    return 'Osuudet ($target)';
  }

  @override
  String get statusConfirmed => 'Vahvistettu';

  @override
  String get statusPending => 'Odottaa';

  @override
  String get statusSent => 'Lähetetty';

  @override
  String get statusSuggested => 'Ehdotettu';

  @override
  String statusWithValue(Object status) {
    return 'Tila: $status';
  }

  @override
  String get suggestedTransferDirections => 'Ehdotetut maksusuunnat';

  @override
  String get suggestedTransferFromExpense => 'Ehdotettu siirto kuluista';

  @override
  String suggestedTransferRows(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ehdotettua tilisiirtoa',
      one: '$count ehdotettu tilisiirto',
    );
    return '$_temp0';
  }

  @override
  String get suggestedTransfersSubtitle => 'Odotetut maksaja- ja vastaanottajarivit.';

  @override
  String get suggestedTransfersTitle => 'Ehdotetut siirrot';

  @override
  String get summarySettledUp => 'Tasattu';

  @override
  String get summaryYouAreOwed => 'Muut ovat sinulle velkaa';

  @override
  String get summaryYouOwe => 'Olet velkaa';

  @override
  String get syncAction => 'Synkronointi';

  @override
  String get syncNowAction => 'Synkronoi nyt';

  @override
  String get syncingStatus => 'Synkronointi';

  @override
  String get tapToViewDetails => 'Napauta nähdäksesi yksityiskohdat';

  @override
  String get themeModeDark => 'Tumma';

  @override
  String get themeModeDarkSubtitle => 'Pehmeä tumma (ei puhdasta mustaa)';

  @override
  String get themeModeLight => 'Vaalea';

  @override
  String get themeModeSystem => 'Järjestelmä';

  @override
  String get themeModeSystemSubtitle => 'Käytä laitteen ulkoasua';

  @override
  String toDirection(Object name) {
    return '$name:lle';
  }

  @override
  String get totalLabel => 'Yhteensä';

  @override
  String get travelerFallbackName => 'Matkustaja';

  @override
  String get tripAlreadyClosed => 'Matka on jo päättynyt.';

  @override
  String get tripArchivedReadOnly => 'Matka arkistoidaan. Vain luku -tila.';

  @override
  String get tripClosedExpenseEditingDisabled => 'Matka on päättynyt. Kulujen muokkaus on poistettu käytöstä.';

  @override
  String get tripClosedExpensesReadOnly => 'Matka on päättynyt. Kulut ovat vain luku -tilassa.';

  @override
  String get tripClosedRandomDisabled => 'Matka on päättynyt. Satunnaisarvonta on pois käytöstä.';

  @override
  String tripCreated(Object name) {
    return 'Matka ”$name” luotu.';
  }

  @override
  String get tripFinished => 'Matka on päättynyt.';

  @override
  String get tripFinishedCompleteSettlements => 'Matka on päättynyt. Hoida maksut.';

  @override
  String get tripFinishedSettlementStarted => 'Matka on päättynyt. Velkojen tasaus on alkanut.';

  @override
  String get tripFullySettledArchived => 'Matka on kokonaan maksettu ja arkistoitu.';

  @override
  String get tripNameHint => 'Hiihtomatka Itävaltaan';

  @override
  String get tripNameLabel => 'Matkan nimi';

  @override
  String get tripNameLengthValidation => 'Matkan nimen on oltava vähintään 2 merkkiä pitkä.';

  @override
  String get tripSnapshotTitle => 'Matkan tilannekatsaus';

  @override
  String get tripTitleShort => 'Matka';

  @override
  String tripStatusWithValue(Object status) {
    return 'Matkan tila: $status';
  }

  @override
  String tripWithId(Object id) {
    return 'Matka nro $id';
  }

  @override
  String get unexpectedErrorLoadingProfile => 'Odottamaton virhe profiilin lataamisessa';

  @override
  String get unexpectedErrorLoadingTripData => 'Odottamaton virhe matkatietojen lataamisessa';

  @override
  String get unexpectedErrorLoadingTrips => 'Odottamaton virhe matkojen lataamisessa';

  @override
  String get unexpectedErrorSavingChanges => 'Odottamaton virhe muutosten tallennuksessa';

  @override
  String get unexpectedErrorSavingCredentials => 'Odottamaton virhe tunnistetietojen tallennuksessa';

  @override
  String get unexpectedErrorUpdatingProfile => 'Odottamaton virhe profiilin päivittämisessä';

  @override
  String get unknownError => 'Tuntematon virhe';

  @override
  String get unknownLabel => 'Tuntematon';

  @override
  String get unreadLabel => 'Lukematon';

  @override
  String unreadUpdates(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lukematonta päivitystä',
      one: '$count lukematon päivitys',
    );
    return '$_temp0';
  }

  @override
  String get missingTripRouteArgument => 'Matkan reittiparametri puuttuu.';

  @override
  String userIdLabel(Object id) {
    return 'Käyttäjätunnus: $id';
  }

  @override
  String userPaidOwesNetLine(Object net, Object owes, Object paid) {
    return 'Maksettu $paid  -  Velkaa $owes  -  Netto $net';
  }

  @override
  String userWithId(Object id) {
    return 'Käyttäjä $id';
  }

  @override
  String get valueLabel => 'Arvo';

  @override
  String get viewAllTrips => 'Näytä kaikki matkat';

  @override
  String get viewByPersonTitle => 'Näytä henkilön mukaan';

  @override
  String get whoOwesWhatSubtitle => 'Kuka maksoi ja kuka on velkaa.';

  @override
  String get whoOwesWhatTitle => 'Kuka on velkaa mitäkin';

  @override
  String whoOwesWhatWithFilter(Object name) {
    return 'Kuka on velkaa mitäkin: $name';
  }

  @override
  String get whyPaymentExistsSubtitle => 'Tähän siirtoon vaikuttavat kulurivit.';

  @override
  String get whyPaymentExistsTitle => 'Miksi tämä maksu on olemassa';

  @override
  String get youLabel => 'Sinä';

  @override
  String get youSettledForExpense => 'Olet maksanut osuutesi tästä kulusta.';

  @override
  String youShouldPay(Object amount) {
    return 'Sinun pitäisi maksaa. $amount';
  }

  @override
  String youShouldReceive(Object amount) {
    return 'Sinun tulee saada $amount';
  }

  @override
  String get yourShare => 'Oma osuus';

  @override
  String get yourTrips => 'Matkanne';

  @override
  String get authIntroSplitSmarter => 'Jaa älykkäämmin.';

  @override
  String get authIntroTravelFree => 'Matkusta vapaasti.';

  @override
  String get authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo => 'Seuraa jaettavia kustannuksia eri valuutoissa ja selvitä tilit välittömästi – ilman hankalia velkakirjoja.';

  @override
  String get authIntroPlanTogether => 'Suunnittele yhdessä.';

  @override
  String get authIntroPayClearly => 'Maksaminen on tehtävä selkeästi.';

  @override
  String get authIntroCreateTripsSecondsAddFriendsKeepEveryExpense => 'Luo matkoja sekunneissa, lisää ystäviä ja pidä kaikki kulut läpinäkyvinä kaikille.';

  @override
  String get authIntroSettleFast => 'Hoida asia nopeasti.';

  @override
  String get authIntroStayFriends => 'Pysytään ystävinä.';

  @override
  String get authIntroFromSharedDinnersFullTripsSplytoKeepsBalances => 'Yhteisistä illallisista kokonaisiin matkoihin – Splyto pitää tilit tasapainossa ja huolehtii stressittömästä kokemuksesta.';

  @override
  String get authIntroAppleSignFailedPleaseTryAgain => 'Apple-kirjautuminen epäonnistui. Yritä uudelleen.';

  @override
  String get authIntroGoogleSignFailedPleaseTryAgain => 'Google-kirjautuminen epäonnistui. Yritä uudelleen.';

  @override
  String get authIntroCreateAccount => 'Luo tili.';

  @override
  String get authIntroChooseSign => 'Valitse, miten haluat rekisteröityä.';

  @override
  String get authIntroContinueGoogle => 'Jatka Googlen avulla';

  @override
  String get authIntroContinueApple => 'Jatka Apple-palvelussa';

  @override
  String get authIntroBack => 'Takaisin';

  @override
  String get authIntroSplitSettled => 'Jako vahvistettu';

  @override
  String get authIntroParis3Friends => 'Pariisi · 3 ystävää';

  @override
  String get authIntroGetStarted => 'Aloita';

  @override
  String get authIntroAlreadyHaveAccount => 'Onko sinulla jo tili? ';

  @override
  String get authIntroSignIn => 'Kirjaudu sisään';

  @override
  String get authIntroSignUpWithEmail => 'Rekisteröidy sähköpostilla';

  @override
  String get authIntroOr => 'TAI';

  @override
  String get authGoogleSignDidNotReturnIdToken => 'Google-kirjautuminen ei palauttanut tunnistetunnusta.';

  @override
  String get authAppleSignAvailableIosDevices => 'Apple-kirjautuminen on käytettävissä iOS-laitteilla.';

  @override
  String get authAppleSignNotAvailableDevice => 'Apple-kirjautuminen ei ole käytettävissä tällä laitteella.';

  @override
  String get authAppleSignDidNotReturnIdentityToken => 'Apple-kirjautuminen ei palauttanut tunnistustunnusta.';

  @override
  String get authCancel => 'Peruuta';

  @override
  String get authSendLink => 'Lähetä linkki';

  @override
  String get authEmailNotVerifiedEnterEmailRequestVerificationLink => 'Sähköpostiosoitetta ei ole vahvistettu. Syötä sähköpostiosoitteesi pyytääksesi vahvistuslinkin.';

  @override
  String get authEmailNotVerified => 'Sähköpostiosoitetta ei ole vahvistettu';

  @override
  String authSendVerificationLinkEmail(Object email) {
    return 'Lähetetäänkö vahvistuslinkki osoitteeseen $email?';
  }

  @override
  String get authVerificationLinkSentCheckEmail => 'Vahvistuslinkki on lähetetty. Tarkista sähköpostisi.';

  @override
  String get authCouldNotSendVerificationLinkPleaseTryAgain => 'Vahvistuslinkkiä ei voitu lähettää. Yritä uudelleen.';

  @override
  String get authVerificationEmailSentPleaseVerifyEmailBeforeLogging => 'Vahvistussähköposti on lähetetty. Vahvista sähköpostiosoitteesi ennen kirjautumista.';

  @override
  String get authVerifyEmail => 'Vahvista sähköpostiosoitteesi';

  @override
  String get authEmailLabel => 'Sähköposti:';

  @override
  String get authClose => 'Sulje';

  @override
  String get authResendLink => 'Lähetä linkki uudelleen';

  @override
  String get profileAppSettingsSectionTitle => 'SOVELLUKSEN ASETUKSET';

  @override
  String get profileAccountSettings => 'Tilin asetukset';

  @override
  String get profileChangePhoto => 'Vaihda profiilikuva';

  @override
  String get profileAppearance => 'Ulkoasu';

  @override
  String get profileThemeDisplayMode => 'Teema ja näyttötila';

  @override
  String get profileLanguage => 'Kieli';

  @override
  String get profileDisplayLanguage => 'Näytön kieli';

  @override
  String get profileNotificationsSectionHeading => 'ILMOITUKSET';

  @override
  String get profileAppBanners => 'Sovelluksen sisäiset bannerit';

  @override
  String get profileShowNewNotificationBannersInsideApp => 'Näytä uudet ilmoitusbannerit sovelluksen sisällä';

  @override
  String get profilePushNotificationsTitle => 'Push-ilmoitukset';

  @override
  String get profilePhoneNotificationsExpensesFriendsTripsSettlements => 'Puhelimen ilmoitukset kuluista, ystävistä, matkoista ja tilityksistä';

  @override
  String get profileSupportSectionHeading => 'TUKI';

  @override
  String get profileContactUs => 'Ota yhteyttä';

  @override
  String get profileReportBugSuggestion => 'Ilmoita virheestä / Ehdotus';

  @override
  String get profileRateSplyto => 'Arvostele Splyto';

  @override
  String get profileLeaveStoreRating => 'Jätä arvostelu kaupasta';

  @override
  String get profileSecuritySectionHeading => 'TURVALLISUUS';

  @override
  String get profileChangePassword => 'Vaihda salasana';

  @override
  String get profileUpdateAccountPassword => 'Päivitä tilin salasana';

  @override
  String get profileDangerZoneSectionHeading => 'VAARALUOKKA';

  @override
  String get profileManageAccountAccess => 'Hallitse tilin käyttöoikeuksia';

  @override
  String get profileMadeWithLabel => 'Toteutettu';

  @override
  String get profileStoreRatingActionWillConnectedNextStep => 'Arvostelutoiminto liitetään mukaan seuraavassa vaiheessa.';

  @override
  String get profileFailedSaveNotificationSettings => 'Ilmoitusasetusten tallentaminen epäonnistui.';

  @override
  String get profilePushNotificationsSectionTitle => 'PUSH-ILMOITUKSET';

  @override
  String get profileInAppBannersSectionTitle => 'SOVELLUKSEN SISÄISET BANNERIT';

  @override
  String get profileInAppTripMemberAddedTitle => 'Jäsen lisätty matkalle';

  @override
  String get profileInAppAutoSettlementReminderTitle => 'Automaattinen maksumuistutus';

  @override
  String get profileExpenseUpdates => 'Kulujen päivitykset';

  @override
  String get profileExpenseAddedBannersInsideApp => 'Sovelluksen sisällä näkyvät kulujen lisäysbannerit';

  @override
  String get profileExpenseAddedNotificationsPhone => 'Kulujen lisäysilmoitukset puhelimeen';

  @override
  String get profileFriendInvites => 'Ystävä kutsuu';

  @override
  String get profileFriendInvitesBannersInsideApp => 'Ystäväpyyntö- ja vastausbannerit sovelluksen sisällä';

  @override
  String get profileFriendRequestResponseNotifications => 'Ystäväpyyntö- ja vastausilmoitukset';

  @override
  String get profileTripUpdates => 'Matkan päivitykset';

  @override
  String get profileTripUpdatesBannersInsideApp => 'Matkan elinkaaren ja jäsenten tilan bannerit sovelluksen sisällä';

  @override
  String get profileTripLifecycleMemberStatusChanges => 'Matkan elinkaari ja jäsenen tilan muutokset';

  @override
  String get profileSettlementUpdates => 'Maksujen käsittelyn päivitykset';

  @override
  String get profileSettlementUpdatesBannersInsideApp => 'Sovelluksen sisällä näkyvät lähetetyt ja vahvistetut maksubannerit';

  @override
  String get profileMarkedSentConfirmedPaymentUpdates => 'Merkitty lähetetyiksi ja vahvistetuiksi maksupäivitykset';

  @override
  String get profileScreenshotSizeMust8Mb => 'Kuvakaappauksen koon on oltava enintään 8 Mt';

  @override
  String get profileFeedbackSendTitle => 'Lähetä palautetta';

  @override
  String get profileFeedbackTypeLabel => 'Kirjoita';

  @override
  String get profileFeedbackTypeBug => 'Virhe';

  @override
  String get profileFeedbackTypeSuggestion => 'Ehdotus';

  @override
  String get profileDescribeIssueSuggestion => 'Kuvaile ongelma tai ehdotus';

  @override
  String get profilePickingImage => 'Valitaan kuvaa...';

  @override
  String get profileAttachScreenshot => 'Liitä kuvakaappaus';

  @override
  String get profileChangeScreenshot => 'Vaihda kuvakaappaus';

  @override
  String get profileRemoveImage => 'Poista kuva';

  @override
  String get profileTipAttachScreenshotFasterBugTriage => 'Vinkki: liitä kuvakaappaus, jotta virheiden luokittelu sujuu nopeammin';

  @override
  String get profileAddDetailsAttachScreenshotBeforeSending => 'Lisää yksityiskohdat tai liitä kuvakaappaus ennen lähettämistä';

  @override
  String get profileSendAction => 'Lähetä';

  @override
  String get profileThanksFeedbackSent => 'Kiitos! Palaute lähetetty';

  @override
  String get profileFailedSendFeedback => 'Palautteen lähettäminen epäonnistui';

  @override
  String get profileCouldNotOpenWebsite => 'Verkkosivustoa ei voitu avata.';

  @override
  String get profileOpenWebsiteQuestion => 'Avaa verkkosivusto?';

  @override
  String get profileOpenPortfolioAction => 'Avaa portfolio.egm.lv';

  @override
  String get profileImageFormatNotSupportedDevicePleaseChooseJpg => 'Tätä kuvamuotoa ei tueta tällä laitteella. Valitse JPG tai PNG.';

  @override
  String get profileEditSetValidEmailEditProfileChangingPassword => 'Salasanan vaihtamiseen tarvitaan voimassa oleva tilin sähköpostiosoite. Ota yhteyttä tukeen, jos sähköpostiosoitteesi puuttuu tai on virheellinen.';

  @override
  String get profileEditDeletionLinkSentEmail => 'Poistolinkki on lähetetty sähköpostiisi.';

  @override
  String get profileEditCouldNotSendDeletionLinkTryAgain => 'Poistolinkkiä ei voitu lähettää. Yritä uudelleen.';

  @override
  String get profileEditEnterCurrentPasswordChangeEmail => 'Syötä nykyinen salasana, jos haluat muuttaa sähköpostiosoitetta.';

  @override
  String get profileEditVerificationWasSentNewEmailSecurityNoticeWas => 'Vahvistus on lähetetty uuteen sähköpostiosoitteeseen. Turvallisuusilmoitus on lähetetty nykyiseen sähköpostiosoitteeseesi.';

  @override
  String get profileEditOverviewCurrency => 'Yleiskatsaus valuutasta';

  @override
  String get profileEditPaymentMethod => 'Maksutapa';

  @override
  String get profileEditBankTransferRevolutPaypalMe => 'Pankkisiirto, Revolut, PayPal.me';

  @override
  String get profileEditEnterPasswordOptionalGoogleApple => 'Syötä salasanasi (valinnainen Google/Apple)';

  @override
  String get profileEditSendDeletionLinkEmail => 'Lähetä poistolinkki sähköpostitse';

  @override
  String get profileEditBackProfile => 'Takaisin profiiliin';

  @override
  String get profileEditSetValidEmailProfileChangingPassword => 'Määritä profiiliin voimassa oleva sähköpostiosoite ennen salasanan vaihtamista.';

  @override
  String get profileEditPasswordUpdated => 'Salasana päivitetty.';

  @override
  String get profileEditFailedUpdatePassword => 'Salasanan päivitys epäonnistui.';

  @override
  String profileEditEmail(Object email) {
    return 'Tili: $email';
  }

  @override
  String get profileEditPrimary => 'Ensisijainen';

  @override
  String get profileEditSearchCurrency => 'Hae valuutta';

  @override
  String get profileEditNoCurrenciesFound => 'Valuuttoja ei löytynyt';

  @override
  String get profileEditOverviewTotalsConvertedCurrency => 'Yhteenvetoluvut muunnetaan tähän valuuttaan.';

  @override
  String get profileEditPaymentInfoUpdated => 'Maksutiedot päivitetty.';

  @override
  String get profileEditCouldNotSavePaymentInfoTryAgain => 'Maksutietoja ei voitu tallentaa. Yritä uudelleen.';

  @override
  String get profileEditCurrentPassword => 'Nykyinen salasana';

  @override
  String get profileEditBankTransferIbanSwift => 'Pankkisiirto (IBAN / SWIFT)';

  @override
  String get profileEditIbanSwift => 'IBAN + SWIFT';

  @override
  String get profileEditRevtagRevolutMe => 'Revtag / revolut.me';

  @override
  String get profileEditPaypalMeLink => 'paypal.me-linkki';

  @override
  String get profileEditChoosePaymentMethod => 'Valitse maksutapa';

  @override
  String get profileEditTapChange => 'Napauta muuttaaksesi';

  @override
  String get profileEditUkTransfersSortCode6DigitsNumber8 => 'Yhdistyneessä kuningaskunnassa suoritettavissa tilisiirroissa pankkitunnuksen on oltava 6-numeroinen ja tilinumero 8-numeroinen.';

  @override
  String get profileEditPaymentInfo => 'Maksutiedot';

  @override
  String get profileEditSaveDetails => 'Tallenna tiedot';

  @override
  String get profileEditBankRegion => 'Pankkialue';

  @override
  String get profileEditEurope => 'Eurooppa';

  @override
  String get profileEditSortCode => 'Pankkitunnus';

  @override
  String get profileEditExample112233 => 'Esimerkki: 112233';

  @override
  String get profileEditNumber => 'Tilinumero';

  @override
  String get profileEdit8Digits => '8 numeroa';

  @override
  String get profileEditUkDomesticTransfersSortCodeNumber => 'Yhdistyneen kuningaskunnan kotimaisissa tilisiirroissa käytä pankkitunnusta (sort code) ja tilinumeroa.';

  @override
  String get profileEditExampleLv80bank0000435195001 => 'Esimerkki: LV80BANK0000435195001';

  @override
  String get profileEdit811Chars => '8 tai 11 merkkiä';

  @override
  String get profileEditHolderNameTakenProfileFullName => 'Tilin haltijan nimi otetaan profiilin täydestä nimestä.';

  @override
  String get profileEditRevolutMeUsername => 'revolut.me/username';

  @override
  String get profileEditRevtag => 'Revtag';

  @override
  String get profileEditUsername => '@username';

  @override
  String get profileEditPaypalMeUsernameUsername => 'paypal.me/username tai käyttäjätunnus';

  @override
  String get profileEditRevolut => 'Revolut';

  @override
  String get profileEditPaypalMe => 'PayPal.me';

  @override
  String get profileEditWise => 'Wise';

  @override
  String get profileEditWisePayUsername => 'wise.com/pay/me/username';

  @override
  String get profileEditUk => 'Iso-Britannia';

  @override
  String get profileEditIbanLabel => 'IBAN';

  @override
  String get profileEditBicSwiftLabel => 'BIC / SWIFT';

  @override
  String get profileEditRevolutMe => 'Revolut.me';

  @override
  String get imageCropperAdjustAvatar => 'Muokkaa avataria';

  @override
  String get imageCropperAdjustTripImage => 'Mukauta matkan kuvaa';

  @override
  String get copyAction => 'Kopioi';

  @override
  String get currencyNameEur => 'Euro';

  @override
  String get currencyNameGbp => 'Ison-Britannian punta';

  @override
  String get currencyNameChf => 'Sveitsin frangi';

  @override
  String get currencyNameNok => 'Norjan kruunu';

  @override
  String get currencyNameSek => 'Ruotsin kruunu';

  @override
  String get currencyNameDkk => 'Tanskan kruunu';

  @override
  String get currencyNamePln => 'Puolan zloty';

  @override
  String get currencyNameCzk => 'Tšekin kruunu';

  @override
  String get currencyNameHuf => 'Unkarin forintti';

  @override
  String get currencyNameRon => 'Romanian leu';

  @override
  String get currencyNameBgn => 'Bulgarian levi';

  @override
  String get currencyNameIsk => 'Islantilainen kruunu';

  @override
  String get currencyNameAll => 'Albanian lek';

  @override
  String get currencyNameBam => 'Bosnia ja Hertsegovina Mark';

  @override
  String get currencyNameByn => 'Valkovenäjän rupla';

  @override
  String get currencyNameMdl => 'Moldovan leu';

  @override
  String get currencyNameMkd => 'Makedonian denar';

  @override
  String get currencyNameRsd => 'Serbian dinaari';

  @override
  String get currencyNameUah => 'Ukrainan hryvnia';

  @override
  String get currencyNameGel => 'Georgian lari';

  @override
  String get currencyNameTry => 'Turkin liira';

  @override
  String get currencyNameUsd => 'Yhdysvaltain dollari';

  @override
  String get currencyNameJpy => 'Japanin jeni';

  @override
  String get currencyNameCny => 'Kiinan juan';

  @override
  String get currencyNameCad => 'Kanadan dollari';

  @override
  String get currencyNameAud => 'Australian dollari';

  @override
  String get expenseCategoryFood => 'Ruoka';

  @override
  String get expenseCategoryGroceries => 'Ruokaostokset';

  @override
  String get expenseCategoryFuel => 'Polttoaine';

  @override
  String get expenseCategoryTransport => 'Liikenne';

  @override
  String get expenseCategoryAccommodation => 'Majoitus';

  @override
  String get expenseCategoryActivities => 'Aktiviteetit';

  @override
  String get expenseCategoryTickets => 'Liput';

  @override
  String get expenseCategoryShopping => 'Ostokset';

  @override
  String get expenseCategoryParty => 'Juhlat';

  @override
  String get expenseCategoryParking => 'Pysäköinti';

  @override
  String get expenseCategoryOther => 'Muu';

  @override
  String get shellTripAlreadyInListOpened => 'Matka on jo luettelossasi. Avasimme sen sinulle.';

  @override
  String get shellJoinedTripFromInviteLink => 'Liityin matkaan kutsulinkin kautta.';

  @override
  String get shellFailedToOpenInviteLink => 'Kutsulinkin avaaminen epäonnistui.';

  @override
  String get shellFailedToOpenFriendLink => 'Ystävälinkin avaaminen epäonnistui.';

  @override
  String get shellTripInviteTitle => 'Matkakutsu';

  @override
  String get shellNoAction => 'Ei';

  @override
  String get shellYesAction => 'Kyllä';

  @override
  String get shellOnlyTripCreatorCanDelete => 'Vain matkan luoja voi poistaa tämän matkan.';

  @override
  String get shellOnlyActiveTripsCanDelete => 'Vain aktiiviset matkat voidaan poistaa.';

  @override
  String shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(Object tripLabel) {
    return 'Poistaako ”$tripLabel”? Tämä on sallittua vain ennen kuin kuluja on lisätty.';
  }

  @override
  String get shellTripDeleted => 'Matka on poistettu.';

  @override
  String get shellFailedToDeleteTrip => 'Matkan poistaminen epäonnistui.';

  @override
  String get shellFailedToLoadNotifications => 'Ilmoitusten lataaminen epäonnistui.';

  @override
  String shellNewNotificationTitle(Object title) {
    return 'Uusi ilmoitus: $title';
  }

  @override
  String get shellFailedToUpdateNotifications => 'Ilmoitusten päivittäminen epäonnistui.';

  @override
  String get shellMarkAllAsReadAction => 'Merkitse kaikki luetuiksi';

  @override
  String get shellNewSection => 'Uusi';

  @override
  String get shellEarlierSection => 'Aiemmin';

  @override
  String get shellShowMoreEarlierAction => 'Näytä lisää aikaisempia';

  @override
  String get shellLoadingMore => 'Ladataan lisää...';

  @override
  String get shellLoadMoreNotificationsAction => 'Lataa lisää ilmoituksia';

  @override
  String get shellTripNoLongerAvailable => 'Tämä matka ei ole enää saatavilla.';

  @override
  String get shellFailedToOpenTrip => 'Matkan avaaminen epäonnistui.';

  @override
  String get shellYesterday => 'Eilen';

  @override
  String shellInviteAlreadyMemberOpenTripNow(Object inviterName, Object tripName) {
    return 'Olet jo jäsenenä matkalla ”$tripName”. Haluatko avata tämän matkan nyt?\n\nKutsunut: $inviterName';
  }

  @override
  String shellInviteJoinTripQuestion(Object inviterName, Object tripName) {
    return 'Haluatko liittyä matkaan ”$tripName”?\n\nKutsunut: $inviterName';
  }

  @override
  String tripsSelectedImage(Object arg1) {
    return 'Valittu kuva: $arg1';
  }

  @override
  String get tripsTripImageAlreadySet => 'Matkan kuva on jo asetettu.';

  @override
  String get tripsTripCreatedButImageUploadFailed => 'Matka luotu, mutta kuvan lataus epäonnistui.';

  @override
  String tripsTripCreatedButImageUploadFailedWithReason(Object arg1) {
    return 'Matka luotu, mutta kuvan lataus epäonnistui: $arg1';
  }

  @override
  String get tripsJoinTripViaInvite => 'Liity matkalle kutsun kautta';

  @override
  String get tripsTotalTrips => 'Matkien kokonaismäärä';

  @override
  String get tripsTotalSpent => 'Kokonaiskulut';

  @override
  String get tripsMixedCurrencies => 'Eri valuutat';

  @override
  String get tripsShowActive => 'Näytä aktiiviset';

  @override
  String get tripsSeeAll => 'Katso kaikki';

  @override
  String get tripsGridView => 'Ruudukkonäkymä';

  @override
  String get tripsListView => 'Luettelonäkymä';

  @override
  String get tripsAddNewTrip => 'Lisää uusi matka';

  @override
  String get tripsLoadMore => 'Lataa lisää';

  @override
  String tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(Object arg1) {
    return 'Poistaako ”$arg1”? Tämä on sallittua vain ennen kuin kuluja on lisätty.';
  }

  @override
  String get tripsTripDates => 'Matkan päivämäärät';

  @override
  String get tripsFrom => 'Lähde:';

  @override
  String get tripsSelectDate => 'Valitse päivämäärä';

  @override
  String get tripsTo => 'To';

  @override
  String get tripsMainCurrency => 'Päävaluutta';

  @override
  String get tripsPleaseSelectTripPeriodFromAndToDates => 'Valitse matkan ajankohta (alkamis- ja päättymispäivämäärät).';

  @override
  String get tripsTripEndDateMustBeOnOrAfterStartDate => 'Matkan päättymispäivän on oltava alkamispäivänä tai sen jälkeen.';

  @override
  String get tripsTripPeriodFormatIsInvalidPleasePickDatesAgain => 'Matkan keston muoto on virheellinen. Valitse päivämäärät uudelleen.';

  @override
  String get tripsYouAreAlreadyAMemberOfThisTrip => 'Olet jo tämän matkan jäsen.';

  @override
  String get tripsJoinedTripSuccessfully => 'Liityit matkaan onnistuneesti.';

  @override
  String get tripsFailedToJoinTripFromInvite => 'Matkan liittymistä kutsusta ei onnistunut.';

  @override
  String get tripsJoinTrip => 'Liity matkalle';

  @override
  String get tripsPasteInviteLinkOrInviteToken => 'Liitä kutsulinkki tai kutsutunnus.';

  @override
  String get tripsHttpsInviteNorthSeaAbc123def4 => 'https://.../?invite=north-sea-abc123def4';

  @override
  String get tripsEnterAValidInviteLinkOrToken => 'Syötä kelvollinen kutsulinkki tai tunnus.';

  @override
  String get tripsClipboardIsEmpty => 'Leikepöytä on tyhjä.';

  @override
  String get tripsPaste => 'Liitä';

  @override
  String get tripsJoin => 'Liity mukaan';

  @override
  String get workspaceTripMembers => 'Matkan osallistujat';

  @override
  String get workspaceFailedToLoadFriends => 'Ystävien lataaminen epäonnistui.';

  @override
  String get workspaceFailedToGenerateInviteLink => 'Kutsulinkin luominen epäonnistui.';

  @override
  String get workspaceInviteLink => 'Kutsulinkki';

  @override
  String get workspaceGeneratingInviteLink => 'Kutsulinkkiä luodaan...';

  @override
  String get workspaceInviteLinkUnavailable => 'Kutsulinkki ei ole käytettävissä.';

  @override
  String get workspaceCopyInviteLink => 'Kopioi kutsulinkki';

  @override
  String get workspaceInviteLinkCopied => 'Kutsulinkki kopioitu.';

  @override
  String workspaceExpiresUtc(Object arg1) {
    return 'Vanhenee: $arg1 UTC';
  }

  @override
  String get workspaceNoFriendsAvailableAddFriendsFirst => 'Ystäviä ei ole saatavilla. Lisää ensin ystäviä.';

  @override
  String get workspaceSettle => 'Selvitä';

  @override
  String get workspaceOwesToTheGroup => 'Velka ryhmälle';

  @override
  String get workspaceGetsBackFromGroup => 'Saa rahaa takaisin ryhmältä';

  @override
  String get workspaceShowingTop4ByBalanceDifference => 'Näytetään 4 parasta saldon eron mukaan.';

  @override
  String get workspaceOpenFlow => 'Yksityiskohdat';

  @override
  String get workspaceFriend => 'Ystävä';

  @override
  String get workspaceSettlementTransfer => 'Maksun siirto';

  @override
  String get workspaceCompleted => 'Valmis';

  @override
  String get workspaceWaitingForConfirmation => 'Odotetaan vahvistusta';

  @override
  String get workspaceWaitingForPayment => 'Maksua odotetaan';

  @override
  String get workspaceActionNeeded => 'Toimenpide vaaditaan';

  @override
  String workspacePaymentSToMarkAsSentToConfirmAsReceived(Object arg1, Object arg2) {
    return 'Lähetetyiksi merkittäviä maksuja: $arg1; vastaanotetuiksi vahvistettavia maksuja: $arg2.';
  }

  @override
  String get workspaceReadyToSettle => 'Valmis maksamaan';

  @override
  String get workspaceAllMembersAreReadyYouCanStartSettlements => 'Kaikki jäsenet ovat valmiina. Voit aloittaa maksujen käsittelyn.';

  @override
  String get workspaceWaitingForEveryoneToMarkReady => 'Odotetaan, että kaikki merkitsevät olevansa valmiina.';

  @override
  String get workspaceIMReady => 'Olen valmis';

  @override
  String get workspaceConfirmThatYouAddedAllYourExpenses => 'Varmista, että olet lisännyt kaikki kulusi.';

  @override
  String get workspaceFinishButtonUnlocksOnceEveryoneMarksReady => 'Lopeta-painike avautuu, kun kaikki ovat merkinneet olevansa valmiita.';

  @override
  String get workspaceGetsBackFromTheGroup => 'Saa rahaa takaisin ryhmältä';

  @override
  String get workspaceSettledWithTheGroup => 'Sovittu ryhmän kanssa';

  @override
  String get workspaceTotalPaid => 'Maksettu yhteensä';

  @override
  String get workspaceTotalOwes => 'Velkasumma';

  @override
  String get workspaceTransactionHistory => 'Tapahtumahistoria';

  @override
  String get workspaceNoTransactionsYetForThisMember => 'Tälle jäsenelle ei ole vielä tehty tapahtumia.';

  @override
  String workspaceSettlements(Object arg1) {
    return 'Maksut: $arg1';
  }

  @override
  String get workspaceAllMembersMustMarkReadyBeforeStartingSettlements => 'Kaikkien jäsenten on merkittävä olevansa valmiina ennen maksujen selvittämisen aloittamista.';

  @override
  String get workspaceYouMarkedYourselfReadyToSettle => 'Olet merkinnyt itsesi valmiiksi maksamaan.';

  @override
  String get workspaceReadyToSettleMarkRemoved => 'Merkintä ”valmis maksettavaksi” on poistettu.';

  @override
  String get workspaceReminderSent => 'Muistutus lähetetty.';

  @override
  String get workspaceInviteLinkOrAddFromFriends => 'Kutsu linkillä tai lisää ystävien joukosta';

  @override
  String get workspaceOnlyTripCreatorCanEditThisTrip => 'Vain matkan luoja voi muokata tätä matkaa.';

  @override
  String get workspaceTripUpdated => 'Matka päivitetty.';

  @override
  String get workspaceFailedToUpdateTrip => 'Matkan päivittäminen epäonnistui.';

  @override
  String get workspaceNoMembersSelectedYet => 'Jäseniä ei ole vielä valittu.';

  @override
  String get workspaceNoInternetExpenseSavedWithoutReceiptImage => 'Ei internetiä. Kulu tallennetaan ilman kuittikuvaa.';

  @override
  String get workspaceRandomPicker => 'Arvonta';

  @override
  String get workspaceCurrency => 'Valuutta';

  @override
  String get workspaceCategory => 'Luokka';

  @override
  String get workspaceCustomCategory => 'Mukautettu luokka';

  @override
  String get workspaceCategoryName => 'Luokan nimi';

  @override
  String get workspaceApartmentRentParkingEtc => 'Asunnon vuokra, pysäköinti jne.';

  @override
  String get workspaceEnterACustomCategory => 'Syötä mukautettu luokka.';

  @override
  String get workspacePickAnExpenseCategory => 'Valitse kululuokka.';

  @override
  String get workspaceCategoryMustBeAtLeast2Characters => 'Luokan on oltava vähintään 2 merkkiä pitkä.';

  @override
  String get workspaceCategoryMustBeUpTo64Characters => 'Luokan pituus saa olla enintään 64 merkkiä.';

  @override
  String get workspacePercentageSplitMustTotal100 => 'Prosentuaalisen jaon summan on oltava 100 %.';

  @override
  String get workspaceSharesMustBeGreaterThan0ForAllParticipants => 'Jokaisen osallistujan osuuksien määrän on oltava suurempi kuin 0.';

  @override
  String get workspaceTotalAmount => 'Kokonaissumma';

  @override
  String get workspaceOriginal => 'Alkuperäinen';

  @override
  String get workspaceTotalCost => 'Kokonaiskustannukset';

  @override
  String workspaceStarted(Object arg1) {
    return 'Käynnistetty $arg1';
  }

  @override
  String workspaceEnded(Object arg1) {
    return 'Päättynyt $arg1';
  }

  @override
  String get workspaceArchivedTrip => 'Arkistoitu matka';

  @override
  String get workspaceActiveTrip => 'Aktiivinen matka';

  @override
  String get workspaceMemberProfile => 'Jäsenprofiili';

  @override
  String get workspaceTripOwner => 'Matkan järjestäjä';

  @override
  String get workspaceMember => 'Jäsen';

  @override
  String get workspaceReadyForSettlement => 'Valmis maksamiseen';

  @override
  String get workspaceNotReadyForSettlement => 'Ei valmis sovitteluun';

  @override
  String get workspaceBankDetails => 'Pankkitiedot';

  @override
  String get workspaceIbanAndPayoutDetailsWillBeAddedHereInA => 'IBAN-numero ja maksutiedot lisätään tähän seuraavassa päivityksessä.';

  @override
  String get workspacePaymentDetails => 'Maksutiedot';

  @override
  String get workspaceThisMemberHasNotAddedPayoutDetailsYet => 'Tämä jäsen ei ole vielä lisännyt maksutietoja.';

  @override
  String get workspaceBankTransfer => 'Pankkisiirto';

  @override
  String get workspaceHolder => 'Holder';

  @override
  String get workspaceCouldNotOpenPaymentLink => 'Maksulinkkiä ei voitu avata.';

  @override
  String get workspaceTripActivity => 'Matkan toiminta';

  @override
  String get workspacePaidExpenses => 'Maksetut kulut';

  @override
  String get workspacePaidTotal => 'Maksettu kokonaissumma';

  @override
  String get workspaceInvolvedIn => 'Osallistuu';

  @override
  String get workspaceCurrentTrip => 'Nykyinen matka';

  @override
  String get workspaceCommonTrips => 'Yhteiset matkat';

  @override
  String get workspaceLoadingCommonTrips => 'Ladataan yhteisiä matkoja…';

  @override
  String get workspaceNoCommonTripsFoundYet => 'Yhteisiä matkoja ei vielä löytynyt.';

  @override
  String get workspaceCouldNotLoadAllCommonTripsShowingCurrentOne => 'Kaikkia yhteisiä matkoja ei voitu ladata. Näytetään nykyinen matka.';

  @override
  String get workspaceMembers => 'jäsenet';

  @override
  String get workspaceExpense => 'Kulut';

  @override
  String get workspacePaid => 'maksettu';

  @override
  String get workspaceLoadingMoreExpenses => 'Ladataan lisää kuluja...';

  @override
  String get workspaceScrollDownToLoadMore => 'Vieritä alaspäin ladataksesi lisää';

  @override
  String get workspaceTripFinished => 'Matka päättynyt';

  @override
  String get workspaceSettlementsAreUnlockedForThisTrip => 'Maksut on avattu tälle matkalle.';

  @override
  String get workspaceFinishTripToStartSettlements => 'Lopeta matka, jotta maksujen selvitys voi alkaa.';

  @override
  String workspaceMarkedTransferAsSent(Object arg1) {
    return '$arg1 merkitsi siirron lähetetyksi.';
  }

  @override
  String workspaceWaitingForToMarkAsPaid(Object arg1) {
    return 'Odotetaan, että $arg1 merkitsee maksun suoritetuksi.';
  }

  @override
  String workspaceConfirmedReceivingThePayment(Object arg1) {
    return '$arg1 on vahvistanut maksun vastaanottamisen.';
  }

  @override
  String workspaceWaitingForToConfirm(Object arg1) {
    return 'Odotetaan $arg1:n vahvistusta.';
  }

  @override
  String get workspaceAllTripSettlementsAreFullyCompleted => 'Kaikki matkan maksut on suoritettu kokonaan.';

  @override
  String get workspaceFinalStateAfterAllTransfersAreConfirmed => 'Lopullinen tila, kun kaikki siirrot on vahvistettu.';

  @override
  String get workspaceSettlementFlow => 'Maksun käsittelyprosessi';

  @override
  String get workspaceActions => 'Toiminnot';

  @override
  String get workspaceQuickPay => 'Pikamaksu';

  @override
  String get workspacePayWithRevolut => 'Maksa Revolutilla';

  @override
  String get workspacePayWithPaypal => 'Maksa PayPalilla';

  @override
  String get workspacePayWithWise => 'Maksa Wise-palvelulla';

  @override
  String get workspaceTransferIsConfirmed => 'Siirto on vahvistettu.';

  @override
  String get workspaceWaitingForTheOtherMemberToCompleteTheNextStep => 'Odotetaan, että toinen jäsen suorittaa seuraavan vaiheen.';

  @override
  String get workspaceSendReminder => 'Lähetä muistutus';

  @override
  String get workspaceInProgress => 'Käynnissä';

  @override
  String get workspaceTimeUnknown => 'Aika tuntematon';

  @override
  String get workspaceRemind => 'Muistutus';

  @override
  String get workspaceYourPosition => 'Sinun kantasi';

  @override
  String get workspaceRecentActivity => 'Viimeaikainen toiminta';

  @override
  String get workspaceNoRecentActivityYet => 'Ei vielä viimeaikaista toimintaa.';

  @override
  String get workspaceAddAtLeastOneMemberToStartSplittingExpenses => 'Lisää vähintään yksi jäsen, jotta voit aloittaa kulujen jakamisen.';

  @override
  String get workspaceMarkYourselfReadyToSettleAfterAddingAllYourExpenses => 'Merkitse itsesi valmiiksi maksamaan, kun olet lisännyt kaikki kulusi.';

  @override
  String workspaceWaitingForMemberSToMarkReady(Object arg1) {
    return 'Osallistujat, jotka eivät vielä ole valmiita: $arg1.';
  }

  @override
  String get workspaceAllMembersAreReadyYouCanFinishTheTripAnd => 'Kaikki jäsenet ovat valmiina. Voit päättää matkan ja aloittaa maksujen selvityksen.';

  @override
  String get workspaceAllMembersAreReadyWaitingForTheTripOwnerTo => 'Kaikki jäsenet ovat valmiina. Odotetaan matkan järjestäjän aloittavan maksujen käsittelyn.';

  @override
  String workspaceSettlementInProgressConfirmed(Object arg1, Object arg2) {
    return 'Maksun käsittely käynnissä: $arg1 / $arg2 vahvistettu.';
  }

  @override
  String get workspaceNoActionsPendingThisTripIsSettled => 'Ei odottavia toimia. Tämä matka on selvitetty.';

  @override
  String get workspaceNoActionsNeededRightNow => 'Tällä hetkellä ei tarvita mitään toimia.';

  @override
  String workspaceYouShouldReceive(Object arg1) {
    return 'Sinun pitäisi saada $arg1.';
  }

  @override
  String workspaceYouShouldPay(Object arg1) {
    return 'Sinun tulisi maksaa $arg1.';
  }

  @override
  String get workspaceYouAreCurrentlySettledInThisTrip => 'Olet tällä hetkellä mukana tässä matkassa.';

  @override
  String get workspaceUnknownTime => 'Tuntematon aika';

  @override
  String get workspaceJustNow => 'Juuri nyt';

  @override
  String workspaceMinAgo(Object arg1) {
    return '$arg1 min sitten';
  }

  @override
  String workspaceHAgo(Object arg1) {
    return '$arg1 h sitten';
  }

  @override
  String workspaceDAgo(Object arg1) {
    return '$arg1 pv sitten';
  }

  @override
  String get friendsRemoveFriend => 'Poista ystävä';

  @override
  String get friendsRemoveThisFriend => 'Poistetaanko tämä ystävä?';

  @override
  String friendsWillBeRemovedFromYourFriendsListYouCanAdd(Object arg1) {
    return '$arg1 poistetaan ystäväluettelostasi. Voit lisätä hänet uudelleen myöhemmin.';
  }

  @override
  String get friendsContinue => 'Jatka';

  @override
  String get friendsFriendRemoved => 'Ystävä poistettu.';

  @override
  String get friendsCouldNotRemoveFriend => 'Ystävää ei voitu poistaa.';

  @override
  String get friendsFriendProfile => 'Ystävän profiili';

  @override
  String get friendsMoreActions => 'Lisää toimintoja';

  @override
  String get friendsThisFriendHasNotAddedPayoutDetailsYet => 'Tämä ystävä ei ole vielä lisännyt maksutietoja.';

  @override
  String get friendsCouldNotLoadCommonTripsRightNow => 'Yhteisiä matkoja ei voitu ladata juuri nyt.';

  @override
  String get friendsFinished => 'Valmis';

  @override
  String friendsTrip(Object arg1) {
    return 'Matka #$arg1';
  }

  @override
  String friendsMembers(Object arg1) {
    return 'Jäsenet: $arg1';
  }

  @override
  String get friendsNoDate => 'Ei päivämäärää';

  @override
  String get friendsIncomingRequests => 'SAAPUVAT PYYNNÖT';

  @override
  String get friendsSentInvites => 'LÄHETETYT KUTSUT';

  @override
  String get friendsMyFriends => 'YSTÄVÄNI';

  @override
  String get friendsRequests => 'Pyynnöt';

  @override
  String get friendsIncoming => 'Saapuvat';

  @override
  String get friendsIncomingRequestSubtitle => 'haluaa olla ystävä';

  @override
  String get friendsOutgoingInviteSubtitle => 'Kutsu lähetetty';

  @override
  String get friendsNoPendingActivity => 'Ei ystäväpyyntöjä';

  @override
  String friendsInviteSentTo(Object arg1) {
    return 'Kutsu lähetetty $arg1:lle.';
  }

  @override
  String get friendsNoIncomingRequests => 'Ei saapuvia pyyntöjä';

  @override
  String get friendsDecline => 'Hylkää';

  @override
  String get friendsAccept => 'Hyväksy';

  @override
  String get friendsNoSentInvites => 'Ei lähetettyjä kutsuja';

  @override
  String get friendsNoFriendsYet => 'Ei vielä ystäviä';

  @override
  String get friendsScrollDownToLoadMoreFriends => 'Vieritä alaspäin ladataksesi lisää ystäviä.';

  @override
  String get friendsUser => 'Käyttäjä';

  @override
  String get friendsSearchUsers => 'Käyttäjien haku';

  @override
  String get friendsFindByNameOrEmailAndSendInvite => 'Etsi nimen tai sähköpostiosoitteen perusteella ja lähetä kutsu';

  @override
  String get friendsScanQr => 'Skannaa QR-koodi';

  @override
  String get friendsScanAnotherUserToAddFriend => 'Skannaa toinen käyttäjä lisätäksesi hänet ystäväksi';

  @override
  String get friendsMyQr => 'Oma QR-koodi';

  @override
  String get friendsShowOrShareYourQrCode => 'Näytä tai jaa QR-koodisi';

  @override
  String get friendsScanFriendQrTitle => 'Skannaa ystävän QR-koodi';

  @override
  String get friendsPlaceFriendQrInsideFrame => 'Sijoita ystävän QR-koodi kehyksen sisään';

  @override
  String get friendsHoldFriendQrInsideFrame => 'Pidä QR-koodi kehyksen sisällä';

  @override
  String friendsConfirmAddFriendTitle(Object arg1) {
    return 'Lisätäänkö $arg1 ystäväksi?';
  }

  @override
  String friendsConfirmSendFriendInviteText(Object arg1) {
    return '$arg1 saa ystäväpyyntösi.';
  }

  @override
  String friendsConfirmAcceptFriendRequestText(Object arg1) {
    return 'Hyväksytkö $arg1:n ystäväpyynnön?';
  }

  @override
  String get friendsMyFriendQrTitle => 'My Friend QR';

  @override
  String get friendsOpenFriendsScanQrOnAnotherPhoneAndScanThisCode => 'Skannaa tämä QR-koodi tai jaa linkki lisätäksesi minut Splytoon.';

  @override
  String get friendsAddMeOnTripSplitFriends => 'Lisää minut Splytoon.';

  @override
  String get friendsTripSplitFriendCode => 'Splyto-ystävälinkki';

  @override
  String get shareAction => 'Jaa';

  @override
  String get friendsQrCodeIsNotAValidFriendCode => 'QR-koodi ei ole kelvollinen ystäväkoodi.';

  @override
  String get friendsYouCannotAddYourself => 'Et voi lisätä itseäsi.';

  @override
  String get friendsThisUserIsAlreadyInYourFriendsList => 'Tämä käyttäjä on jo ystäväluettelossasi.';

  @override
  String get friendsInviteToThisUserIsAlreadySent => 'Kutsu tälle käyttäjälle on jo lähetetty.';

  @override
  String get friendsFriendRequestProcessed => 'Ystäväpyyntö käsitelty.';

  @override
  String get friendsFailedToProcessFriendQr => 'Ystävän QR-koodin käsittely epäonnistui.';

  @override
  String get friendsCouldNotLoadYourUserProfile => 'Käyttäjäprofiiliasi ei voitu ladata.';

  @override
  String get friendsMyProfile => 'Oma profiili';

  @override
  String get friendsUnexpectedErrorLoadingFriends => 'Ystävien lataamisessa tapahtui odottamaton virhe.';

  @override
  String get friendsFriendAdded => 'Ystävä lisätty.';

  @override
  String get friendsRequestDeclined => 'Pyyntö hylätty.';

  @override
  String get friendsFailedToUpdateRequest => 'Pyynnön päivittäminen epäonnistui.';

  @override
  String get friendsCancelInvite => 'Peruuta kutsu';

  @override
  String friendsCancelInviteTo(Object arg1) {
    return 'Peruutetaanko kutsu $arg1:lle?';
  }

  @override
  String get friendsKeep => 'Säilytä';

  @override
  String friendsInviteToCancelled(Object arg1) {
    return 'Kutsu $arg1:een peruutettu.';
  }

  @override
  String get friendsFailedToCancelInvite => 'Kutsun peruuttaminen epäonnistui.';

  @override
  String get analyticsOther => 'Muu';

  @override
  String get analyticsSelectATripForAnalytics => 'Valitse matka analytiikkaa varten';

  @override
  String analyticsMembers(Object arg1, Object arg2, Object arg3, Object arg4) {
    return '$arg1 • Jäsenet: $arg2 • $arg3 • $arg4';
  }

  @override
  String get analyticsDailySpending => 'Päivittäiset menot';

  @override
  String get analyticsMyDaily => 'Päivittäiset kuluni';

  @override
  String get analyticsGroupDaily => 'Ryhmän päivittäiset kulut';

  @override
  String get analyticsByMember => 'Osallistujittain';

  @override
  String get analyticsShowLess => 'Näytä vähemmän';

  @override
  String get analyticsByCategory => 'Luokittain';

  @override
  String get analyticsQuickInsights => 'Pikakatsaus';

  @override
  String analyticsBiggestExpense(Object arg1, Object arg2) {
    return 'Suurin kulu: $arg1 ($arg2)';
  }

  @override
  String analyticsTopSpender(Object arg1, Object arg2) {
    return 'Eniten kuluttanut: $arg1 ($arg2)';
  }

  @override
  String analyticsHighestGroupDay(Object arg1, Object arg2) {
    return 'Ryhmän ennätyspäivä: $arg1 ($arg2)';
  }

  @override
  String get analyticsNoDates => 'Ei päivämääriä';

  @override
  String get friendsSearchFailedTryAgain => 'Haku epäonnistui. Yritä uudelleen.';

  @override
  String get friendsFailedToSendInvite => 'Kutsun lähettäminen epäonnistui.';

  @override
  String get friendsAddFriend => 'Lisää ystävä';

  @override
  String get friendsSearchByNameOrEmail => 'Hae nimen tai sähköpostiosoitteen perusteella';

  @override
  String get friendsTypeAtLeast2CharactersToSearch => 'Kirjoita hakua varten vähintään 2 merkkiä.';

  @override
  String get friendsNoUsersFound => 'Käyttäjiä ei löytynyt';

  @override
  String get friendsInviteAction => 'Kutsu';

  @override
  String get workspacePaidForGroup => 'Maksettu ryhmä';

  @override
  String workspacePaidForGroupDate(Object arg1) {
    return 'Maksettu ryhmä • $arg1';
  }

  @override
  String get workspaceShareOfExpense => 'Kustannusten jakaminen';

  @override
  String workspaceShareOfExpenseDate(Object arg1) {
    return 'Kustannusten jakaminen • $arg1';
  }

  @override
  String get paymentHolderNameCopied => 'Käyttäjän nimi kopioitu.';

  @override
  String get paymentIbanCopied => 'IBAN kopioitu.';

  @override
  String get paymentSwiftCopied => 'SWIFT kopioitu.';

  @override
  String get paymentRevtagCopied => 'Revtag kopioitu.';

  @override
  String get paymentCouldNotCopyToClipboard => 'Kopiointi leikepöydälle epäonnistui.';

  @override
  String get paymentCopied => 'Kopioitu.';

  @override
  String get paymentRequestAction => 'Pyydä maksua';

  @override
  String get paymentRecordAction => 'Tallenna maksu';

  @override
  String get paymentRequestSheetTitle => 'Pyydä maksua';

  @override
  String get paymentRecordSheetTitle => 'Tallenna maksu';

  @override
  String paymentRequestSheetBody(Object arg1) {
    return 'Pyydä $arg1:tä maksamaan summa, jonka hän on sinulle tällä hetkellä velkaa.';
  }

  @override
  String paymentRecordSheetBody(Object arg1) {
    return 'Käytä tätä, kun olet maksanut $arg1:lle Splyton ulkopuolella. He vahvistavat maksun vastaanottamisen.';
  }

  @override
  String paymentMaxAmount(Object arg1) {
    return 'Enintään $arg1';
  }

  @override
  String get paymentNoteHint => 'Pankkisiirto, Revolut, käteinen...';

  @override
  String get paymentAmountPositiveError => 'Summan on oltava suurempi kuin nolla.';

  @override
  String get paymentAmountTooHighError => 'Summa ei voi olla suurempi kuin maksamaton saldo.';

  @override
  String get paymentRequestCreated => 'Maksupyyntö lähetetty.';

  @override
  String get paymentRecordedWaiting => 'Maksu kirjattu. Odotetaan vahvistusta.';

  @override
  String get paymentConfirmTitle => 'Vahvista maksu';

  @override
  String paymentConfirmText(Object arg1, Object arg2) {
    return 'Vahvista, että olet vastaanottanut maksun, jonka summa on $arg1 ja lähettäjä $arg2.';
  }

  @override
  String get paymentConfirmedMessage => 'Maksu vahvistettu.';

  @override
  String get paymentCancelRecordTitle => 'Peruuta maksutietue';

  @override
  String paymentCancelRecordText(Object arg1, Object arg2) {
    return 'Perutaanko merkintä maksustasi, jonka summa on $arg1 ja saaja $arg2?';
  }

  @override
  String get paymentRecordCancelled => 'Maksutapahtuma peruutettu.';

  @override
  String get paymentNotReceivedTitle => 'Maksua ei ole vastaanotettu';

  @override
  String paymentNotReceivedText(Object arg1, Object arg2) {
    return 'Merkitäänkö $arg1-maksu $arg2:lta vastaanottamattomaksi?';
  }

  @override
  String get paymentMarkedNotReceived => 'Maksu on merkitty vastaanottamattomaksi.';

  @override
  String get paymentActivityTitle => 'Maksutoiminta';

  @override
  String paymentOpenRequestsCount(Object arg1) {
    return 'Avoimet maksupyynnöt: $arg1';
  }

  @override
  String paymentAwaitingConfirmationCount(Object arg1) {
    return 'Vahvistusta odottavat maksut: $arg1';
  }

  @override
  String get paymentRecordedPaymentsTitle => 'Kirjatut maksut';

  @override
  String paymentRequestedFrom(Object arg1, Object arg2) {
    return '$arg1 pyysi maksua $arg2:lta';
  }

  @override
  String paymentPaidTo(Object arg1, Object arg2) {
    return '$arg1 maksoi henkilölle $arg2';
  }

  @override
  String get paymentRequestPendingStatus => 'Maksua pyydetty';

  @override
  String get paymentAwaitingConfirmationStatus => 'Odottaa vahvistusta';

  @override
  String get paymentReviewRequestAction => 'Tarkista pyyntö';

  @override
  String get paymentViewDetailsAction => 'Maksutiedot';

  @override
  String get paymentMarkPaidAction => 'Olen maksanut';

  @override
  String get paymentDeclineAction => 'Hylkää';

  @override
  String get paymentRequestReviewTitle => 'Maksupyyntö';

  @override
  String paymentRequestReviewBody(Object arg1, Object arg2) {
    return '$arg1 pyysi sinulta $arg2. Maksa Splyton ulkopuolella ja merkitse maksu sitten maksetuksi.';
  }

  @override
  String get paymentRequestMarkPaidConfirmTitle => 'Merkitäänkö pyyntö maksetuksi?';

  @override
  String paymentRequestMarkPaidConfirmText(Object arg1, Object arg2) {
    return 'Vahvista vasta, kun olet maksanut $arg1:n $arg2:lle Splyton ulkopuolella.';
  }

  @override
  String get paymentRequestMarkedPaid => 'Merkitty maksetuksi. Odotetaan vahvistusta.';

  @override
  String get paymentRequestCancelTitle => 'Peruuta maksupyyntö?';

  @override
  String paymentRequestCancelText(Object arg1, Object arg2) {
    return 'Haluatko peruuttaa $arg1-pyyntösi $arg2:lle?';
  }

  @override
  String get paymentRequestCancelled => 'Maksupyyntö peruutettu.';

  @override
  String get paymentRequestDeclineTitle => 'Hylätä maksupyyntö?';

  @override
  String paymentRequestDeclineText(Object arg1, Object arg2) {
    return 'Hylätäänkö henkilön $arg2 lähettämä maksupyyntö, jonka summa on $arg1? Hänelle lähetetään ilmoitus.';
  }

  @override
  String get paymentRequestDeclined => 'Maksupyyntö hylätty.';

  @override
  String get paymentPendingBeforeFinish => 'Selvitä avoimet maksupyynnöt ja vahvistamattomat maksut ennen lopullista tilitystä.';

  @override
  String get paymentFinishBlockedByPending => 'Maali avautuu, kun maksupyynnöt ja vahvistamattomat maksut on ratkaistu.';

  @override
  String get notificationPaymentRequestedTitle => 'Maksua pyydetty';

  @override
  String notificationPaymentRequestedBody(Object arg1, Object arg2) {
    return '$arg1 pyysi sinulta $arg2.';
  }

  @override
  String get notificationPaymentRequestedBodyGeneric => 'Olet saanut maksupyynnön.';

  @override
  String get notificationPaymentRequestSentTitle => 'Pyydetty maksu lähetetty';

  @override
  String notificationPaymentRequestSentBody(Object arg1, Object arg2) {
    return '$arg1 merkitsi $arg2-maksupyyntösi maksetuksi.';
  }

  @override
  String get notificationPaymentRequestSentBodyGeneric => 'Maksupyyntösi on merkitty maksetuksi.';

  @override
  String get notificationPaymentRequestCancelledTitle => 'Maksupyyntö peruutettu';

  @override
  String notificationPaymentRequestCancelledBody(Object arg1, Object arg2) {
    return '$arg1 peruutti $arg2-maksupyynnön.';
  }

  @override
  String get notificationPaymentRequestCancelledBodyGeneric => 'Maksupyyntö peruutettiin.';

  @override
  String get notificationPaymentRequestDeclinedTitle => 'Maksupyyntö hylätty';

  @override
  String notificationPaymentRequestDeclinedBody(Object arg1, Object arg2) {
    return '$arg1 on hylännyt $arg2-maksupyyntösi.';
  }

  @override
  String get notificationPaymentRequestDeclinedBodyGeneric => 'Maksupyyntösi hylättiin.';

  @override
  String get notificationPaymentSentTitle => 'Maksu merkitty lähetetyksi';

  @override
  String notificationPaymentSentBody(Object arg1, Object arg2) {
    return '$arg1 merkitsi $arg2:n sinulle maksetuksi.';
  }

  @override
  String get notificationPaymentSentBodyGeneric => 'Maksu on merkitty sinulle lähetetyksi.';

  @override
  String get notificationPaymentConfirmedTitle => 'Maksu vahvistettu';

  @override
  String notificationPaymentConfirmedBody(Object arg1, Object arg2) {
    return '$arg1 on vahvistanut vastaanottaneensa $arg2 sinulta.';
  }

  @override
  String get notificationPaymentConfirmedBodyGeneric => 'Maksusi on vahvistettu.';

  @override
  String get notificationPaymentCancelledTitle => 'Maksu peruutettu';

  @override
  String notificationPaymentCancelledBody(Object arg1, Object arg2) {
    return '$arg1 peruutti $arg2-maksumerkinnän.';
  }

  @override
  String get notificationPaymentCancelledBodyGeneric => 'Maksumerkintä peruutettiin.';

  @override
  String get notificationPaymentNotReceivedTitle => 'Maksua ei ole vastaanotettu';

  @override
  String notificationPaymentNotReceivedBody(Object arg1, Object arg2) {
    return '$arg1 merkitsi $arg2-maksun vastaanottamattomaksi.';
  }

  @override
  String get notificationPaymentNotReceivedBodyGeneric => 'Maksu on merkitty vastaanottamattomaksi.';

  @override
  String get quickStartTitle => 'Pikaopas';

  @override
  String get quickStartCreateTitle => 'Luo matka';

  @override
  String get quickStartCreateBody => 'Valitse nimi ja valuutta. Hoida omat kulusi itse tai jaa kustannukset ryhmän kanssa.';

  @override
  String get quickStartInviteTitle => 'Matkusta yhdessä tai yksin';

  @override
  String get quickStartInviteBody => 'Kutsu ystäviä mukaan matkallesi tai aloita henkilökohtainen matka yksin.';

  @override
  String get quickStartExpenseTitle => 'Lisää ensimmäinen kulusi';

  @override
  String get quickStartExpenseBody => 'Syötä summa, valitse maksaja ja jaa kustannukset. Saldojesi tiedot pysyvät ajan tasalla.';

  @override
  String get quickStartNext => 'Seuraava';

  @override
  String get quickStartBack => 'Takaisin';

  @override
  String get quickStartSkip => 'Ohita';

  @override
  String get quickStartCreateAction => 'Luo matka';

  @override
  String get quickStartClose => 'Sulje Pikaopas';

  @override
  String get quickStartSubtitle => 'Katso, miten matkat ja kulut toimivat';

  @override
  String quickStartStep(int step, int total) {
    return 'Vaihe $step / $total';
  }

  @override
  String get workspaceTripTotal => 'Matkan kokonaissumma';

  @override
  String get workspacePersonalTotal => 'Kokonaiskulut';

  @override
  String get workspaceBalanceEven => 'Saldosi on tasattu';

  @override
  String workspaceBalanceOwe(String amount) {
    return 'Olet velkaa $amount';
  }

  @override
  String workspaceBalanceReceive(String amount) {
    return 'Saat takaisin $amount';
  }

  @override
  String workspaceMemberCount(int count) {
    return 'Jäsenet: $count';
  }

  @override
  String get workspaceSearchExpenses => 'Hae kuluja';

  @override
  String get workspaceClearSearch => 'Selkeä haku';

  @override
  String get workspaceSearchLoadedHint => 'Haku kattaa ladatut kulut. Lataa lisää, jos haluat sisällyttää vanhempia kuluja.';

  @override
  String get workspaceNoExpenseMatches => 'Ei vastaavia kuluja';

  @override
  String get workspaceNoExpenseMatchesBody => 'Kokeile toista hakua tai tyhjennä haku nähdäksesi kaikki ladatut kulut.';

  @override
  String get workspaceEmptyPersonalExpenses => 'Lisää ensimmäinen kulusi aloittaaksesi kulujen seurannan.';

  @override
  String get workspaceEmptyGroupExpenses => 'Lisää ensimmäinen jaettu kulusi nähdäksesi kaikkien osuudet.';

  @override
  String get workspaceLoadMoreExpenses => 'Lataa lisää kuluja';

  @override
  String workspaceOriginalExpenseAmount(String amount) {
    return 'Alkuperäinen summa: $amount';
  }

  @override
  String workspaceCommentCount(int count) {
    return 'Kommentit: $count';
  }

  @override
  String get workspaceExpenseActions => 'Kulujen käsittely';

  @override
  String get workspaceLoadErrorTitle => 'Tätä matkaa ei voitu ladata';

  @override
  String get workspaceCachedWarning => 'Tallennettujen tietojen näyttäminen. Tiedot voivat olla vanhentuneita.';

  @override
  String get workspaceActivityTab => 'Toiminta';

  @override
  String get workspaceLoadingTrip => 'Matkan lataaminen';

  @override
  String get workspaceRefreshFailed => 'Päivitys epäonnistui';

  @override
  String get expenseDetailsTitle => 'Kulutiedot';

  @override
  String get expenseQuickCategories => 'Pikaluokat';

  @override
  String get expenseReceiptRead => 'Kuitin lukeminen ja lomakkeen päivittäminen.';

  @override
  String get expenseReceiptNoData => 'Kuitti liitteenä. Selkeää summaa, päivämäärää tai kauppiasta ei löytynyt.';

  @override
  String get expenseReceiptScanFailed => 'Kuitta valittu. Automaattinen lukeminen epäonnistui; tarkista kentät manuaalisesti.';

  @override
  String get expenseReceiptOffline => 'Kuitti ladataan, kun tallennat. Automaattinen lukeminen edellyttää verkkoyhteyttä.';

  @override
  String get expenseReadingReceipt => 'Luetaan kuittia…';

  @override
  String get expenseCommentsLoadFailed => 'Kommentteja ei voitu ladata. Yritä uudelleen.';

  @override
  String get expenseReplyAction => 'Vastaa';

  @override
  String get expenseReplyHint => 'Kirjoita vastaus…';

  @override
  String expenseReplyTo(String name) {
    return 'Vastaa $name';
  }

  @override
  String get balanceEmptyBody => 'Saldot näkyvät, kun kulut on lisätty.';

  @override
  String get balanceAfterPayments => 'Saldot sisältävät vahvistetut maksut.';

  @override
  String get balanceExpenseShare => 'Kulujen jakaminen';

  @override
  String get balanceHistoryScope => 'Kirjatut kulut ja vahvistetut maksut. Tämä luettelo ei välttämättä sisällä koko matkahistoriaa.';

  @override
  String balancePaymentTo(String name) {
    return 'Maksu $name:lle';
  }

  @override
  String balancePaymentFrom(String name) {
    return 'Maksu lähettäjältä $name';
  }

  @override
  String get settlementEmptyActive => 'Merkitse kaikki valmiiksi ennen lopullisten tilitysten aloittamista.';

  @override
  String get settlementEmptyClosed => 'Tälle matkalle ei ole lueteltu yhtään rahansiirtoa.';

  @override
  String settlementConfirmedCount(int count, int total) {
    return '$count / $total siirtoa vahvistettu';
  }

  @override
  String settlementReadyCount(int count, int total) {
    return '$count / $total jäsentä valmiina';
  }

  @override
  String get settlementMemberReady => 'Valmis';

  @override
  String get settlementMemberNotReady => 'Ei valmis';

  @override
  String get settlementSuggested => 'Ehdotettu siirto';

  @override
  String get activityLoadFailed => 'Toimintaa ei voitu päivittää. Näkyvät merkinnät voivat olla vanhentuneita.';

  @override
  String get activityMember => 'Matkan osallistuja';

  @override
  String get friendsEmptyBody => 'Etsi ystävä nimen tai sähköpostiosoitteen perusteella tai käytä QR-koodia.';

  @override
  String get friendsDeclineAction => 'Hylkää';

  @override
  String get friendsLoading => 'Ystävien lataaminen';

  @override
  String friendsCommonTripsCount(int count) {
    return 'Jaetut matkat: $count';
  }

  @override
  String get memberActivityScope => 'Perustuu syötettyihin kuluihin; tämä ei välttämättä kata koko matkaa.';

  @override
  String get sharedTripsLoadedLimit => 'Näytetään enintään 20 jaettua matkaa.';

  @override
  String get memberRemoveTitle => 'Poistetaanko jäsen?';

  @override
  String memberRemoveBody(String name) {
    return 'Poistetaanko $name tästä matkasta? Tämä on mahdollista vain, jos hänellä ei ole kuluja, tilityksiä tai saldoja.';
  }

  @override
  String get memberRemoveAction => 'Poista matkalta';

  @override
  String memberRemoved(String name) {
    return '$name on poistettu matkalta.';
  }

  @override
  String get profilePaymentNotAdded => 'Ei vielä lisätty';

  @override
  String get friendRelationshipLabel => 'Ystävä';

  @override
  String get sharedTripsEmptyBody => 'Matkanne, joihin molemmat osallistutte, näkyvät tässä.';

  @override
  String get analyticsAllTrips => 'Kaikki matkat';

  @override
  String get analyticsByTrip => 'Matkan mukaan';

  @override
  String get analyticsYourSpending => 'Omat kulut';

  @override
  String get analyticsActiveArchived => 'Aktiiviset ja arkistoidut matkat';

  @override
  String get analyticsTrips => 'Matkan';

  @override
  String get analyticsAveragePerTrip => 'Keskimääräinen matkaa kohti';

  @override
  String get analyticsPaidByMember => 'Jäsen maksaa';

  @override
  String get analyticsYouPaid => 'Sinä maksoit.';

  @override
  String get analyticsYouGetBack => 'Saat takaisin';

  @override
  String get analyticsYouOwe => 'Olet velkaa';

  @override
  String get analyticsParticipants => 'Osallistujat';

  @override
  String get analyticsYourCategories => 'Kulutuksesi luokittain';

  @override
  String get analyticsLargestShares => 'Suurimmat kuluosuuteni';

  @override
  String get analyticsLargestExpenses => 'Suurimmat kulut';

  @override
  String get analyticsSpendingByTrip => 'Kulut matkaa kohden';

  @override
  String get analyticsEmptyTitle => 'Ei vielä kuluja';

  @override
  String get analyticsEmptyBody => 'Kulut näkyvät tässä, kun lisäät kuluja matkaan.';

  @override
  String get analyticsPeriodEmptyBody => 'Tätä näkymää ei veloiteta. Kokeile toista matkaa tai ajanjaksoa.';

  @override
  String get analyticsLoadFailed => 'Koko kuluraporttia ei voitu ladata. Yritä uudelleen.';

  @override
  String get analyticsLastLoaded => 'Näytetään viimeisin onnistuneesti ladattu raportti.';

  @override
  String analyticsExpenseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kulua',
      one: '$count kulu',
    );
    return '$_temp0';
  }

  @override
  String get tripOptionsTitle => 'Matka-asetukset';

  @override
  String get editTripAction => 'Muokkaa matkaa';

  @override
  String get deleteTripAction => 'Poista matka';

  @override
  String get inviteTripMembersAction => 'Kutsu jäseniä';

  @override
  String get tripCoverPhoto => 'Kansikuva';

  @override
  String get tripInviteLaterHint => 'Voit kutsua ihmisiä matkan luomisen jälkeen.';

  @override
  String get inviteClipboardFailed => 'Leikepöytää ei voitu käyttää. Yritä uudelleen.';

  @override
  String get friendInviteToTrip => 'Kutsu matkalle';

  @override
  String get friendChooseTrip => 'Valitse matka';

  @override
  String get friendNoInvitableTrips => 'Käytettävissä olevia matkoja ei ole. Voit kutsua ystäviä hallinnoimiisi aktiivisiin ryhmämatkoihin, elleivät he ole jo jäseniä tai heillä ole odottavaa kutsua.';

  @override
  String get friendTripInviteSent => 'Kutsu lähetetty.';

  @override
  String get friendTripUnavailable => 'Tätä matkaa ei voi enää käyttää tähän toimintoon. Päivitä sivu ja yritä uudelleen.';

  @override
  String get friendTripActionFailed => 'Toimintoa ei voitu suorittaa. Yritä uudelleen.';

  @override
  String get profileContactDescription => 'Onko sinulla ongelma, ehdotus tai kysymys Splytosta? Lähetä meille sähköpostia – autamme mielellämme.';

  @override
  String get profileContactEmailAction => 'Kirjoita sähköpostiviesti';

  @override
  String get profileContactEmailUnavailable => 'Sähköpostisovellusta ei voitu avata. Kopioi osoite ja kirjoita meille sähköpostisovelluksestasi.';

  @override
  String get profilePrivacyPolicy => 'Tietosuojakäytäntö';

  @override
  String get privacyLoadFailed => 'Tietosuojakäytäntöä ei voitu ladata. Yritä uudelleen.';

  @override
  String get addReceiptAction => 'Lisää kuitti';

  @override
  String get receiptPickFailed => 'Kuittia ei voitu ladata. Yritä uudelleen.';

  @override
  String get receiptPhotoAccessDenied => 'Salli Splytolle pääsy kameraan tai valokuvakirjastoon Asetuksissa ja yritä sitten uudelleen.';

  @override
  String get receiptPhotoLabel => 'Kuitin kuva';

  @override
  String get replaceReceiptAction => 'Korvaa kuitti';

  @override
  String get removeReceiptAction => 'Poista kuitti';

  @override
  String get restoreReceiptAction => 'Palauta edellinen kuitti';

  @override
  String get expenseSplitBetween => 'Jaa seuraavasti';

  @override
  String get expenseEditParticipants => 'Valitse osallistujat';

  @override
  String get expenseCustomSplit => 'Mukautettu jakaminen';

  @override
  String expenseSplitAllocated(String amount) {
    return 'Koko $amount jaettu';
  }

  @override
  String expenseSplitRemaining(String amount) {
    return 'Jäljellä jaettava summa: $amount';
  }

  @override
  String expenseSplitOver(String amount) {
    return '$amount yli kokonaissumman';
  }

  @override
  String get profilePaymentSharingTitle => 'Jaa maksutavat matkoilleni';

  @override
  String get profilePaymentSharingDescription => 'Salli luomieni matkojen ja niiden matkojen, joihin liityn, hyväksyttyjen osallistujien nähdä maksutapani. Tämä koskee nykyisiä ja tulevia matkoja. Voit poistaa jakamisen käytöstä milloin tahansa estääksesi tietojen katselun jatkossa.';

  @override
  String get memberPaymentDetailsNotShared => 'Maksutapoja ei jaeta tai ne eivät ole tällä hetkellä käytettävissä.';

  @override
  String get homeTripInvitations => 'Matkakutsut';

  @override
  String get homeNoTripInvitations => 'Ei odottavia matkakutsuja';

  @override
  String get homeInvitationsLoadFailed => 'Kutsuja ei voitu ladata. Yritä uudelleen.';

  @override
  String get homeInvitationResponseFailed => 'Kutsuun ei voitu vastata. Yritä uudelleen.';

  @override
  String get homeTripShareFailed => 'Matkaa ei voitu jakaa. Yritä uudelleen.';

  @override
  String get settleStillToReceive => 'Vielä saamatta';

  @override
  String get settleStillToPay => 'Vielä maksamatta';

  @override
  String get settleEstimateCaption => 'Arvio perustuu nykyisiin kuluihin. Summat voivat muuttua ennen matkan päättymistä.';

  @override
  String get settleOutstandingCaption => 'Odotetaan maksua tai vahvistusta.';

  @override
  String get settleWaitingForYou => 'Odotamme, että merkitset olevasi valmis.';

  @override
  String get settleWhoPaysWhom => 'Kuka maksaa kenelle';

  @override
  String get settlePreviewCaption => 'Esikatselu · viimeistellään matkan päättyessä';

  @override
  String get settleOpenPaymentCaption => 'Avaa maksu nähdäksesi yksityiskohdat ja käytettävissä olevat toiminnot.';

  @override
  String get tripBudgetEnable => 'Aseta budjetti';

  @override
  String get tripBudgetSoloHint => 'Valinnainen kulutustavoite tälle matkalle.';

  @override
  String get tripBudgetGroupHint => 'Yksi jaettu budjetti koko ryhmälle.';

  @override
  String get tripBudgetAmount => 'Budjetin määrä';

  @override
  String get tripBudgetInvalid => 'Syötä summa väliltä 0,01–999999999,99, enintään kahden desimaalin tarkkuudella.';

  @override
  String get tripBudgetTitle => 'Matkan budjetti';

  @override
  String get tripBudgetGroupTitle => 'Ryhmän budjetti';

  @override
  String get tripBudgetRemaining => 'Jäljellä';

  @override
  String get tripBudgetOver => 'Yli budjetin';

  @override
  String get tripBudgetSpent => 'Käytetty';

  @override
  String get tripBudgetLimit => 'Budjetti';

  @override
  String get travelMapTitle => 'Matkakarttani';

  @override
  String get travelMapSubtitle => 'Käydyt paikat, juuri sinulle.';

  @override
  String get travelMapHere => 'Olen ollut täällä';

  @override
  String get travelMapAdd => 'Lisää paikka';

  @override
  String get travelMapSearch => 'Hae kaupunki ja maa';

  @override
  String get travelMapSearchAction => 'Haku';

  @override
  String get travelMapSearchHint => 'Esimerkiksi Lissabon, Portugali';

  @override
  String get travelMapEmpty => 'Seuraava muistosi alkaa tästä';

  @override
  String get travelMapEmptyBody => 'Lisää kaupunki, jossa olet käynyt, tai kirjaudu sisään nykyiseen sijaintiisi.';

  @override
  String get travelMapConfirm => 'Tallennetaanko tämä vierailu?';

  @override
  String get travelMapConfirmBody => 'Tarkista kaupunki ja päivämäärä ennen kuin tallennat ne yksityiselle kartallesi.';

  @override
  String get travelMapDate => 'Vierailupäivä';

  @override
  String get travelMapSave => 'Tallenna kartalleni';

  @override
  String get travelMapCancel => 'Peruuta';

  @override
  String get travelMapClose => 'Sulje';

  @override
  String get travelMapNoResults => 'Kaupunkia ei löytynyt. Kokeile lisätä maata hakuun.';

  @override
  String get travelMapLookupError => 'Kaupunkia ei löytynyt. Tarkista yhteytesi tai lisää paikka manuaalisesti.';

  @override
  String get travelMapDenied => 'Sijainnin käyttöoikeus on pois päältä. Voit silti lisätä kaupungin manuaalisesti.';

  @override
  String get travelMapDisabled => 'Ota sijaintipalvelut käyttöön tai lisää kaupunki manuaalisesti.';

  @override
  String get travelMapError => 'Matkakarttaa ei voitu ladata. Yritä uudelleen.';

  @override
  String get travelMapSaveError => 'Vierailua ei voitu tallentaa. Yritä uudelleen.';

  @override
  String get travelMapUnavailable => 'Matkakartta vaatii palvelinpäivityksen.';

  @override
  String get travelMapOffline => 'Offline · tallennettujen paikkojen näyttäminen';

  @override
  String get travelMapRetry => 'Yritä uudelleen';

  @override
  String get travelMapDelete => 'Poista vierailu';

  @override
  String get travelMapDeleteConfirm => 'Poistetaanko tämä vierailu yksityiseltä kartaltasi?';

  @override
  String get travelMapFit => 'Näytä kaikki paikat';

  @override
  String get travelMapSaved => 'Käy tallennetussa';

  @override
  String get travelMapVisited => 'Käyty';

  @override
  String get travelMapLimit => 'Karttasi on saavuttanut 1 000 käyntiä. Poista vanha käynti ennen uuden lisäämistä.';

  @override
  String travelMapCounts(int countries, int cities) {
    String _temp0 = intl.Intl.pluralLogic(
      countries,
      locale: localeName,
      other: '$countries maata',
      one: '$countries maa',
    );
    String _temp1 = intl.Intl.pluralLogic(
      cities,
      locale: localeName,
      other: '$cities kaupunkia',
      one: '$cities kaupunki',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String travelMapVisits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vierailua',
      one: '$count vierailu',
    );
    return '$_temp0';
  }

  @override
  String get travelTripDestinations => 'Kohteet (valinnainen)';

  @override
  String get travelAddDestination => 'Lisää määränpää';

  @override
  String get travelRemoveDestination => 'Poista määränpää';

  @override
  String get travelFromTrip => 'Matkan näkökulmasta';

  @override
  String get travelChooseTrip => 'Valitse matka';

  @override
  String get travelNoTrips => 'Matkoja ei ole vielä saatavilla. Voit lisätä paikan manuaalisesti.';

  @override
  String get travelAddToMap => 'Lisää kartalleni';

  @override
  String get travelTripConfirm => 'Tallenna vain paikat, joissa olet todella käynyt. Tämä lisää yksityisen muiston kartallesi.';

  @override
  String get travelVisitTitle => 'Otsikko (valinnainen)';

  @override
  String get travelAddPhoto => 'Lisää valokuva';

  @override
  String get travelChangePhoto => 'Vaihda valokuva';

  @override
  String get travelRemovePhoto => 'Poista valokuva';

  @override
  String get travelPhotoError => 'Tätä valokuvaa ei voitu valmistella. Valitse toinen.';

  @override
  String get travelEditVisit => 'Muokkaa vierailua';

  @override
  String get travelOpenTrip => 'Avoin matka';

  @override
  String get travelPreviousVisit => 'Edellinen vierailu';

  @override
  String get travelNextVisit => 'Seuraava vierailu';

  @override
  String get travelDuplicate => 'Tämä vierailu on jo kartallasi.';

  @override
  String get liveMapTitle => 'Reaaliaikainen kartta';

  @override
  String get liveShareTitle => 'Jaa sijaintini';

  @override
  String get liveConsent => 'Jaa tarkka sijaintisi vain tämän matkan hyväksytyille osallistujille valitsemaksesi ajaksi. Jakaminen jatkuu taustalla, ja voit lopettaa sen milloin tahansa.';

  @override
  String get liveBackgroundNote => 'Päivitykset voivat keskeytyä ilman internetyhteyttä tai jos suljet sovelluksen pakotetusti. Vain viimeisin sijainti tallennetaan; reittihistoriaa ei tallenneta.';

  @override
  String get liveStart => 'Aloita jakaminen';

  @override
  String get liveStop => 'Lopeta jakaminen';

  @override
  String get liveNotification => 'Sijaintisi jaetaan matkaseurueellesi. Avaa Splyto lopettaaksesi jakamisen.';

  @override
  String get livePermissionError => 'Salli sijainnin käyttö puhelimen asetuksissa, jotta voit jakaa sijaintisi.';

  @override
  String get liveStartError => 'Jakamista ei voitu aloittaa. Tarkista sijainnin käyttöoikeudet, internetyhteys sekä puhelimesi päivämäärä ja kellonaika.';

  @override
  String get liveStopPending => 'Päivitykset on keskeytetty. Odotetaan internetyhteyttä viimeisen sijaintisi poistamiseksi; se katoaa kartalta 2 minuutin kuluessa ilman päivityksiä.';

  @override
  String get liveSharing => 'jakaa sijaintia';

  @override
  String get liveUnavailable => 'Tätä reaaliaikaista karttaa ei ole saatavilla. Palaa matkaan ja päivitä sivu.';

  @override
  String get liveMapLoadError => 'Karttaa ei voitu ladata. Tarkista verkkoyhteytesi ja avaa kartta uudelleen.';

  @override
  String get liveLoadError => 'Sijainteja ei voitu päivittää. Vain viimeisimmät päivitykset näytetään.';

  @override
  String get liveFit => 'Näytä kaikki kartalla';

  @override
  String get liveEmpty => 'Kukaan ei vielä jaa viimeaikaista sijaintiaan.';

  @override
  String get liveRecent => 'Juuri päivitetty';

  @override
  String get liveLastKnown => 'Viimeksi päivitetty';

  @override
  String get liveAccuracy => 'Tarkkuus';

  @override
  String get liveUntil => 'Jakaminen kestää';

  @override
  String get liveOtherSession => 'Aloitettu toisessa istunnossa. Voit lopettaa sen täällä.';

  @override
  String get liveUpdatesPaused => 'Päivitykset keskeytetty. Tarkista sijainnin käyttöoikeudet ja internetyhteys.';

  @override
  String get livePrivateUntilShared => 'Sijaintisi pysyy yksityisenä, kunnes päätät jakaa sen.';

  @override
  String get activityEventExpenseCreated => 'lisätty kulu';

  @override
  String get activityEventExpenseUpdated => 'päivitetty kulu';

  @override
  String get activityEventExpenseDeleted => 'kustannus poistettu';

  @override
  String get activityEventTripCreated => 'loi matkan';

  @override
  String get activityEventTripUpdated => 'päivitetyt matkatiedot';

  @override
  String get activityEventTripMembersAdded => 'lisätyt jäsenet';

  @override
  String activityEventTripMembersInvited(int count) {
    return 'lähetetyt kutsut: $count';
  }

  @override
  String get activityEventTripMemberJoined => 'liittyi matkaan';

  @override
  String get activityEventTripInvitationDeclined => 'hylkäsi matkakutsun';

  @override
  String get activityEventTripInvitationRevoked => 'matkakutsun peruuttaminen';

  @override
  String activityEventTripMemberRemoved(String name) {
    return '$name on poistettu matkalta';
  }

  @override
  String get activityEventTripMemberLeft => 'poistui matkalta';

  @override
  String activityEventTripMemberRoleUpdated(String name, String role) {
    return '$name:n rooli muutettiin rooliksi $role';
  }

  @override
  String get activityEventTripMemberReady => 'merkitty valmiiksi maksettavaksi';

  @override
  String get activityEventTripMemberNotReady => 'merkitty ei valmis';

  @override
  String get activityEventTripAllMembersReady => 'Kaikki jäsenet ovat valmiita maksamaan';

  @override
  String get activityEventTripFinished => 'matka päättynyt';

  @override
  String get activityEventSettlementMarkedSent => 'merkitsi siirron lähetetyksi';

  @override
  String get activityEventSettlementConfirmed => 'vahvisti siirron';

  @override
  String get activityEventSettlementSentCancelled => 'peruutettu lähetetty tila';

  @override
  String get activityEventSettlementNotReceived => 'merkitsi siirron vastaanottamattomaksi';

  @override
  String get activityEventSettlementReminderSent => 'lähetti maksumuistutuksen';

  @override
  String get activityEventPaymentMarkedSent => 'kirjasi maksun';

  @override
  String get activityEventPaymentRequested => 'pyysi maksua';

  @override
  String get activityEventPaymentRequestMarkedSent => 'merkitsi pyydetyn maksun lähetetyksi';

  @override
  String get activityEventPaymentRequestCancelled => 'peruutti maksupyynnön';

  @override
  String get activityEventPaymentRequestDeclined => 'hylkäsi maksupyynnön';

  @override
  String get activityEventPaymentConfirmed => 'vahvisti maksun';

  @override
  String get activityEventPaymentCancelled => 'peruutettu maksutapahtuma';

  @override
  String get activityEventPaymentNotReceived => 'merkitsi maksun vastaanottamattomaksi';

  @override
  String get activityEventUnknown => 'tehty muutos';

  @override
  String get privacyEnglishFallback => 'Tietosuojakäytäntö on tällä hetkellä saatavilla englanniksi.';

  @override
  String get activityRoleAdmin => 'Järjestelmänvalvoja';

  @override
  String get accountDeleteTitle => 'Poista tili';

  @override
  String get accountDeleteIntro => 'Vahvista poistaminen sähköpostitse. Vahvistuksen jälkeen sitä ei voi perua.';

  @override
  String get accountDeleteConsequences => 'Poisto on lopullinen. Profiilisi anonymisoidaan ja pääsy tilillesi poistetaan. Jaetut matka- ja kulutiedot säilytetään muiden jäsenten käyttöön.';

  @override
  String get accountDeleteReasonsTitle => 'Mitä olisimme voineet tehdä paremmin?';

  @override
  String get accountDeleteReasonsHint => 'Syy (vapaaehtoinen)';

  @override
  String get accountDeleteReasonNotUsing => 'En enää tarvitse Splytoa matkoillani';

  @override
  String get accountDeleteReasonAnotherWay => 'Hallinnoin jaettuja kuluja toisella tavalla';

  @override
  String get accountDeleteReasonComplicated => 'Asioiden hoitaminen vaatii liikaa vaivaa';

  @override
  String get accountDeleteReasonTechnical => 'Olen kohdannut virheitä tai teknisiä ongelmia';

  @override
  String get accountDeleteReasonPrivacy => 'Haluaisin poistaa tilitietoni';

  @override
  String get accountDeleteReasonOther => 'Haluan poistaa tilini muusta syystä';

  @override
  String get accountDeleteEmailStep => 'Seuraava vaihe on vahvistus sähköpostitse.';

  @override
  String get accountDeletePasswordHint => 'Syötä nykyinen Splyto-salasanasi pyytääksesi vahvistussähköpostia. Tilisi on edelleen aktiivinen.';

  @override
  String get accountDeleteInboxTitle => 'Vielä yksi vaihe sähköpostilaatikossasi';

  @override
  String accountDeleteSentBody(String email) {
    return 'Vahvistuslinkki lähetetty osoitteeseen $email.';
  }

  @override
  String get accountDeleteSentHint => 'Tilisi pysyy aktiivisena, kunnes vahvistat poistamisen.';

  @override
  String get accountDeleteSending => 'Vahvistussähköpostin lähettäminen';

  @override
  String get friendsShowMore => 'Näytä lisää';
}
