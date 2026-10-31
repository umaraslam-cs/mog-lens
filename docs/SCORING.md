# MogLens — how the score is calculated

Reference for the M2 build. Every number the app shows is derived from the
measurements described here. Nothing is estimated, guessed, or produced by a
model — the same photo always produces the same score.

Prepared 20 Aug 2026.

---

## 1. The short version

1. Apple's Vision framework finds facial landmarks in the photo.
2. Five geometric measurements are taken from those landmarks.
3. Each measurement is compared against where real faces actually fall, giving a
   percentile ("Top X%").
4. The five percentiles are combined into one score out of 100.
5. The score maps to a tier.

The only part that involves judgement is step 3 — deciding what counts as
average — and that is set from measured photos, not opinion. Section 5 covers
where those numbers came from.

---

## 2. Getting the landmarks

**Detection.** `VNDetectFaceLandmarksRequest`, Apple's on-device face model. If
several faces are in frame, the largest is scanned. No face at all is rejected
before the analysis screen.

**Six readings, not one.** The photo is read six times — at three sizes (100%,
90%, 80%), each also mirrored left-to-right — and the median of each measurement
is taken.

This matters more than it sounds. Vision's landmark positions shift by a pixel
or two depending on how the image is sampled, and a properly calibrated score
amplifies that, because the percentile scale is only as wide as real faces
actually spread. The mirrored readings do most of the work: all five
measurements are unchanged by mirroring (flipping a face cannot change how
symmetric it is, or the angle at its jaw), but Vision's own left/right bias
flips with the image and cancels out in the median.

Measured effect, on 34 photos each re-read after a 3° rotation, both runs using
the exact scoring tables below so only the reading count differs:

| | three readings | six readings |
|---|---|---|
| typical score difference | 5.5 points | **3.5 points** |
| worst case | 24 points | **18 points** |
| photos keeping their tier | 23 / 34 | **31 / 34** |

Five and seven sizes were also tested. The typical difference stops improving
while the worst case gets worse, so six is where it settles.

**Corrections applied before measuring.**

- *Head tilt (roll)* is removed — every point is rotated so the eyes are level,
  so a tilted head doesn't skew anything measured against the facial midline.
- *Image aspect* is corrected so horizontal and vertical distances are in the
  same units.
- *Scale* — every measurement is either an angle, or one distance divided by
  another taken from the same face, so how large the face sits in the frame does
  not change the result.

**Head turn (yaw)** is estimated but never blocks a scan. Past 12° the result
carries a visible note that the head was turned. The scan still scores — the
agreed behaviour is warn, never block.

---

## 3. The five measurements

All coordinates are in a square space with equal units on both axes, after the
corrections above.

### Facial Symmetry — 0–100, higher is better

Four paired features are compared across the facial midline, which runs from the
midpoint between the pupils to the chin:

- left eye centre vs right eye centre
- left eyebrow centre vs right eyebrow centre
- left mouth corner vs right mouth corner
- left end of the jaw outline vs right end (up by the ears)

For each pair, the perpendicular distance from each side to the midline is
measured, and the two are subtracted. The four differences are averaged and
divided by the interpupillary distance.

```
symmetry = 100 − (mean paired difference ÷ interpupillary distance) × 400
```

A mean difference of 0.25 interpupillary widths scores 0. Perfect agreement
scores 100.

### Jaw Angle — degrees, higher is sharper

Measured at the **gonion** — the corner of the jaw, not the chin — between the
line running up to the ear and the line running forward to the chin. Both sides
are measured and averaged, which steadies the number when one side of the jaw
outline is detected less cleanly.

```
jaw angle = mean of ( angle at left gonion, angle at right gonion )
```

Measuring at the chin instead would give a different quantity entirely, around
50°, and would not be comparable to the gonial angles used in the community.

### Chin-to-Nose Ratio — ratio, 1.0 is balanced

Lower third of the face over middle third.

```
chin ratio = distance(nose base → chin) ÷ distance(brow line → nose base)
```

The brow line is the average of the two eyebrows, not the pupil line. Pupils sit
well below the brows, and using them shortens the denominator enough to push
every face far above 1.0.

Scored on **distance from 1.0** — equal thirds. Being well above or well below
is penalised the same.

