# Style lock — Senior App (Flutter)

Established: 2026-08-30. Source: reference image `~/Desktop/original-c6c0c56db1a8bf8ecb5275e73c178043.webp` (an "ElderNet" senior-care app mockup — mint/teal gradients, pill buttons, arch-shaped photo frames, icon-grid tiles), extracted deterministically with `scripts/extract_palette.py`. Note: `DESIGN.md` in the project root (Apple's web design system, from the awesome-design-md collection) was added separately as a restraint/rhythm reference at the user's request — it is a CSS/web spec, not this project's token source; this lock is authoritative for the Flutter app.

This is an **app-shell** project (persistent bottom-tab shell over Home/Profile, pushed forms/settings) — not a marketing site. Sections below that only apply to marketing pages (macrostructure, narrative arc, section-padding tiers) are omitted per the format's own guidance.

## Palette

This project uses **two roles per brand hue** — a design decision made mid-pass after auditing real usage (see Color contract below for why): a darker **text/icon/border** variant used directly on light backgrounds (links, outlined labels, icons, focus rings — ~30 call sites across the app), and a brighter **fill** variant used only as a solid/gradient fill, always paired with dark foreground content on top. Collapsing these into one value either breaks the many text-role usages (if kept bright) or muddies the brand's actual reference color on every button (if kept dark) — two roles is what lets both stay correct.

- Background: `#FFFFFF` → `#E9F8F4` (soft mint) vertical gradient (`AppColors.backgroundGradient`) — page background
- Surface: `#FFFFFF` (`Colors.white`) — cards/panels (`SoftCard`, request cards, form cards)
- Primary (text/icon/border role): `#0A7A6E` (`AppColors.tealStart`) — links, outlined button labels, icons, focus borders, active nav state
- Primary (fill role): `#12B8A6` → `#4FD1C5` (`AppColors.tealFillStart`/`tealFillEnd`, i.e. `AppColors.primaryGradient`) — the reference image's actual bright mint/teal, used only as the CTA/hero gradient fill, always paired with dark (`textDark`) foreground content
- Emergency (text/icon/border role): `#CC3B3B` (`AppColors.emergencyRed`) — labels, icons, focus borders, the Cancel/Log-out text buttons
- Emergency (fill role): `#F27070` (`AppColors.emergencyFill`) — the lighter reference-accurate coral, used only for the emergency Call button's solid fill, paired with dark foreground text
- Accent: `#4F8FF0` (`AppColors.blueAccent`) — used sparingly, icon-only (background-check tile); not currently used as a text or fill color
- Text primary: `#1F2933` (`AppColors.textDark`) — contrast vs background: 14.76:1 (AA pass); also the foreground used on both fill colors above
- Text muted: `#5C6370` (`AppColors.textGrey`) — contrast vs mint surface: 5.53:1 (AA pass, was 4.42:1/fail before this pass) — **not** legible against either fill color (2.43:1 / 3.24:1 against the teal fill's two stops), so hero/CTA subtitles use full-opacity `textDark` at a lighter weight for hierarchy instead of a lightened tint
- Dark mode: a dark `ColorScheme` is generated at runtime via `ColorScheme.fromSeed(seedColor: tealStart, brightness: dark)` in `main.dart` (Material 3 auto-derivation), toggled from Settings. This is *not* an author-time companion palette re-verified against the contract above — it's Flutter's own M3 harmonization. Known gap: the custom `AppColors` constants (used directly in many widgets instead of `Theme.of(context).colorScheme`) do not adapt to dark mode at all. Flagged, not fixed in this pass.

## Color contract

Verified with `scripts/check_contrast.py` (single-pair checks per role, since this project has two brand hues each with two roles rather than one flat 7-role matrix):

- **Text-safe (≥4.5:1):** text/bg (14.76), text/surface (13.49), tealStart/bg (5.92 — as text on white), emergencyRed/bg (4.93 — as text on white), textDark/tealFillStart (5.92 — dark text on bright fill), textDark/tealFillEnd (7.91), textDark/emergencyFill (5.15), textGrey/surface (6.05), statusCompleted/bg (5.47), statusCancelled/bg (4.83)
- **UI-safe (≥3.0, <4.5):** bg/blueAccent (3.22 — icon-only use)
- **Decorative/failed, must not be used (<4.5 where 4.5 is required):** white text on `tealFillStart`/`tealFillEnd` (2.49 / 1.87 — why fills use dark text instead), white text on `emergencyFill` (well under floor, same reasoning), `textGrey` on either fill stop (2.43 / 3.24), `textDark` directly on the darker text-role `tealStart` as a fill (2.83 — that value is for text-on-light-bg, not fill-with-text-on-top; don't reuse it as a background)

Values adjusted this pass (all found by actually running `check_contrast.py`, not assumed):
- Introduced `tealFillStart`/`tealFillEnd` (`#12B8A6`/`#4FD1C5`, the reference's original bright values) as fill-only colors, foreground switched to `textDark` (5.92:1/7.91:1) — better margin than darkening the fill itself would have given (an earlier version of this pass darkened `tealStart` to `#0A7A6E` and kept white text at 5.22:1; superseded by this two-role approach per explicit user request to try another scheme)
- Introduced `emergencyFill` (`#F27070`) the same way for the Call button — dark text at 5.15:1
- `tealStart` (text/icon/border role) kept at `#0A7A6E` (5.92:1 vs white) — this is what all ~30 existing link/icon/border call sites already relied on; reverting it to the bright original would have broken every one of them
- `emergencyRed` (text/icon/border role) kept at `#CC3B3B` (4.93:1 vs white) — same reasoning
- `textGrey` `#6B7280` → `#5C6370` — vs. the mint surface was 4.42:1 (just under floor), now 6.05:1
- `statusCompleted` `#3FAE5C` → `#26783D` — as a `StatusPill` label (text-on-near-white) was 2.83:1, now 5.47:1
- `statusCancelled` `#9CA3AF` → `#6B7280` (the *old* textGrey value, reused rather than inventing a new one) — was 2.54:1, now 4.83:1

**Don't**: use a fill color (`tealFillStart`/`tealFillEnd`/`emergencyFill`) with white or any light foreground — always pair fills with `textDark`. Don't use a text-role color (`tealStart`/`emergencyRed`) as a solid fill background expecting white text to work — it wasn't tested for that and isn't needed for it (icons/badges using the darker `tealStart`/`emergencyRed` as a fill already pair correctly with white per the icon-scale UI-safe floor, e.g. the phone-icon badge at 4.93:1 — that one wasn't touched this pass). Don't use `blueAccent` as a text/label color on light surfaces without re-running the check — it's currently only cleared for icon-scale UI-safe use (bg/accent 3.22:1), not text-safe.

## Typography
- Display/heading font: **Fredoka** (Google Fonts) — rounded, high-personality letterforms; matches the reference's friendly, non-corporate feel and gives strong letter distinction for a senior-facing audience
- Body font: **Nunito** (Google Fonts) — rounded sans, very legible at larger sizes, pairs cleanly with Fredoka without competing
- Scale: heading1 30px / heading2 22px / body 17px / bodySecondary 15px / caption 13px, all further scaled 0.8×–1.6× at runtime by the user's own Settings text-size slider (`textScaleNotifier`) — a real accessibility feature already in place, not something this pass added

## Shape language
- Corner radius: `AppRadius.field` 14px (inputs, small buttons) · `AppRadius.card` 20px (cards, dialogs) · `AppRadius.hero` 28px (hero banner) · `AppRadius.pill` 30px (nav bar, welcome-screen CTAs) — centralized in `lib/data/constants.dart`, not per-widget literals
- Shadow depth: one soft shadow (`AppColors.softShadow` — black 6% opacity, 16px blur, (0,6) offset) reused everywhere via `SoftCard`, rather than every card hand-rolling its own `BoxShadow`
- Border usage: borders only used as selection state (task-type tile, 2px teal when selected) — not for general separation, which uses the shared shadow instead

## Density & spacing
- Base unit: 4px, structural spacing snaps to 10/12/14/16/20/24
- Content card internal padding: 16px (`SoftCard` default) — mobile touch density, not the 24px web-card floor
- Screen horizontal padding: 20px, consistent across all pages
- Overall density: comfortable, generous whitespace on Welcome/Login; denser list-card rhythm on Home screens (appropriate — those are "operate" screens, not "persuade" screens)
- Section separation: no marketing-style section tinting; screens are single-purpose (this app has no long-scroll marketing pages)

## Reference intelligence
- Reference board: not created as a separate file — single reference image supplied directly by the user, viewed and used directly (`extract_palette.py` output confirms real pixel-derived hues, not an inferred guess)
- Design read: consumer mobile app for a senior + companion/volunteer dual audience, mode **Operate** (Home/Request/Accept flows) with light **Persuade** framing on Welcome/onboarding only
- Dials: variance 3/10 (deliberately low — consistency matters more than novelty for this audience), motion 3/10 (restrained, functional only), density 4/10 (comfortable), art direction 5/10 (a few custom shapes — arch clip, gradient pills — over otherwise-standard Material)
- Foundation: Flutter Material 3 (`ColorScheme.fromSeed`), extended with this project's own token layer (`AppColors`/`AppRadius`/`AppTextStyles`) rather than a fully custom design system
- Quality bar: the reference mockup (ElderNet) set the palette/shape family; Apple's `DESIGN.md` (installed separately) was consulted for restraint principles (single accent discipline, sparing shadow use) but its literal web tokens were not ported
- Direction contract: Thesis — warm, high-contrast, unmistakably-tappable UI for users who may have low vision or low tech confidence, without looking "medical" or infantilizing; First viewport — Welcome screen's single hero + single primary CTA; System — Material 3 + custom token layer; Risk — hardcoded `AppColors` bypass the M3 `ColorScheme` in dark mode (see Palette section's flagged gap)
- Anti-references: generic indigo/purple SaaS gradients, dense enterprise-dashboard information density, decorative-only motion

## Taste memory
- Profile priors used: none (first tastemaker run for this user — `~/.tastemaker/profile.md` did not exist before this pass)
- Decision log: `.tastemaker/decisions.log`
- Last resolved decisions (2026-08-30): user chose "run a design-taste pass" when asked to clarify "redo the app"; user then chose the two-role fill/text color system (bright reference-accurate fills + dark text) over both "keep the darkened-brand-color version" and "generate an unrelated palette" when shown the tradeoff — both logged `kept`/`source:user` in decisions.log
- Pending review: the hero subtitle's "full-opacity dark text at lighter weight instead of a lightened tint" treatment was shown to the user as part of the same screenshot but not asked about specifically — logged `pending-review`/`source:agent-pending`
- Profile promotion: none yet — this is a single resolved decision in one project; promotion rules require it to repeat across 2+ surfaces/projects or an explicit "carry this forward" from the user, neither of which has happened
- Memory precedence note: no conflict — this was a cold start, current request is the only input

## Navigation chrome
- Sidebar/tab bar: floating pill-shaped bottom `NavigationBar` (not a sidebar — this is a phone app), background white, `AppRadius.pill` (30px) radius, `AppColors.softShadow`
- Content area background: `AppColors.backgroundGradient` (mint → white)
- Active nav item treatment: bold teal label + teal icon tint, `tealStart` at 15% opacity pill indicator behind the icon
- Inactive treatment: `textGrey` icon/label, no fill
- Shell density: two destinations only (Home, Profile) — Settings and Request Help are pushed screens, not tabs

## Mood descriptors
Warm, clear, unhurried, trustworthy.

## Aesthetic mode
None.

## Assets
- Anchor asset: `assets/lotties/welcome.json` (house-building Lottie animation) — everything else (arch clip, mint backdrop) was built to frame this one asset
- Asset style: Material rounded icons (`_rounded` suffix set) throughout — no external icon package added; consistent single-family stroke/fill style already achieved via Material's own rounded variants
- Illustration vs. photography split: no photography in this app (mobile app, not a marketing site); the one illustration asset is the Lottie animation. A rendering bug was found and fixed this pass — the bundled `lottie: ^3.3.1` package silently dropped most of the animation's shapes (merge-path/matte support gap), rendering only a chimney fragment; upgrading to `lottie: ^3.5.1` fixed it to render the full house correctly.
- Illustration source used: pre-existing project asset, not newly sourced this pass
- Logo: none — the app has no distinct logo/wordmark yet, just the "Senior App" text title. Not addressed this pass (out of scope for a design-taste-only request); flagged as a gap.

## Motion
- Feel: quick and restrained — utility, not spectacle, per this audience's needs
- Curves: `Curves.easeOut` (entrances/switch-in), `Curves.easeIn` (switch-out) — Flutter's built-in curves, no custom cubic-bezier needed at this scale
- Durations: tab switch 220ms; list-card stagger 260ms per card, 40ms stagger delay between cards
- Entrance duration/distance: list cards fade in + rise 6% of their own height (`Offset(0, 0.06)` slide), staggered by index via the new `StaggeredEntrance` widget (`lib/views/widgets/app_widgets.dart`)
- Added this pass: `AnimatedSwitcher` cross-fade between Home/Profile tabs (`lib/views/widget_tree.dart`) and `StaggeredEntrance` on both home screens' request/commitment lists — previously all state changes were instant with zero motion, which fails the skill's "app shell screens need panel-switch and staggered-entrance motion" default. Both respect `MediaQuery.disableAnimationsOf`/`accessibilityFeatures.disableAnimations` (reduce-motion), collapsing to no animation rather than ignoring the OS setting.
- Not done this pass (flagged, not fixed): no loading/skeleton states, no animated success/error feedback on form submission beyond the existing SnackBars — the "core app states are designed" non-negotiable is only partially met.
