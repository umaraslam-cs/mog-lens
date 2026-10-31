import Foundation

/// Every literal that appears in the design, in one place.
///
/// This is the shipped copy deck — recommendation text, benefit lines, progress
/// messages and sample scan values are all hand-written, never generated. When
/// the real Vision pipeline and StoreKit products land, only the scan and plan
/// sections are replaced; the static copy stays.
enum DesignContent {

    // MARK: - Onboarding

    enum Onboarding {
        static let discoverEyebrow = "FACIAL GEOMETRY & PROPORTIONS"
        static let discoverTitleLead = "DISCOVER WHAT"
        static let discoverTitleAccent = "YOUR FACE"
        static let discoverTitleMid = " IS"
        static let discoverTitleEnd = "REALLY SAYING."
        static let discoverBody = "Your facial proportions create subtle patterns that are easy to miss in the mirror."

        static let ageTitle = "How old are you?"
        static let ageSubtitle = "We'll benchmark your facial proportions against the appropriate age group."

        static let haloEyebrow = "THE HALO EFFECT"
        static let haloTitleLead = "PEOPLE FORM AN"
        static let haloTitleAccent = "IMPRESSION"
        static let haloTitleMid = "BEFORE YOU"
        static let haloTitleEnd = "SPEAK."
        static let haloBody = "Facial features can influence how people perceive confidence, trustworthiness and presence."

        static let selfRatingEyebrow = "BE HONEST"
        static let selfRatingTitleLead = "HOW WOULD YOU RATE"
        static let selfRatingTitleMid = "YOUR "
        static let selfRatingTitleAccent = "APPEARANCE"
        static let selfRatingTitleEnd = " RIGHT"
        static let selfRatingTitleBottom = "NOW?"
        static let selfRatingPerceptionLabel = "YOUR PERCEPTION"
        static let selfRatingScoreDenominator = "/10"
        static let selfRatingNeedsWork = "NEEDS WORK"
        static let selfRatingAverage = "AVERAGE"
        static let selfRatingFlawless = "FLAWLESS"

        static let personalGapTitleAccent = "YOUR PERCEPTION"
        static let personalGapTitleMid = "ISN'T ALWAYS THE"
        static let personalGapTitleEnd = "FULL PICTURE."
        static let personalGapSelfReported = "SELF-REPORTED"
        static let personalGapLeftCaption = "HOW YOU SEE\nYOURSELF"
        static let personalGapRightCaption = "WHAT YOUR FACE\nMEASURES"
        static let personalGapBody = "Some facial proportions are difficult to judge accurately in a mirror. We'll measure the structure behind them."

        static let futureSelfEyebrow = "FUTURE SELF"
        static let futureSelfTitleLead = "Imagine knowing"
        static let futureSelfTitleAccent = "\nexactly what to improve."
        static let futureSelfBody = "Your face already has structural strengths. Our algorithms isolate these baseline metrics to project your optimal aesthetic trajectory."
        static let futureSelfBannerText = "We analyze 128 nodal points to reveal the path to your highest structural potential."

        static let desiredResultEyebrow = "TARGET ARCHITECTURE"
        static let desiredResultTitle = "What kind of result are you aiming for?"
        static let desiredResultCTA = "CONTINUE"

        static let concernTitle = "WHAT WOULD YOU MOST\nLIKE TO IMPROVE?"
        static let concernSubtitle = "Select all areas of focus for your customized aesthetic report."

        static let whyTitle = "The question is"
        static let whyHeroAccent = "Where do you"
        static let whyHeroRemaining = "\nactually stand?"
        static let whySubtitle = "Where do you\nactually stand?"

        static let valuePropositions: [ValueProposition] = [
            .init(
                id: 0,
                symbol: "eye.fill",
                eyebrow: "FIRST IMPRESSION",
                title: "You're read in seconds.",
                detail: "Human brains assess facial symmetry and proportion almost instantaneously. This rapid evaluation shapes subconscious biases before you even speak."
            ),
            .init(
                id: 1,
                symbol: "person.fill.viewfinder",
                eyebrow: "PRESENCE",
                title: "Knowing your strengths can change how you carry yourself.",
                detail: "Confidence isn't just internal; it's heavily influenced by objective self-awareness. Recognizing optimal facial angles enhances physical bearing."
            )
        ]

        static let targetRankTitle = "Where do you want to end up?"
        static let targetRankSubtitle = "Pick the tier you're training toward."
        static let targetRankNote = "Your target sets the gap Mogscan measures you against."
        static let targetRankCTA = "Set Target"

