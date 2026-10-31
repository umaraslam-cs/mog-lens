# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

MogLens — native SwiftUI iOS app (facial analysis). M1–M3 are built: Vision runs the real landmark detection and scoring (`VisionFaceAnalyser`), scans persist to disk (`FileScanRepository`), and RevenueCat holds the entitlement (`RevenueCatSubscriptionRepository`, live key in `RevenueCatConfiguration`). Static content in `Data/Sources/DesignContent.swift` is now copy only — every number on screen is measured or comes from the store. **No purchase has ever executed**: the Paid Applications Agreement is unsigned, so App Store Connect serves no products and the paywall resolves to its "plans unavailable" state.

**Renamed to MogLens on Oct 31, 2026.** The bundle ID moved to `com.moglens.app` and the product IDs to `moglens_monthly` / `moglens_annual`. None of that exists outside the repo yet. Until the account holder creates the App ID, the `MogLens_Dev` / `MogLens Distribution` profiles, a new App Store Connect app with both products, and a new RevenueCat app (whose key replaces the one in `RevenueCatConfiguration`), device and release builds won't sign and the paywall has no products. Support email `help@moglens.app` and the privacy URL `moglens.org` assume those domains are live.

- iOS 17.0, iPhone only, portrait only, **dark mode only** (`UIUserInterfaceStyle = Dark`)
- Bundle ID `com.moglens.app`, Swift 5, single target `MogLens`, one SPM dependency (RevenueCat), no CocoaPods
- `docs/IMPLEMENTATION.md` is the authoritative spec: screen map, design tokens, fidelity notes, deliberate deviations, and the "what to wire next" list. Read it before changing UI.

## Client brief

Freelance contract (Upwork). Client **Jon Page**; developer **Umar Aslam** (`maslam@tentwenty.me`, Apple ID on the dev team `umaraslam.cs@gmail.com`). App name **MogLens**, subtitle **Facial Analysis**. Niche: "lookmaxing" facial aesthetics scoring.

Positioning, verbatim from the client, drives every product decision: **"measured, not guessed"** — real geometric measurements from Apple's Vision framework, not an AI guess or a filter. Reference apps for *spirit only, never a clone*: **Ascension: Facial Analysis** and **Mog Academy**. Distinct visual identity required.

The client's own framing of the build, equally load-bearing: *"an app that gives users an aesthetic facial score through an interface that looks highly technical, while relying on simple and effective calculations"* — his brief headers the feature list **"minimum technical complexity, maximum impact"** and the scan screen **"the technical illusion"**. Vision does real landmark detection and the ratios are real, but the perceived depth comes from presentation. So padding the analysis to feel substantial is **sanctioned product design, not a hack** — see the pacing section. Both halves hold at once: the theatre is deliberate, the numbers still have to be honest and reproducible.

**Hard constraints agreed with the client:**

- Native Swift/SwiftUI only. Vision framework (`VNDetectFaceLandmarksRequest`) used **directly** — no Flutter, no platform channels.
- Scoring is **simple geometric ratios**, not a model. No custom AI/ML.
- **Everything on-device.** No Firebase, no custom backend, no user accounts, no cross-device sync. Client explicitly rejected Firebase for the MVP.
- Only external service is **RevenueCat** for subscription/entitlement. RevenueCat **anonymous user ID** carries entitlement — that is the whole "backend".
- Advice/tips are a **pre-written lookup table** supplied by the client, keyed by metric × score tier. Not AI-generated, not personalised.
- Client handles logo/branding himself (final logo delivered Aug 5, 2026). Model imagery and overall aesthetic are the developer's responsibility, and must lean **bold American lookmaxing** — aspirational "glow-up", not soft or clinical. Onboarding models must be **Western-looking male** — the client rejected the AI-generated placeholders on those grounds. He supplied one photo, scoped **only** to the "Measured. Not guessed." technology screen (`AppImage.technologyPortrait`); he stated explicitly it is not for use anywhere else. `AppImage.haloPortrait` is still the developer's to source.
- Marketing tools are **out of scope**. The client originally wanted the Ascension equivalents — a rating-card generator (upload a photo, manually set rating/current/potential tier and percentile, export a styled image) and a scan-animation MP4 generator — and first scaled the ask down to 10–15 pre-rendered cards plus 2–3 generic clips for his TikTok creators, then withdrew it entirely: he is building both as standalone web pages himself. In those assets the numbers are **fake by design** — the creator picks whatever looks good. Nothing about them touches this app.

