# f2-allday -- the specification we REJECTED, kept and published so that rejecting it is on record.
#
# The move: every station-day is present as a row for all ten stations in all years (f0-audit).
# So one can hold the denominator perfectly constant by treating a missing `nebel` as "no fog was
# reported on that day", i.e. as a zero, and dividing by all 131 490 station-days.
#
# It is arithmetically clean, the denominator is literally constant, and it is wrong: a day on
# which nobody looked is not a day without fog. It manufactures a steeper decline than the data
# support, out of exactly the stations that stopped looking. We ran it so we would know how much
# it was worth, and it is worth about twenty points of decline. That is the size of the thumb we
# are not putting on the scale.

d <- read.csv("inputs/fog-nebel-gew.csv", stringsAsFactors = FALSE)
d$year <- as.integer(substr(d$time, 1, 4))
d <- d[d$year <= 2024, ]
d$period <- paste0(d$year - (d$year %% 5), "-", d$year - (d$year %% 5) + 4)

d$nebel0 <- ifelse(is.na(d$nebel), 0, d$nebel)          # <- the move
rep_only <- d[!is.na(d$nebel), ]

agg <- data.frame(
  period        = sort(unique(d$period)),
  na_as_zero    = round(100 * tapply(d$nebel0, d$period, mean), 2),
  reported_only = round(100 * tapply(rep_only$nebel, rep_only$period, mean), 2)
)

dir.create("out", showWarnings = FALSE)
write.csv(agg, "out/rejected-na-as-zero.csv", row.names = FALSE)

sink("out/why-rejected.txt")
cat("REJECTED SPECIFICATION -- published so the rejection is on record.\n\n")
print(agg, row.names = FALSE)
cat(sprintf("\n1990-1994 -> 2020-2024, NA treated as no-fog: %.2f%% -> %.2f%%  (%+.1f%%)\n",
            agg$na_as_zero[1], agg$na_as_zero[7],
            100 * (agg$na_as_zero[7] / agg$na_as_zero[1] - 1)))
cat(sprintf("1990-1994 -> 2020-2024, reported days only:   %.2f%% -> %.2f%%  (%+.1f%%)\n",
            agg$reported_only[1], agg$reported_only[7],
            100 * (agg$reported_only[7] / agg$reported_only[1] - 1)))
cat(sprintf("\nThe recode buys %.1f extra percentage points of headline decline.\n",
            abs(100 * (agg$na_as_zero[7] / agg$na_as_zero[1] - 1)) -
            abs(100 * (agg$reported_only[7] / agg$reported_only[1] - 1))))
cat("\nIt buys them by counting station 20 (stopped 2007), station 35 (2007) and station 170\n")
cat("(2013) as fog-free every day since. They are not fog-free. Nobody is looking.\n")
cat("\nNot used in any figure we stand behind.\n")
sink()

png("out/rejected-na-as-zero.png", width = 900, height = 520)
barplot(rbind(agg$na_as_zero, agg$reported_only), beside = TRUE,
        names.arg = agg$period, las = 2, col = c("#cccccc", "#2166ac"),
        ylab = "fog days (%)", main = "REJECTED: missing treated as no-fog (grey) vs reported days only (blue)")
legend("topright", c("NA counted as no fog -- rejected", "reported station-days"),
       fill = c("#cccccc", "#2166ac"), bty = "n")
dev.off()

cat(readLines("out/why-rejected.txt"), sep = "\n")