        static let urgencyTitle = "Most men are guessing."
        static let urgencyBody = """
        Jaw angle. Facial thirds. Canthal tilt. These aren't opinions — \
        they're measurable ratios that researchers have studied for decades. \
        In 30 seconds, you'll know exactly where you stand, backed by geometry, not filters.
        """

        static let technologyEyebrow = "HOW WE ANALYZE YOU"
        static let technologyTitleLead = "MEASURED."
        static let technologyTitleAccent = "NOT GUESSED."
        static let technologySubtitle = "Your face is analyzed using measurable facial landmarks and geometric proportions."
        static let technologyPhoto = "Male portrait, front-on, neutral expression"
        static let technologyCTA = "SEE WHAT WE MEASURE"

        static let technologyClaims: [TechnologyClaim] = [
            .init(
                id: 0,
                number: "01",
                symbol: "scope",
                title: "76 Facial Landmarks",
                detail: "Precise topographical mapping of your unique facial structure."
            ),
            .init(
                id: 1,
                number: "02",
                symbol: "angle",
                title: "Real Geometry",
                detail: "Facial proportions calculated directly from raw coordinate data."
            ),
            .init(
                id: 2,
                number: "03",
                symbol: "chart.xyaxis.line",
                title: "Objective Metrics",
                detail: "Hard measurements instead of subjective aesthetic ratings."
            )
        ]

        static let metricsPreviewTitleLead = "YOUR FACE HAS MORE DATA"
        static let metricsPreviewTitleEnd = "THAN A MIRROR SHOWS."
        static let metricsPreviewBody = "Unlock the precise mathematical dimensions of your facial structure through advanced algorithmic analysis."

        static let metricsPreviewTeasers: [FacialMetricTeaser] = [
            .init(
                id: 0,
                symbol: "viewfinder",
                title: "JAW ANGLE",
                detail: "Mandibular ramus angle\nagainst Frankfort plane",
                value: "124°"
            ),
            .init(
                id: 1,
                symbol: "eye.fill",
                title: "CANTHAL TILT",
                detail: "Medial-lateral canthal tilt\nand IPD compactness",
                value: "+5.8°"
            ),
            .init(
                id: 2,
                symbol: "ruler.fill",
                title: "MIDFACE RATIO",
                detail: "Interpupillary to stomion\nvertical ratio index",
                value: "1.01"
            ),
            .init(
                id: 3,
                symbol: "angle",
                title: "CHIN RATIO",
                detail: "1:2 philtrum-to-chin\ngolden ratio balance",
                value: "1 : 2.1"
            ),
            .init(
                id: 4,
                symbol: "arrow.left.and.right",
                title: "fWHR RATIO",
                detail: "Bizygomatic breadth vs\nupper facial height",
                value: "1.88"
            ),
            .init(
                id: 5,
                symbol: "square.split.2x1",
                title: "FACIAL SYMMETRY",
                detail: "76-point sagittal parity\nacross facial planes",
                value: "98.4%"
            ),
            .init(
                id: 6,
                symbol: "lines.measurement.horizontal",
                title: "FACIAL THIRDS",
                detail: "1:1:1 vertical harmony:\nforehead, mid & chin",
                value: "1 : 1 : 1"
            ),
            .init(
                id: 7,
                symbol: "diamond.fill",
                title: "CHEEKBONE ARCH",
                detail: "Zygomatic projection &\nhollow cheek contours",
                value: "1.41"
            )
        ]

        static let scanPrepEyebrow = "WE'RE READY"
        static let scanPrepTitleLead = "Let's meet"
        static let scanPrepTitleEnd = "your face."
        static let scanPrepSubtitle = "For the most accurate analysis:"

        static let scanPrepTips: [ScanPreparationTip] = [
            .init(
                id: 0,
                symbol: "face.smiling",
                title: "Face camera directly",
                subtitle: "Look straight into the lens."
            ),
            .init(
                id: 1,
                symbol: "sun.max.fill",
                title: "Even, natural lighting",
                subtitle: "Avoid harsh shadows."
            ),
            .init(
                id: 2,
                symbol: "face.dashed",
                title: "Neutral expression",
                subtitle: "Relax your facial muscles."
            )
        ]