**Commercials:** $950 fixed, 4 milestones, plus 4 weeks free post-launch bug support.

| Milestone | Amount | Scope | Status |
|---|---|---|---|
| M1 | $250 | Project setup, complete UI, navigation flow | Approved & paid Aug 11, 2026 |
| M2 | $250 | Vision integration, landmark detection + overlay, scan animation with progress states, facial measurements, score/percentile/tier calculation | Active (funded Aug 11, 2026) |
| M3 | $250 | RevenueCat/StoreKit, paywall, results functionality, tips by score range | Built Aug 24, 2026; SDK key wired and live Aug 25. Blocked on the **Paid Applications Agreement** — until the account holder signs it, no products exist, so buying cannot be tested. Restore can. |
| M4 | $200 | Final UI polish, testing/bug fixes, TestFlight build, App Store submission-ready build | Not started |

**Timeline:** ~3 weeks development + 1 week polish/QA/submission, roughly one milestone per week. Client asked to land development-complete and submitted around **Aug 24–25, 2026**; developer agreed it's achievable, promised to flag early if anything slips, and committed to a progress update every 2–3 days. Nearest commitment: **M2 build for review by end of Sunday, Aug 16, 2026**. Client is online 1pm–1am CET, **text/chat only — no voice or video calls**.

This is the second engagement with this client — the first, a Spanish-language micro-learning app, was scrapped by him before development started. Nothing carries over.

## Product scope (client's MVP list)

1. **Onboarding/intro** in this exact order: age question (number picker) → "hype" copy screens (looks matter more than people admit; the **halo effect** — attractive people are read as more trustworthy/successful/intelligent) → **target rank** question (dial/wheel over the tier labels) → motivational/urgency screens ("most people never even realize until it's too late") → photo capture.
2. **Photo capture or import.**
3. **Animated scan screen** with the Vision landmark overlay, dynamic progress text ("Analyzing facial proportions…") and a progress bar. **Free and visible to everyone** — this is the hook.
4. **Results:** the analysed photo **stays visible with the landmarks overlaid**, plus 4–6 metrics, each a value + percentile ("Top X%"), plus one overall tier label. Dark theme, **green progress bars for strong scores**.
5. **Paywall gates the ENTIRE result.** Nothing beyond the scan animation is free — no score, no metric, no tier. Subscription required to see any part of the outcome.
6. **Unlocked report:** score + metrics + tier, plus a few generic actionable tips per weak metric, from the lookup table. Purpose: stop it feeling like selling a bare number.
7. **App Store submission-ready build.**

**Tier labels** (community terms, simple score-range lookup): `LTN`, `MTN`, `HTN`, `Chad Lite`, `Chad`.

**Metrics — five, confirmed by the client on Aug 15, 2026:** Facial Symmetry, Jaw Angle, Chin-to-Nose Ratio, Eye Spacing, Midface Ratio. The first three he named himself (symmetry from eye/nose/mouth landmark distances, chin-to-nose from two key points, jaw angle from three points along the jawline); the last two he approved and supplied advice copy for. Percentiles come from **predefined thresholds** on the computed value — e.g. jaw angle above 125° renders "Top 10%", his one calibrated anchor.

**Angled photos: warn, never block** — his decision, Aug 15, 2026. With a hard paywall and no free trial he wants no added friction before purchase. His condition: the note must be **clearly visible**, not fine print, so the score doesn't read as misleading.

**Scoring must be stable/reproducible.** Client called this out explicitly: two scans in a row under similar lighting and angle must land within a point or two, never fluctuate randomly. Consistency *is* the "measured, not guessed" claim — treat any nondeterminism in the scoring math as a bug.

## Settled decisions — don't reopen

The design (17-screen HTML prototype, shared Aug 4, 2026) was approved **as-is, no changes**. The first build recording (Aug 8) drew the notes below; the second (Aug 10) drew none and closed out M1. Feedback already resolved:

- **Extra "the science behind it" screen: rejected.** The client asked for a couple of cards on why the measurements are scientifically grounded; the developer argued the existing technology screens already carry that, and the client accepted rewriting their copy instead of adding a screen. Don't add one.
- **Urgency screen copy is client-written and verbatim** — `DesignContent.Onboarding.urgencyTitle` / body ("Most men are guessing." / jaw angle, facial thirds, canthal tilt, "backed by geometry, not filters"). Same for the technology screen copy, which the client asked be **kept unchanged**. Don't reword either.
- **A 1-question "what's your main goal?" screen before scanning: built Aug 24, 2026, removed Aug 25, 2026.** It was never in the client's MVP list, so it came out again along with `ScanGoal`, `OnboardingStep.goal`, `AppRouter.goal` and the Improve-tab eyebrow that reflected it. Onboarding is six steps, ending on the technology screen. Do not re-add it without the client asking.

