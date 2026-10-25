# Duo layout adaptation — 2026-10-24

Implemented against Xcode 27.1 / iOS 27.1 (24A94232), using the iPhone Duo simulator.

## Behavior

- The shared page scaffold uses a scrolling side navigation at 700 available logical pixels, accounting for system safe areas. Compact windows keep the raised Expenses bottom action. This is based on usable width, not a device name or orientation.
- The body stays in the same element-tree slot across navigation changes, preserving page state and drafts when the device folds. Content receives its available width after the navigation rail and safe-area padding.
- Forms use a centered maximum width of 720 logical pixels. Large trip cover pickers use a 360-pixel preview, preserving the crop aspect ratio.
- Open trip forms now use two columns at 680 available pixels: cover on the left, fields and a matching-width submit action on the right. Compact forms stack the same elements vertically. The same Flex tree retains field focus, text selection and draft state across the breakpoint; the open form avoids stretching the action to the entire screen width.
- Follow-up for the closed Duo trip form: iOS 27.1's active occlusion regions provide the actual camera/status bounds. The create/edit trip header remains beside that region; the form and submit action use a centered full-width area below it. This replaces the previous full-height right gutter in that form. Other pages retain their standard side-safe layout.
- Native geometry is checked against the current Flutter window before use. Unsupported OS versions, unavailable channels and very short keyboard layouts fall back to the usual safe area. The header can scroll at large text sizes without squeezing out the submit action.
- Trip overview puts the cover and summary side by side at 640 content pixels; the scrolling trip content is capped at 1040 pixels.
- The welcome illustration and onboarding text sit side by side on wide windows. Text remains scrollable at short heights and large text sizes. Account-choice controls wrap without horizontal overflow.
- Sheets use system top/side safe areas, default to at most 640 logical pixels, and allow the child to shrink within the available height.

## Validation

- 285 selected widget/regression tests passed across navigation, home, analytics, friends, profile, trip forms, workspace, input pages and shell.
- After the final sheet-height change, 174 tests passed across sheets, quick start, notifications and workspace; all 5 dedicated Duo tests passed again, including an oversized sheet.
- Dedicated tests resize between 466×678, 951×669, 669×951 and short landscape; check draft/state retention, keyboard clearance, asymmetric right safe areas and 200% text scaling.
- Targeted analysis of shared scaffolds, navigation, sheets, welcome, trip forms and new tests: no issues. Full-project analysis reports 19 existing findings outside the newly changed logic; these were not silently suppressed.
- Debug simulator build succeeded. Native Device Hub checks: open and closed Home navigation, create-trip form, and Friends selection retained across folding.
- Closed-form follow-up: 49 tests passed across dedicated Duo layouts, trip forms and workspace input forms, including centered fields/buttons, status-region clearance, keyboard clearance, folding draft retention and the unavailable-native-channel fallback.
- Open-form follow-up: 51 tests passed in the same suites, adding column alignment and focused-field/selection preservation through folding with keyboard insets at normal and 200% text sizes. Simulator inspection confirms the open two-column form.

## Scope and remaining limits

Simulator account has no trips, so populated workspace data was verified using widget-test fixtures rather than creating production trips. No claims of physical Duo hardware verification, exhaustive external sign-in/camera testing or App Review approval. No TestFlight archive or version bump was produced. The generated promotional images are not real screenshots of this adapted interface.

Apple reference: https://developer.apple.com/iphone-duo/prepare/