        static let expertPerspectiveEyebrow = "EXPERT PERSPECTIVE"
        static let expertPerspectiveTitleLead = "FACIAL HARMONY IS ABOUT HOW YOUR FEATURES"
        static let expertPerspectiveTitleAccent = "WORK TOGETHER."
        static let expertPerspectiveSubtitle = "Your face is unique. Understand what makes it work."
        static let expertCards: [ExpertCard] = [
            .init(
                id: 0,
                name: "Dr. Alexander Finch, MD",
                role: "Facial Aesthetics & Craniofacial Specialist",
                credentials: "BOARD CERTIFIED • CLINICAL ADVISOR",
                quote: "“Most men obsess over isolated flaws. True structural presence comes from maximizing proportions and natural symmetry already present in your bone structure.”",
                imageName: AppImage.doctorFinchPortrait
            ),
            .init(
                id: 1,
                name: "Dr. Marcus Webb, MD",
                role: "Maxillofacial & Reconstructive Surgeon",
                credentials: "FELLOW ACSS • RESEARCH DIRECTOR",
                quote: "“The geometry of your face tells a story. Bone structure, jaw projection, and midface ratios interact in ways most people never consciously realize — but everyone perceives.”",
                imageName: AppImage.doctorWebbPortrait
            )
        ]
        static let expertPerspectiveCTA = "CONTINUE"

        static let researchEyebrow = "FIRST IMPRESSIONS"
        static let researchSectionTitle = "What the research says about first impressions"
        static let researchTitleLead = "What the research"
        static let researchTitleMid = "says about"
        static let researchTitleAccent = "first impressions."
        static let researchCardFooter = "Research on how people are judged, not an endorsement of Mogscan."
        static let researchCTA = "Continue"
        static let socialProofCTA = "Continue"

        static let researchCards: [ResearchCard] = [
            .init(
                id: 0,
                headline: "People form an impression of a face in about a tenth of a second.",
                quote: "\"minimal exposure to faces is sufficient for people to form trait impressions\"",
                attribution: "Alexander Todorov & Janine Willis, Princeton University, Psychological Science, 2006",
                footer: "Research on how people are judged, not an endorsement of Mogscan."
            ),
            .init(
                id: 1,
                headline: "Attractive faces tend to be judged as having better personalities and more future success.",
                quote: "\"What is beautiful is good\" (the title of their study)",
                attribution: "Karen Dion, Ellen Berscheid & Elaine Walster, Journal of Personality and Social Psychology, 1972",
                footer: "Research on how people are judged, not an endorsement of Mogscan."
            ),
            .init(
                id: 2,
                headline: "Economist Daniel Hamermesh found attractive people tend to be more likely to be employed, earn more, and get loans approved.",
                quote: nil,
                attribution: "Daniel Hamermesh, University of Texas, Beauty Pays, Princeton University Press, 2011",
                footer: "Research on how people are judged, not an endorsement of Mogscan."
            )
        ]

        static let continueTitle = "Continue"
    }

    // MARK: - Splash

    enum Splash {
        static let wordmark = "MOGSCAN"
        static let subtitle = "Facial Analysis"
        static let footer = "POWERED BY APPLE VISION"
    }

    // MARK: - Home

    enum Home {
        static let welcomeReturning = "Welcome back"
        static let welcomeFirstRun = "Welcome"
        static let title = "Your Face"
        static let currentTierLabel = "CURRENT TIER"
        static let scanAgain = "Scan Again"
        static let metricsSection = "Your metrics"
        static let historySection = "History"
        static let viewAction = "View"
        /// Long-press a history row. Deletes that scan's photo and measurements
        /// from the device — Settings holds the delete-everything button.
        static let deleteScan = "Delete Scan"

        static let emptyTitle = "No scan yet"
        static let emptyBody = """
        One photo. Thirty seconds. You'll see exactly where your face ranks \
        and what to work on.
        """
        static let emptyCTA = "Run Your First Scan"
        static let emptyCaption = "Analysis runs on-device."

        // MARK: Locked

        /// Shown when scans exist but the subscription does not. Names what is
        /// held without giving any of it away — no score, no tier, no metric.
        static let lockedTitle = "Your results are ready"

        static func lockedDetail(count: Int) -> String {
            count == 1
                ? "1 scan measured and waiting. Unlock to see where you stand."
                : "\(count) scans measured and waiting. Unlock to see where you stand."
        }

        static let lockedCTA = "Unlock My Results"
    }

    // MARK: - Scan

    enum Scan {
        static let title = "Scan"
        static let subtitle = "Front-on, neutral face, even light."
        static let takePhoto = "Take Photo"
        static let importPhoto = "Import Photo"

        static let guidelines: [CaptureGuideline] = [
            .init(id: 0, symbol: AppSymbol.evenLight, text: "Even, front-facing light"),
            .init(id: 1, symbol: AppSymbol.neutralExpression, text: "Neutral expression, mouth closed"),
            .init(id: 2, symbol: AppSymbol.eyesLevel, text: "Eyes level with the camera")
        ]

        static let captureTitle = "Position your face"
        static let capturePhoto = "Live camera — male face, front-on"

