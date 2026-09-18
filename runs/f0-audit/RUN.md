# f0-audit

**From:** fog
**Started:** 2026-09-18

## What I am trying

Count the denominator before computing any rate.

## What happened

All 131 490 rows are present for all ten stations in all years. What changes is whether a row
carries a value. Across 1990-1994 -> 2020-2024 the `nebel` denominator falls **-34.0%**
(18 138 -> 11 975 station-days) while `gew`'s falls only **-9.5%** (18 138 -> 16 408) — off the
*same rows*. Stations 20 and 170 stop reporting `nebel` (2007, 2013) and go on reporting `gew`
through 2025.

So any rate over "station-days that reported" is partly a measure of who was reporting, and the
starter's figure is such a rate. This run is what sent us to a balanced panel (f3).

Six stations carry a `nebel` value in every year 1990-2024: 30, 80, 93, 105, 131, 145.

**Published.** It is the run that makes our headline legible, and it is the run that hands the
other side their first question already answered.
