# f5-abolition -- "on track to disappear". This run exists to show what that phrase is made of.
#
# It is a straight line through 35 annual points, extended until it crosses zero. That is all it
# is. The run computes the same extrapolation for the thunderstorm indicator, from the same
# stations and the same days, because the identical arithmetic there produces a conclusion nobody
# in the room will accept, and the comparison is the honest way to price the phrase.

d <- read.csv("inputs/fog-nebel-gew.csv", stringsAsFactors = FALSE)
d$year <- as.integer(substr(d$time, 1, 4))
d <- d[d$year >= 1990 & d$year <= 2024, ]
cov_n    <- table(d$station[!is.na(d$nebel)], d$year[!is.na(d$nebel)])
balanced <- as.integer(rownames(cov_n)[apply(cov_n, 1, function(r) all(r > 0))])
b <- d[d$station %in% balanced & !is.na(d$nebel) & !is.na(d$gew), ]

yr <- data.frame(year      = sort(unique(b$year)),
                 nebel_pct = 100 * tapply(b$nebel, b$year, mean),
                 gew_pct   = 100 * tapply(b$gew,   b$year, mean))

dir.create("out", showWarnings = FALSE)

cross <- function(fit) -coef(fit)[1] / coef(fit)[2]
fn <- lm(nebel_pct ~ year, data = yr)
fg <- lm(gew_pct   ~ year, data = yr)

# the same line fitted to log-rate, i.e. constant proportional decline, which never reaches zero
fl <- lm(log(nebel_pct) ~ year, data = yr)

fut <- data.frame(year = 1990:2070)
pn  <- predict(fn, fut, interval = "prediction")
res <- data.frame(year = fut$year, fit = round(pn[, 1], 3),
                  lwr = round(pn[, 2], 3), upr = round(pn[, 3], 3),
                  log_model = round(exp(predict(fl, fut)), 3))
write.csv(res, "out/extrapolation.csv", row.names = FALSE)

sink("out/abolition.txt")
cat("Linear extrapolation of the balanced-panel annual fog rate, 1990-2024.\n\n")
cat(sprintf("nebel: %+.4f pp/yr, intercept %.2f -> crosses zero in %.0f\n",
            coef(fn)[2], predict(fn, data.frame(year = 1990)), cross(fn)))
cat(sprintf("gew:   %+.4f pp/yr, intercept %.2f -> crosses zero in %.0f\n",
            coef(fg)[2], predict(fg, data.frame(year = 1990)), cross(fg)))
cat("\nThe second line is the price of the first. Nothing in the data distinguishes the two\n")
cat("extrapolations; they are the same arithmetic on two columns of the same rows. If\n")
cat("'fog is abolished by 2043' is a finding, then 'thunderstorms are abolished by 2065' is\n")
cat("the same finding, and it is absurd. A linear fit to a bounded, strictly positive quantity\n")
cat("has a zero crossing by construction, whatever the data are.\n")
# both models scored on the ORIGINAL scale, so the comparison means something
sse <- function(p) sum((yr$nebel_pct - p)^2)
sst <- sum((yr$nebel_pct - mean(yr$nebel_pct))^2)
r2_lin <- 1 - sse(fitted(fn)) / sst
r2_log <- 1 - sse(exp(fitted(fl))) / sst
cat(sprintf("\nA constant-proportional-decline model on the same points (log-linear, %+.2f%%/yr)\n",
            100 * (exp(coef(fl)[2]) - 1)))
cat(sprintf("fits the observed rates slightly WORSE (R2 on the original scale %.3f vs %.3f)\n",
            r2_log, r2_lin))
cat("and never reaches zero at all:\n")
for (y in c(2030, 2043, 2050, 2070))
  cat(sprintf("   %d: linear %+6.2f%%   log-linear %5.2f%%\n",
              y, res$fit[res$year == y], res$log_model[res$year == y]))
cat(sprintf("\nThe two models are %.3f vs %.3f on the same scale -- a difference of %.1f%% of the\n",
            r2_lin, r2_log, 100 * (r2_lin - r2_log)))
cat("variance, which is not a basis on which to prefer either. Both are fitted to the same 35\n")
cat("numbers. Choosing between them is a choice about what fog is, not a result read off the\n")
cat("file, and the two disagree about whether the claim in the TASK is true at all.\n")
sink()

png("out/abolition.png", width = 980, height = 560)
plot(yr$year, yr$nebel_pct, pch = 19, col = "#2166ac", xlim = c(1990, 2070),
     ylim = c(-2, 12), xlab = "year", ylab = "fog days (% of station-days)",
     main = "'On track to disappear': one straight line, extended")
polygon(c(res$year, rev(res$year)), c(res$lwr, rev(res$upr)),
        col = "#2166ac22", border = NA)
abline(h = 0, col = "grey40")
lines(res$year, res$fit, lwd = 2, lty = 2, col = "#2166ac")
lines(res$year, res$log_model, lwd = 2, col = "#1a9850")
points(cross(fn), 0, pch = 4, cex = 2, lwd = 3, col = "#b2182b")
text(cross(fn), 0.7, sprintf("zero in %.0f", cross(fn)), col = "#b2182b")
legend("topright", bty = "n", lwd = 2, lty = c(2, 1), col = c("#2166ac", "#1a9850"),
       legend = c("linear fit, with 95% prediction band", "constant-proportional fit, never reaches zero"))
dev.off()

png("out/abolition-both.png", width = 980, height = 560)
plot(yr$year, yr$nebel_pct, pch = 19, col = "#2166ac", xlim = c(1990, 2070),
     ylim = c(-2, 12), xlab = "year", ylab = "% of station-days",
     main = "The same extrapolation applied to thunderstorms")
points(yr$year, yr$gew_pct, pch = 17, col = "#b2182b")
abline(h = 0, col = "grey40")
lines(res$year, res$fit, lwd = 2, lty = 2, col = "#2166ac")
lines(fut$year, predict(fg, fut), lwd = 2, lty = 2, col = "#b2182b")
points(c(cross(fn), cross(fg)), c(0, 0), pch = 4, cex = 2, lwd = 3)
text(cross(fn), 0.8, sprintf("fog: %.0f", cross(fn)), col = "#2166ac")
text(cross(fg), 0.8, sprintf("thunderstorms: %.0f", cross(fg)), col = "#b2182b")
dev.off()

cat(readLines("out/abolition.txt"), sep = "\n")
