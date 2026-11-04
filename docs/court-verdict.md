# The verdict: GUILTY, 10 to 2

**The case:** An app that connects seniors with volunteers who help them get to medical check-ups, pick up medicine, go for scans and similar health errands.

**The charge:** The case fails as stated: it should not go ahead the way it is described.

## How the jury voted

| Juror | Vote | Why |
|---|---|---|
| The Accountant | GUILTY | The defense itself concedes a backend, volunteer vetting and insurance are all required before any real use, each of those costs money, and the record names no budget, no payments, no partners and unpaid volunteers, so nobody is shown paying for the things the product cannot run without. |
| The First-Time Customer | GUILTY | As someone hearing about this for the first time, I would not put my mother in an unvetted stranger's car for her scan this week, and I couldn't even if I wanted to, because the app as described cannot get her request to a volunteer, so I would keep relying on family, a taxi or the clinic's own transport. |
| The Competitor | GUILTY | As the business this would compete with, I'd ignore it: the only thing it has that I lack is big buttons and plain wording, which I can copy in a sprint, while the hard parts of my business are vetted volunteers, insurance and a reliable supply of people, and this case has none of them and no plan for any. |
| The Retired Judge | GUILTY | Much of the prosecution's case rests on silence, but the flow described in the record lets any volunteer browse and accept a frail senior's ride or escort request with no check in between, and the defense's claims of "trust designed in" and "costs little" are hope with no evidence behind them, so the burden is met by the record and the defense's own admissions. |
| The Teenager | GUILTY | An app where grandma posts "I need a ride to my scan" and nobody shows up is worse than no app, and nothing in here says who those unpaid volunteers are or why they'd open it twice. |
| The Engineer | NOT GUILTY | A post-accept-check-in-complete loop is an ordinary two-sided app I could build. What's missing (a backend, a vetting gate before a volunteer can accept, a fallback when nobody accepts a fixed-time medical errand) gets added on top of the existing screens without throwing them away, and it's a known next step for something the owner openly calls a prototype. |
| The Small-Business Owner | GUILTY | Twenty years behind a counter taught me you need someone to unlock the door on Monday and money to keep the lights on until it pays, and this plan has unpaid helpers it has no plan to recruit, no money, and no backup when nobody turns up for a senior's scan. |
| The Statistician | GUILTY | The record has a sample size of zero on both sides, with no senior who has tried the screens and no volunteer signed up, and an unpaid two-sided marketplace for time-fixed medical errands has nothing here to show it beats the usual odds of never getting enough supply. |
| The Parent | GUILTY | I would not put my own mother in an unchecked stranger's car with no one covering a crash or fall, and the case as described puts nothing in place to stop that. |
| The Investor | GUILTY | I would not put my own money into this as described, because I see no way it earns money and no limit on what it could cost me: volunteers are unpaid, there are no payments, and it has no budget or launch market, while it puts strangers in cars with frail seniors with no insurance or vetting. |
| The Designer | NOT GUILTY | A stranger gets this in one breath, an app where unpaid volunteers help seniors get to check-ups, scans and medicine pickups, and the owner has made large text, big buttons and plain wording a core requirement; the vetting and insurance gaps are real, but they block a launch, not the prototype the case describes. |
| The Lawyer | GUILTY | As described, the app puts unvetted, uninsured strangers in cars with frail seniors and handles their medicine and health-related details with no named market, so nobody can say which law applies or who carries the loss when something goes wrong. |

## Charges that stuck
1. **No vetting.** Any volunteer can browse and accept a frail senior's ride or escort request with no identity or background check first (7 jurors).
2. **No insurance.** Rides and medicine pickups have no stated cover, so nobody is shown carrying the loss from a crash, fall or wrong prescription (5 jurors).
3. **No supply side.** Unpaid volunteers, with no recruitment plan, partner or launch market and no fallback when nobody turns up for a fixed-time scan (4 jurors).

## What the defense got right
1. The scope is short and concrete: errands, rides and company, with no hands-on care, and the senior side is built around large text, big buttons and plain wording from the start.
2. It is honestly a prototype. The missing backend, vetting gate and no-show handling can be added on top of the existing screens without throwing them away.

## Conditions for acquittal
1. **Name a launch area and a partner** (a clinic or volunteer group) that already has vetted, insured volunteers. This is the most common flip condition.
2. **Put a vetting gate in the flow:** a volunteer cannot see or accept any request until identity and background checks are passed. Add it to the spec and the prototype screens now.
3. **Write down who pays for the backend, the checks and ride insurance, and what happens if nobody accepts or a volunteer does not show up.** A named insurer or a partner's existing cover counts.

## The sentence
Keep building the prototype, but stop calling it a matching service until it has a gate. This week, find one partner in one named area whose volunteers are already checked and insured, and redesign the volunteer side so that nobody unchecked can see a senior's request.

_The full trial is in /Users/_abrahamli/Development/projects/flutter_app/.claude/worktrees/senior-care-premium-140213/.court/20261103-003811: the opening statements, the rebuttals and every juror's vote._

_Made with [/court](https://github.com/alexyc9381/court-skill), a free Claude Code skill by Alex Chen ([@nocodealex](https://instagram.com/nocodealex))._