### Eye Spacing — ratio, average is best

```
eye spacing = distance(pupil → pupil) ÷ face width at its widest
```

Scored on **distance from average**, because the brief describes this one
relatively — eyes set tighter or wider than average read differently, with
neither extreme named as the good one.

An earlier version measured pupil separation against a single eye's own width.
That was the weakest metric in the set: an eye region is small, so its detected
size drifts as the face gets smaller in frame — 21% between a large and a small
photo of the same face. Both distances in the current formula are large and
stable.

### Midface Ratio — ratio, lower is better

```
midface ratio = distance(pupil line → mouth, vertically) ÷ face width
```

Shorter scores higher, with no penalty at the short end, matching the brief:
"shorter midface reads as more compact, hunter-coded, and youthful."

---

## 4. Turning a measurement into a percentile

Each measurement is placed on a curve of anchor points. A value at the observed
median earns the 50th percentile; the observed 90th earns p90; values between
anchors are interpolated in a straight line.

Interpolated rather than bucketed on purpose — with buckets, a measurement
moving a hair makes the score jump, which reads as the app being unstable.

Values beyond the ends of a curve are held at the end value.

### Facial Symmetry (higher is better)

| value | 70.9 | 78.8 | 88.3 | 90.8 | 93.1 | 95.5 | 96.7 |
|---|---|---|---|---|---|---|---|
| percentile | 2 | 5 | 25 | 50 | 75 | 90 | 98 |

### Jaw Angle (higher is better)

| degrees | 126.9 | 131.4 | 134.7 | 137.2 | 139.8 | 144.2 | 146.6 |
|---|---|---|---|---|---|---|---|
| percentile | 2 | 5 | 25 | 50 | 75 | 90 | 98 |

### Chin-to-Nose Ratio (scored on distance from 1.0)

| distance from 1.0 | 0.021 | 0.070 | 0.154 | 0.215 | 0.313 | 0.332 |
|---|---|---|---|---|---|---|
| percentile | 95 | 75 | 50 | 25 | 10 | 5 |

### Eye Spacing (scored on distance from 0.4816)

| distance from average | 0.0024 | 0.0085 | 0.0149 | 0.0309 | 0.0353 | 0.0410 |
|---|---|---|---|---|---|---|
| percentile | 95 | 75 | 50 | 25 | 10 | 5 |

### Midface Ratio (lower is better)

| ratio | 0.4587 | 0.4662 | 0.4716 | 0.5085 | 0.5318 | 0.5656 | 0.5815 | 0.6229 |
|---|---|---|---|---|---|---|---|---|
| percentile | 98 | 95 | 90 | 75 | 50 | 25 | 10 | 2 |

---

## 5. Where these numbers came from

**34 phone photos, supplied 20 Aug 2026.** Every one was run through the real
app pipeline — same Vision request, same six readings — and the anchors above
are that set's quantiles. All 34 were usable: face detected, full outline, and
every one front-on within 6° of straight.

**They replaced curves built from public web portraits**, which measured the
wrong thing. Front-camera photos are taken close up, and that perspective
stretches the lower face. Against the web-derived curves, these phone photos
scored a median of p3 on midface with 18 of 34 pinned to the bottom, p18 on eye
spacing with 11 pinned, and p81 on jaw with 15 pinned to the top. Only chin ratio
survived. That mismatch is what produced HTN on almost every scan.

**Honest limitation: 34 faces is a small sample, and the ends are the thin part.**
The middle of each curve — the median and quartiles — rests on ten or more faces
and is solid. The p2 and p98 anchors rest on one or two faces each and will move
when more photos arrive. In practice this shows up as scores at the very bottom
bunching together rather than spreading out.

More photos, shot the same way (phone front camera, straight on, mixed range of
face types), is the fix. Around 150 would firm up the ends.

---

## 6. Combining into one score

### Weights

The five percentiles are averaged, weighted by how reliably each measurement
reproduces:

| metric | weight | signal-to-noise |
|---|---|---|
| Chin-to-Nose Ratio | 2 | 23.8 |
| Midface Ratio | 2 | 21.5 |
| Jaw Angle | 2 | 20.4 |
| Eye Spacing | 1 | 11.1 |
| Facial Symmetry | 1 | 4.7 |

