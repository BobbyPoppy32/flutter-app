# Alongside: overnight changes

The app used to be "Senior App". It is now **Alongside**: checked local volunteers who help older people get to doctor's check-ups, scans and X-rays, and blood or lab tests, pick up their medicine, give rides to appointments, or simply come along. Three roles share one device-local world, seeded so that every screen has something on it the first time it opens:

- **Senior:** Margaret Chu, 79, uses a walker and is hard of hearing.
- **Volunteer:** Daniel Okafor, a retired school librarian with a car.
- **Family:** Lena Chu, Margaret's daughter.

## How to run it

```bash
/Users/_abrahamli/Development/flutter/bin/flutter pub get
/Users/_abrahamli/Development/flutter/bin/flutter run -d "iPhone 16 Pro"
```

1. On the first screen, tap **Look around with sample people**.
2. Pick who to be. **Sign out** under Profile takes you back to choose someone else.
3. **Get started** creates your own local account instead. A new volunteer can't see any request until their checks pass. On Find, the prototype has a **Pretend my checks have passed** button.

Checks:

```bash
/Users/_abrahamli/Development/flutter/bin/flutter analyze
/Users/_abrahamli/Development/flutter/bin/flutter test
/Users/_abrahamli/Development/flutter/bin/flutter drive --driver=test_driver/integration_test.dart --target=integration_test/walkthrough_test.dart -d A2FFC444-ABBC-47A8-84C4-2965A12B5BC5
```

The last command taps through every main screen on the iPhone 16 Pro simulator, including 200% text and dark mode, and writes the screenshots to `docs/screenshots/`.

## The court verdict and what it changed

The idea was put on trial with `.claude/skills/court` and a full jury of 12. The full verdict is in [`docs/court-verdict.md`](docs/court-verdict.md).

**The jury found it guilty, 10 to 2.** These charges stuck:

- No volunteer vetting (7 jurors).
- No insurance (5 jurors).
- No supply side, and no fallback when nobody turns up (4 jurors).

The two not-guilty votes (the Engineer and the Designer) both said these are things to add before launch, not reasons to stop building the prototype. The judge's sentence was: "keep building the prototype, but stop calling it a matching service until it has a gate."

How each condition shaped the build:

| Verdict condition or objection | What the app now does |
| --- | --- |
| Put a vetting gate in the flow: a volunteer cannot **see or accept** any request until checks pass | `AppState.openFor()` returns nothing for an unchecked volunteer. The gate is in the data layer, not only on the screen. Find shows "Your checks come first" with the checklist: photo ID, background check with its date, two references, and a safety and dignity course. A widget test covers this. |
| Ride insurance | Rides are hidden from any volunteer without a car whose insurance has been checked (`Vetting.carInsured`). Seniors see "Car insurance checked" on the volunteer's profile. |
| What happens if nobody accepts | Every request has a backup deadline: a day before, or halfway there for short notice. It's stated when the request is sent. Once it passes, Home shows "Nobody has said yes yet" with buttons to call family (or, for the family member, to call the senior). One seeded request is past its deadline so you can see this. |
| What happens if a volunteer doesn't show up | The volunteer taps **I'm still coming** the day before and **I'm at the door** (available from an hour before). If they're 10 minutes late, the senior and family see "Daniel hasn't arrived yet" with Call buttons. **I can't make it** reopens the request, tells the senior, and marks it "Their volunteer had to drop out" for other volunteers. |
| Trust at the door | A four-digit door code is shown to both sides: "Daniel will show you this number. If it doesn't match, don't open the door." |
| Privacy of health details | Before saying yes, a volunteer sees only the kind of help, the time, "Harold P.", the area and distance, and mobility needs. The place, full name, phone number and notes are shared after they accept. A widget test covers this. Notes on the form say "Only the volunteer who says yes sees your notes." |
| Family involvement (the Parent and First-Time Customer jurors) | A **family** role (Lena) follows Margaret's visits, gets the same alerts, can call Margaret or the volunteer, and can ask for help on her behalf. Margaret can turn this off in Profile ("Lena can follow my visits"). |
| Accountability after the visit | Seniors rate the visit (five 52dp stars with words, plus an optional note), and a rating of 1–2 offers **Report a problem**. Report a problem is also on every visit. Ratings and notes show on the volunteer's public profile. |
| Partner organisation, launch area, funding | Not app work. These are left for the owner (see "Left unfinished"). |

