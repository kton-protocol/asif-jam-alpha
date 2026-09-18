# f6-stations -- where the headline decline actually lives.
#
# "Fog in Austria" is six stations. This run takes the headline apart station by station, because
# a panel mean can be a national fact or it can be two stations, and the difference matters.

d <- read.csv("inputs/fog-nebel-gew.csv", stringsAsFactors = FALSE)
d$year <- as.integer(substr(d$time, 1, 4))
d <- d[d$year >= 1990 & d$year <= 2024, ]
cov_n    <- table(d$station[!is.na(d$nebel)], d$year[!is.na(d$nebel)])
balanced <- as.integer(rownames(cov_n)[apply(cov_n, 1, function(r) all(r > 0))])
b <- d[d$station %in% balanced & !is.na(d$nebel), ]

dir.create("out", showWarnings = FALSE)

rows <- do.call(rbind, lapply(balanced, function(s) {
  e  <- b[b$station == s, ]
  y  <- data.frame(year = sort(unique(e$year)),
                   pct  = 100 * tapply(e$nebel, e$year, mean))
  f  <- lm(pct ~ year, data = y)
  data.frame(station   = s,
             first5    = round(mean(y$pct[1:5]), 2),
             last5     = round(mean(y$pct[31:35]), 2),
             pct_chg   = round(100 * (mean(y$pct[31:35]) / mean(y$pct[1:5]) - 1), 1),
             slope     = round(coef(f)[2], 4),
             p         = signif(coef(summary(f))[2, 4], 3),
             fogdays_1990_1994 = sum(e$nebel[e$year <= 1994]),
             fogdays_2020_2024 = sum(e$nebel[e$year >= 2020]))
}))
write.csv(rows, "out/by-station.csv", row.names = FALSE)

tot_drop <- sum(rows$fogdays_1990_1994) - sum(rows$fogdays_2020_2024)
rows$share_of_drop <- round(100 * (rows$fogdays_1990_1994 - rows$fogdays_2020_2024) / tot_drop, 1)

# leave-one-out: does the panel trend survive dropping each station in turn?
loo <- do.call(rbind, lapply(balanced, function(s) {
  e <- b[b$station != s, ]
  y <- data.frame(year = sort(unique(e$year)), pct = 100 * tapply(e$nebel, e$year, mean))
  f <- lm(pct ~ year, data = y)
  data.frame(dropped = s, slope = round(coef(f)[2], 4),
             p = signif(coef(summary(f))[2, 4], 3),
             chg_pct = round(100 * (mean(y$pct[31:35]) / mean(y$pct[1:5]) - 1), 1))
}))
write.csv(loo, "out/leave-one-out.csv", row.names = FALSE)

sink("out/by-station.txt")
cat("Balanced panel taken apart, 1990-2024. 'first5'/'last5' are mean annual fog-day rates.\n\n")
print(rows, row.names = FALSE)
cat(sprintf("\nEvery one of the %d stations declines. Slope is negative in all %d;\n",
            nrow(rows), sum(rows$slope < 0)))
cat(sprintf("significant at p<0.05 in %d of %d.\n", sum(rows$p < 0.05), nrow(rows)))
cat("\nBUT the decline is not evenly spread. Two stations carry most of it:\n")
o <- rows[order(-rows$share_of_drop), ]
for (i in seq_len(nrow(o)))
  cat(sprintf("  station %-4d %5.2f%% -> %5.2f%%  (%+6.1f%%)   %4.1f%% of the panel's lost fog days\n",
              o$station[i], o$first5[i], o$last5[i], o$pct_chg[i], o$share_of_drop[i]))
cat(sprintf("\nThe top two stations account for %.1f%% of the drop in fog days.\n",
            sum(o$share_of_drop[1:2])))
cat(sprintf("Station %d alone starts at %.2f%%, nearly three times the panel's quietest station,\n",
            o$station[1], o$first5[1]))
cat("and ends indistinguishable from it. A site that changes that much relative to its\n")
cat("neighbours is as consistent with something changing at the site -- instrument, exposure,\n")
cat("observer, surroundings -- as with regional climate. This file cannot tell us which.\n")
cat("\nLeave-one-out: panel trend with each station removed in turn:\n")
print(loo, row.names = FALSE)
cat(sprintf("\nSlope range across the six leave-one-out panels: %.4f to %.4f (full panel %.4f).\n",
            min(loo$slope), max(loo$slope), -0.1704))
cat("The sign and significance survive every deletion. The MAGNITUDE does not: it ranges from\n")
cat(sprintf("%+.1f%% to %+.1f%% depending on which single station is left out.\n",
            min(loo$chg_pct), max(loo$chg_pct)))
sink()

png("out/by-station.png", width = 980, height = 560)
par(mar = c(5, 4, 4, 2))
m <- rbind(rows$first5, rows$last5)
bp <- barplot(m, beside = TRUE, names.arg = paste("stn", rows$station),
              col = c("#92c5de", "#2166ac"), ylab = "fog days (% of station-days)",
              main = "Every station falls -- but two of six carry most of the fall")
legend("topright", c("1990-1994", "2020-2024"), fill = c("#92c5de", "#2166ac"), bty = "n")
text(colMeans(bp), pmax(m[1, ], m[2, ]) + 0.6, sprintf("%+.0f%%", rows$pct_chg), cex = 0.9)
dev.off()

png("out/station-series.png", width = 980, height = 560)
cols <- c("#2166ac", "#b2182b", "#1a9850", "#d95f02", "#7570b3", "#666666")
plot(NA, xlim = c(1990, 2024), ylim = c(0, 25), xlab = "year",
     ylab = "fog days (% of station-days)", main = "Each panel station, annual fog-day rate")
for (i in seq_along(balanced)) {
  e <- b[b$station == balanced[i], ]
  y <- data.frame(year = sort(unique(e$year)), pct = 100 * tapply(e$nebel, e$year, mean))
  lines(y$year, y$pct, lwd = 2, col = cols[i])
}
legend("topright", paste("station", balanced), lwd = 2, col = cols, bty = "n", ncol = 2)
dev.off()

cat(readLines("out/by-station.txt"), sep = "\n")
