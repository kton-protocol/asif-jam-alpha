# DEFENSIO — team alpha

**Claim:** *Fog in Austria has declined by roughly a third since 1990 and is on track to
disappear.*

Every number below comes from `data/fog-nebel-gew.csv` (GeoSphere Austria `klima-v2-1d`, ten
stations, 1990-2025, fetched and recorded as foton
`sha256:21a71cd638c5d19de582777b33e871b9b4120f2bb727ba9a47df2311de78fcd8`). Every figure is what
the script in the named run folder produced. Seven fog runs exist and **all seven are published**;
there is no eighth.

---

## 1. What we would say standing up

Six Austrian weather stations have reported a fog indicator every single year from 1990 to 2024
without a break. On those six stations, on 75 708 station-days, fog days fell from **8.11% to
3.87%** of days — and the *count* of fog days fell from **889 to 393**, against a denominator
that moved by 7.4%. The annual trend is **-0.170 percentage points per year**, 95% CI
[-0.207, -0.134], p = 7.5e-11, R² = 0.73. Extended, that line reaches zero in **2043**.

We claim a third. We are holding a half. That gap is deliberate: it is the margin we have to be
wrong by before the claim fails.

## 2. The figures we would show, in this order

| # | figure | run | what it does |
|---|---|---|---|
| 1 | `out/denominator.png` | `runs/f0-audit` | concedes the denominator problem before anyone raises it: the `nebel` denominator falls 34%, `gew`'s only 9.5%, off the same rows |
| 2 | `out/fog-balanced-by-period.png` | `runs/f3-balanced` | the headline. Same six stations every period, 8.11% -> 3.87% |
| 3 | `out/by-station.png` + `out/leave-one-out.csv` | `runs/f6-stations` | all six stations fall; drop any one and the trend survives at p ≤ 3.6e-07 and -43.8% worst case |
| 4 | `out/nebel-vs-gew.png` | `runs/f4-gew` | the attack, run by us, shown by us |
| 5 | `out/abolition.png` | `runs/f5-abolition` | the extrapolation — with the log-linear line that never reaches zero drawn on the same axes |

Figures 1, 4 and 5 all contain material that damages us. That is the strategy: a room that has
watched us hand over our own weak points stops auditing us and starts trusting us, and **that is
precisely the effect we are exploiting.** Pre-emption is a rhetorical device, not a proof.

## 3. Where our thumb is

The four places the README names, answered straight.

**Sampling.** Not ours. `examples/fog/fetch.sh` chose ten station ids, 1990-2025, two parameters.
We did not pick them and we did not vary them. We have no idea whether these ten stations are
representative of Austria and neither does anyone else in the room. "Fog in Austria" is a phrase
about a country; our evidence is six thermometers. **This is the softest thing we say and it is in
the headline.**

**Evidence.** Every run is published, including the rejected one (`f2-allday`) and the one that
argues against us (`f4-gew`). `jam list` shows nine folders; nine fotons exist.

**Agreement.** `cockpit.config.json` has `reproduction.requiredLevel: "L0"` and an empty
normaliser — we changed neither. Bit-identical outputs or nothing. We are not claiming two runs
are "the same" under any loosened definition.

**Framing.** Three real choices, all reversible from the record:
- *1990-2024, 2025 dropped.* 2025 is a part-period and two panel stations are short in it.
  Including 2025 in the naive spec produces a bar that goes back **up** to 6.61%.
- *Balanced panel, not all ten stations.* This choice makes our number **bigger** (-52% vs -30.6%),
  which is why we can afford to make it in public.
- *"Roughly a third."* Chosen against our own evidence for a half, because a conservative number
  survives an attack that a maximal one does not.

## 4. What we expect the other side to do, and what happens when they do

### 4.1 `gew` — this is the one that hurts, and there is no answer

They will plot `gew` beside `nebel` on our own panel, on our own days. They will get:

| | 1990-1994 | 2020-2024 | change | slope |
|---|---|---|---|---|
| `nebel` | 8.11% | 3.80% | **-53.2%** | -0.1704 pp/yr |
| `gew`   | 9.97% | 5.06% | **-49.2%** | -0.1321 pp/yr |

Two indicators off the same rows, falling by nearly the same fraction.

(`nebel` reads 3.80% here and 3.87% in §1. Both are ours and both are in the record: §1 is
`f3-balanced`, pooling all nebel-reporting station-days in the period; this table is `f4-gew`,
averaging annual rates over the days carrying *both* indicators, which is the only basis on which
the comparison is fair. 0.07 points. We flag it so nobody has to find it.) Nobody believes aerosol
cleanup abolishes thunderstorms. A change in how these stations observed — manned to automatic,
altered coding practice, a national instruction — would produce exactly this, and it would produce
it in both columns at once.

What we will say, and the limit of it:

1. The two indicators are almost disjoint in the calendar: 72.2% of fog days are Oct-Jan, 81.1% of
   storm days are May-Aug (`runs/f4-gew/out/seasonality.png`). They are not one observation made
   twice.
2. `nebel ~ year + gew`: the year coefficient goes -0.1704 -> -0.1667, 97.8% survives, `gew` is
   insignificant at p = 0.83.

**And point 2 is worthless, and we said so in the run's own output before they said it to us.** A
covariate that trends with year is collinear with year; the fit hands the trend to whichever term
is in the model. That regression could not have come out any other way. It tests year-to-year
covariation, not a common secular decline. It is in
`runs/f4-gew/out/gew-control.txt` under the heading "WHAT THIS TEST CAN AND CANNOT DO".

If they take `gew` as a pure observing-effort proxy, the ratio `nebel:gew` goes 0.814 -> 0.751,
**-7.8%**, and our claim is gone. We do not think `gew` is a pure effort proxy — thunderstorm
frequency has its own physics and its own literature. But **this file cannot decide it**, and the
metadata that would (station histories, automation dates, observing manuals) is not in our input
and is not in our record. That is the honest end of the argument.

**Our actual position:** "fog declined" is defensible. "Fog is being abolished" is not something
this file can establish, because the same file says thunderstorms are being abolished too.

### 4.2 "Show us the count, not the rate"

Already shown. 889 -> 393 fog days, **-55.8%**, on a denominator that moved -7.4%
(`runs/f3-balanced/out/fog-balanced-by-period.csv`). The count falls harder than the rate. This
attack is the TASK's named example of a good Defensio and it is the one we are strongest against.

### 4.3 "Your denominator"

Conceded in figure 1 before they ask. It is why the naive spec (`f1-naive`, -30.6%) is published
and not used. Residual: the balanced panel's denominator still moves -7.4%, because stations 131
and 145 are short in 2023-24. Tightening to 365/365 every year drops both — and they are the two
foggiest — so the tighter panel is the less representative one. We took coverage. Anyone can
re-run it the other way from our script in four characters.

### 4.4 "2043 is not a finding"

Correct, and we drew the refutation ourselves. The same arithmetic on `gew` abolishes
thunderstorms in **2065** (`runs/f5-abolition/out/abolition-both.png`). A linear fit to a bounded,
strictly positive quantity has a zero crossing by construction. A constant-proportional model on
the same 35 points (-3.00%/yr) fits within four points of variance (R² 0.688 vs 0.728 on the same
scale) and **never reaches zero**: it says 1.94% in 2043 and 0.85% in 2070.

And the prediction band on our own figure says it too. At 2043 the 95% band for a single year's
fog rate is **[-2.54%, +2.66%]** — it contains zero, and it has contained zero since 2030. A band
that admits a negative fog rate is a band that has left the physics behind. It is drawn on
`runs/f5-abolition/out/abolition.png` at full width; we did not trim the axis to hide it.

"On track to disappear" is a sentence about a model we chose, not about Austria. We put it in the
claim anyway. That is the rhetoric the exercise is about, and it is the sentence we would lose on.

### 4.5 "Six stations is not a country"

Also correct. `runs/f6-stations` shows stations 131 and 30 carry 65.7% of the lost fog days;
station 131 starts at 15.55%, nearly three times the panel's quietest station, and ends
indistinguishable from it. A site-level change that large is as consistent with something changing
at the site as with regional climate.

Leave-one-out is our answer and it is a real one: drop any single station and the slope stays
between -0.1081 and -0.1984 (full panel -0.1704), p never worse than 3.6e-07, period change
-43.8% to -56.7%. Drop station 131 — our biggest contributor — and it is still **-43.8%**.

That is robustness to deletion. It is **not** evidence about the 1 200 Austrian stations we never
fetched, and we will not pretend otherwise.

### 4.6 "How many runs did you throw away?"

None. Nine run folders, nine fotons, all published. The rejected specification — treating a
missing `nebel` as no fog, which is worth **23.6 extra percentage points** of headline decline —
is published as `f2-allday` with `out/why-rejected.txt` explaining why we did not take it.

## 5. The concession we would make if pressed properly

If the other side plots `gew` against `nebel` on our panel and asks us to name a single
observation in this file that distinguishes "fog declined" from "these six stations changed how
they observe", **we cannot.** Not "we would need more analysis" — the discriminating evidence is
not in the input.

Our claim survives the denominator attack, survives the count attack, survives leave-one-out, and
does not survive `gew`. It is fully reproducible from foton
`sha256:acbd872dcc13659a5d684bde72587e5afb4623e6ca94038ed5295828a2a17673` and the room should not believe it.

*"Reproducible" and "true" are different statements. We built the first one carefully. The second
one is still open, and this file cannot close it.*
