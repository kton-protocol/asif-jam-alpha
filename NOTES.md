# NOTES.md — team alpha, friction log

First-ever users of `bin/jam` + `cockpit`. Everything that snagged, in the order it snagged.
Nothing here is fixed by us; this is a report.

---

## 1. `bin/setup` — key-permission warnings, four times, for one fact

`bin/setup` completed in 7s. It printed the same warning four times (twice from keygen, twice
from `cockpit doctor`):

```
warning: keys/team.key was created with mode -rwxrwxrwx, not the 0600 that was requested - this
  platform or filesystem does not enforce it (Windows, FAT/exFAT, some network mounts).
```

and then, in doctor:

```
  plankton key:   .../keys/team.key  [READABLE BY OTHERS: mode -rwxrwxrwx]
```

The repo lives on `/mnt/c` (a Windows drive mounted into WSL), which cannot carry POSIX modes.
This is unavoidable and the text says so, but a first-time user reading `README.md` — "if that is
unhappy, stop and fix it before working" — has no way to tell whether doctor is *unhappy* or
merely *chatty*. There is no exit-code or summary line saying "ok" vs "not ok". We guessed.

**Want:** a final `doctor: ok (2 warnings)` / `doctor: FAILED` line, and a documented way to say
"this filesystem cannot do modes, stop telling me".

## 2. `bin/jam` points at a subcommand that does not exist

`bin/jam`, when the cockpit binary is missing:

```
no cockpit at $COCKPIT — run: jam setup
```

There is no `jam setup`. It is `bin/setup`. Minor, but it is the first message a user who skipped
setup will see.

## 3. The warm-up example's stated premise is false for the data the warm-up fetches

`examples/quakes/TASK.md`: *"Draw the count per year. It rises."* and *"find the smallest change to
your own analysis that makes the rise go away"*.

It does not rise. `runs/q1` is `examples/quakes/starter.R` byte-for-byte:

```
ALL events in the same file, per year:
               Estimate  Std. Error   t value  Pr(>|t|)
year          -3.867259    3.108066 -1.244265 0.2187757
1970-1979 total: 5249
2016-2025 total: 4893
ratio: 0.93x
```

Slope is *negative* and not significant. The reason is that the fetch floors at M3, and the
California regional network was already complete above M3 in 1970 — the detection artefact the
example is built to teach lives at M1-M2, which this query deliberately excludes. `fetch.sh` says
it chose M3 to keep the file under the 50 MB commit ceiling. The size constraint and the teaching
goal are in direct conflict and nobody noticed.

We had to invert the exercise (find the smallest change that makes it *rise*: `runs/q2`, subset to
moment magnitudes, 122x) which worked fine and taught the same lesson — but a team following the
TASK literally will spend its hour confused and conclude the tooling is broken.

**Want:** either fetch M2+ for a smaller region/window, or reword the TASK.

## 4. `jam check <foton-id>` — documented, accepted, returns nothing

`README.md`: "bin/jam check <output-hash-or-foton-id>". `bin/jam`'s own header: "jam check <ref>
what produced these bytes, and who stands behind it".

Given a foton id — the exact string `jam publish` printed and wrote into `runs/q1/.published` —
it exits 0 and returns an empty answer:

```
$ bin/jam check sha256:7de94c5f0563a5f1e5d3b081604c94efb18d4d82d7f74e9262eb9611c4cfd725
{
  "query": "producer",
  "ref": "sha256:7de94c5f...",
  "raw": "",
  "filterApplied": "none — every record verified against a configured trust tier is included; ..."
}
```

Exit 0. No "not found", no "that is a foton id, give me an output hash". Given an *output content
hash* it works perfectly. So the only id the tooling ever hands you is the one id the query does
not accept.

## 5. …and nothing tells you how to get an output hash

To make `jam check` work you need `sha256:` of a file in `out/`. Nothing in `README.md`, `bin/jam`,
or either `TASK.md` says how. It is `./bin/plankton hash <file>` — line 73 of `plankton --help`,
a binary the README never mentions, in a tool `bin/setup` describes as being "used by `jam` only
for hashing a file the way the substrate does".

**Want:** `jam check` to accept a path (`jam check runs/q1/out/quakes-per-year.csv`), or
`jam publish` to print the output hashes alongside the foton id.

## 6. `jam publish` is slow, and it is slow because it pushes

Two `jam publish` calls took over 120 s together and got moved to the background. Each publish
makes **two** git commits (`publish: <cmd>` then `foton: <cmd>`) and pushes. Four network
round-trips to github.com for two runs.

