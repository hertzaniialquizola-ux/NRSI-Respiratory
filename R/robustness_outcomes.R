# =========================================================
# R/robustness_outcomes.R
# NRSI Hackathon -- multi-outcome robustness check
#
# Direct analog to the "four additional outcomes" robustness strategy
# from the author's prior NHSJS paper (PM2.5/pediatric asthma,
# Philippines): re-run the identical OLS specification
#   outcome ~ ozone + smoking + poverty + age
# on two additional CDC PLACES outcomes, using the SAME county sample
# construction logic as linear_model.R, to test whether the modest
# ozone effect found for COPD is specific to COPD or shows up anywhere:
#
#   1. CASTHMA (adult current asthma prevalence) -- a second respiratory
#      outcome. If ozone shows a similar modest, significant effect
#      here, that's a second independent confirmation of the main
#      finding (same logic as testing COPD across model classes, now
#      extended across outcomes).
#   2. DIABETES (adult diabetes prevalence) -- a falsification /
#      specificity check. Ozone has no known biological mechanism
#      affecting diabetes risk. If ozone "predicts" diabetes about as
#      well as it predicts COPD, that would suggest the COPD finding is
#      picking up general county-level confounding (unhealthy/poor
#      counties look bad on everything) rather than a real
#      ozone-respiratory effect. If it doesn't, that strengthens the
#      case that the COPD result is specific and real.
#
# This is a SUPPLEMENTARY check, not one of the brief's two primary
# visuals (feature importance + ozone PDP, per the method plan) -- its
# output is a comparison table (+ one supplementary figure) for the
# Discussion/robustness section, matching how the benchmark paper's
# multi-outcome test was framed as reinforcing, not replacing, its
# primary result.
# =========================================================

library(tidyverse)
library(car)      # vif()
library(broom)    # tidy()
library(janitor)

dir.create("output", showWarnings = FALSE)

# ---------------------------------------------------------
# 1. Load data. Re-derive each outcome's own complete-case sample from
#    the same merged file linear_model.R uses -- PLACES suppresses
#    each measure independently, so CASTHMA/DIABETES may be missing
#    for a handful of the 684 counties even though COPD is not.
# ---------------------------------------------------------
df <- read_csv("data/county_ozone_copd_merged.csv", show_col_types = FALSE) %>%
  clean_names()

base_df <- df %>%
  select(
    ozone   = ozone_mean,
    smoking = csmoking_crude_prev,
    poverty = poverty_rate,
    age     = median_age,
    copd    = copd_crude_prev,
    asthma  = casthma_crude_prev,
    diabetes = diabetes_crude_prev
  )

cat("N in main COPD sample (from linear_model.R):", sum(complete.cases(
  base_df %>% select(ozone, smoking, poverty, age, copd)
)), "\n")

# ---------------------------------------------------------
# 2. Fit the identical specification on each outcome, on that
#    outcome's own complete-case subsample
# ---------------------------------------------------------
fit_outcome <- function(data, outcome_col, label) {
  model_df <- data %>%
    select(ozone, smoking, poverty, age, outcome = all_of(outcome_col)) %>%
    drop_na()

  model     <- lm(outcome ~ ozone + smoking + poverty + age, data = model_df)
  model_std <- lm(
    outcome ~ ozone + smoking + poverty + age,
    data = model_df %>% mutate(across(c(ozone, smoking, poverty, age), ~ as.numeric(scale(.x))))
  )

  ozone_row     <- tidy(model, conf.int = TRUE) %>% filter(term == "ozone")
  ozone_std_row <- tidy(model_std, conf.int = TRUE) %>% filter(term == "ozone")
  vif_vals      <- car::vif(model)

  tibble(
    outcome           = label,
    n                 = nrow(model_df),
    ozone_coefficient = ozone_row$estimate,
    ozone_se          = ozone_row$std.error,
    ozone_p_value     = ozone_row$p.value,
    ozone_std_coef    = ozone_std_row$estimate,
    ozone_std_se      = ozone_std_row$std.error,
    ozone_std_conf_low  = ozone_std_row$conf.low,
    ozone_std_conf_high = ozone_std_row$conf.high,
    adj_r_squared     = summary(model)$adj.r.squared,
    max_vif           = max(vif_vals)
  )
}