## Pacing and presentation (client requests, M2/M3)

The flow read as too quick/thin. Three changes, all animation/UI only — no new logic:

1. **Scan animation cycles sequential messages** rather than one static line: "Detecting facial landmarks…" → "Calculating symmetry…" → "Cross-referencing facial geometry…" → "Finalizing analysis…". Stretch to **8–10 seconds total**, even though the real computation is instant.
2. **Results reveal staggers metric-by-metric** with a short delay each, countdown-style — not one instant dump.
3. **Per-metric percentile bar/indicator** showing where the raw value falls on the scale, next to the number.

## Subscription pricing (final)

- Monthly **$12**
- Annual **$39.99**
- **No weekly plan** — client dropped it.

Superseded earlier placeholder pricing; this is the version to ship. RevenueCat, not StoreKit directly, per the contract — the anonymous user ID holds the entitlement.

**No price ships in the binary.** Every figure on the paywall is built from the RevenueCat `StoreProduct`, and there is no bundled plan list to fall back on. Until the store answers, the paywall shows "Loading plans…" or, if the offering comes back empty, "Plans couldn't be loaded" with a retry — and the CTA stays disabled. Do not reintroduce hardcoded prices; a figure nobody will be charged is worse than an empty list.

## Advice lookup table (client-supplied, M3)

Keyed metric × tier. Tier ranges below are the client's placeholders — **adjust to the actual scoring thresholds**, don't take 0–40 / 40–70 / 70–100 as final. Copy is verbatim client content; do not rewrite it.

**Symmetry** — why it matters: "Symmetry affects how balanced a face reads at a glance - it's one of the first things perceived, even subconsciously."
- *Low:* sleeping on your back rather than one side can stop asymmetry worsening; jaw clenching/teeth grinding pulls the jawline out of alignment over months — a night guard helps.
- *Mid:* posture matters more than people think — chin-forward posture from phone/laptop use visually skews balance; chewing evenly on both sides keeps jaw muscle development balanced.
- *High:* already a strong percentile — maintenance only: consistent sleep position, no one-sided chewing.

**Jaw Angle** — why it matters: "Jaw definition is one of the most immediately noticeable structural traits, tied closely to perceived masculinity/sharpness."
- *Low:* mewing (tongue on the roof of the mouth) consistently over months, not days; reducing body fat percentage usually has the single biggest visible impact.
- *Mid:* jaw exercises (gum, resistance trainers) over 2–3 months of consistency; hydration reduces facial water retention that softens the apparent angle.
- *High:* grooming — beard shaping, a hairstyle that doesn't compete with jaw visibility.

**Chin-to-Nose Ratio** — why it matters: "This ratio is a key driver of how balanced the lower and mid face appear together."
- *Low:* mostly structural/bone-based, so it responds less to lifestyle change — good posture stops it looking worse than it is; a well-groomed beard can visually balance chin proportion.
- *Mid:* nothing drastic — a hairstyle with volume/length variation subtly shifts proportion perception.
- *High:* already working in your favour — keep facial hair well-maintained, it interacts directly with this feature.

**Eye Spacing** — why it matters: "Eye spacing is one of the biggest factors in how 'hunter vs prey' a face reads - tighter or wider than average changes perceived intensity."
- *Low:* almost entirely structural, genetics call the shots — spend the effort on skin, jaw and grooming instead; strong brow grooming reframes how spacing reads at a glance.
- *Mid:* close to the sweet spot — hooded or tired-looking eyes throw off perceived spacing, so sleep and hydration genuinely pull weight; a slightly lower, more textured brow shape tightens the visual gap.
- *High:* already working for you, low-maintenance — just don't let brow grooming drift into over-plucked territory.

**Midface Ratio** — why it matters: "Midface length is a core 'chad vs average' signal in the community - shorter midface reads as more compact, hunter-coded, and youthful."
- *Low:* mostly bone structure, so lifestyle won't shrink it — consistent mewing tightens the surrounding muscle over time; avoid hairstyles with lots of forehead exposure, they stretch the midface visually.
- *Mid:* solid range — facial fat loss is the biggest lever left; a well-placed hairline/fringe visually shortens midface perception.
- *High:* a genuine strength, part of the "compact" hunter look — keep facial leanness up to preserve it.

