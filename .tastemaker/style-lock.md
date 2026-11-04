# Alongside style lock: Harbour Ink

Replaces the earlier teal "editorial greeting" lock (November 2026). Code is the source of truth:
`lib/data/constants.dart` (tokens), `lib/main.dart` (theme), `lib/views/widgets/brand.dart` (logo).
`test/design_test.dart` enforces the contrast floors below.

## Promise and voice
- Promise: a checked neighbour beside you, there and back.
- Feel: steady, warm, plain-spoken, certain, unhurried. Never cute, clinical, techy, glossy or urgent.
- Copy promises only what the app does. Good news before warnings. No "elderly", no "peace of mind".

## Logo: "Leaning A"
- A tall stroke rises and leans in; a shorter stroke leans against it; a dot forms the crossbar. Two people walking together, and the A of the name.
- One geometry (`AlongsideMarkPainter`, 1×1 box, stroke 0.13, round caps). A ground-coloured cut where the strokes meet, so it works in one colour.
- Light ground: navy + deep apricot. Dark ground: warm white + apricot. App icon: linen + apricot on full-bleed navy.
- Wordmark: "Alongside" in Literata 600, sentence case, live text, never inside the icon tile.
- Never: medical cross, heart, hands, gradients, outlines thinner than the stroke.

## Colour roles
| Role | Light | Dark | Use |
|---|---|---|---|
| ground | #F6F1E8 linen | #16181D charcoal | page |
| panel | #FFFCF7 | #1F232A | cards |
| raised | #EEE7DA | #292E36 | inner rows, codes, chips |
| ink | #1B2230 | #F3EEE6 | text (14:1 / 15:1) |
| muted | #4E5563 | #B7B1A7 | secondary text (7:1+) |
| accent | #1F3A5F navy | #9DBDE6 harbour blue | the one main action, focus |
| accentTint | #DDE5F0 | #24344C | selected states |
| highlight | #E8A25A apricot | same | warmth, only behind dark ink |
| danger | #A8261D | #FF9C91 | errors, "can't make it" |
| border | #857C6E | #737A86 | outlines (3:1+) |

Status tones (bg / ink): waiting ochre, booked navy, with-you apricot, done green, cancelled grey, each ≥ 4.5:1 and always with an icon and words; colour is never the only signal.

Floors: body ink 7:1, other text 4.5:1, borders, marks and the accent on ground 3:1.

## Type
- Literata 600 for display (38), title (30), heading (23), the door code (36, tabular) and the wordmark.
- Atkinson Hyperlegible Next 400/600/700 for everything else: section 19 bold, body 18, secondary 16, small and label 15.
- Body text scales to 200%; titles, icons and tab labels stop at 150%.

## Shape, space, motion
- Radii: cards 24, rows 16, buttons fully round. No resting shadows.
- Spacing steps: 4, 8, 12, 16, 20, 24, 32, 48.
- Motion: 150 ms (press, select), 240 ms (cards, steps, sheets), 420 ms (one success moment). Ease-out cubic, no bounce, no parallax, no confetti. Reduce Motion makes every duration zero.
- Haptics: selection clicks on choices and stars; one success tap on request sent, "Yes, I'll help" and visit done. None on ordinary buttons.

## Icons
Material icons only. `_outlined` for objects and places, `_rounded` for arrows, checks and status. Sizes 20 inline, 24 in buttons, 28 in tiles, always through `AppText.icon`.
