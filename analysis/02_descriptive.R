# ============================================================
# 02_descriptive.R - descriptive statistics and method decisions
# Run from the repository root or the analysis folder.
# Input: analysis/dataset.csv (prepared analysis dataset)
# Output: report/tables, report/figures, analysis/interim
# ============================================================

# Normalise the working directory so this script works when sourced
# from the repository root or run while already inside analysis/.
if (file.exists("analysis/helpers.R")) {
  setwd("analysis")
} else if (!file.exists("helpers.R")) {
  stop("Cannot find analysis/helpers.R. Run from the repository root ",
       "or the analysis folder.")
}

source("helpers.R")
setup_dirs()
d <- load_data("dataset.csv")
cat("Cafes in dataset.csv:", nrow(d), "\n")

# ---- decision rule (stated in the report) ----
skew_max <- 0.5
n_clt <- 30
boot_skew_max <- 0.3
B <- 5000
seed <- 2026

rf <- d$roastery_f
ct <- d$cafe_type_f
sp <- function(variable, x, group, used)
  list(variable = variable, x = x, group = group, used = used)

specs <- list(
  sp(VN$esp, d$espresso, G_ALL, "A1, A8"),
  sp(VN$esp, d$espresso[which(rf == "Roastery")], "Roastery", "A2"),
  sp(VN$esp, d$espresso[which(rf == "Other cafes")], "Other cafes", "A2"),
  sp(VN$cap, d$cappuccino, G_ALL, "A6-A10"),
  sp(VN$cap, d$cappuccino[which(ct == "Independent")], "Independent", "A4"),
  sp(VN$cap, d$cappuccino[which(ct == "Local chain")], "Local chain", "A4"),
  sp(VN$cap, d$cappuccino[which(ct == "International chain")],
     "International chain", "A4"),
  sp(VN$diff, d$flatwhite - d$cappuccino, G_DIFF, "A3"),
  sp(VN$fw, d$flatwhite, G_ALL, "A5, A10 (median split)"),
  sp(VN$adj, d$adj_rating, G_ALL, "A6-A10")
)

boots <- list()
desc_row <- function(s) {
  x <- s$x[!is.na(s$x)]
  n <- length(x)
  if (n == 0) stop("No non-missing observations for ", s$variable,
                   " / ", s$group)
  sk <- skewness(x)
  sw <- if (n >= 3 && n <= 5000 && sd(x) > 0)
    shapiro.test(x)$p.value else NA_real_
  bm <- boot_means(x, B, seed)
  bsk <- skewness(bm)
  normal <- n >= 3 && !is.na(sk) && abs(sk) <= skew_max
  clt <- n >= n_clt && abs(bsk) <= boot_skew_max
  boots[[length(boots) + 1]] <<- data.frame(
    label = paste(s$variable, "|", s$group), value = bm
  )
  data.frame(
    variable = s$variable, group = s$group, used = s$used,
    n = n, missing = sum(is.na(s$x)), mean = mean(x), sd = sd(x),
    median = median(x), iqr = IQR(x), min = min(x), max = max(x),
    skew = sk, boot_skew = bsk, shapiro_p = sw,
    normal = normal, clt = clt, parametric = normal || clt,
    stringsAsFactors = FALSE
  )
}

tab <- do.call(rbind, lapply(specs, desc_row))
rownames(tab) <- NULL

yn <- function(x) ifelse(x, "Yes", "No")
D <- data.frame(
  Variable = tab$variable, Group = tab$group, n = tab$n,
  Missing = tab$missing, Skewness = f2(tab$skew),
  `Looks normal` = yn(tab$normal), `CLT applies` = yn(tab$clt),
  Method = ifelse(tab$parametric, "Parametric", "Non-parametric"),
  `Used in` = tab$used, check.names = FALSE
)
write_tex(D, "D_table", align = "llrrrllll")

