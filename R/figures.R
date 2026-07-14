# =========================================================
# R/figures.R
# NRSI Hackathon — final figures for the Research Brief
#
# Per the method plan: "Two visuals only" — feature importance
# + ozone partial dependence plot. This script does NOT add a
# third visual; it takes what ml_model.R already produced and
# finalizes it (consistent styling, captions with the actual
# N/CV numbers, a rug plot on the PDP showing where the ozone
# data has support) for inclusion in the brief.
#
# Run linear_model.R, ml_model.R, and pm25_sensitivity.R first —
# this script reads their saved outputs rather than re-fitting.
# =========================================================

library(tidyverse)
library(randomForest)
library(pdp)
library(janitor)

dir.create("output", showWarnings = FALSE)

# ---------------------------------------------------------
# 1. Reload what's needed: the fitted RF model, the CV summary
#    (for caption numbers), and the main analytic data (same
#    pipeline as linear_model.R / ml_model.R)
# ---------------------------------------------------------
rf_full    <- readRDS("output/rf_model.rds")
cv_summary <- read_csv("output/ml_cv_summary.csv", show_col_types = FALSE)
importance_summary <- read_csv("output/ml_feature_importance.csv", show_col_types = FALSE)

df <- read_csv("data/county_ozone_copd_merged.csv", show_col_types = FALSE) %>%
  clean_names()

model_df <- df %>%
  select(
    copd    = copd_crude_prev,
    ozone   = ozone_mean,
    smoking = csmoking_crude_prev,
    poverty = poverty_rate,
    age     = median_age
  ) %>%
  drop_na()

rf_r2    <- cv_summary %>% filter(model == "random_forest") %>% pull(mean_r2)
rf_r2_sd <- cv_summary %>% filter(model == "random_forest") %>% pull(sd_r2)

# ---------------------------------------------------------
# 2. Figure 1 — feature importance (mean +/- cross-fold SD)
# ---------------------------------------------------------
fig1 <- ggplot(
  importance_summary,
  aes(x = reorder(predictor, mean_inc_mse), y = mean_inc_mse)
) +
  geom_col(fill = "#2c5f8a", width = 0.65) +
  geom_errorbar(
    aes(ymin = pmax(mean_inc_mse - sd_inc_mse, 0), ymax = mean_inc_mse + sd_inc_mse),
    width = 0.15, color = "#333333"
  ) +
  coord_flip() +
  labs(
    title = "Figure 1. Random forest variable importance",
    subtitle = sprintf(
      "10-fold CV, N = %d counties. Bars = mean %%IncMSE across folds; error bars = cross-fold SD.\nCV R^2 = %.3f (SD %.3f).",
      nrow(model_df), rf_r2, rf_r2_sd
    ),
    x = NULL, y = "% increase in MSE when permuted"
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.subtitle = element_text(size = 9, color = "grey30"))

ggsave("output/figure1_feature_importance.png", fig1, width = 7.5, height = 4.5, dpi = 300)

# ---------------------------------------------------------
# 3. Figure 2 — ozone partial dependence, with a rug showing
#    the actual ozone distribution. PDPs can be misleading in
#    regions with thin data support (sparse tails); showing the
#    rug is a one-line safeguard against over-reading the curve
#    shape where there isn't much data behind it.
# ---------------------------------------------------------
pdp_ozone <- pdp::partial(rf_full, pred.var = "ozone", train = model_df)

fig2 <- ggplot(pdp_ozone, aes(x = ozone, y = yhat)) +
  geom_line(color = "#2c5f8a", linewidth = 1) +
  geom_rug(
    data = model_df, aes(x = ozone),
    sides = "b", alpha = 0.25, inherit.aes = FALSE
  ) +
  labs(
    title = "Figure 2. Partial dependence of predicted COPD prevalence on ozone",
    subtitle = sprintf(
      "N = %d counties. Rug (bottom) shows the actual distribution of county-level ozone —\ninterpret the curve cautiously wherever the rug is sparse.",
      nrow(model_df)
    ),
    x = "Annual mean ozone", y = "Predicted adult COPD prevalence (%)"
  ) +
  theme_minimal(base_size = 12) +
  theme(plot.subtitle = element_text(size = 9, color = "grey30"))

ggsave("output/figure2_ozone_pdp.png", fig2, width = 7.5, height = 4.5, dpi = 300)

cat("\n--- Done ---\n")
cat("Saved: output/figure1_feature_importance.png\n")
cat("Saved: output/figure2_ozone_pdp.png\n")