## Brand palette

Source of truth for `AppColor`.

**Rebranded to acid lime on Nov 1, 2026**, replacing the client's original cyan-on-navy values (`#3FD4D9 → #2A8FD6` on `#000000 → #0E1F2E`). Current tokens:

- Background: black → deep green-black gradient, `#000000` → `#07130A` (58%) → `#0F1A12`
- Primary accent: acid lime → green, `#C6FF3D` → `#3DFF8A` — glows, highlights, progress bars, CTAs; `#0A1405` on top of it
- Text: `#EAEDEA` primary, `#8FA094` secondary
- Success/good `#3DDCFF` (cyan, so a strong score doesn't blend into the lime accent — note the client's MVP list asked for **green** bars for strong scores), warning/acceptable `#FFB84D`, needs work `#FF6B4A`
- Baked-in cyan in the onboarding artwork and videos (mesh, goal, halo, discover-face images; `futureself.mp4/.gif`, `technologysteps.mp4`) was hue-shifted to lime selectively, leaving skin and photo tones alone. `TechnologyPortrait` (client-supplied) and the doctor photos were not touched.
- The app icon and splash logo were **not** changed in the rebrand; they are still the client's monochrome mark.

Logo direction: dark, skull-based, teal/cyan facial-landmark mesh overlay. Final logo plus a transparent 1024×1024 PNG for splash were delivered by the client.

## Signing and distribution

The Apple Developer account is an **Individual** account (team `QVA3ZF63S6`) held by a colleague of the client — certificates carry that person's name, not the client's, which is expected. This account is Admin on App Store Connect with access to all apps, so **App Store Connect roles are not the blocker**: an Individual account simply cannot delegate Certificates, Identifiers & Profiles. Converting to Organization was declined (needs a D-U-N-S number). Consequences to work around, not fix:

