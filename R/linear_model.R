# =========================================================
# R/linear_model.R
# NRSI Hackathon — OLS baseline
# COPD ~ ozone + smoking + poverty + age, + VIF check
# (method plan step 2 — run before any ML model / interpretation)
# =========================================================

library(tidyverse)
library(car)      # vif()
library(janitor)  # clean_names()
library(broom)    # tidy()

dir.create("output", showWarnings = FALSE)

# ---------------------------------------------------------
# 1. Load data
# ---------------------------------------------------------
df <- read_csv("data/county_ozone_copd_merged.csv") %>%
  clean_names()

cat("N counties loaded:", nrow(df), "\n")
print(names(df))

# ---------------------------------------------------------
# 2. Column mapping (confirmed against actual build_dataset.R output)
#
#    NOTE on copd_crude_prev vs copd_adj_prev: PLACES' age-adjusted
#    prevalence is standardized to a reference population, i.e. it
#    already removes each county's age-composition effect on COPD.
#    Since age is also a covariate here, using copd_adj_prev as the
#    outcome would double-adjust for age (once by CDC, once by this
#    model). Using crude prevalence + median_age as a covariate lets
#    the regression estimate age's contribution directly instead of
#    having it partially absorbed twice. Worth a sentence in the
#    Method section — it's the kind of explicit scope decision your
#    log already calls out (PM2.5 sensitivity-only, ecological fallacy).
# ---------------------------------------------------------
col_map <- c(
  copd    = "copd_crude_prev",     # adult COPD prevalence, % (PLACES, crude)
  ozone   = "ozone_mean",          # annual mean ozone (EPA)
  smoking = "csmoking_crude_prev", # adult smoking prevalence, % (PLACES)
  poverty = "poverty_rate",        # % below federal poverty line (ACS)
  age     = "median_age"           # county median age (ACS)
)

missing_cols <- setdiff(col_map, names(df))
if (length(missing_cols) > 0) {
  stop(
    "Column(s) not found in df: ", paste(missing_cols, collapse = ", "),
    "\nRun `names(df)` above and update col_map to match your actual columns."
  )
}

model_df <- df %>%
  select(all_of(col_map)) %>%   # named vector selects + renames in one step
  drop_na()

cat("N in model (complete cases on all 5 vars):", nrow(model_df), "\n")
if (nrow(model_df) != nrow(df)) {
  cat("Note:", nrow(df) - nrow(model_df),
      "rows dropped here for NAs beyond the build_dataset.R filter — ",
      "investigate if this number is nonzero, since build_dataset.R was\n",
      "supposed to already enforce complete cases on these vars.\n")
}

# ---------------------------------------------------------
# 3. OLS baseline model
# ---------------------------------------------------------
ols_model <- lm(copd ~ ozone + smoking + poverty + age, data = model_df)
summary(ols_model)

# ---------------------------------------------------------
# 4. VIF check — BEFORE interpreting any coefficient
#    (per method plan: smoking/poverty are the likely correlated pair)
# ---------------------------------------------------------
vif_values <- car::vif(ols_model)
print(vif_values)

vif_flags <- tibble(
  predictor = names(vif_values),
  vif = as.numeric(vif_values)
) %>%
  mutate(flag = case_when(
    vif > 10 ~ "SEVERE multicollinearity",
    vif > 5  ~ "moderate multicollinearity",
    TRUE     ~ "ok"
  ))
print(vif_flags)

# ---------------------------------------------------------
# 5. Standardized (beta) coefficients
#    Needed to answer "how much does ozone contribute relative
#    to smoking/poverty/age" — raw coefficients aren't comparable
#    across variables measured in different units/scales.
# ---------------------------------------------------------
model_df_z <- model_df %>%
  mutate(across(c(ozone, smoking, poverty, age), ~ as.numeric(scale(.x))))

ols_model_std <- lm(copd ~ ozone + smoking + poverty + age, data = model_df_z)

std_coefs <- tidy(ols_model_std) %>%
  filter(term != "(Intercept)") %>%
  arrange(desc(abs(estimate)))

print(std_coefs)

# ---------------------------------------------------------
# 5b. Ozone x poverty interaction
#
#    The Motivation section cites SPIROMICS AIR's finding that ozone
#    and neighborhood poverty INTERACT -- COPD patients in poorer
#    neighborhoods respond worse to the same ozone exposure -- and
#    argues poverty should be treated as an effect-modifier, not just
#    a control-and-forget covariate. That claim needs an actual
#    interaction term, not just the additive model above, or the
#    brief is asserting more sophistication than it tested.
#
#    Ozone and poverty are mean-centered before interacting -- standard
#    practice so the main-effect coefficients stay interpretable at the
#    sample mean and any multicollinearity between the main effects and
#    the product term is purely structural, not substantive.
# ---------------------------------------------------------
interaction_df <- model_df %>%
  mutate(
    ozone_c   = ozone - mean(ozone),
    poverty_c = poverty - mean(poverty)
  )

interaction_model <- lm(
  copd ~ ozone_c * poverty_c + smoking + age,
  data = interaction_df
)

summary(interaction_model)

interaction_coefs <- tidy(interaction_model, conf.int = TRUE)
print(interaction_coefs)

# GVIF on the interaction model (car::vif() reports GVIF^(1/(2*df)) for
# terms with >1 df; here every term has 1 df so it's directly comparable
# to the VIF values above)
vif_interaction <- car::vif(interaction_model)
print(vif_interaction)

write_csv(interaction_coefs, "output/linear_model_interaction_coefficients.csv")

interaction_term <- interaction_coefs %>% filter(term == "ozone_c:poverty_c")
cat(sprintf(
  "\nOzone x poverty interaction: coefficient = %.3f, p = %.4f\n",
  interaction_term$estimate, interaction_term$p.value
))
cat(
  if (interaction_term$p.value < 0.05) {
    "Significant: poverty DOES modify ozone's association with COPD prevalence\nin this data -- report the direction and magnitude, don't just flag significance.\n"
  } else {
    "Not significant at alpha=0.05: this data does NOT show poverty modifying\nozone's association with COPD prevalence. Report this as a genuine null result\nfor the interaction (distinct from poverty's own main-effect confound, which\nis still real and already established) -- don't quietly drop the interaction\ntest just because it came back null.\n"
  }
)

# ---------------------------------------------------------
# 6. Residual diagnostics (quick sanity check / appendix figure)
# ---------------------------------------------------------
png("output/linear_model_diagnostics.png", width = 900, height = 900)
par(mfrow = c(2, 2))
plot(ols_model)
par(mfrow = c(1, 1))
dev.off()

# ---------------------------------------------------------
# 7. Save outputs for the Research Brief
# ---------------------------------------------------------
write_csv(tidy(ols_model, conf.int = TRUE), "output/linear_model_coefficients.csv")
write_csv(vif_flags, "output/linear_model_vif.csv")
write_csv(std_coefs, "output/linear_model_standardized_coefficients.csv")
saveRDS(ols_model, "output/linear_model.rds")

cat("\n--- Done ---\n")
cat("Adjusted R^2:", round(summary(ols_model)$adj.r.squared, 3), "\n")
cat("N:", nrow(model_df), "\n")
cat("Max VIF:", round(max(vif_values), 2),
    "(", vif_flags$predictor[which.max(vif_values)], ")\n")
