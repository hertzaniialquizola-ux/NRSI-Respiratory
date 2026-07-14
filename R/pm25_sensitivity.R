# Sensitivity check: does ozone's estimated contribution survive when PM2.5
# is added as a fifth predictor? Scoped as a robustness appendix, not a
# redesign of the primary model (see Method, step 5).
#
# TODO:
# 1. Load data/processed/merged_county_data.csv (must include a pm25 column).
# 2. Re-run OLS (and ideally the RF model) with PM2.5 added.
# 3. Compare ozone's coefficient/importance with vs. without PM2.5.
# 4. Report as a small table, not a full third visual.

library(readr)
library(car)

pm25_sensitivity_check <- function() {
  stop("Run after linear_model.R / ml_model.R.")
}

pm25_sensitivity_check()
