# q1

**From:** quakes
**Started:** 2026-09-18

## What I am trying

The starter script, unmodified. `examples/quakes/TASK.md` says "Draw the count per year. It rises."

## What happened

It does not rise. California M3+ from USGS ComCat, 1970-2025: OLS slope -3.87 events/year
(SE 3.11, p = 0.22). The 1970s total 5249 events; 2016-2025 total 4893. The series is flat with
four enormous aftershock spikes (1992 Landers, 1999 Hector Mine, 2010 El Mayor-Cucapah,
2019 Ridgecrest).

The detection trap the TASK describes is real, but it is invisible at M3+ in California, because
the regional network was already complete above M3 in 1970. It bites at M1-M2, which this fetch
does not contain. Recorded in NOTES.md as friction: the example's stated premise does not hold
for the query the example ships.

Published anyway, because a published null is the honest half of the pair.