`README.md` sells run folders as cheap and says to make a lot of them — which is true of `jam new`,
but `publish` is where you find out the cost. Nothing warns you, and there is no progress output
between "publishing q1" and the foton id a minute later. The first time, you cannot tell whether
it has hung.

**Want:** a line saying it is pushing; a `--no-push` for batching; or one commit per publish.

## 7. `jam publish` commits the run, but not `RUN.md` or `.published`

After publishing q1 and q2:

```
$ git status --short
?? NOTES.md
?? cockpit.config.json
?? keys/
?? registry/keys/team-claims.pub
?? registry/keys/team.pub
?? runs/q1/.published
?? runs/q1/RUN.md
?? runs/q2/.published
?? runs/q2/RUN.md
```

`README.md` says "Everything in `data/`, `runs/` and `registry/` is committed and pushed, which is
what makes your work checkable — and what makes a half-finished thought you left in `out/`
visible."

It is not. `jam publish` stages only the files named in the foton (`inputs/`, `analysis.R`, `out/`).
`RUN.md` — the file `jam new` generates, the one that says *what you were trying* — never reaches
the remote unless you commit it by hand. So does the reassurance about half-finished thoughts being
visible: they are not.

Worse, `registry/keys/team.pub` is untracked. That is the public key the trust tier
`self` points at. A cloner gets the registry and the fotons and no key to verify them against,
until someone remembers to `git add` it.

## 8. `cockpit ask` gives the same error for a missing ref and an unknown query

```
$ ./bin/cockpit ask '{"query":"producer"}'
ask requires ref (the hash, subject, or value to query)
$ ./bin/cockpit ask '{"query":"help"}'
ask requires ref (the hash, subject, or value to query)
```

There is no way to discover what queries exist besides `producer`. `jam check` hardcodes it.

---

# Fog task

## 9. `examples/fog/starter.R` has a binning bug that fabricates an eighth period

```r
d$period <- paste0(d$year - (d$year %% 5), "-", d$year - (d$year %% 5) + 4)
```

The fetch runs to 2025-12-31, so 2025 lands in a bin labelled **"2025-2029"** containing one year.
The starter's own output:

```
     period fog_day_pct
1 1990-1994        7.13
...
7 2020-2024        4.95
8 2025-2029        6.61
```

The last bar in `out/fog-by-period.png` is a single year, is labelled as five, and goes back *up*.
A team that publishes the starter figure unmodified publishes a chart with a mislabelled bar in it.
That is not the trap the TASK is teaching; it is just a bug, and it lands in the one figure every
team will produce first.

**Want:** drop incomplete periods, or label it `2025 (part)`.

## 10. The foton records the command but nothing about the environment

`jam publish` records `cmd`, input hashes, output hashes. It records no R version, no package set,
no locale, no timezone. `README.md` says "they get your exact inputs by hash and your exact
command", and `jam publish` prints "the other side can now re-run this from the record alone."

They cannot, quite. `Rscript runs/f3-balanced/analysis.R` on a box with a different R will
reproduce our numbers or it will not, and nothing in the record says which R we had (4.3.3) or
which packages. Our scripts are deliberately base-R only *because* we noticed this — which is a
constraint the tooling imposed without telling us.

There is also no `renv.lock`, no `sessionInfo()` capture, and no hook where one would go. If a
team uses ggplot2 the other side has to guess the version.

**Want:** `jam publish` to write `out/sessionInfo.txt` automatically, or to record the interpreter
version in the foton.

## 11. Only 165 R packages and no `ggplot2`

`Rscript -e 'installed.packages()'` — no ggplot2, no dplyr-adjacent plotting, no `trend`, no
`Kendall`, no `zyp`. So: no Mann-Kendall, no Theil-Sen, no non-parametric trend test at all,
on a task whose entire subject is a trend. We used OLS on annual rates, which is the weaker tool,
because it is the tool that was there.

