# f4-gew

**From:** fog
**Started:** 2026-09-18

## What I am trying

The control the TASK says the other side will run: `gew` beside `nebel` on the same station-days.
Run it ourselves, on our own headline panel, before they do.

## What happened

It does not go our way, and we are publishing it.

- `nebel` -0.1704 pp/yr, 8.11% -> 3.80%, **-53.2%**
- `gew`   -0.1321 pp/yr, 9.97% -> 5.06%, **-49.2%**

Both fall, by a similar fraction, off the same rows. Nobody thinks aerosol cleanup abolishes
thunderstorms, so a common cause — a change in observing practice across these stations — is on
the table and this file cannot rule it out.

What we found that *does* cut our way:

- the two indicators are nearly disjoint in the calendar. 72.2% of fog days are Oct-Jan; 81.1% of
  storm days are May-Aug. They are not the same observation being made twice.
- `nebel ~ year + gew`: the year coefficient goes -0.1704 -> -0.1667, 97.8% of it survives, and
  `gew` itself is insignificant (p = 0.83).

And the honest limit on that second point, which is written into `out/gew-control.txt` so it
travels with the figure: **that regression could not have come out any other way.** A covariate
that trends with year is collinear with year, and the fit gives the trend to whichever term is in
the model. It tests year-to-year covariation, not a common secular decline. It is reported because
we ran it, not because it settles anything.

The ratio `nebel:gew` goes 0.814 -> 0.751, -7.8%. If you believe `gew` is a pure observing-effort
proxy, -7.8% is all that is left of our claim. We do not believe that, but the file does not
decide it.

**Published.** Publishing the run that damages us is the only version of this we can defend.
