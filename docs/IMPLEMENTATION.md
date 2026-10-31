# MogLens — SwiftUI implementation notes

The 17 screens in `project/MogLens.dc.html` built as a native iOS app. UI only:
no Vision requests, no StoreKit transactions, no persistence. Every screen
renders from static content that mirrors the design exactly.

- **Target:** iOS 17.0, iPhone, portrait, dark only
- **Open with:** `MogLens.xcodeproj` (Xcode 16 or later — the project uses
  file-system-synchronized groups, so new files in `MogLens/` are picked up
  without editing the project file)
- **Bundle ID:** `com.moglens.app`

## Architecture

Clean Architecture with MVVM. Dependencies point inward: `Presentation → Domain`
and `Data → Domain`. Nothing in `Domain` imports SwiftUI.

```
MogLens/
  App/              MogLensApp, RootView, AppRouter — launch → onboarding → tabs
  Core/
    Constants/      AppSymbol — the design's icon table resolved to SF Symbols
    DI/             AppDependencies (composition root), PreviewData
  Domain/
    Entities/       FaceScan, FacialMetric, FacialTier, MetricRating,
                    Recommendation, SubscriptionPlan, AnalysisStep, …
    Repositories/   Protocols only
    UseCases/       One call-site-shaped use case per read
  Data/
    Sources/        DesignContent (the copy deck), SampleScans
    Repositories/   Static implementations of the Domain protocols
  DesignSystem/
    Foundation/     AppColor, AppGradient, AppFont, Layout, AppMotion
    Components/     Buttons, cards, metric views, tier badge, progress bars,
                    wheel picker, score ring, landmark overlay, photo slot, …
    Modifiers/      surfaceCard / gradientCard
  Presentation/
    Splash · Onboarding · MainTab · Home · Settings · Scan · Paywall ·
    Results · Improve      (each: View + ViewModel + Components/)
  Resources/        Assets.xcassets
```

View models are `@Observable` and take use cases, never repositories directly.
Views own no formatting logic — dates, captions and percentile strings are
composed in the view model or the entity.

To move onto real data, swap the implementations registered in
`AppDependencies`; no view or view model changes are required.

## Screen map

| # | Design | View |
|---|---|---|
| 01 | Splash | `Presentation/Splash/SplashView` |
| 02 | Onboarding — Age | `Onboarding/Steps/AgeStepView` |
| 03 | Hype 1 — Halo Effect | `Onboarding/Steps/HaloEffectStepView` |
| 04 | Hype 2 — Why it matters | `Onboarding/Steps/WhyItMattersStepView` |
| 05 | Target Rank | `Onboarding/Steps/TargetRankStepView` |
| 06 | Hype 3 — Urgency | `Onboarding/Steps/UrgencyStepView` |
| 07 | Technology | `Onboarding/Steps/TechnologyStepView` |
| 08 | Home — dashboard | `Home/HomeView` |
| 09 | Home — empty state | `Home/HomeView` + `Components/HomeEmptyState` |
| 10 | Settings sheet | `Settings/SettingsView` |
| 11 | Scan — entry | `Scan/ScanView` |
| 12 | Camera permission | `Scan/CameraPermissionAlertView` |
| 13 | Facial capture | `Scan/CaptureView` |
| 14 | Analysing | `Scan/AnalysingView` |
| 15 | Paywall | `Paywall/PaywallView` |
| 16 | Results | `Results/ResultsView` |
| 17 | Improve | `Improve/ImproveView` |
| — | Privacy Policy / Terms of Service | `Legal/LegalDocumentView` |

Every screen has a `#Preview` named after its design number.

`LegalDocumentView` has no design number: the prototype links to both documents
from Settings and the paywall but never draws them. One sheet renders either —
`LegalDocument.Kind` picks the copy, the layout is identical — and it reuses
`SheetHeader` with Settings so the two sheets sit flush.

## Tokens

Taken verbatim from the design system section of the prototype.

- **Background** `#000000 → #07130A 58% → #0F1A12` (`AppGradient.background`)
- **Accent** `#C6FF3D → #3DFF8A` (`AppGradient.accent`)
- **Text** `#EAEDEA` primary, `#8FA094` secondary
- **Semantic** `#3DDCFF` excellent · `#FFB84D` average · `#FF6B4A` needs improvement
  (thresholds ≥75th / 40–74th / <40th, in `MetricRating`)
- **Surfaces** white 4.5%, hairlines white 8% — never a solid grey fill
- **Radii** 10 controls · 16 buttons & cards · 18 list cards · 24 hero cards
- **Spacing** 4 / 8 / 16 / 20 / 24 / 32
- **Motion** every duration and curve in `AppMotion`, matching the motion spec

## Fidelity notes

**Coordinates.** The prototype positions everything absolutely inside a
393 × 852 frame whose status bar is 54pt tall. Screens that are laid out
absolutely in the design (onboarding, Scan, Paywall) reproduce those offsets
relative to the top safe area, i.e. `designY − 54`. Bottom CTAs sit 12pt inside
the bottom safe area, which is the design's "32pt above the home indicator".

**No simulated chrome.** The prototype draws its own status bar and home
indicator because it renders in a browser. The app does not — iOS draws both.

**Tab bar.** Native `TabView`, restyled through `UITabBarAppearance`
(`TabBarAppearance.apply()`) to the design's translucent `#081017` at 86% with a
white 8% hairline and the accent/secondary item pair.

**Wheel pickers.** Built as a custom `WheelPicker` on iOS 17 scroll snapping
rather than `Picker(.wheel)`. The Target Rank wheel needs an accent-tinted
selection band and an accent selected row, which a system wheel cannot express.
It keeps the native feel: rows snap, the centred row animates up in weight, and
each detent fires a `.selection` haptic.