## Art direction (taste-skill, app-screens mode)

`draw.mjs --app --kind workspace --keep palette,type` was run with seed `1106281488`. It dealt **Editorial greeting**, which I chose over Achromatic ledger because Alongside is a personal home people glance at, not a money screen. The move: the greeting is the h1 and carries today's one fact, which is built from the data ("Daniel is helping with your lab test on Thursday 5 November at 9:40 am"). Figures sit on tonal panels.

- **Palette kept.** The brand hues in `constants.dart` are unchanged: teal `#0A7A6E`, mint `#EDF6F3`, ink `#1F2933`, muted `#5C6370`, red `#CC3B3B`. They are now mapped onto roles in a `ThemeExtension` (`AppPalette`) with a real dark version, which fixes the gap flagged in the style lock: dark mode used to ignore every custom colour. Every text pair was checked with the WCAG formula. The lowest is 4.74:1 (teal text on mint). Status pills are 6.6:1 or better in light and 8.3:1 or better in dark.
- **What taste-skill made me remove.** I removed the teal gradients (hero banner, buttons, category tiles), the shadows on resting cards, and the icons in tinted squares. Structure now comes from tone (white ground, mint panels) and the accent is kept to the one primary action and key data. That is the strong reason the palette's *use* changed, while the colours stayed.
- **Type changed.** Fredoka and Nunito are replaced by **Atkinson Hyperlegible**, which the Braille Institute designed for low-vision readers, for all text, and **Fraunces** (a warm serif) for greetings and titles only. Fredoka read as childish for this audience. The fonts are bundled as assets (OFL licences in `assets/fonts/`), so `google_fonts` and runtime font downloads are gone. Body text is 18, and nothing is under 15.
- **Signature element.** The visit is drawn as a journey ("You asked", "Daniel said yes", "Daniel at your door", "Visit done"). The welcome screen draws the same idea as a line from a house to a clinic (`RouteMotif`, drawn in code, animated once, still when Reduce Motion is on).

## Changes by area

### Screens (`lib/views/pages/`)

- **Onboarding** (`welcome_page.dart`):
  - Welcome has a "Is this easy to read? Smaller / Bigger" text-size control on the very first screen.
  - "Continue as …" appears for accounts already on the phone.
  - **Who are you?** offers three roles.
  - A short sign-up (name, phone). The volunteer version explains the checks.
  - **Look around with sample people** signs straight into a demo person.
- **Senior home** (`senior_home_page.dart`):
  - Greeting and today's one fact.
  - **Ask for help**.
  - Backup or no-show alerts with call buttons.
  - The next visit, with the volunteer, door code and Call / Message.
  - Also coming up.
  - "If something is wrong", with a red **Call Lena** button.
- **Ask for help** (`request_flow_page.dart`):
  - One question per screen, with "Step n of 5", a labelled **Back** and kept answers.
    1. What: six big rows.
    2. When: day chips for the next 7 days, then "A later day" (four weeks as a list, not a calendar grid). Then "My appointment is at" with −/+ 15 minute buttons, not a wheel picker.
    3. Where: the senior's home address, the place, and "Places you've been before".
    4. Anything we should know: needs pre-ticked from the profile, plus notes.
    5. Check and send: each row has **Change**, which returns to the summary.
  - A sent screen says what happens next.
  - Leaving mid-way asks "Stop asking for help?".
- **My visits / Visit detail** (`visits_page.dart`, `visit_detail_page.dart`):
  - Coming up and Past.
  - Status pills.
  - The volunteer with **Checks passed**, rating and visit count. Tapping it opens their profile.
  - Door code, Call and Message, the journey timeline, and what the volunteer knows.
  - Rating after a visit, Report a problem, and Cancel (with a confirmation that says who will be told).
