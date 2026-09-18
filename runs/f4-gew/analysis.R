# f4-gew -- the control the other side is entitled to ask for, run on our own headline panel.
#
# examples/fog/TASK.md names it: "plot `gew` beside `nebel` on the same station-days". So we did,
# on the balanced panel from f3, and we publish what came out including the part that hurts.
#
# What comes out: gew falls too, by almost as much. Everything downstream of that is the argument.

d <- read.csv("inputs/fog-nebel-gew.csv", stringsAsFactors = FALSE)
d$year  <- as.integer(substr(d$time, 1, 4))
d$month <- as.integer(substr(d$time, 6, 7))
d <- d[d$year >= 1990 & d$year <= 2024, ]

cov_n    <- table(d$station[!is.na(d$nebel)], d$year[!is.na(d$nebel)])
balanced <- as.integer(rownames(cov_n)[apply(cov_n, 1, function(r) all(r > 0))])

# the SAME station-days: rows on the panel that carry BOTH indicators
b <- d[d$station %in% balanced & !is.na(d$nebel) & !is.na(d$gew), ]

dir.create("out", showWarnings = FALSE)

yr <- data.frame(
  year      = sort(unique(b$year)),
  nebel_pct = round(100 * tapply(b$nebel, b$year, mean), 3),
  gew_pct   = round(100 * tapply(b$gew,   b$year, mean), 3),
  n         = as.integer(tapply(b$nebel, b$year, length))
)
write.csv(yr, "out/nebel-vs-gew-by-year.csv", row.names = FALSE)

mon <- data.frame(
  month     = 1:12,
  nebel_pct = round(100 * tapply(b$nebel, b$month, mean), 2),
  gew_pct   = round(100 * tapply(b$gew,   b$month, mean), 2)
)
write.csv(mon, "out/seasonality.csv", row.names = FALSE)

fn  <- lm(nebel_pct ~ year, data = yr)
fg  <- lm(gew_pct   ~ year, data = yr)
fnc <- lm(nebel_pct ~ year + gew_pct, data = yr)      # gew as a covariate

sink("out/gew-control.txt")
cat("Same six stations, same station-days, both indicators, 1990-2024.\n")
cat(sprintf("%d station-days carry BOTH nebel and gew.\n\n", nrow(b)))
cat("Trend in each indicator, annual rate, OLS:\n")
cat(sprintf("  nebel  %+.4f pp/yr  p = %.2e   %.2f%% -> %.2f%%  (%+.1f%%)\n",
            coef(fn)[2], coef(summary(fn))[2, 4],
            mean(yr$nebel_pct[1:5]), mean(yr$nebel_pct[31:35]),
            100 * (mean(yr$nebel_pct[31:35]) / mean(yr$nebel_pct[1:5]) - 1)))
cat(sprintf("  gew    %+.4f pp/yr  p = %.2e   %.2f%% -> %.2f%%  (%+.1f%%)\n",
            coef(fg)[2], coef(summary(fg))[2, 4],
            mean(yr$gew_pct[1:5]), mean(yr$gew_pct[31:35]),
            100 * (mean(yr$gew_pct[31:35]) / mean(yr$gew_pct[1:5]) - 1)))
cat("\nSO: BOTH INDICATORS FALL, AND BY A SIMILAR FRACTION. That is the finding, stated plainly.\n")

cat("\nSeasonality -- the two indicators are almost disjoint in the calendar:\n")
print(mon, row.names = FALSE)
cat(sprintf("\n  nebel: %.1f%% of its fog days fall in Oct-Jan\n",
            100 * sum(b$nebel[b$month %in% c(10, 11, 12, 1)]) / sum(b$nebel)))
cat(sprintf("  gew:   %.1f%% of its storm days fall in May-Aug\n",
            100 * sum(b$gew[b$month %in% 5:8]) / sum(b$gew)))

cat("\nnebel ~ year + gew, i.e. the fog trend with the thunderstorm indicator held constant:\n")
print(coef(summary(fnc)))
cat(sprintf("\n  year coefficient alone:          %+.4f\n", coef(fn)[2]))
cat(sprintf("  year coefficient with gew in it: %+.4f  (%.1f%% of it survives)\n",
            coef(fnc)[2], 100 * coef(fnc)[2] / coef(fn)[2]))
cat(sprintf("  gew coefficient:                 %+.4f, p = %.2f\n",
            coef(fnc)[3], coef(summary(fnc))[3, 4]))
cat(sprintf("  correlation of the two annual series: r = %.3f\n",
            cor(yr$nebel_pct, yr$gew_pct)))

cat("\nWHAT THIS TEST CAN AND CANNOT DO -- read before quoting it.\n")
cat("It shows year-to-year thunderstorm variation does not explain year-to-year fog variation.\n")
cat("It CANNOT separate a common secular decline, because a covariate that trends with year is\n")
cat("collinear with year and the fit hands the trend to whichever term is in the model. This\n")
cat("regression could not have come out any other way. It is reported because we ran it, not\n")
cat("because it settles anything.\n")
cat(sprintf("\nRatio nebel:gew, first five years %.3f, last five years %.3f (%+.1f%%).\n",
            mean(yr$nebel_pct[1:5]) / mean(yr$gew_pct[1:5]),
            mean(yr$nebel_pct[31:35]) / mean(yr$gew_pct[31:35]),
            100 * ((mean(yr$nebel_pct[31:35]) / mean(yr$gew_pct[31:35])) /
                   (mean(yr$nebel_pct[1:5]) / mean(yr$gew_pct[1:5])) - 1)))
cat("If gew is taken as a pure observing-effort proxy, that ratio is what is left of the fog\n")
cat("decline, and it is small. We do not think gew is a pure effort proxy. Neither reading is\n")
cat("decidable from this file.\n")
sink()

png("out/nebel-vs-gew.png", width = 900, height = 560)
plot(yr$year, yr$gew_pct, type = "b", pch = 17, lwd = 2, col = "#b2182b",
     ylim = c(0, max(c(yr$gew_pct, yr$nebel_pct)) * 1.05),
     xlab = "year", ylab = "% of station-days",
     main = "Same stations, same days: fog (blue) and thunderstorm (red)")
lines(yr$year, yr$nebel_pct, type = "b", pch = 19, lwd = 2, col = "#2166ac")
abline(fn, lty = 2, col = "#2166ac"); abline(fg, lty = 2, col = "#b2182b")
legend("topright", bty = "n", pch = c(19, 17), col = c("#2166ac", "#b2182b"),
       legend = c(sprintf("nebel  %+.3f pp/yr", coef(fn)[2]),
                  sprintf("gew    %+.3f pp/yr", coef(fg)[2])))
dev.off()

png("out/seasonality.png", width = 900, height = 520)
barplot(rbind(mon$nebel_pct, mon$gew_pct), beside = TRUE, names.arg = month.abb,
        col = c("#2166ac", "#b2182b"), ylab = "% of station-days",
        main = "The two indicators barely share a month (1990-2024, balanced panel)")
legend("topleft", c("nebel", "gew"), fill = c("#2166ac", "#b2182b"), bty = "n")
dev.off()

cat(readLines("out/gew-control.txt"), sep = "\n")