S <- data.frame(
  Variable = tab$variable, Group = tab$group, n = tab$n,
  Mean = mapply(fx, tab$variable, tab$mean),
  SD = mapply(fx, tab$variable, tab$sd),
  Median = mapply(fx, tab$variable, tab$median),
  IQR = mapply(fx, tab$variable, tab$iqr),
  Min = mapply(fx, tab$variable, tab$min),
  Max = mapply(fx, tab$variable, tab$max),
  `Shapiro p` = pplain(tab$shapiro_p),
  `Boot. skew` = f2(tab$boot_skew),
  check.names = FALSE, row.names = NULL
)
write_tex(S, "D_stats", align = "llrrrrrrrrr")

above <- factor(
  ifelse(d$above_med_flatwhite == 1, "Above median", "At or below median"),
  levels = c("Above median", "At or below median")
)
cat_tab <- function(label, f) {
  t <- table(f, useNA = "no")
  data.frame(
    Variable = label, Category = names(t), n = as.integer(t),
    Percent = f1(100 * as.numeric(t) / sum(t)),
    Missing = sum(is.na(f)), stringsAsFactors = FALSE
  )
}
C <- rbind(
  cat_tab("Cafe type", d$cafe_type_f),
  cat_tab("Roastery", d$roastery_f),
  cat_tab("District", d$prague1_f),
  cat_tab("Flat white price vs median", above)
)
write_tex(C, "D_cat_table", align = "llrrr")

dir.create("interim", recursive = TRUE, showWarnings = FALSE)
write.csv(
  tab[, c("variable", "group", "normal", "clt", "parametric")],
  "interim/D_decisions.csv", row.names = FALSE
)

pl <- do.call(rbind, lapply(specs, function(s) {
  x <- s$x[!is.na(s$x)]
  data.frame(
    variable = s$variable, group = s$group,
    label = paste(s$variable, "|", s$group), value = x
  )
}))
bl <- do.call(rbind, boots)
lab <- label_wrap_gen(30)

save_fig(
  ggplot(pl, aes(value)) +
    geom_histogram(bins = 20, fill = "grey70", colour = "white") +
    facet_wrap(~label, scales = "free", ncol = 3, labeller = lab) +
    labs(x = NULL, y = "Number of cafes"),
  "D_hist", 9, 9
)
save_fig(
  ggplot(pl, aes(group, value)) +
    geom_boxplot(outlier.shape = NA, fill = "grey90") +
    geom_jitter(width = .15, alpha = .3, size = .8) +
    facet_wrap(~variable, scales = "free", ncol = 3, labeller = lab) +
    labs(x = NULL, y = NULL) +
    theme(axis.text.x = element_text(angle = 25, hjust = 1)),
  "D_box", 9, 8
)
save_fig(
  ggplot(pl, aes(sample = value)) +
    stat_qq(size = .8) + stat_qq_line(colour = "red") +
    facet_wrap(~label, scales = "free", ncol = 3, labeller = lab) +
    labs(x = "Theoretical quantiles", y = "Sample quantiles"),
  "D_qq", 9, 9
)
save_fig(
  ggplot(bl, aes(value)) +
    geom_histogram(bins = 30, fill = "grey70", colour = "white") +
    facet_wrap(~label, scales = "free", ncol = 3, labeller = lab) +
    labs(x = paste0("Bootstrapped mean (", B, " resamples, seed ", seed, ")"),
         y = "Count"),
  "D_bootmeans", 9, 9
)

options(width = 220)
cat("\nMedian flat white price:", median(d$flatwhite, na.rm = TRUE), "CZK\n")
cat("\n=== Decision table ===\n"); print(D, row.names = FALSE)
cat("\n=== Descriptive statistics ===\n"); print(S, row.names = FALSE)
cat("\n=== Categorical variables ===\n"); print(C, row.names = FALSE)
cat("\nSaved tables, figures and interim/D_decisions.csv\n")

# Return to the caller's repository-root context for the next script.
setwd("..")