- **Volunteer profile** (`volunteer_profile_page.dart`): bio, languages, car, visits, average rating and people helped (all computed), "What we checked" with dates, and "What people said".
- **Volunteer home** (`volunteer_home_page.dart`):
  - The next visit with the one action that applies right now (I'm still coming / I'm at the door / Visit done) and I can't make it.
  - Also coming up.
  - Open requests near you.
  - "What you've given": visits, hours and people, computed from completed visits.
- **Find** (`find_requests_page.dart`):
  - The vetting gate.
  - A filter summary that opens a sheet: kind of help, distance (2/5/10 km) and when (today, next 3 days, this week).
  - Request cards with time, "Margaret C., 1.8 km away" and needs.
- **Volunteer request** (`volunteer_request_page.dart`):
  - Privacy before accepting.
  - Say yes (with a confirmation naming who will be told).
  - After accepting: full details, a door code to show, and Message first when the senior is hard of hearing.
  - The lifecycle actions.
  - **Visit done** asks "Is Eleanor home safely?" and takes an optional note for the senior.
- **Family home** (`family_home_page.dart`): Margaret's next visit and alerts, Ask for help for Margaret, and Call Margaret. If Margaret has turned sharing off, it respects that.
- **Profile** (`profile_page.dart`): role-specific details. Seniors have details, someone to call, usual needs and the family-sharing switch. Volunteers have their checks and history links. Profile also has an edit page, Settings, and Sign out (confirmed).
- **Settings** (`settings_page.dart`): a text-size slider from 100% to 200% with a live preview sentence, Dark screen, and "Start the sample visits again".

### Components (`lib/views/widgets/`)

- `app_widgets.dart`:
  - `Panel`, the only container. Secondary buttons inside it switch to the ground colour on their own so they still read as buttons.
  - `ScreenTitle`, `SectionHeading`, `PrimaryButton` (60dp, flat teal, or red with `danger`) and `SecondaryButton` (tonal pill).
  - `StatusPill`: a tint plus ink plus a glyph, so status never relies on colour alone.
  - `Avatar`: initials, with stable tints reused from the contrast-checked status pairs.
  - `VettedBadge`, `InfoLine`.
  - `ChoiceTile`: radio, checkbox or navigation. Selection shows a thick border, a tint and a filled tick.
  - `ChipChoice` (52dp chips), `EmptyState`, `StarRating`, `PageBody` and `StaggeredEntrance`.
- `visit_widgets.dart`: `JourneyTimeline`, `VisitCard`, `StatStrip` (stacks at large text), `ContactButtons`, `confirmAction` (a bottom sheet that says who will be told), `showDone`, and `RouteMotif`.
- `format.dart`: dates spelled out in full ("Thursday 5 November at 9:40 am", "today", "tomorrow"), sentence phrases, icons per help type, and `contact()`, which opens the phone or messages app or shows the number when the device can't.

### Theme (`lib/data/constants.dart`, `lib/main.dart`)

- An `AppPalette` theme extension with light and dark roles, and `context.palette`.
- `AppText` (Fraunces titles, Atkinson body) and `AppRadius` (cards 20, rows 14, round buttons).
- `buildTheme()` themes every Material control from the palette: buttons, inputs with labels above the value, sheets, the nav bar, switches, the slider and the date picker.
- The in-app text size multiplies the phone's own setting, capped at 2x.

### Data and models (`lib/data/`)

- `HelpType` has the six kinds of help in the senior's words, plus a description and a noun for use mid-sentence. `RequestStatus` is open, matched, with you, done and cancelled, with senior and volunteer wording. `MobilityNeed` has six needs.
- `Vetting` tracks the ID, background check date, references, training and car insurance.
- `HelpRequest` gained:
  - duration, address and distance;
  - needs;
  - volunteer, confirmed, checked-in and completed times;
  - rating and note, a volunteer note, a problem report;
  - door code and dropped-by;
  - `backupDeadline`, `needsBackup()` and `isNoShow()`.