        static let permissionTitle = "“Mogscan” Would Like to Access the Camera"
        static let permissionBody = """
        Your photo is used to detect facial landmarks on this device. \
        It is never uploaded.
        """
        static let permissionDeny = "Don't Allow"
        static let permissionAllow = "Allow"

        /// Shown when access was refused earlier: iOS will not prompt a second
        /// time, so Settings is the only way back.
        static let cameraDeniedTitle = "Camera access is off"
        static let cameraDeniedBody = """
        Turn on camera access in Settings to take a photo, or import one from \
        your library instead.
        """
        static let cameraDeniedSettings = "Open Settings"
        static let cameraDeniedCancel = "Not now"

        static let analysingTitle = "Analysing"
        static let analysingPhoto = "Captured face photo"

        static let poseFrontOn = "front-on"
        static let poseAngled = "slightly angled"
        static let poseWarning = """
        Your head was turned slightly. Retake it straight-on for the most \
        accurate reading.
        """

        /// One per ``FaceAnalysisError``. All three end the flow the same way,
        /// but the wording tells the user what to do differently next time.
        static func analysisFailure(_ error: FaceAnalysisError) -> (title: String, body: String) {
            switch error {
            case .noFaceDetected:
                ("No face detected", "Make sure your whole face is in the frame and well lit, then try again.")
            case .landmarksUnavailable:
                ("Couldn't read the photo", "Try a clearer, front-on photo with nothing covering your face.")
            case .imageUnreadable:
                ("Couldn't open that photo", "Take a new photo or pick a different one from your library.")
            }
        }

        static let analysisFailureDismiss = "OK"

        /// Progress messages, in order.
        static let analysisSteps: [AnalysisStep] = [
            .init(id: 0, title: "Mapping facial landmarks…", state: .inProgress),
            .init(id: 1, title: "Calculating facial symmetry…", state: .pending),
            .init(id: 2, title: "Evaluating proportions…", state: .pending),
            .init(id: 3, title: "Computing jaw angle…", state: .pending),
            .init(id: 4, title: "Preparing results…", state: .pending)
        ]
    }

    // MARK: - Paywall

    enum Paywall {
        static let title = "Your analysis is ready."
        static let subtitle = "76 landmarks measured. Unlock to see where you actually stand."
        static let cta = "Unlock My Results"

        /// Names the target the user picked in onboarding, which is theirs
        /// already and gives nothing of the result away. Naming the tier they
        /// actually scored here would breach the hard paywall.
        static func targetTeaser(_ target: String) -> String {
            "You're training for \(target). Find out how far off you are."
        }

        static let disclaimer = "Auto-renews until cancelled. Cancel anytime in Settings."
        static let restore = "Restore Purchases"
        /// Spelled out rather than abbreviated to "Terms" / "Privacy": Guideline
        /// 3.1.2 asks for links to the Terms of Use and the privacy policy by
        /// name, and this row is the only place a subscriber sees them.
        static let terms = "Terms of Use"
        static let privacy = "Privacy Policy"

        static let benefits: [PaywallBenefit] = [
            .init(
                id: 0,
                symbol: "scope",
                title: "Overall Score & Facial Tier",
                subtitle: "Your verified aesthetic rating & percentile",
                detail: "See your composite 1.0–10.0 rating and unlock your true tier and global percentile rank.",
                highlights: [
                    "Exact 1.0–10.0 composite aesthetic rating",
                    "Aesthetic tier classification (Subfive to Chad)",
                    "Global & age benchmarked percentile standing"
                ]
            ),
            .init(
                id: 1,
                symbol: "ruler.fill",
                title: "Full Biometric Scan Breakdown",
                subtitle: "76 landmark points across all facial planes",
                detail: "Get hard mathematical readouts for gonial angle, canthal tilt, midface ratio, fWHR, and symmetry.",
                highlights: [
                    "Exact angles in degrees, millimeters & ratios",
                    "Frankfort plane & sagittal vector analysis",
                    "Target reference ideal ranges for every metric"
                ]
            ),
            .init(
                id: 2,
                symbol: "arrow.clockwise",
                title: "Unlimited Scans & Trajectory Tracking",
                subtitle: "Track changes over time with side by side history",
                detail: "Track your aesthetic progression over time with unlimited rescans and side-by-side comparisons.",
                highlights: [
                    "Unlimited scans with instant AI analysis",
                    "Side by side historical photo comparisons",
                    "Longitudinal ratio & symmetry progress charts"
                ]
            )
        ]

        /// Plan names and the shapes the price captions are poured into.
        ///
        /// Copy only — every figure comes from the RevenueCat `StoreProduct`,
        /// so an App Store price change or a foreign currency needs no build,
        /// and nothing here can quote a price the store isn't charging.
        static func planTitle(_ period: SubscriptionPlan.Period) -> String {
            switch period {
            case .monthly: "Monthly"
            case .annual: "Annual"
            }
        }

