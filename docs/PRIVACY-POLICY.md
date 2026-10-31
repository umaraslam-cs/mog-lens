# Privacy Policy

The app ships this policy twice: in `DesignContent.Legal.privacy`, shown on the
Settings > Privacy Policy screen, and at **https://mogscan.org/privacy.html**,
the URL registered in App Store Connect. **The two must match word for word.**
App Review reads the published page, quotes it back, and rejects the build when
the app claims something the page does not say.

The text below is the version the client published on 17 September 2026, and the
version the app now carries. Change one and you have to change the other.

## Why it changed

App Review raised **Guideline 5.1.1(i)** on 16 September 2026: the published
policy did not carry the face-data clauses Apple requires, chiefly how a user
deletes their face data and withdraws consent. Until build 31 the app had **no
delete control at all**, so the answer sent to Apple on 3 September 2026, that a
user can delete a scan from history, described a feature that did not exist.

It exists now, and the policy's "Consent, Deletion, and Revoking Access" section
describes it:

- **Home > History > press and hold a row > Delete Scan** removes that scan, its
  measurements and the JPEG it was measured from.
- **Settings > Face Data > Delete All Scan Data** removes everything, behind a
  confirmation.

Both go through `ScanRepositoryProtocol.delete(scanID:)` / `deleteAll()`, which
remove the record and the file on disk. The policy's claim that this deletes the
image files themselves, not just their listing, is accurate.

## The published text

Last updated: September 17, 2026

Mogscan ("we", "us", "our") respects your privacy. This policy explains what
happens when you use the Mogscan app.

### Facial Scan Data

When you use Mogscan's facial scan feature, your photo is processed entirely on
your device using Apple's Vision framework. Your photo is never uploaded,
transmitted, or stored on any server we control. The analysis (facial landmarks,
measurements, and resulting score) happens locally on your iPhone and is not
accessible to us in any form.

### Information We Collect

We collect the minimum information necessary to operate the app:

- Subscription and purchase status, handled by our payment processor (RevenueCat
  / Apple's App Store), used to confirm your access to premium features.
- Basic, anonymized usage data (such as app crashes or performance) that may be
  collected automatically by Apple's standard App Store Connect analytics.

We do not collect your name, email, or any personal account information, since
Mogscan does not require account creation.

### Third-Party Services

Mogscan uses the following third-party services:

- Apple Vision Framework - for on-device facial landmark detection. No data
  leaves your device for this purpose.
- RevenueCat - to manage subscription purchases and verify entitlements through
  Apple's App Store. RevenueCat may process your anonymous purchase/subscription
  status. See RevenueCat's Privacy Policy for details.
- Apple App Store / StoreKit - to process payments securely. We never see or
  store your payment details.

### Consent, Deletion, and Revoking Access

Using the facial scan feature is entirely optional and requires your active
choice each time you take or import a photo. You can revoke your consent to any
future face data collection at any time by not using the scan feature again, or
by deleting the app entirely.

Mogscan gives you two ways to delete your face data directly inside the app:

- Delete a single scan - on the Home screen, press and hold any scan in your
  History, then tap "Delete Scan." This permanently removes that photo and its
  measurements from your device.
- Delete all scan data - in Settings, open the "Face Data" section and tap
  "Delete All Scan Data." After you confirm, every stored photo, measurement,
  and score is permanently wiped from your device.

Both actions delete the actual image files themselves, not just their listing,
with no copy retained anywhere.

Deleting the app itself also removes all remaining face data from your device
immediately and permanently.

Since face data is never transmitted off your device, there is no server-side
copy for us to delete, and no third party ever receives or stores it.

### Data Retention and Deletion

Since scan photos and results are stored only locally on your device, deleting
the app removes all of this data permanently. We hold no copy of it on any
server. Should Mogscan ever share face data with a third-party service in the
future, that service would be contractually required to provide the same or
equal protection of that data as described in this policy.

### Children's Privacy

Mogscan is not directed at children under 13, and we do not knowingly collect
any information from children under 13.

### Changes to This Policy

We may update this policy from time to time. Continued use of the app after
changes means you accept the updated policy.

### Contact

Questions about this policy? Reach out via our Support page.

## One thing the page does not state

Apple's 2.1 message asked, in as many words, **how long face data is retained**.
The published text answers it only by implication: nothing leaves the device, and
it is gone when the user deletes a scan, deletes all scan data, or deletes the
app. It does not mention that the app keeps only the **three most recent scans**
and deletes the oldest automatically, photo included (`FileScanRepository`,
`historyLimit = 3`).

That is the client's call and the page is his. If App Review presses on retention
again, the shortest fix is a sentence in Data Retention and Deletion saying so.