- `AppState`:
  - accounts (demo and own), sign-in and sign-out;
  - requests with accept, confirm, check-in, complete, withdraw, cancel, rate and report;
  - the vetting gate;
  - computed volunteer stats;
  - reset to the sample data.
- The seed writes 13 people and 19 requests, spread from six weeks back to two weeks ahead and relative to the first launch, so the dates always look current.
- Storage keys were bumped to v2, so old on-device data from the previous model is ignored rather than mis-read. The theme and text-size settings keep their old keys.

### Tests

- `test/widget_test.dart` has 10 tests, all passing:
  - the app boots;
  - **the senior request flow** end to end, with validation, the ±15 min time, Change from the summary and the saved request;
  - **the volunteer accept flow**, with privacy before and full details after;
  - the vetting gate, with rides hidden without insurance;
  - the visit lifecycle and drop-out reopening;
  - backup and no-show timing, based on the door time;
  - persistence across a restart;
  - day labels across a daylight-saving change;
  - the gate held inside `accept()`, with past requests dropping out of every list;
  - family can't see visits once sharing is off.
- `integration_test/walkthrough_test.dart` with `test_driver/integration_test.dart` is the simulator walkthrough that produced `docs/screenshots/`.

### Accessibility

- Text scales to 200% (in-app control × system setting). Every row wraps, side-by-side stats stack, and buttons grow. The bottom tab labels alone are capped at 150%, because four labels can't sit side by side at 2x.
- Touch targets are at least 48dp: primary buttons 60, secondary 56, chips 52, rows 64, stars 52 and time buttons 60.
- AA contrast on every text pair, light and dark. Disabled controls keep readable muted text instead of fading out.
- No hidden gestures: every action is a labelled button, and swipe-to-anything is never required. Back is a labelled button in the request flow.
- Screen reader labels:
  - headers are marked;
  - the journey steps say "Done / Now / Not yet";
  - the door code is read digit by digit;
  - each star has a label ("4 stars, Very good");
  - selection state is on tiles and chips;
  - error messages are live regions.
- Reduce Motion turns off the list entrances, the tab cross-fade and the welcome drawing.
- Plain words throughout: "Finding a volunteer", "Checks passed", "Is this easy to read?".

### Agent reviews and what they changed

The verdict and the reviews were run with the bundled agents, each given its file as its role. Their notes are in the shared notes folder: `ux-architect.md`, `ui-designer.md`, `code-review.md`, `a11y-audit.md`, `persona-walkthrough.md` and `finish-gate.md`.

- **UX Architect** (flows): led to these changes.
  - The vetting gate lives in the data layer, not only on the screen.
  - "I'm still coming" is separate from "I'm at the door".
  - No-show and missed-backup alerts carry call buttons.
  - Confirmation sheets say who will be told.
  - The time is set with ±15 min buttons instead of a wheel picker, and the day is chosen from a list instead of a calendar.
  - Privacy before accept.
  - Report a problem.
  - Text size is offered on the very first screen.
- **UI Designer** (components): led to these changes.
  - Tonal secondary buttons.
  - Avatar tints reused from the checked status pairs.
  - Underlined text actions.
  - The step header.
  - The journey timeline spec.
- **Code Reviewer**, which found 3 blockers, all fixed:
  - "I can't make it" on Home popped the root route.
  - Day maths broke across daylight saving.
  - The family Visits tab ignored the senior's privacy switch.

  Also fixed from the same review:
  - Past requests now expire from every list.
  - `accept()` re-checks the gate.
  - The finish sheet owns its text controller.
  - Profile fields can be cleared.
  - Send is guarded against double taps.
  - The time is re-checked at send.
  - Unreadable saved data reseeds instead of hanging on launch.
  - Resetting the samples keeps your own requests.