        static func monthlyCaption(_ price: String) -> String { "\(price) / month" }

        static func annualCaption(_ price: String, perMonth: String) -> String {
            "\(price) / year · \(perMonth) per month"
        }

        static func savingsBadge(_ percent: Int) -> String { "SAVE \(percent)%" }

        /// Stand-ins for the plan list. Shown instead of prices, never beside
        /// them: until the App Store answers there is no figure to quote.
        static let plansLoading = "Loading plans\u{2026}"
        static let plansUnavailable = "Plans couldn't be loaded. Check your connection and try again."
        static let plansRetry = "Try Again"

        // MARK: Purchase outcomes

        /// Shown when a restore found no active subscription. Not phrased as a
        /// failure — the common cause is a user who never subscribed tapping it
        /// to see what it does.
        /// Titles the outcome alert. Neutral on purpose — the same alert carries
        /// a failed purchase and an empty restore.
        static let noticeTitle = "Subscription"
        static let nothingToRestore = "No active subscription found on this Apple ID."
        /// A purchase that completed without granting the entitlement — Ask to
        /// Buy awaiting a parent, or a payment still being authorised. Not a
        /// failure, and not a reason to charge again.
        static let purchasePending = "Your purchase is still being confirmed. Your results unlock as soon as it clears."
        static let purchaseFailed = "That purchase didn't go through. Nothing has been charged."
        static let restoreFailed = "Couldn't reach the App Store to restore. Try again in a moment."
        static let offeringUnavailable = "Plans are still loading. Give it a second and try again."
        static let errorDismiss = "OK"
    }

    // MARK: - Results

    enum Results {
        static let metricsSection = "Metrics"
        /// Heads the advice block under the metrics.
        ///
        /// The client's condition for the unlocked report was that it not feel
        /// like selling a bare number, so the two weakest metrics come with
        /// something to do about them before the CTA to the full plan.
        static let adviceSection = "What to work on"
        static let adviceWhyLabel = "WHY IT MATTERS"
        static let photo = "Analysed face photo"
        static let planCTA = "See My Plan"
        /// Ends the scan flow and hands over to the tab shell.
        static let homeCTA = "Go to Home"

        /// Home hero line, naming whichever metric carries the score.
        static func summary(_ metricName: String, topPercentage: Int) -> String {
            "\(metricName) is carrying your score — top \(topPercentage)%."
        }

        static let summaryFallback = "Your analysis is ready."

        /// Age-banded comparison is not wired yet — onboarding collects an age
        /// but nothing passes it to scoring. Reads against the whole population
        /// until it does.
        static func percentileSummary(_ score: Int) -> String {
            "Better than \(score)% of men"
        }

        /// The distance between the tier picked in onboarding and the one
        /// scored, which is what the target question was collected for.
        static let currentLabel = "CURRENT"
        static let targetLabel = "TARGET"

        static func targetReached(_ tier: String) -> String {
            "You're at your target — \(tier)"
        }

        static func targetPassed(_ tier: String) -> String {
            "You're past your target — \(tier)"
        }
    }

    // MARK: - Improve

    enum Improve {
        static let title = "Improve"
        static func subtitle(dateText: String) -> String { "Based on your scan of \(dateText)." }

        /// Shown in place of the measured advice while the scan is unpaid.
        /// Names what is held back without naming a metric.
        static let lockedDetail = "Your plan is built from your scan. Unlock to see what to work on first."

        /// Cards in their declared order. Only the sort order is dynamic.
        static let recommendations: [Recommendation] = [
            .init(
                category: .skincare,
                detail: "Cleanse, moisturise, SPF daily. Clear skin lifts perceived symmetry.",
                difficulty: .easy,
                timeCommitment: "5 min / day"
            ),
            .init(
                category: .posture,
                detail: "Neutral neck and chin tucked. Forward head flattens the jawline.",
                difficulty: .medium,
                timeCommitment: "All day"
            ),
            .init(
                category: .jawExercises,
                detail: "Chewing resistance and tongue posture, worked consistently.",
                difficulty: .hard,
                timeCommitment: "10 min / day"
            ),
            .init(
                category: .sleep,
                detail: "7–9 hours, back sleeping. Puffiness is the fastest visible win.",
                difficulty: .easy,
                timeCommitment: "Nightly"
            ),
            .init(
                category: .hydration,
                detail: "3L water, low sodium. Water retention blurs facial definition.",
                difficulty: .easy,
                timeCommitment: nil
            ),
            .init(
                category: .grooming,
                detail: "Hairline, brows and stubble shaped to your face width.",
                difficulty: nil,
                timeCommitment: nil
            ),
            .init(
                category: .lifestyle,
                detail: "Lower body fat, less alcohol, train consistently.",
                difficulty: nil,
                timeCommitment: nil
            )
        ]

