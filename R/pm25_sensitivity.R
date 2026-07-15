# =========================================================
# R/pm25_sensitivity.R
# NRSI Hackathon — PM2.5 sensitivity check
#
# Does ozone's effect on COPD prevalence hold up once PM2.5 is
# added as an additional covariate, in the (smaller) subset of
# counties that have both an ozone AND a PM2.5 monitor?
#
# PM2.5 is NOT a full covariate in the main analysis — method
# plan scopes it as sensitivity-only. This script IS that
# sensitivity check, not a replacement for linear_model.R.
# =========================================================

library(tidyverse)
library(car)      # vif()
library(broom)    # tidy()
library(janitor)

dir.create("output", showWarnings = FALSE)

# ---------------------------------------------------------
# 1. Load data, build the PM2.5 sensitivity subsample
#    (same column mapping as linear_model.R / ml_model.R,
#    plus pm25_mean — complete cases on all 6 vars now,
#    so this subsample is smaller than the main N=684)
# ---------------------------------------------------------
df <- read_csv("data/county_ozone_copd_merged.csv") %>%
  clean_names()

sens_df <- df %>%
  select(
    copd    = copd_crude_prev,
    ozone   = ozone_mean,
    smoking = csmoking_crude_prev,
    poverty = poverty_rate,
    age     = median_age,
    pm25    = pm25_mean
  ) %>%
  drop_na()

cat("N in PM2.5 sensitivity subsample:", nrow(sens_df), "\n")
cat("(main analytic sample was N=684; this one additionally requires\n",
    " a PM2.5 monitor, so it will be smaller — that's expected.)\n")

# ---------------------------------------------------------
# 1b. Characterize how the PM2.5-monitored subsample differs from the
#     counties dropped for lacking a PM2.5 monitor. This matters because
#     the ozone coefficient shifts noticeably (about 19 -> 27) just from
#     restricting to this subsample, BEFORE PM2.5 is even added as a
#     covariate -- if that shift went unexplained, it would look like an
#     unacknowledged inconsistency. Comparing means on both sides shows
#     whether it's a real compositional difference (consistent with the
#     non-random monitor-placement bias already discussed elsewhere in
#     the brief) rather than an error.
# ---------------------------------------------------------
main_df <- df %>%
  select(
    copd    = copd_crude_prev,
    ozone   = ozone_mean,
    smoking = csmoking_crude_prev,
    poverty = poverty_rate,
    age     = median_age,
    pm25    = pm25_mean
  ) %>%
  filter(!is.na(ozone), !is.na(copd), !is.na(smoking), !is.na(poverty), !is.na(age))

subsample_comparison <- main_df %>%
  mutate(has_pm25 = !is.na(pm25)) %>%
  group_by(has_pm25) %>%
  summarise(
    n             = n(),
    mean_ozone    = mean(ozone),
    mean_smoking  = mean(smoking),
    mean_poverty  = mean(poverty),
    mean_age      = mean(age),
    mean_copd     = mean(copd),
    .groups = "drop"
  ) %>%
  arrange(desc(has_pm25))

cat(sprintf(
  "\nHow does the PM2.5-monitored subsample (N=%d) differ from the counties\ndropped for lacking a PM2.5 monitor (N=%d)?\n",
  sum(!is.na(main_df$pm25)), sum(is.na(main_df$pm25))
))
print(subsample_comparison)

write_csv(subsample_comparison, "output/pm25_subsample_comparison.csv")

# ---------------------------------------------------------
# 2. Two models on the IDENTICAL subsample. Fitting both on
#    the same rows isolates "what changes when PM2.5 is added"
#    from "what changes because the sample is smaller" — those
#    would be confounded if the 4-var model were instead pulled
#    from linear_model.R's full N=684 fit.
# ---------------------------------------------------------
model_4var <- lm(copd ~ ozone + smoking + poverty + age, data = sens_df)
model_5var <- lm(copd ~ ozone + smoking + poverty + age + pm25, data = sens_df)

# ---------------------------------------------------------
# 3. VIF on the 5-variable model — ozone and PM2.5 are both
#    pollutants and plausibly correlated at the county level
# ---------------------------------------------------------
vif_5var <- car::vif(model_5var)
print(vif_5var)

vif_flags <- tibble(
  predictor = names(vif_5var),
  vif = as.numeric(vif_5var)
) %>%
  mutate(flag = case_when(
    vif > 10 ~ "SEVERE multicollinearity",
    vif > 5  ~ "moderate multicollinearity",
    TRUE     ~ "ok"
  ))
print(vif_flags)

# ---------------------------------------------------------
# 4. Direct before/after comparison of the ozone coefficient
#    — this table IS the sensitivity check
# ---------------------------------------------------------
ozone_comparison <- bind_rows(
  tidy(model_4var, conf.int = TRUE) %>% filter(term == "ozone") %>% mutate(model = "without_pm25"),
  tidy(model_5var, conf.int = TRUE) %>% filter(term == "ozone") %>% mutate(model = "with_pm25")
) %>%
  select(model, estimate, std.error, statistic, p.value, conf.low, conf.high)

print(ozone_comparison)

# ---------------------------------------------------------
# 5. Full coefficient tables for both models, for the appendix
# ---------------------------------------------------------
coefs_4var <- tidy(model_4var, conf.int = TRUE) %>% mutate(model = "without_pm25")
coefs_5var <- tidy(model_5var, conf.int = TRUE) %>% mutate(model = "with_pm25")
all_coefs  <- bind_rows(coefs_4var, coefs_5var)
print(all_coefs)

# ---------------------------------------------------------
# 6. Save outputs
# ---------------------------------------------------------
write_csv(all_coefs, "output/pm25_sensitivity_coefficients.csv")
write_csv(ozone_comparison, "output/pm25_sensitivity_ozone_comparison.csv")
write_csv(vif_flags, "output/pm25_sensitivity_vif.csv")
saveRDS(model_5var, "output/pm25_sensitivity_model.rds")

cat("\n--- Done ---\n")
cat("N (sensitivity subsample):", nrow(sens_df), "\n")
cat(
  "Ozone coefficient without PM2.5:",
  round(coefs_4var$estimate[coefs_4var$term == "ozone"], 3),
  " (p =", signif(coefs_4var$p.value[coefs_4var$term == "ozone"], 3), ")\n"
)
cat(
  "Ozone coefficient with PM2.5:   ",
  round(coefs_5var$estimate[coefs_5var$term == "ozone"], 3),
  " (p =", signif(coefs_5var$p.value[coefs_5var$term == "ozone"], 3), ")\n"
)
cat(
  "Max VIF (5-var model):", round(max(vif_5var), 2),
  "(", vif_flags$predictor[which.max(vif_5var)], ")\n"
)