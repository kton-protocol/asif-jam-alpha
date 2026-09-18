# f3-balanced -- the headline. A fixed panel of stations, so the denominator cannot move.
#
# f0-audit showed that the nebel denominator falls 34% across the window while gew's falls 9.5%.
# Any rate over "rows that reported" is therefore partly a measure of who was reporting. The fix
# is not a weighting; it is to throw away every station that ever stopped.
#
# Balanced panel: the stations that carry a nebel value in EVERY year 1990-2024. Six of ten:
# 30, 80, 93, 105, 131, 145. The other four (20, 35, 124, 170) are dropped entirely -- not just
# in the years they are missing, but for the whole window, so no station enters or leaves.
#
# 2025 is excluded throughout: it is a part-period in a five-year scheme and two panel stations
# (131, 145) are incomplete in it. Including it is a framing decision and we did not want one.

d <- read.csv("inputs/fog-nebel-gew.csv", stringsAsFactors = FALSE)
d$year <- as.integer(substr(d$time, 1, 4))
d <- d[d$year >= 1990 & d$year <= 2024, ]

cov_n    <- table(d$station[!is.na(d$nebel)], d$year[!is.na(d$nebel)])
balanced <- as.integer(rownames(cov_n)[apply(cov_n, 1, function(r) all(r > 0))])

b <- d[d$station %in% balanced & !is.na(d$nebel), ]
b$period <- paste0(b$year - (b$year %% 5), "-", b$year - (b$year %% 5) + 4)

dir.create("out", showWarnings = FALSE)

# --- by period ---------------------------------------------------------------------------------
per <- data.frame(
  period   = sort(unique(b$period)),
  fog_pct  = round(100 * tapply(b$nebel, b$period, mean), 2),
  fog_days = as.integer(tapply(b$nebel, b$period, sum)),
  denom    = as.integer(tapply(b$nebel, b$period, length)),
  stations = as.integer(tapply(b$station, b$period, function(x) length(unique(x))))
)
write.csv(per, "out/fog-balanced-by-period.csv", row.names = FALSE)

# --- by year, and the trend --------------------------------------------------------------------
yr <- data.frame(
  year     = sort(unique(b$year)),
  fog_pct  = round(100 * tapply(b$nebel, b$year, mean), 3),
  fog_days = as.integer(tapply(b$nebel, b$year, sum)),
  denom    = as.integer(tapply(b$nebel, b$year, length))
)
write.csv(yr, "out/fog-balanced-by-year.csv", row.names = FALSE)

fit <- lm(fog_pct ~ year, data = yr)
ci  <- confint(fit)

sink("out/balanced.txt")
cat("Balanced panel, GeoSphere klima-v2-1d, 1990-2024.\n")
cat(sprintf("stations: %s  (%d of 10)\n", paste(balanced, collapse = ", "), length(balanced)))
cat(sprintf("station-days: %d; every one of them carries a nebel value.\n\n", nrow(b)))
cat("Fog days as a percentage of station-days, by five-year period:\n")
print(per, row.names = FALSE)
cat(sprintf("\nThe denominator moves by %.1f%% across the whole window (%d -> %d station-days),\n",
            100 * (per$denom[7] / per$denom[1] - 1), per$denom[1], per$denom[7]))
cat("and the panel is the same six stations in every period.\n")
cat(sprintf("\n1990-1994 -> 2020-2024:  %.2f%% -> %.2f%%   (%+.1f%%)\n",
            per$fog_pct[1], per$fog_pct[7], 100 * (per$fog_pct[7] / per$fog_pct[1] - 1)))
cat(sprintf("fog days counted:        %d -> %d          (%+.1f%%)\n",
            per$fog_days[1], per$fog_days[7], 100 * (per$fog_days[7] / per$fog_days[1] - 1)))
cat("\nAnnual trend, OLS on the yearly rate:\n")
print(coef(summary(fit)))
cat(sprintf("\nslope %.4f pp/yr   95%% CI [%.4f, %.4f]   R2 = %.3f\n",
            coef(fit)[2], ci[2, 1], ci[2, 2], summary(fit)$r.squared))
cat(sprintf("over 35 years that is %.2f percentage points, from a 1990 fitted level of %.2f%%.\n",
            35 * coef(fit)[2], predict(fit, data.frame(year = 1990))))
sink()

# --- figures -----------------------------------------------------------------------------------
png("out/fog-balanced-by-period.png", width = 900, height = 520)
bp <- barplot(per$fog_pct, names.arg = per$period, las = 2, col = "#2166ac",
              ylim = c(0, 10), ylab = "fog days (% of station-days)",
              main = "Fog days, six Austrian stations reporting continuously 1990-2024")
text(bp, per$fog_pct + 0.3, sprintf("%.2f", per$fog_pct), cex = 0.9)
mtext(sprintf("same six stations, %s station-days per period; denominator varies %.1f%%",
              format(per$denom[1], big.mark = " "), 100 * (per$denom[7] / per$denom[1] - 1)),
      side = 3, line = 0.2, cex = 0.85)
dev.off()

png("out/fog-balanced-by-year.png", width = 900, height = 520)
plot(yr$year, yr$fog_pct, type = "b", pch = 19, lwd = 2, col = "#2166ac",
     ylim = c(0, max(yr$fog_pct) * 1.05),
     xlab = "year", ylab = "fog days (% of station-days)",
     main = "Fog days per year, balanced panel of six stations")
abline(fit, lty = 2, lwd = 2, col = "#b2182b")
legend("topright", bty = "n",
       legend = sprintf("OLS %.3f pp/yr, p = %.1e", coef(fit)[2], coef(summary(fit))[2, 4]))
dev.off()

cat(readLines("out/balanced.txt"), sep = "\n")