        /// Heads the metric-by-metric advice, above the general habit cards.
        static let adviceSection = "Your metrics"
        static let habitsSection = "General habits"

        static let lowerThirdFocus = PriorityFocus(
            title: "Priority: lower third",
            detail: "Chin ratio and jaw definition move your score most.",
            leadingCategory: .jawExercises
        )

        /// Banner copy for whichever metric scored lowest.
        ///
        /// Was a single fixed line naming the lower third whatever the scan
        /// said, which read as canned the moment a user's weakest metric was
        /// their eyes. Each case names the region the score actually points at
        /// and floats the habit card that moves it.
        static func focus(for kind: FacialMetric.Kind) -> PriorityFocus {
            switch kind {
            case .facialSymmetry:
                PriorityFocus(
                    title: "Priority: balance",
                    detail: "Symmetry is your weakest metric. Sleep position and even chewing hold it steady.",
                    leadingCategory: .sleep
                )
            case .jawAngle:
                PriorityFocus(
                    title: "Priority: jawline",
                    detail: "Jaw angle is your weakest metric. Body fat and jaw work move it most.",
                    leadingCategory: .jawExercises
                )
            case .chinRatio:
                lowerThirdFocus
            case .eyeSpacing:
                PriorityFocus(
                    title: "Priority: upper third",
                    detail: "Eye spacing is your weakest metric. Brow shape and sleep change how it reads.",
                    leadingCategory: .grooming
                )
            case .midfaceRatio:
                PriorityFocus(
                    title: "Priority: midface",
                    detail: "Midface ratio is your weakest metric. Facial leanness is the biggest lever.",
                    leadingCategory: .lifestyle
                )
            }
        }
    }

    // MARK: - Settings

    enum Settings {
        /// Delete All Scan Data. Worded so the confirmation says exactly what
        /// leaves the device — App Review reads this as the consent-withdrawal
        /// mechanism for face data, so it has to name the photos, not just the
        /// scores.
        static let deleteDataConfirmTitle = "Delete all scan data?"
        static let deleteDataConfirmBody = """
        This permanently removes every scan on this device: the photos, the \
        facial landmarks measured from them and the scores. It cannot be undone, \
        and there is no copy anywhere else.
        """
        static let deleteDataConfirm = "Delete Everything"
        static let deleteDataCancel = "Cancel"

        /// Shown after a restore that actually brought a subscription back.
        /// Nothing else on the sheet changes, so without this the row reads as
        /// a button that did nothing.
        static let restoreSucceeded = "Your subscription is active again. Your results are unlocked."

        /// Apple's subscription management page. Used when the in-app sheet has
        /// nothing to show — see ``SettingsView.manageSubscription()``.
        static let manageSubscriptionsURL = URL(string: "https://apps.apple.com/account/subscriptions")

        static let title = "Settings"
        static let done = "Done"

        /// Support inbox. Contact Support opens the mail app on this address
        /// with the subject prefilled, so a mail arrives already labelled.
        static let supportEmail = "help@mogscan.app"
        static let supportSubject = "Mogscan support"

        /// The App Store listing, used by both Rate App and Share App.
        ///
        /// The numeric id is the app's Apple ID on App Store Connect. It is
        /// stable for the life of the app, and the slug in a full marketing URL
        /// is not, so the id form is the one to hardcode.
        static let appStoreID = "6799755757"
        static var appStoreURL: URL? {
            URL(string: "https://apps.apple.com/app/id\(appStoreID)")
        }

        /// Sits above the link in the share sheet. Written to be forwarded to a
        /// friend, so it says what the app does rather than naming it twice.
        static let shareSubject = "Mogscan — Facial Analysis"
        static let shareMessage = """
        I ran my face through this — it measures jaw angle, symmetry and facial \
        thirds with real geometry and scores you against everyone else. \
        Measured, not guessed. See where you land:
        """