Nothing in `README.md` or either `TASK.md` says what is installed or whether installing is
allowed. Installing would also break reproducibility for the other side (see #10), so we did not.

**Want:** one line in the README saying "these packages are available, do not add any", or a
lockfile in the template.

## 12. `jam new` copies 5 MB per run folder, silently

Seven fog runs = seven copies of `data/fog-nebel-gew.csv` = 34 MB, all of it committed on publish.
The README explains *why* (a run folder is a whole thing; kton matches on bytes) and that is a
good reason. But it also says "They are cheap — make a lot of them", and the interaction with
`fetch`'s own 50 MB ceiling is never mentioned: the ceiling is per-dataset, and twenty run folders
of a 40 MB dataset would be 800 MB in git with nothing complaining.

**Want:** `jam new` to print the copy size, and the ceiling doc to say it is not the real limit.

## 13. `jam list` counts files in `out/`, which is not what you want to know

```
  f4-gew                       4 output(s)    foton sha256:…
```

The column that would matter — is this run's `out/` newer than its `analysis.R`, i.e. did I
re-run after I last edited — is not there. We caught a wrong sentence in `runs/f5-abolition/`
after the first run, patched the script and re-ran it; had we forgotten the re-run, `jam publish`
would have recorded the new script against the old outputs and said nothing. It hashes both and
compares neither to the other.

**Want:** a staleness marker, or `jam publish` to refuse when `analysis.R` is newer than `out/`.

## 14. `.published` keeps only the latest foton (from reading `bin/jam`, not from hitting it)

`cmd_publish` ends with `echo "$id" > "$dir/.published"`. So a second publish of the same slug
overwrites the first foton id in the working tree. It survives in the registry and in `git log`,
but the run folder itself only ever points at the most recent one. A team that publishes a figure,
changes the script and publishes again has no in-folder record of what it actually showed the room.

We did not hit this — we published each slug once — but the record of *which* version was shown is
exactly the thing this tooling exists to keep.

**Want:** append to `.published`, not overwrite.

## 15. No way to attach a claim to a run from `jam`

`cockpit.config.json` allows two claim templates, `reproduces` and `working-on`, and the cockpit
has a `say` verb. `bin/jam` exposes `fetch/new/list/publish/check` and no way to say anything.
So `templates/reproduces.json` exists, the whole Offensio story is built around it, and the team
CLI has no verb that emits one. We would have had to hand-write `cockpit say` JSON, and nothing
documents its shape.

**Want:** `jam reproduces <foton> --level L0` or at minimum an example in the README.

## 16. `cockpit doctor` flags the private key, and the repo layout invites the mistake

`keys/` holds four files: `team.key`, `team.pub`, `team-claims.key`, `team-claims.pub`. `.gitignore`
ignores `keys/*.key`, which is correct — but a team that types `git add keys/` gets no warning and
nothing bad happens, so the habit forms. On this filesystem the keys are mode `-rwxrwxrwx` and
doctor says so four times (#1), which is the *permission* problem, not the *commit* problem, and
the two warnings read alike.

The two public keys also exist twice — `keys/team.pub` and `registry/keys/team.pub` — copied by
`bin/setup`. Nothing says which one is authoritative or what happens if they diverge.

## 17. Everything `jam publish` does not stage, we had to stage by hand

Final `git status` before our own commit — 24 untracked paths, including all nine `RUN.md`, all
nine `.published`, `cockpit.config.json`, both public keys, `DEFENSIO.md` and this file. A team
that trusts `README.md`'s "everything in `runs/` is committed and pushed" and does not run
`git status` ships a repo where the Offensio side can re-run every analysis and cannot read a
single word about why any of it was done.

## 18. Timings, for whoever sizes the event

| step | wall clock |
|---|---|
| `bin/setup` | 7 s |
| `bin/jam fetch quakes` | **1 m 58 s** (56 sequential USGS calls) |
| `bin/jam fetch fog` | 29 s |
| `Rscript analysis.R`, any run | 1-3 s |
| `bin/jam publish`, per run | **~20 s** |

Nine publishes ≈ 3 minutes of nothing but waiting. `jam fetch quakes` prints a dot per year, which
is the only progress indicator anywhere in the tooling; `jam publish` prints nothing between its
header and its foton id. Two of our `publish` invocations exceeded a 120 s agent timeout and had to
be backgrounded.

---

## Summary — the five that cost us most

1. **#3** — the quakes warm-up teaches a rise that its own fetch does not contain. An hour, spent
   on believing the tooling was broken.
2. **#4 + #5** — `jam check` rejects the only identifier the tooling ever gives you, and the
   identifier it wants is produced by an undocumented binary.
3. **#7 + #17** — `jam publish` does not commit `RUN.md`, contradicting the README, so the *reasons*
   for the work are the one thing that does not reach the record.
4. **#9** — a binning bug in `examples/fog/starter.R` puts a mislabelled bar in the first figure
   every team will draw.
5. **#10 + #11** — "re-runnable from the record alone" is not true: no R version, no package set,
   no lockfile, and a package list too thin for a non-parametric trend test on a task about trends.
