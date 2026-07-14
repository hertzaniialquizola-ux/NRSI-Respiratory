# Run this once to install everything the analysis scripts need.

install.packages(c(
  "dplyr",       # data wrangling
  "readr",       # read/write CSVs
  "tidyr",       # reshaping
  "car",         # VIF diagnostics
  "randomForest",# ML model
  "caret",       # k-fold cross-validation
  "fastshap",    # SHAP values
  "pdp",         # partial dependence plots
  "ggplot2"      # visualization
))