        static let sections: [SettingsSection] = [
            SettingsSection(
                id: "subscription",
                header: "SUBSCRIPTION",
                entries: [
                    .init(
                        id: "restore",
                        title: "Restore Purchases",
                        symbol: AppSymbol.restorePurchases,
                        tint: .accent
                    ),
                    .init(
                        id: "manage",
                        title: "Manage Subscription",
                        symbol: AppSymbol.manageSubscription,
                        tint: .accent
                    )
                ]
            ),
            SettingsSection(
                id: "legal",
                header: "LEGAL",
                entries: [
                    .init(
                        id: "privacy",
                        title: "Privacy Policy",
                        symbol: AppSymbol.privacyPolicy,
                        tint: .neutral
                    ),
                    .init(
                        id: "terms",
                        title: "Terms of Use",
                        symbol: AppSymbol.termsOfService,
                        tint: .neutral
                    )
                ]
            ),
            SettingsSection(
                id: "data",
                header: "FACE DATA",
                entries: [
                    .init(
                        id: "delete-data",
                        title: "Delete All Scan Data",
                        symbol: AppSymbol.delete,
                        tint: .destructive
                    )
                ]
            ),
            SettingsSection(
                id: "support",
                header: "SUPPORT",
                entries: [
                    .init(id: "rate", title: "Rate App", symbol: AppSymbol.rateApp, tint: .warning),
                    .init(id: "share", title: "Share App", symbol: AppSymbol.shareApp, tint: .accent),
                    .init(
                        id: "contact",
                        title: "Contact Support",
                        symbol: AppSymbol.contactSupport,
                        tint: .neutral
                    )
                ]
            )
        ]

        static let version = AppVersionInfo(
            marketingVersion: "1.0.1",
            buildNumber: "31",
            disclaimer: "Not a medical device."
        )
    }

    // MARK: - Legal

    /// Client-supplied legal copy, verbatim from the published Privacy Policy
    /// and Terms of Use dated 24 August 2026. Wording is not ours to edit — a
    /// change here has to come from the client's own documents, so the two stay
    /// in step. Bullet lists are newline-joined because ``LegalDocument.Section``
    /// renders one `Text` per section.
    enum Legal {
        static let done = "Done"

        static let privacy = LegalDocument(
            kind: .privacy,
            title: "Privacy Policy",
            lastUpdated: "Last updated: September 17, 2026",
            summary: """
            Mogscan ("we", "us", "our") respects your privacy. This policy \
            explains what happens when you use the Mogscan app.
            """,
            sections: [
                .init(
                    id: 0,
                    heading: "Facial Scan Data",
                    body: """
                    When you use Mogscan's facial scan feature, your photo is \
                    processed entirely on your device using Apple's Vision \
                    framework. Your photo is never uploaded, transmitted, or \
                    stored on any server we control. The analysis (facial \
                    landmarks, measurements, and resulting score) happens \
                    locally on your iPhone and is not accessible to us in any \
                    form.
                    """
                ),
                .init(
                    id: 1,
                    heading: "Information We Collect",
                    body: """
                    We collect the minimum information necessary to operate the app:

                    \u{2022}  Subscription and purchase status, handled by our \
                    payment processor (RevenueCat / Apple's App Store), used to \
                    confirm your access to premium features.
                    \u{2022}  Basic, anonymized usage data (such as app crashes \
                    or performance) that may be collected automatically by \
                    Apple's standard App Store Connect analytics.

                    We do not collect your name, email, or any personal account \
                    information, since Mogscan does not require account creation.
                    """
                ),
                .init(
                    id: 2,
                    heading: "Third-Party Services",
                    body: """
                    Mogscan uses the following third-party services:

                    \u{2022}  Apple Vision Framework - for on-device facial \
                    landmark detection. No data leaves your device for this \
                    purpose.
                    \u{2022}  RevenueCat - to manage subscription purchases and \
                    verify entitlements through Apple's App Store. RevenueCat \
                    may process your anonymous purchase/subscription status. \
                    See RevenueCat's Privacy Policy for details.
                    \u{2022}  Apple App Store / StoreKit - to process payments \
                    securely. We never see or store your payment details.
                    """
                ),
                .init(
                    id: 3,
                    heading: "Consent, Deletion, and Revoking Access",
                    body: """
                    Using the facial scan feature is entirely optional and \
                    requires your active choice each time you take or import a \
                    photo. You can revoke your consent to any future face data \
                    collection at any time by not using the scan feature again, \
                    or by deleting the app entirely.

                    Mogscan gives you two ways to delete your face data \
                    directly inside the app:

                    \u{2022}  Delete a single scan - on the Home screen, press \
                    and hold any scan in your History, then tap "Delete Scan." \
                    This permanently removes that photo and its measurements \
                    from your device.
                    \u{2022}  Delete all scan data - in Settings, open the \
                    "Face Data" section and tap "Delete All Scan Data." After \
                    you confirm, every stored photo, measurement, and score is \
                    permanently wiped from your device.

                    Both actions delete the actual image files themselves, not \
                    just their listing, with no copy retained anywhere.

                    Deleting the app itself also removes all remaining face \
                    data from your device immediately and permanently.

                    Since face data is never transmitted off your device, there \
                    is no server-side copy for us to delete, and no third party \
                    ever receives or stores it.
                    """
                ),
                .init(
                    id: 4,
                    heading: "Data Retention and Deletion",
                    body: """
                    Since scan photos and results are stored only locally on \
                    your device, deleting the app removes all of this data \
                    permanently. We hold no copy of it on any server. Should \
                    Mogscan ever share face data with a third-party service in \
                    the future, that service would be contractually required to \
                    provide the same or equal protection of that data as \
                    described in this policy.
                    """
                ),
                .init(
                    id: 5,
                    heading: "Children's Privacy",
                    body: """
                    Mogscan is not directed at children under 13, and we do not \
                    knowingly collect any information from children under 13.
                    """
                ),
                .init(
                    id: 6,
                    heading: "Changes to This Policy",
                    body: """
                    We may update this policy from time to time. Continued use \
                    of the app after changes means you accept the updated policy.
                    """
                ),
                .init(
                    id: 7,
                    heading: "Contact",
                    body: """
                    Questions about this policy? Reach out via our Support page.
                    """
                )
            ]
        )

