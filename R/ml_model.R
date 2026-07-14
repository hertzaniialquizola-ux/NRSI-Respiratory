# =========================================================
# R/ml_model.R
# NRSI Hackathon — Predictive ML model
# Random forest, same 4 predictors as linear_model.R:
#   copd ~ ozone + smoking + poverty + age
# 10-fold CV for R^2/RMSE (RF and linear, same folds, for a
# fair head-to-head), cross-fold variance in feature importance
# (not a single ranking), ozone partial dependence plot.
# (method plan step 3 + step 4: compare directly against OLS)
# =========================================================

library(tidyverse)
library(randomForest)
library(caret)    # createFolds()
library(pdp)      # partial()
library(janitor)

dir.create("output", showWarnings = FALSE)
set.seed(2026)  # fixed seed -> reproducible folds/RF across reruns

# ---------------------------------------------------------
# 1. Load data (column mapping confirmed against actual
#    build_dataset.R output — same as linear_model.R)
# ---------------------------------------------------------
df <- read_csv("data/county_ozone_copd_merged.csv") %>%
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

cat("N in model:", nrow(model_df), "\n")

# ---------------------------------------------------------
# 2. k-fold CV — same folds used for RF and linear, so the
#    step-4 "compare the two models directly" comparison is
#    apples-to-apples (out-of-sample R^2/RMSE for both, not
#    RF's CV number against the linear model's in-sample
#    adjusted R^2 from linear_model.R, which would be unfair).
# ---------------------------------------------------------
k <- 10
folds <- caret::createFolds(model_df$copd, k = k, list = TRUE)

compute_metrics <- function(actual, predicted) {
  resid <- actual - predicted
  tibble(
    rmse      = sqrt(mean(resid^2)),
    r_squared = 1 - sum(resid^2) / sum((actual - mean(actual))^2)
  )
}

cv_metrics_list    <- vector("list", k)
cv_importance_list <- vector("list", k)

for (i in seq_len(k)) {
  test_idx <- folds[[i]]
  train_df <- model_df[-test_idx, ]
  test_df  <- model_df[test_idx, ]
  
  # --- Random forest ---
  rf_fold   <- randomForest(
    copd ~ ozone + smoking + poverty + age,
    data = train_df, ntree = 500, importance = TRUE
  )
  rf_preds  <- predict(rf_fold, newdata = test_df)
  
  # --- Linear model, same fold split ---
  lm_fold   <- lm(copd ~ ozone + smoking + poverty + age, data = train_df)
  lm_preds  <- predict(lm_fold, newdata = test_df)
  
  cv_metrics_list[[i]] <- bind_rows(
    compute_metrics(test_df$copd, rf_preds) %>% mutate(model = "random_forest", fold = i),
    compute_metrics(test_df$copd, lm_preds) %>% mutate(model = "linear",        fold = i)
  )
  
  imp <- importance(rf_fold, type = 1)  # %IncMSE (permutation importance)
  cv_importance_list[[i]] <- tibble(
    fold = i,
    predictor = rownames(imp),
    inc_mse = imp[, "%IncMSE"]
  )
}

cv_metrics_df    <- bind_rows(cv_metrics_list)
cv_importance_df <- bind_rows(cv_importance_list)

# ---------------------------------------------------------
# 3. CV performance summary — mean +/- SD per model, not a
#    single number (10 folds x ~68 counties/fold is small
#    enough that fold-to-fold variance is worth reporting)
# ---------------------------------------------------------
cv_summary <- cv_metrics_df %>%
  group_by(model) %>%
  summarise(
    mean_r2   = mean(r_squared), sd_r2   = sd(r_squared),
    mean_rmse = mean(rmse),      sd_rmse = sd(rmse),
    .groups = "drop"
  )
print(cv_summary)

# ---------------------------------------------------------
# 4. Feature importance — mean + cross-fold SD, not a single
#    ranking (per method plan / peer feedback)
# ---------------------------------------------------------
importance_summary <- cv_importance_df %>%
  group_by(predictor) %>%
  summarise(
    mean_inc_mse = mean(inc_mse),
    sd_inc_mse   = sd(inc_mse),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_inc_mse))