Signal-to-noise is the spread between different people divided by the spread
across repeat readings of the same face. A high number means the metric tells
people apart reliably; a low number means much of what it reports is measurement
noise. Measured on the 34 photos, each re-read after a 3° rotation.

Symmetry and Jaw Angle remain the headline metrics in the interface, where they
lead the list.

### The composite curve

Averaging five numbers pulls hard toward the middle: a face rarely sits at the
same extreme on all five at once, so the highs and lows cancel. Across the 34
calibration photos the weighted average only ran from 31.7 to 72.5 — left as it
is, nobody would ever see a score above 73 or below 32. It is therefore mapped
back out across the full range:

| weighted average | 31.7 | 33.8 | 43.4 | 51.3 | 58.5 | 65.4 | 72.5 |
|---|---|---|---|---|---|---|---|
| score | 2 | 5 | 25 | 50 | 75 | 90 | 98 |

### Tiers

| tier | score | share of people |
|---|---|---|
| LTN | 0–24 | bottom 25% |
| MTN | 25–54 | next 30% |
| HTN | 55–79 | next 25% |
| Chad Lite | 80–94 | next 15% |
| Chad | 95–100 | top 5% |

Because the score is spread evenly across its range, these bands set how common
each tier is directly.

**Scoring is honest, not generous** — the average face scores 50, not 70. Chosen
20 Aug 2026 so that the progress tracking planned after launch has somewhere to
climb to.

---

## 7. How the current build behaves

Scored across the 34 calibration photos:

| | |
|---|---|
| range | 2 – 98 |
| median | 50 |
| LTN | 8 photos (24%) |
| MTN | 9 photos (27%) |
| HTN | 12 photos (36%) |
| Chad Lite | 3 photos (9%) |
| Chad | 1 photo (3%) |

Verified on an iPhone against the same photos run on a Mac: scores agreed within
1 point typically, 6 at worst, with 32 of 33 landing on the same tier.

### Repeatability

Two scans of the same face should agree. Measured by re-reading each photo after
a 3° rotation:

| | |
|---|---|
| typical difference | 3.5 points |
| within 5 points | 22 / 34 |
| worst case | 18 points |
| same tier both times | 31 / 34 |

Re-scanning the identical image gives an identical score every time — there is
no randomness anywhere in the pipeline.

**This does not yet fully meet the "two scans within a point or two" bar.**
Symmetry is the cause: at a signal-to-noise of 4.7 it is far noisier than the
other four, and that is a property of the measurement — comparing small
left/right differences — rather than a defect that can be tuned away. It already
carries the lowest weight. Reducing its influence further, or showing it without
letting it move the score, would close most of the remaining gap. That is a
product decision, since it is the first metric named in the brief.

---

## 8. Decisions behind these numbers

**Jaw angle anchor.** The original guidance was 125° = Top 10%. Measured with
this pipeline, every one of the 34 phone photos exceeds 125° (the lowest is
125.7°), and 98% of the earlier web-portrait sample did too, so applying it
literally would rank effectively everyone in the top tenth. The measured 90th percentile — 144.2° on
phone photos — sits where 125° was meant to. Confirmed 20 Aug 2026: the
measurement wins over the original estimate.

**Weighting.** The instruction was for the score to lean on whichever metrics are
most consistent, with chin ratio and eye spacing named as the pair. Those names
came from signal-to-noise figures measured on the earlier web-portrait sample
with the earlier eye-spacing formula. On the phone photos with the current
pipeline that ordering does not hold — jaw angle is among the *steadiest*
metrics, and eye spacing is second-weakest. The weights above follow the stated
principle applied to the corrected figures. **This differs from the literal
instruction and is worth confirming.** Reverting to chin ratio and eye spacing at
double weight is a one-line change.

**Honest vs generous scoring.** Honest, average = 50. Confirmed 20 Aug 2026.

---

## 9. What would change these numbers

- **More calibration photos** — the single highest-value input. Firms up the ends
  of every curve.
- **Changing any weight** requires the composite curve in section 6 to be
  re-derived, or the average score drifts off 50.
- **Changing a metric formula** requires that metric's curve re-derived.

All of it lives in one file (`ScoringTable.swift`) and is a matter of replacing
numbers — no logic changes.
