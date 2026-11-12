# App Privacy answers (App Store Connect)

For App Store Connect → App Privacy. Checked on 2026-11-12 against `privacy.html`
(effective 11 November 2026), the API, the mobile code and the privacy manifests of
the bundled iOS SDKs (MapboxCommon, MapboxMaps, GoogleSignIn, Sentry). Update this
file and `privacy.html` together whenever data collection changes.

## First question

**Do you or your third-party partners collect data from this app?** → **Yes**

**Tracking:** answer **No** for every data type. Nothing is combined with other
companies' data for advertising, and no data goes to data brokers. No App Tracking
Transparency prompt is needed. (All SDK manifests declare `NSPrivacyTracking = false`.)

## Data types to select

"Linked" = linked to the user's identity. Purposes are the App Store Connect options.

| Category → Data type | Linked | Purposes | Why |
| --- | --- | --- | --- |
| Contact Info → **Name** | Yes | App Functionality | Account name/nickname; name from Apple/Google sign-in |
| Contact Info → **Email Address** | Yes | App Functionality | Account, sign-in, verification and password emails |
| Financial Info → **Other Financial Info** | Yes | App Functionality | Optional account holder, IBAN, BIC, Revolut/PayPal/Wise for paying friends back |
| Location → **Precise Location** | Yes | App Functionality, Analytics | Live location sharing (opt-in, time-limited); Mapbox SDK telemetry (anonymous, analytics) |
| Location → **Coarse Location** | Yes | App Functionality, Analytics | Visited cities on the private travel map; Mapbox SDK telemetry |
| User Content → **Photos or Videos** | Yes | App Functionality | Profile photo, trip covers, visit photos, receipts |
| User Content → **Other User Content** | Yes | App Functionality | Trips, expenses, comments, reactions, settlements, travel map entries |
| Identifiers → **User ID** | Yes | App Functionality, Analytics | Splyto account ID, Apple/Google account identifier; Mapbox anonymous telemetry ID |
| Identifiers → **Device ID** | Yes | App Functionality | App installation identifier and push token |
| Usage Data → **Product Interaction** | Yes | App Functionality, Analytics | Trip activity history; first-party daily active counts in the admin panel; Mapbox telemetry |
| Usage Data → **Other Usage Data** | No | Analytics | Mapbox SDK telemetry |
| Diagnostics → **Performance Data** | No | Analytics | Mapbox SDK telemetry |
| Diagnostics → **Other Diagnostic Data** | Yes | App Functionality, Analytics | Server request logs (IP, time, device and app version) for errors and abuse protection; Mapbox telemetry |

App Store Connect asks once per data type. Where one source is linked (for example
live location) and another is not (Mapbox telemetry), answer **Linked: Yes** and
select all purposes that apply, as in the table.

## Do not select

| Data type | Reason |
| --- | --- |
| Phone Number, Physical Address, Other Contact Info | Not collected. GoogleSignIn's manifest lists a phone number for Google's own sign-in; Splyto receives only name, email and the account identifier. |
| Payment Info, Credit Info | No cards or bank logins; no purchases in the app. |
| Health, Fitness, Sensitive Info, Contacts | Not collected; the address book is never read. |
| Emails or Text Messages, Audio, Gameplay | Not collected. Comments are "Other User Content". |
| Customer Support | In-app feedback is no longer reachable in this version; support email is outside the app. |
| Browsing History, Search History | Friend search is not stored as a history. |
| Purchases | No in-app purchases yet. Add when paid Premium launches. |
| Advertising Data | No ads. |
| Crash Data | Sentry SDK is built in, but release builds have no DSN, so nothing is sent. If a DSN is ever added, declare Crash Data, Performance Data and Other Diagnostic Data (App Functionality) and update `privacy.html`. |
| Other Data Types | — |

## Privacy policy URL

`https://splyto.eu/privacy.html`

## Things to keep consistent

- `privacy.html` says "no third-party analytics". Mapbox's own anonymous telemetry is
  why Analytics appears above; the policy already mentions Mapbox and its "i" opt-out.
  Mapbox's terms do not allow switching the telemetry off for everyone.
- Adding Sentry, paid Premium, new providers or new personal data means updating this
  file, `privacy.html` (with its effective date) and App Store Connect together.
