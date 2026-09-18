# Earthquakes per year, M3+ California -- counted the way a moment-magnitude catalogue counts them.
#
# Identical to q1 in every respect but one line: the subset. q1 counts every M3+ event in the file.
# This counts every M3+ event in the file whose magnitude is reported as a MOMENT magnitude
# (magType mw/mwr/mwb/mwc/mww). Same file, same window, same magnitude floor, same region.
#
# Moment magnitude requires broadband instruments and waveform inversion. California had almost
# none of that in 1970 and has it everywhere now. So this line does not measure the Earth.

d <- read.csv("inputs/quakes.csv", stringsAsFactors = FALSE)
d$year <- as.integer(substr(d$time, 1, 4))
d <- d[!is.na(d$year) & !is.na(d$mag), ]

mw <- d[grepl("^mw", d$magType, ignore.case = TRUE), ]

years <- data.frame(year = 1970:2025)
agg <- merge(years,
             as.data.frame(table(year = mw$year), stringsAsFactors = FALSE),
             by = "year", all.x = TRUE)
names(agg)[2] <- "quakes"
agg$quakes[is.na(agg$quakes)] <- 0
agg$year <- as.integer(agg$year)

# the same count for the whole catalogue, so both series are in one recorded output
all_agg <- merge(years, as.data.frame(table(year = d$year), stringsAsFactors = FALSE),
                 by = "year", all.x = TRUE)
names(all_agg)[2] <- "all_quakes"
all_agg$all_quakes[is.na(all_agg$all_quakes)] <- 0
agg <- merge(agg, all_agg, by = "year")

dir.create("out", showWarnings = FALSE)
write.csv(agg, "out/quakes-moment-magnitude-per-year.csv", row.names = FALSE)

fit_mw  <- lm(quakes ~ year, data = agg)
fit_all <- lm(all_quakes ~ year, data = agg)
sink("out/trend.txt")
cat("California M3+, 1970-2025, USGS ComCat.\n\n")
cat("Events reported with a MOMENT magnitude, per year:\n")
print(coef(summary(fit_mw)))
cat(sprintf("\n1970-1979 total: %d\n", sum(agg$quakes[agg$year < 1980])))
cat(sprintf("2016-2025 total: %d\n", sum(agg$quakes[agg$year >= 2016])))
cat(sprintf("ratio: %.1fx\n", sum(agg$quakes[agg$year >= 2016]) / sum(agg$quakes[agg$year < 1980])))
cat("\nALL events in the same file, per year:\n")
print(coef(summary(fit_all)))
cat(sprintf("\n1970-1979 total: %d\n", sum(agg$all_quakes[agg$year < 1980])))
cat(sprintf("2016-2025 total: %d\n", sum(agg$all_quakes[agg$year >= 2016])))
cat(sprintf("ratio: %.2fx\n", sum(agg$all_quakes[agg$year >= 2016]) / sum(agg$all_quakes[agg$year < 1980])))
sink()

png("out/quakes-moment-magnitude-per-year.png", width = 900, height = 520)
plot(agg$year, agg$quakes, type = "l", lwd = 2, col = "#b2182b",
     xlab = "year", ylab = "earthquakes M3+ recorded",
     main = "California M3+ earthquakes reported with a moment magnitude")
abline(fit_mw, lty = 2, col = "#b2182b")
dev.off()

png("out/both-series.png", width = 900, height = 520)
plot(agg$year, agg$all_quakes, type = "l", lwd = 2, col = "#4d4d4d",
     ylim = c(0, max(agg$all_quakes)),
     xlab = "year", ylab = "earthquakes M3+ recorded",
     main = "Same file, same events: all M3+ (grey) vs moment-magnitude only (red)")
lines(agg$year, agg$quakes, lwd = 2, col = "#b2182b")
dev.off()

cat("wrote out/\n")
print(agg)
