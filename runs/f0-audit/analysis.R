# f0-audit -- what is actually in the file, before anybody computes a trend.
#
# Written first, on purpose. The thing that decides whether a fog rate means anything is the
# denominator, and the denominator is not a modelling choice, it is a fact about the file.

d <- read.csv("inputs/fog-nebel-gew.csv", stringsAsFactors = FALSE)
d$year <- as.integer(substr(d$time, 1, 4))

dir.create("out", showWarnings = FALSE)

# 1. coverage: how many station-days carry a value for each indicator, per station per year
cov_n <- table(station = d$station[!is.na(d$nebel)], year = d$year[!is.na(d$nebel)])
cov_g <- table(station = d$station[!is.na(d$gew)],   year = d$year[!is.na(d$gew)])
write.csv(as.data.frame.matrix(cov_n), "out/coverage-nebel.csv")
write.csv(as.data.frame.matrix(cov_g), "out/coverage-gew.csv")

# 2. the denominator, per five-year period, for both indicators side by side
d5 <- d[d$year <= 2024, ]
d5$period <- paste0(d5$year - (d5$year %% 5), "-", d5$year - (d5$year %% 5) + 4)
den <- data.frame(
  period      = sort(unique(d5$period)),
  nebel_days  = as.integer(tapply(!is.na(d5$nebel), d5$period, sum)),
  gew_days    = as.integer(tapply(!is.na(d5$gew),   d5$period, sum)),
  nebel_stns  = as.integer(tapply(d5$station[!is.na(d5$nebel)], d5$period[!is.na(d5$nebel)],
                                  function(x) length(unique(x)))),
  gew_stns    = as.integer(tapply(d5$station[!is.na(d5$gew)],   d5$period[!is.na(d5$gew)],
                                  function(x) length(unique(x))))
)
write.csv(den, "out/denominator-by-period.csv", row.names = FALSE)

# 3. which stations report nebel in every year of 1990-2024 -- the balanced panel
balanced <- as.integer(rownames(cov_n)[apply(cov_n[, as.character(1990:2024)], 1,
                                             function(r) all(r > 0))])
writeLines(as.character(balanced), "out/balanced-panel-stations.txt")

sink("out/audit.txt")
cat("GeoSphere klima-v2-1d, 10 stations, 1990-2025.\n")
cat(sprintf("rows: %d   station-days with nebel: %d   with gew: %d\n\n",
            nrow(d), sum(!is.na(d$nebel)), sum(!is.na(d$gew))))
cat("Every station-day is present as a ROW for all ten stations in all years.\n")
cat("What changes is whether the row carries a value.\n\n")
cat("Denominator by period (1990-2024; 2025 excluded, it is a part-period):\n")
print(den, row.names = FALSE)
cat(sprintf("\nnebel reporting station-days, 1990-1994 -> 2020-2024: %d -> %d  (%+.1f%%)\n",
            den$nebel_days[1], den$nebel_days[7],
            100 * (den$nebel_days[7] / den$nebel_days[1] - 1)))
cat(sprintf("gew   reporting station-days, 1990-1994 -> 2020-2024: %d -> %d  (%+.1f%%)\n",
            den$gew_days[1], den$gew_days[7],
            100 * (den$gew_days[7] / den$gew_days[1] - 1)))
cat("\nThe two indicators come off the SAME rows and their denominators diverge. Any rate\n")
cat("computed over 'rows that reported' is therefore partly a measure of who was reporting.\n")
cat("\nStations reporting nebel in EVERY year 1990-2024 (the balanced panel):\n")
cat(paste(balanced, collapse = ", "), "\n")
cat(sprintf("%d of 10 stations.\n", length(balanced)))
cat("\nStations that stop reporting nebel, and the last year they do:\n")
for (s in rownames(cov_n)) {
  yrs <- as.integer(colnames(cov_n)[cov_n[s, ] > 0])
  if (max(yrs) < 2024) cat(sprintf("  station %-4s last nebel %d", s, max(yrs)))
  else if (!(as.integer(s) %in% balanced)) cat(sprintf("  station %-4s gaps, last nebel %d", s, max(yrs)))
  else next
  gy <- as.integer(colnames(cov_g)[cov_g[s, ] > 0])
  cat(sprintf("   (still reporting gew through %d)\n", max(gy)))
}
sink()

png("out/denominator.png", width = 900, height = 520)
mat <- rbind(nebel = den$nebel_days, gew = den$gew_days)
barplot(mat, beside = TRUE, names.arg = den$period, las = 2,
        col = c("#2166ac", "#b2182b"), ylab = "station-days carrying a value",
        main = "The denominator: who was reporting, per indicator")
legend("topright", c("nebel", "gew"), fill = c("#2166ac", "#b2182b"), bty = "n")
dev.off()

cat(readLines("out/audit.txt"), sep = "\n")
