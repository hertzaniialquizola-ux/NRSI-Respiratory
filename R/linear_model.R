# OLS baseline: COPD prevalence ~ ozone + smoking + poverty + age.
#
# TODO:
# 1. Load data/processed/merged_county_data.csv (readr::read_csv)
# 2. Fit OLS: lm(copd_prevalence ~ ozone + smoking + poverty + age, data = df)
# 3. Run VIF diagnostics on all four predictors: car::vif(model)
# 4. Report coefficients, p-values, R^2 (summary(model)), and the VIF table.

library(readr)
library(car)

fit_linear_model <- function() {
  stop("Fit OLS + VIF once the merged dataset exists.")
}

fit_linear_model()