**Imagery.** No photos ship with the design — its image areas are drop targets.
`PhotoSlot` renders a striped dark placeholder with a monospace caption naming
what belongs there. Pass `imageName:` to swap in a real asset with no other
change at the call site.

**Reduce Motion.** Every looping animation (sweep, breathing glows, landmark
pulses, spinners) settles into a static state when Reduce Motion is on.

## Deviations, and why

1. **Screen 02 annotation.** The design prints `UIPickerView · .wheel style`
   inside the phone frame. That is a handoff note, not product copy, so it is
   not rendered in the app.
2. **Midface Ratio value.** The design shows this metric's percentile (61) on
   Home but never its raw value — Results only lists four cards, with the fifth
   noted as scrolled off. `SampleScans` uses `1.02` as a placeholder, flagged in
   a comment.
3. **Second history scan's metrics.** The design shows only date, score and tier
   for the 28 Feb scan. Tapping it opens Results, so a plausible metric set is
   supplied in `SampleScans.previous`.
4. **Camera permission (12).** The real prompt is drawn by the system and cannot
   be restyled. `CameraPermissionAlertView` is a pixel-matched replica so the
   flow can be reviewed end to end; replace it with
   `AVCaptureDevice.requestAccess(for: .video)` when wiring capture.
5. **Analysing progress.** The design captures the screen mid-run at 64%. A
   shipped flow has to start at 0% and finish on its own, so the five steps run
   0 → 100% at one second each (`AppMotion.analysisStepInterval`), driven by
   `AnalysingViewModel.runAnalysis()`. Replace the sleep with real Vision
   completions calling `completeCurrentStep()`; nothing else changes.
6. **Splash mark.** The design draws two rings, a rotating quarter-arc and an
   accent diamond, because it had no logo to place. With the real logo — which
   carries its own scan brackets — the rings read as a loading spinner wrapped
   around a second frame. `SplashLogoMark` instead sweeps the logo into view,
   the same gesture the analysing screen makes. `AppMotion.splashRingDuration`
   is replaced by `splashRevealDuration`.

7. **Legal copy.** `DesignContent.Legal` ships placeholder text for both
   documents, every paragraph marked as such. The screen, the repository and the
   use case are final; only the wording waits on legal review.

## Short containers — iPad compatibility and 4.7-inch phones

Onboarding, Scan, Analysing and the Home empty state place their content at the
prototype's absolute offsets from the top safe area. Those offsets were drawn for
a phone; two containers are shorter than the one they assume:

- an iPhone-only app on iPad, which iPadOS runs in a **375x647pt compatibility
  window** — verified on the iPad Air 11-inch (M3) App Review used;
- the **4.7-inch iPhones** still on iOS 17, whose content area is 647pt tall.

In both, the last rows of content ran under the pinned CTA. Build 1.0.1 (30) made
the screens scroll, which put that content in reach but left it looking cropped
at rest — which is what a reviewer screenshots, and App Review rejected it a
second time on the same ground.

Two pieces in `DesignSystem/Foundation/DesignFit.swift` fit them instead:

- **`DesignOffsetStack`** — a `SwiftUI.Layout` that places blocks at the design's
  offsets and, when the height available is short, squeezes the offsets by
  bisection while keeping every block a minimum gap clear of the one above. A
  block can move up; two blocks can never collide, which a plain scale factor on
  the offsets cannot promise, because the copy standing at those offsets keeps
  its own height. The available height is passed in — these stacks live inside
  scroll views, which propose unbounded height — and the owning screen measures
  its slot with `measureHeight`.
- **`Layout.designFit(slot:design:)`** — the ratio that shrinks the fixed-height
  imagery a closed gap cannot make room for: the halo portrait, the technology
  landmark frame, the Scan face guide, the analysis photo. `Layout.DesignSlot`
  holds the height each was drawn against, chosen so the factor is 1 on every
  supported iPhone.

Both are inert at the design's own height. Verified by pixel-diffing every screen
on an iPhone 17 Pro against the previous build: identical below the status bar,
apart from the animated sweep and breathing glows, and the two screens whose
content changed on purpose.

The screens still scroll as well. That is the fallback at the largest
accessibility text sizes, where no gap is enough.

## What to wire next

Vision (M2) and the subscription layer (M3) are wired. What remains:

- **Nothing on the store side.** RevenueCat is wired to the client's live
  `moglens` project: the public SDK key is in `RevenueCatConfiguration`, the
  entitlement is `premium`, and the `default` offering carries `$rc_annual` →
  `moglens_annual` and `$rc_monthly` → `moglens_monthly`. Both products exist in
  the `MogLens Pro` subscription group on App Store Connect at $39.99/year and
  $12.99/month. They sit at *Prepare for Submission*: Apple requires the first
  subscription group be submitted with an app version, so purchases only run in
  sandbox until the build ships — and RevenueCat shows the products as
  "Could not check" for the same reason.
- **Real legal copy.** `DesignContent.Legal` is placeholder text, marked as such
  paragraph by paragraph. The screen, repository and use case are final. The
  exception is the Privacy Policy's **Facial Scan Data** and **Data Retention and
  Deletion** sections, rewritten on 17 September 2026 to carry what App Review
  asks for under 5.1.1(i) — see `docs/PRIVACY-POLICY.md`, which is the text the
  published policy at moglens.org/privacy.html has to match word for word.
- **App Store submission** (M4): metadata, screenshots and the Transporter
  upload. `Resources/PrivacyInfo.xcprivacy` is already in place.