        static let terms = LegalDocument(
            kind: .terms,
            title: "Terms of Use",
            lastUpdated: "Last updated 24 August 2026",
            summary: """
            By downloading or using Mogscan ("the App"), you agree to these \
            Terms of Use.
            """,
            sections: [
                .init(
                    id: 0,
                    heading: "Description of Service",
                    body: """
                    Mogscan analyzes a photo of your face using on-device \
                    geometric measurements to provide an aesthetic score, tier \
                    ranking, and related content. Mogscan is intended for \
                    entertainment and self-improvement purposes only.
                    """
                ),
                .init(
                    id: 1,
                    heading: "Not Medical Advice",
                    body: """
                    Mogscan does not provide medical, dermatological, \
                    psychological, or professional advice of any kind. Results, \
                    tips, and routines shown in the app are for general \
                    informational purposes only and should not be relied upon as \
                    a substitute for professional consultation.
                    """
                ),
                .init(
                    id: 2,
                    heading: "Subscriptions",
                    body: """
                    Mogscan offers auto-renewing subscription plans (monthly and \
                    annual) that unlock full access to your scan results and \
                    related features.

                    \u{2022}  Payment is charged to your Apple ID account at \
                    confirmation of purchase.
                    \u{2022}  Subscriptions automatically renew unless canceled \
                    at least 24 hours before the end of the current period.
                    \u{2022}  You can manage or cancel your subscription anytime \
                    in your Apple ID account settings.
                    \u{2022}  No refund will be issued for the unused portion of \
                    a subscription term, except as required by Apple's policies \
                    or applicable law.
                    """
                ),
                .init(
                    id: 3,
                    heading: "Acceptable Use",
                    body: """
                    You agree not to use Mogscan to upload or attempt to analyze \
                    photos of anyone other than yourself without their consent, \
                    or to misuse the app in any way that violates applicable laws.
                    """
                ),
                .init(
                    id: 4,
                    heading: "Accuracy of Results",
                    body: """
                    While Mogscan's measurements are based on real geometric \
                    calculations from your photo, results are inherently limited \
                    by photo quality, angle, and lighting. We make no guarantee \
                    of clinical or scientific precision.
                    """
                ),
                .init(
                    id: 5,
                    heading: "Limitation of Liability",
                    body: """
                    Mogscan is provided "as is" without warranties of any kind. \
                    To the maximum extent permitted by law, we are not liable for \
                    any indirect, incidental, or consequential damages arising \
                    from your use of the app.
                    """
                ),
                .init(
                    id: 6,
                    heading: "Changes to These Terms",
                    body: """
                    We may update these Terms from time to time. Continued use of \
                    the app after changes means you accept the updated Terms.
                    """
                ),
                .init(
                    id: 7,
                    heading: "Contact",
                    body: """
                    Questions about these Terms? Reach out via our Support page.
                    """
                )
            ]
        )
    }

    // MARK: - Tab bar

    enum Tabs {
        static let home = "Home"
        static let scan = "Scan"
        static let improve = "Improve"
    }

    // MARK: - Rating Prompt

    enum RatingPrompt {
        static let eyebrow = "APP STORE REVIEW"
        static let title = "Enjoying MogScan?"
        static let subtitle = "Your rating helps us refine our AI facial geometry models and keep improving your aesthetic analysis."
        static let trustBadge = "⭐ 4.9 • Trusted by 140,000+ Men"
        static let rateCTA = "RATE ON APP STORE"
        static let continueCTA = "Continue to Results"
        static let appStoreURLString = "https://apps.apple.com/app/id6799755757?action=write-review"
    }
}