- **Section 508 specialist** (no blockers): led to these changes.
  - Each request step scrolls to the top and is announced to VoiceOver.
  - Border tokens darkened to 3.3:1 or better (WCAG 1.4.11).
  - The place error sits on its field.
  - Confirmations stay 8 seconds and can be closed.
  - "This phone can't make calls" is a dialog showing the number.
  - The slider has a name.
  - Tappable cards read as one item.
  - "Change" links keep their tap action.
  - Header flags were added.
  - Every sheet has a "Go back" button.
  - Quick time choices were added (8:00 am–3:00 pm), and the time is a VoiceOver adjustable.
  - The duplicate Settings title was removed.
- **Persona walkthroughs** (Dorothy, 82, low vision; Marcus, 34, nurse): led to these changes.
  - The **door time** is now separate from the appointment time: 45 minutes before an appointment, or 30 minutes after a pharmacy pickup. It shows on Home, the visit, the summary and the volunteer's screens, and check-in and no-show are timed from it.
  - "Rated 4.7 by 3 people" replaces a visit count that clashed with the profile.
  - When there's no family contact, "Add someone to call" appears.
  - Find cards show the length, "needs a car" and "Needed soon: nobody has said yes".
  - Medicine visits finish with "Has Harold got the medicine?".
  - Old messages are cleared when switching tabs.
- **UI Finish-Gate Reviewer** (PASS WITH FIXES): led to these changes.
  - One labelled "Back" pattern on every screen (`PageAppBar`).
  - No duplicate "Call Margaret".
  - Seeded times rounded to the quarter hour.
  - Danger buttons look the same everywhere.
  - Icons and the "+" scale with text, to 1.5x.
  - Titles capped at 1.5x.
  - A calmer, deeper teal for the dark-mode primary.
  - Secondary buttons and chips get a visible edge.

### Removed code and packages