- Certificates and provisioning profiles are generated by the account holder from a CSR sent over, then installed locally. Profiles in use: `MogLens_Dev` (this iPhone's UDID `00008110-0006483C2202601E` registered) and `MogLens Distribution`.
- **Xcode's own upload path is broken** — the certificate and profile resolve fine, but the Team field reads "Unknown Name (QVA3ZF63S6)" instead of the account holder's name. Sign-out/sign-in, manual profile download, correct clock, and no VPN all ruled out. Don't re-debug this.
- **TestFlight uploads therefore go through the Transporter app** with an App Store Connect API key (Key ID `3Q2Q478U4X`, issuer `ba780232-3edb-4f6b-93f1-3960436bb333`, `.p8` held locally). Archive in Xcode, export, upload with Transporter. Known to be slow and manual; accepted for now.
- Client tests as an internal TestFlight tester (`i7590680@gmail.com`).

Never commit the `.p8` key, `.cer`, or `.mobileprovision` files.

## Commands

```bash
# Build, install and launch on a simulator — booted one, else iPhone 17 Pro
scripts/run.sh
scripts/run.sh "iPhone 16"   # named device, booting it if needed
scripts/run.sh --clean       # wipe DerivedData first

# Build, install and launch on the connected iPhone (Vision needs real hardware)
scripts/run.sh --device
scripts/run.sh --device "Umar"   # name-matched, when several are connected
scripts/run.sh --list            # list connected iPhones and exit

# Build only
xcodebuild -project MogLens.xcodeproj -scheme MogLens \
  -destination 'id=<simulator-udid>' build
```

Installs are always fresh — the old copy is uninstalled first, so onboarding
replays and the scan store starts empty on every run. To keep state across
builds (a live subscription, scan history, `hasOnboarded`), install over the top
instead:

```bash
xcrun devicectl device install app --device <device-id> \
  .build/derived/Build/Products/Debug-iphoneos/MogLens.app
```

`scripts/run.sh` builds into `.build/derived`, which `.gitignore` already covers, so it never collides with Xcode's own DerivedData. Reach for `--clean` when the simulator's behaviour disagrees with the source — a stale incremental build is the usual cause.

To see a screen without driving the whole app, use its `#Preview` (⌥⌘↩ in Xcode). Every screen has one, named after its design number and fed by `PreviewData`.

No test target exists — there are no tests to run, and no lint/format tooling configured. Adding a file under `MogLens/` needs no project-file edit: the target uses file-system-synchronized groups (Xcode 16+).

## Architecture

Clean Architecture + MVVM. Dependencies point inward: `Presentation → Domain`, `Data → Domain`. **Nothing in `Domain` imports SwiftUI.**

Data flow for any read:

```
View  ──@Environment(AppDependencies)──▶ ViewModel(dependencies:)
ViewModel ──use case (callAsFunction)──▶ Repository protocol ──▶ Static* implementation
```

Key rules that hold everywhere:

- **View models never touch repositories.** They take use-case protocols. `AppDependencies` (`Core/DI/AppDependencies.swift`) is the only composition root; it constructs repositories and vends use cases as computed properties.
- **Use cases are call-site-shaped**, one per read, each a `protocol` + `struct` pair exposing `callAsFunction()`. Adding a read means adding both to `Domain/UseCases/` and a property on `AppDependencies`.
- **Views hold no formatting logic.** Dates, captions, percentile strings are composed in the view model or the entity.
- View models are `@Observable` final classes with a `convenience init(dependencies: AppDependencies)`.
- Moving to real data = swap the implementation registered in `AppDependencies`. No view or view model changes.

## App flow

`AppRouter` (`App/AppRouter.swift`) owns phase, selected tab, and the Settings sheet flag; injected via `.environment`. `MainTabView` has three tabs (Home / Scan / Improve) — Settings is a sheet from Home, never a tab.

`AppRouter.Phase` is the single switch: `.splash → .onboarding → .scan → .main`. Only `.main` renders `MainTabView`, so **the first scan runs with no tab bar**.

```
splash (1.8s) → onboarding (6 steps) → scan flow, standalone — no tab bar
                                          │
Scan ──Take Photo──▶ permission ──Allow──▶ capture ─┐
     ──Import Photo─────────────────────────────────┴──▶ analysing
analysing (5 steps × 1.8s ≈ 9s, 0 → 100%) ──▶ paywall ──Unlock──▶ results
results ──Go to Home / back──▶ tabs on Home
        ──See My Plan────────▶ tabs on Improve
```

Rules of the flow:

- **The scan flow is presented over the tab shell, never pushed inside it.** `ScanView` shows it in a `fullScreenCover` driven by `ScanViewModel.isFlowActive`; only the Scan *entry* screen is a tab. Nothing in the flow hides the tab bar, because nothing in the flow is behind one — that hiding is what made the bar animate back a beat late on the way out.
- **The flow renders `ScanViewModel.screens.last` directly — there is no `NavigationStack` inside it.** The flow is linear and each screen carries its own way out; a stack only added a back-swipe that re-ran the analysing screen or landed on a blank root. `screens` is `private(set)`: the model is the only writer, and the view calls its methods rather than mutating navigation state.
- Results is the **end** of the scan flow. It reports where to land through one closure, `onExit: (AppRouter.Tab) -> Void`, which calls `ScanViewModel.finish(landingOn:)`. That closes the cover; the tab is applied in `onDismiss` via `flowDidDismiss()`, which returns it. **Landing on a tab must wait until the flow is off screen** — swapping the shell underneath a dismissing cover strands it.
- Dismissal is two beats on purpose: `dismissFlow()` closes the cover, `flowDidDismiss()` clears `screens`, the photo and the scan afterwards. Emptying them earlier blanks the flow while it is still visible.
- `onExit` is `nil` when Results is opened from Home — there the back chevron dismisses the cover and the "Go to Home" button is hidden. Any new exit from Results goes through `onExit`, not a second navigation mechanism.
- Cancel from capture and close from the paywall call `dismissFlow()` only, returning to the Scan entry screen. Do not route those to Home.
- `ScanViewModel` never touches `AppRouter`; phase and tab changes are made by the view. Keep it that way.
- **Results is standalone wherever it opens from.** Home presents it in a `fullScreenCover` keyed on `presentedScan` — from the score card and from history rows alike — which bypasses the paywall by design, since those scans are already unlocked. Do not turn these back into `NavigationLink`s.
- `AppRouter.hasOnboarded` and the target rank persist in `UserDefaults`, so onboarding replays only after an uninstall — which is what `scripts/run.sh` does on every run. Install without the uninstall step to keep state across builds.

## Design system — use tokens, never literals

`DesignSystem/Foundation/` holds the whole token set; never hardcode a colour, size, spacing, radius or animation.

- `AppColor` — surfaces are white at 4.5%, hairlines white 8%; **never a solid grey fill**. Semantic colours map to percentile bands (≥75 success / 40–74 warning / <40 negative), encoded in `MetricRating`.
- `Spacing`, `Radius`, `Layout`, `AppShadow` (`Layout.swift`) — 8pt system; radii 10 controls / 16 buttons & cards / 18 list cards / 24 hero cards.
- `AppFont` — SF Pro via `Font.system`; use `AppFont.mono(_:_:)` or `.monospacedDigit()` for any animating numeral.
- `AppMotion` — every duration and curve. Looping animations must settle to a static state under Reduce Motion.
- `AppSymbol` (`Core/Constants/AppSymbol.swift`) — the only source of SF Symbol names. One library, no mixing, no inline `systemImage:` string literals. `AppImage` is its counterpart for asset-catalog artwork.
- All user-facing copy lives in `DesignContent`; no string literals in views.

Screens laid out absolutely in the design (onboarding, Scan, Paywall) reproduce prototype offsets as `designY − 54` relative to the top safe area. Bottom CTAs sit 12pt inside the bottom safe area (`Layout.bottomCTAInset`).

## Keep it simple

This is a small UI-only app and should read like one. Prefer the boring option.

- **Smallest change that works.** No new layers, protocols, coordinators or state containers unless an existing one genuinely cannot express the need. A two-line closure in a view beats a new abstraction.
- **One idea per type.** View models hold state and display strings; views lay out; use cases fetch. If a file starts doing two of those, split along that line, not a new one.
- **No speculative generality.** Don't add parameters, generics or protocol witnesses for a case that doesn't exist yet. `docs/IMPLEMENTATION.md:136` lists what is actually coming.
- **Name things after intent**, not mechanics — `analysisDidFinish()`, not `nextStep()`.
- **Comment the why.** The layout constants and stand-ins here are deliberate; a comment that explains a design offset or a stub earns its place, one that restates the code does not.
- **Flow changes go through `AppRouter` or the owning view model's `screens`** — never a second source of navigation truth.
- Keep views shallow: extract a subview into `Presentation/<Screen>/Components/` once a `body` needs scrolling to read.

## Conventions

- Every screen carries a `#Preview` named after its design number (e.g. `#Preview("08 Home")`), fed by `PreviewData` fixtures — keep this when adding screens.
- Doc comments reference the design number and explain *why* a deviation exists; match that density.
- `AppDependencies.empty` drives the Home empty state for previews/testing; `PreviewData.dependencies` is the unlocked one, `PreviewData.lockedDependencies` the locked one the paywall preview needs.
- Results stay gated on `SubscriptionRepositoryProtocol.isSubscribed()` — the paywall renders before any result value reaches a view model. Preserve that ordering.

## Entitlement

One boolean gates the whole app: is the RevenueCat `premium` entitlement active on this device. `LiveSubscriptionRepository.make()` is registered in `AppDependencies` — it builds the RevenueCat repository when a key is present and falls back to a locked `StaticSubscriptionRepository` when one isn't, so a key-stripped build still runs the flow end to end.

The cache is read synchronously (navigation cannot await the network) and corrected around that read:

| Where | Kind | Guards against |
|---|---|---|
| App launch (`RootView.task`) | network | The cache starting locked and showing a subscriber the paywall |
| Scan gate (`analysisDidFinish`) | **cached** | Nothing — this is the read being protected |
| Paywall appears (`load()`) | network | A purchase made elsewhere; leaves for Results without showing the ask |
| Home / Improve appear | network | A lapse going unnoticed on a screen full of results |
| Settings sheet dismissed | network | A restore that worked leaving Home locked |
| Purchase or restore fails | network | A transaction that completed as the connection dropped being paid for twice |
| Any time, app running | push | `customerInfoStream` — renewals, cancellations, restores from another device |

Rules that hold here:

- **Gate on entitlement, don't just hide.** The Improve tab does not compute its weakest-first ordering while locked — that ordering is itself a result. Same for Home's metrics and history.
- Entitlement cache writes are `@MainActor`; the stream and the store calls are two writers and navigation is a synchronous reader.
- Restore is reachable from **Settings** as well as the paywall — App Store Review 3.1.2 expects it without a purchase in front of it. Settings reports success explicitly, because nothing on that screen changes when it works.
- Manage Subscription opens Apple's in-app sheet only when the entitlement is active, and the App Store subscriptions URL otherwise: the sheet has nothing to show without a live subscription and gives no callback when it declines to present.

Known gaps, all recorded rather than fixed: a lapse while Results is open is not re-checked until the user navigates away; offline keeps the last known answer; and closing the paywall on a first run returns to the Scan entry screen with no route to the tabs, which follows from the hard paywall.