results <- bind_rows(
  fit_outcome(base_df, "copd",     "COPD prevalence (primary outcome)"),
  fit_outcome(base_df, "asthma",   "Current asthma prevalence (2nd respiratory outcome)"),
  fit_outcome(base_df, "diabetes", "Diabetes prevalence (falsification check)")
)

print(results)

# ---------------------------------------------------------
# 3. Interpretation printed to console -- does the falsification
#    check behave as expected (weaker/absent ozone effect vs. the two
#    respiratory outcomes)?
# ---------------------------------------------------------
copd_std     <- results$ozone_std_coef[results$outcome == "COPD prevalence (primary outcome)"]
asthma_std   <- results$ozone_std_coef[results$outcome == "Current asthma prevalence (2nd respiratory outcome)"]
diabetes_std <- results$ozone_std_coef[results$outcome == "Diabetes prevalence (falsification check)"]

cat(sprintf(
  "\nStandardized ozone effect -- COPD: %.3f | Asthma: %.3f | Diabetes (falsification): %.3f\n",
  copd_std, asthma_std, diabetes_std
))
cat(
  if (abs(diabetes_std) < abs(copd_std) && abs(diabetes_std) < abs(asthma_std)) {
    "Falsification check PASSES: ozone's effect on diabetes is smaller than on either\nrespiratory outcome -- consistent with a real, respiratory-specific effect rather\nthan generic county-level confounding.\n"
  } else {
    "Falsification check DID NOT clearly pass: ozone's effect on diabetes is not\nclearly smaller than on the respiratory outcomes -- report this honestly rather\nthan omitting it; it would suggest some of the COPD effect may reflect general\ncounty-level confounding not fully captured by smoking/poverty/age.\n"
  }
)

# ---------------------------------------------------------
# 4. Supplementary figure (NOT one of the brief's two primary visuals --
#    this is appendix/robustness material, styled to match Figure 1/2)
# ---------------------------------------------------------
results_plot <- results %>%
  mutate(is_falsification = outcome == "Diabetes prevalence (falsification check)")

fig_supp <- ggplot(
  results_plot,
  aes(x = reorder(outcome, ozone_std_coef), y = ozone_std_coef, fill = is_falsification)
) +
  geom_col(width = 0.6) +
  geom_errorbar(
    aes(ymin = ozone_std_conf_low, ymax = ozone_std_conf_high),
    width = 0.15, color = "#333333"
  ) +
  coord_flip() +
  scale_fill_manual(values = c(`FALSE` = "#2c5f8a", `TRUE` = "#c0392b"), guide = "none") +
  labs(
    title = "Supplementary Figure. Ozone's standardized effect across three outcomes",
    subtitle = "Diabetes (red) has no known ozone mechanism -- included as a falsification check.\nA smaller effect there than for COPD/asthma supports outcome-specificity.",
    x = NULL, y = "Standardized ozone coefficient (95% CI)"
  ) +
  theme_minimal(base_size = 11) +
  theme(plot.subtitle = element_text(size = 8, color = "grey30"))

ggsave("output/figure_supplementary_robustness_outcomes.png", fig_supp, width = 8, height = 4, dpi = 300)

# ---------------------------------------------------------
# 5. Save results
# ---------------------------------------------------------
write_csv(results, "output/robustness_outcomes_comparison.csv")

cat("\n--- Done ---\n")
cat("Saved: output/robustness_outcomes_comparison.csv\n")
cat("Saved: output/figure_supplementary_robustness_outcomes.png\n")