- Pages:
  - `login_page.dart`: the email and password login. There's no server, so passwords added nothing. It's replaced by role sign-up and "Continue as".
  - `role_selection_page.dart`, `helpers_page.dart` (browsing companions, which seniors don't need), `companion_home_page.dart` and `companion_requests_page.dart`.
  - `senior_requests_page.dart` and `request_help_form_page.dart`.
  - The old `senior_home_page.dart`, rewritten from scratch.
- Widgets: `hero_widgets.dart` (gradient hero), `help_category_grid.dart`, `wellness_tip_card.dart` (off-topic), `upcoming_request_card.dart`, `emergency_contact_card.dart`, `role_picker.dart`, `navbar_widgets.dart` (floating pill nav), `task_type_icons.dart` and `request_date_format.dart`. These were folded into the new components.
- Assets: `assets/lotties/welcome.json` (a house being built, unrelated to the subject) and the unused `assets/images/bg.jpg`.
- Packages: `google_fonts` and `lottie`. `integration_test` and `flutter_driver` (both from the Flutter SDK) were added as dev dependencies. No third-party package was added.
- Models: the old `companion` role became `volunteer`, and the old help types (house care, quality food) are out of scope.
- `.claude/` is removed from the branch (`git rm -r --cached .claude`). It stays gitignored, along with `.court/` and `.taste-skill/`.

### After the live walkthrough

Four problems found while tapping through the app in the simulator, now fixed:

- **Family wording.** Lena used to read "comes to your door" and "Daniel will show you this number" about Margaret's door. These lines now name the senior when family is looking (`familyView` and `doorOf` in `format.dart`). A widget test covers it.
- **Next button.** It is now pinned to the bottom of each request step. Before, it sat under the list on step 1, and you had to scroll to find it.
- **Icons at large text.** Button, tile, card and chevron icons now grow with the text, capped at 1.5x like titles. Before, they stayed small at 200%.
- **Needs.** On a request, a volunteer now sees the needs from the request and from the senior's profile together. Before, "No mobility needs listed" could sit next to "Margaret is hard of hearing".

### After the second court trial

A 12-juror trial (`docs/court-verdict-app-test.md`) asked whether the app is ready for a supervised test with real people. The verdict was GUILTY, 8 to 4. The charge every guilty juror relied on was that the app promises things nobody does. Every such line now says only what the app does:

- **Report a problem.** "A coordinator will call you" is now "Your report is saved with this visit. If you need help now, call someone you trust", followed by the emergency-number line. A `shortcut:` comment marks where a real coordinator goes once one exists.
- **"We'll tell you" and "will be told".** These now say where to look. "You'll see a warning on your Home screen, and so will Lena". "Margaret and Lena will see it's you in the app". "Other volunteers can see the request again". "The day before, come back here to confirm."

The verdict's other two conditions are for the owner, not the code: a one-page test plan with a named facilitator, and a signed consent step.

## Decisions I made on my own

- **Name:** "Alongside", from "someone to come along with me". The iOS display name is changed; the bundle id is left as `com.example.flutterApp`.
- **One fact under the greeting** instead of a dashboard. The senior home answers "what happens next, and is it sorted?".
- **No passwords.** Local accounts plus "Continue as" on this phone. A real build needs proper sign-in on a server.
- **The volunteer's day-before check** ("I'm still coming") is separate from "I'm at the door". The UX Architect review pointed out that one early check-in would tell Margaret "Volunteer is with you" the night before.
- **"Step 2 of 5" is shown as text,** even though taste-skill bans index numbering. For this audience, knowing how much is left matters more.
- **Five-star ratings kept** (the UX review suggested Good / Not good). The task asks for ratings. Each star is labelled in words and low ratings lead to Report a problem.
- **Material outline icons kept** (the finish gate asked for drawn glyphs). taste-skill's app-screen rules allow one outline icon set, in grey or ink, with no tinted containers. For older readers the icon next to the time and the place speeds up scanning. Drawing a custom set is a good next step, not a fix.
- **"Dorothy needs a pickup time she can choose"**: the door time is computed (appointment minus 45 minutes) rather than asked for. One fewer question to answer, and it's shown everywhere so it can be checked.
- **Filters kept** (the UX review said they could be skipped). The task asks for them. They live in one summary row that opens a sheet, so the list still starts on the first screen.
- **The reminders switch was removed.** There's no notification package, and a switch that does nothing would mislead.
- **The bottom tab labels are capped at 150% text size** (see Accessibility).
- **A family member who signs up** is linked to the sample senior Margaret, because there's no server to find a real relative on.
- **Distances** are one seeded number per senior, not geocoded (`shortcut:` comment in `models.dart`).
- **Seeded people, phone numbers (555), places and reviews are samples.** Proof is never invented outside the sample world: the ratings and "What people said" come from the seeded visits themselves.

## Left unfinished, or for the owner

- **The verdict's business conditions:** name a launch area and a partner (a clinic or volunteer centre) whose volunteers are already checked and insured, and write down who pays for the backend, the checks and ride insurance. The app no longer promises a coordinator after a problem report; it only saves the report. A real coordinator is still needed before real visits.
- **A backend.** Requests only live on this phone, so a senior and a volunteer on two phones can't meet yet. The vetting gate, privacy and alerts are in `AppState` and would move to the server.
- **Real notifications** (the day-before reminder, family alerts). They appear in the app, not as push notifications.
- **Real calls and messages** only work on a phone. The simulator shows the number instead.
- **Sample dates are set at first launch.** If the app sits for a day, the "today" visit becomes a past one. Settings → **Start the sample visits again** re-dates everything to now.
- **VoiceOver was not tested on a device.** The semantics were reviewed in code and checked in widget tests, not listened to.
- **Body text stops at 200%.** iOS's largest accessibility sizes go to about 310%.
- **The emergency number** depends on the launch area, so the app says "call your local emergency number".
- The **live simulator panel** in the Claude app needed a one-time "Let Claude use it" approval that couldn't be given overnight. The app was therefore installed and driven with `xcrun simctl` and `flutter drive` on the same iPhone 16 Pro simulator, and it's left running there.
