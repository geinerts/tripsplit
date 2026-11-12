# App Review notes (App Store Connect)

Paste the block below into App Store Connect → App Review Information → Notes.
Replace the demo account placeholders in the Sign-In Information fields, never here.
The demo account needs a **group trip with at least one other accepted member**,
because the live map exists only in active group trips.

Facts checked against the code on 2026-11-12 (`docs/api/live-location.md`,
`mobile/lib/features/live_location/`, `ios/Runner/Info.plist`). Update this text if
live location changes.

---

Splyto is a travel expense app for solo trips and groups. Sign in with the demo account provided in the Sign-In Information.

Background location (UIBackgroundModes: location)

Splyto has an optional "Live map" in group trips, so friends travelling together can find each other for a short time (for example, when meeting up in a city).

- It is off by default. Opening the map does not request location.
- The user starts it themselves: Trip → Live map → Share my location → choose 15 minutes, 1 hour, 4 hours or 8 hours → Start sharing. The consent screen explains that sharing continues in the background until it ends or is stopped.
- Only the accepted members of that one trip can see the location. Pending invitations, friends and other trips cannot.
- Sharing stops automatically when the chosen time ends (the server enforces the end time), and the user can stop it at any time with "Stop sharing". Logging out, leaving the trip or finishing the trip also stops it.
- Background updates are needed because travellers lock their phone or switch apps while walking to the meeting point; without them the location would freeze as soon as the screen locks.
- The app asks only for "When In Use" permission, never "Always". Updates start while the app is in the foreground, and iOS shows the blue location indicator for the whole time sharing is active.
- Only the latest position is kept on the server and it disappears from the map 2 minutes after the last update. No route or location history is stored, and location is never used for advertising or tracking.

The other location use is optional: suggesting the current city when the user adds a place to their private travel map (When In Use only, one-time).

How to try it: open the demo group trip → Live map → Share my location → pick 15 minutes → Start sharing. The blue indicator appears; tap "Stop sharing" to end it.

Account deletion: Profile → Delete account.
