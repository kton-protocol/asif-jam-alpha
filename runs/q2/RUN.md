# q2

**From:** quakes
**Started:** 2026-09-18

## What I am trying

q1 refused to rise, so: the smallest change to q1 that makes the catalogue rise anyway. One line —
subset to events whose `magType` is a moment magnitude.

## What happened

It rises by a factor of 122. Slope +2.35 events/year, p = 8.7e-15. 9 events in the 1970s,
1102 in 2016-2025.

Nothing was filtered by time, region, magnitude or depth. It is the same file, the same M3+ floor,
the same box, the same window. The only thing that changed between 1970 and 2025 is that
California acquired the broadband instruments and the waveform-inversion pipeline needed to report
a moment magnitude at all. The series measures the seismometers.

out/both-series.png puts the two on one axis, which is the whole lesson in one picture: the grey
line is the Earth, the red line is the budget.

A Defensio built on the red line would be fully reproducible and completely dishonest, and
`jam check` cannot tell the difference. That is the point of the warm-up.