print(importance_summary)

importance_plot <- ggplot(
  importance_summary,
  aes(x = reorder(predictor, mean_inc_mse), y = mean_inc_mse)
) +
  geom_col(fill = "steelblue") +
  geom_errorbar(
    aes(ymin = mean_inc_mse - sd_inc_mse, ymax = mean_inc_mse + sd_inc_mse),
    width = 0.2
  ) +
  coord_flip() +
  labs(
    title = "Random forest feature importance (10-fold CV)",
    subtitle = "Bars = mean %IncMSE across folds; error bars = cross-fold SD",
    x = NULL, y = "% increase in MSE when permuted"
  ) +
  theme_minimal()

ggsave("output/ml_feature_importance.png", importance_plot, width = 7, height = 4.5)

# ---------------------------------------------------------
# 5. Final model on full data — for the partial dependence
#    plot only. CV metrics/importance above (steps 3-4) are
#    what to report for performance; this model exists purely
#    to visualize the shape of the ozone relationship.
# ---------------------------------------------------------
rf_full <- randomForest(
  copd ~ ozone + smoking + poverty + age,
  data = model_df, ntree = 500, importance = TRUE
)

# ---------------------------------------------------------
# 6. Partial dependence plot — ozone specifically (shows
#    shape: linear vs threshold vs plateau, not just magnitude)
# ---------------------------------------------------------
pdp_ozone <- pdp::partial(rf_full, pred.var = "ozone", train = model_df)

pdp_plot <- autoplot(pdp_ozone) +
  labs(
    title = "Partial dependence: ozone -> predicted COPD prevalence",
    x = "Annual mean ozone", y = "Predicted COPD prevalence (%)"
  ) +
  theme_minimal()

ggsave("output/ml_ozone_pdp.png", pdp_plot, width = 7, height = 4.5)

# ---------------------------------------------------------
# 7. Optional: SHAP via fastshap (installed Day 1, unused
#    until now). NOT one of the "two visuals" in the method
#    plan — left commented as a possible swap-in for the
#    importance plot above, not an addition to it. Calls
#    fastshap::explain() explicitly per the dplyr/fastshap
#    masking note from setup.
# ---------------------------------------------------------
# pred_wrapper <- function(object, newdata) predict(object, newdata = newdata)
# shap_values <- fastshap::explain(
#   rf_full,
#   X = as.data.frame(model_df[, c("ozone", "smoking", "poverty", "age")]),
#   pred_wrapper = pred_wrapper,
#   nsim = 50
# )
# shap_summary <- as_tibble(shap_values) %>%
#   summarise(across(everything(), ~ mean(abs(.x)))) %>%
#   pivot_longer(everything(), names_to = "predictor", values_to = "mean_abs_shap") %>%
#   arrange(desc(mean_abs_shap))
# print(shap_summary)

# ---------------------------------------------------------
# 8. Save outputs
# ---------------------------------------------------------
write_csv(cv_metrics_df, "output/ml_cv_metrics_by_fold.csv")
write_csv(cv_summary, "output/ml_cv_summary.csv")
write_csv(importance_summary, "output/ml_feature_importance.csv")
saveRDS(rf_full, "output/rf_model.rds")

cat("\n--- Done ---\n")
print(cv_summary)
cat("Top predictor (RF importance):", importance_summary$predictor[1], "\n")
cat(
  "\nNote: compare cv_summary's two rows directly for step 4 of the method",
  "\nplan (agreement = robustness signal, disagreement = evidence of a",
  "\nnonlinear/threshold relationship). Don't compare this to the in-sample",
  "\nadjusted R^2 printed by linear_model.R (0.902) — that number is",
  "\nin-sample, not cross-validated, so it isn't a fair comparison to the",
  "\nout-of-sample numbers here.\n"
)