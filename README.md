# Ozone and Adult COPD: A County-Level Regression and ML Analysis

NSRI Summer Research Hackathon 2026 — Health & Life Sciences track

## Research Question

> Does county-level ambient ozone exposure predict adult COPD prevalence in the United States, and how much does it contribute relative to smoking prevalence and poverty rate?

## Why This Question

Ground-level ozone is a *secondary* pollutant — formed when NOx and VOCs react in sunlight, not emitted directly like PM2.5. As a reactive gas, it inflames airway tissue directly on contact, rather than depositing deep in the lungs the way particulates do. In COPD, where airways are already chronically damaged, that oxidative irritation can trigger exacerbations and, with chronic exposure, is linked to disease progression.

Smoking prevalence, poverty rate, and age structure are included as covariates, not afterthoughts:
- **Smoking** is the dominant driver of COPD. Without controlling for it, ozone could get credit or blame for what's actually a smoking effect.
- **Poverty** cuts both directions — it may raise *true* COPD burden (higher smoking rates, worse occupational/indoor air exposure) while simultaneously lowering *diagnosed* prevalence through reduced healthcare access. This diagnostic-capacity confound is treated as a central discussion point, not a footnote.
- **Age** is a necessary fourth covariate — COPD prevalence is heavily age-graded, and counties with older populations show higher prevalence largely independent of air quality. Omitting age risks ozone's estimated contribution partly reflecting where older populations happen to live.

**Scope note:** this is a county-level (ecological) analysis of an individual-level disease mechanism. A county-level association between ozone and COPD prevalence does not establish that ozone exposure affects COPD risk at the individual level — that gap is treated as a first-order limitation throughout, not a footnote.

## Data Sources

| Source | Provides | Link |
|---|---|---|
| EPA AirData | County-level daily ozone → annual mean (primary exposure variable) | [epa.gov/outdoor-air-quality-data](https://www.epa.gov/outdoor-air-quality-data/download-daily-data) |
| EPA AirData | County-level PM2.5 (sensitivity check only) | [epa.gov/outdoor-air-quality-data](https://www.epa.gov/outdoor-air-quality-data/download-daily-data) |
| CDC PLACES | County-level adult COPD prevalence + adult smoking prevalence | [cdc.gov/places](https://www.cdc.gov/places/index.html) |
| Census ACS 5-Year Estimates | County-level poverty rate + median age / %65+ | [data.census.gov](https://data.census.gov) |

Join key: **county FIPS code**. Most recent complete year, single cross-section (not a panel — see Limitations).

## Results

- **Final sample: N = 684 of 3,222 U.S. counties** (2,538 dropped — 2,477 for no ozone monitor, 61 for suppressed COPD prevalence). Only 754 U.S. counties have any ozone monitor at all.
- **OLS**: ozone significantly predicts COPD prevalence (coefficient = 18.9, p < 0.001) net of smoking/poverty/age; adjusted R² = 0.902 (in-sample, N = 684). VIF < 1.7 for all predictors — no multicollinearity concern.
- **Standardized coefficients**: smoking 1.19 > age 0.82 > poverty 0.40 > ozone 0.08 — ozone matters, but at roughly 1/15th the size of smoking's effect.
- **Random forest, 10-fold CV** (same folds as linear model, for a fair comparison): linear CV R² = 0.899 ± 0.031 vs. RF CV R² = 0.869 ± 0.031. The linear model modestly outperforms the more flexible RF, suggesting a near-linear relationship rather than a strong nonlinear/threshold effect.
- **Feature importance** (RF, mean %IncMSE ± cross-fold SD): smoking 63.7 ± 1.2, age 59.5 ± 2.7, poverty 33.0 ± 1.0, ozone 5.1 ± 1.8 — same rank order as the standardized OLS coefficients, a robustness signal across two different model classes.
- **Ozone partial dependence** (Figure 2): predicted COPD prevalence rises roughly monotonically from ~7.05% to ~7.4% across the observed ozone range, with no clear threshold or plateau.
- **PM2.5 sensitivity check** (N = 444 monitored subsample): ozone's coefficient barely moves (27.0 → 26.3, both p < 0.0001) after adding PM2.5 — its effect is not an artifact of omitted PM2.5 confounding. PM2.5 itself comes out negative (−0.080, p < 0.0001) in that model, which is unexplained and flagged as an open question rather than resolved.
- **Supplementary multi-outcome robustness check** (`R/robustness_outcomes.R`): the identical model re-fit on adult current-asthma prevalence (positive but non-significant, p = 0.142 — likely a model-fit mismatch, not a failed replication) and adult diabetes prevalence as a falsification check (no reliable ozone association, p = 0.135, unlike COPD's p = 0.0005) — the diabetes null result is the pattern a specific, real respiratory effect should produce, strengthening the case against generic county-level confounding.
- **Ozone × poverty interaction**: not significant (coefficient = 64.2, p = 0.571) — this data doesn't show poverty modifying ozone's effect the way SPIROMICS AIR's individual-level cohort did, most likely because this is a coarser county-average design; poverty remains a real confound, just not a detectable effect-modifier here.
- **PM2.5-monitored subsample characterization**: the N=444 PM2.5-monitored counties are younger, less-smoking, more impoverished, and lower-COPD than the 240 dropped for lacking a PM2.5 monitor — this compositional difference, not omitted confounding, explains why the baseline ozone coefficient is higher in the PM2.5 sensitivity check (27.0) than in the main N=684 model (18.9).

Full detail, tables, and interpretation: `research_brief_draft.md`.

## Method

1. **Build the dataset, report final N.** Merge EPA AirData ozone (annual mean, computed from daily data — not the regulatory design value), CDC PLACES (COPD + smoking prevalence), and Census ACS (poverty rate + median age) on FIPS code. EPA ozone monitors cover only 754 of 3,222 U.S. counties, so the final N (684) is reported up front, prominently, since it bounds how much weight the results can carry.
2. **Linear regression baseline + VIF check.** OLS predicting COPD prevalence from ozone + smoking + poverty + age. VIF is checked across all four predictors before interpreting any coefficient.
2b. **Ozone×poverty interaction** (`R/linear_model.R`), testing SPIROMICS AIR's effect-modification finding directly rather than only citing it.
3. **Predictive ML model.** Gradient boosting or random forest, same four predictors, k-fold cross-validation for R²/RMSE, feature importance reported **with cross-fold variance** (not a single point-estimate ranking — importance can be unstable at this sample size), and a partial dependence plot for ozone specifically.
4. **Compare the two models directly.** Agreement = robustness signal. Disagreement = evidence of a nonlinear/threshold relationship worth discussing.
5. **PM2.5 sensitivity check.** Re-run with PM2.5 added as a fifth predictor to test whether ozone's estimated contribution survives alongside the more established particulate-matter risk factor. Scoped as a robustness appendix, not a full second model.
6. **Two primary visuals:** feature importance/SHAP summary (with variance shown) + ozone partial dependence plot.
7. **Discussion**, led by the poverty confounding-direction ambiguity and the ecological-inference caveat, then explicit named scope decisions rather than generic hedging.

### Deliberately Out of Scope

- **No multi-year panel** — a clean multi-year merge across three independently-sourced datasets risks a rushed, error-prone join in this timeframe. Single most-recent-year cross-section instead; panel design is named as future work.
- **No independent validation dataset** — no fast equivalent available for a U.S. nationwide analysis at this timeframe.

## Repository Structure

```
.
├── data/
│   ├── raw/                              # unmodified EPA / CDC / Census downloads (gitignored)
│   ├── county_ozone_copd_merged.csv       # main analytic dataset, N = 684
│   └── dropped_counties.csv               # per-county reason for exclusion, N = 2,538
├── notebooks/                              # exploratory analysis (.Rmd)
├── R/
│   ├── build_dataset.R      # merge + clean the four sources (ozone, PM2.5, PLACES, ACS)
│   ├── linear_model.R       # OLS + VIF (ozone, smoking, poverty, age)
│   ├── ml_model.R           # random forest + CV + importance variance
│   ├── pm25_sensitivity.R   # robustness check: does ozone survive with PM2.5 added?
│   ├── figures.R            # final feature importance + partial dependence plots
│   └── robustness_outcomes.R # 2nd respiratory outcome (asthma) + falsification check (diabetes)
├── output/                # all model outputs: coefficient/VIF/CV tables, .rds models, figures
├── NRSI-Respiratory.Rproj  # open this in RStudio to set the working directory
├── install_packages.R      # run once to install all required R packages
├── research_brief_draft.md  # full research brief — export to PDF for final submission
└── README.md
```

## Reproducing This Analysis

Open `NRSI-Respiratory.Rproj` in RStudio first — this sets the working directory automatically, so relative paths (`data/...`, `output/...`) work without edits.

```r
# One-time setup
source("install_packages.R")

# Build the merged dataset
source("R/build_dataset.R")

# Run models
source("R/linear_model.R")
source("R/ml_model.R")
source("R/pm25_sensitivity.R")
source("R/robustness_outcomes.R")

# Generate figures
source("R/figures.R")
```

*(Fill in `requirements.txt` once the analysis environment is finalized.)*

## Limitations

- **Ecological inference limitation (leads the list).** This is a county-level aggregate analysis speaking to an individual-level disease mechanism. A county-level association does not establish that ozone exposure affects COPD risk at the individual level.
- **EPA ozone monitor coverage is the dominant limitation.** Only 754 of 3,222 U.S. counties have any ozone monitor (643 have PM2.5); final N = 684 (78.8% of counties dropped — 2,477 for no ozone monitor, 61 for suppressed COPD prevalence). Monitor placement is not random — likely biased toward higher-population/higher-pollution areas.
- Annual mean ozone is used as the exposure metric rather than the EPA regulatory design value — standard for chronic-exposure research, but itself a simplification.
- **PM2.5 is a sensitivity check only, not a full covariate.** Ozone's coefficient held up well after adding PM2.5 (27.0 → 26.3, both p < 0.0001, on a matched N = 444 subsample) with low VIF throughout — but PM2.5 itself came out with an unexplained negative coefficient, flagged as an open question.
- Single-year cross-section — no ability to establish temporal precedence.
- No independent validation dataset for this analysis.
- **CDC PLACES COPD prevalence is *diagnosed*, not true, prevalence** — its underlying measure is a BRFSS self-report question ("ever told by a doctor..."), and self-reported diagnosis is known to substantially undercount spirometry-confirmed disease: in the same NHANES sample, only 6.0% of adults 40-79 self-reported a COPD diagnosis vs. 14.0-15.4% with spirometry-confirmed airflow obstruction (Tilert et al., 2013, *Respiratory Research*, doi:10.1186/1465-9921-14-103). That this gap plausibly widens with reduced healthcare access is this project's own inference, not a claim that paper makes directly — see `research_brief_draft.md` Limitations for the full framing.
- ML feature-importance rankings turned out to be **stable** across folds (cross-fold SDs small relative to their means) and matched the standardized OLS ranking exactly — reporting cross-fold variance was still the right methodological call, it just turned out low.
- The ozone×poverty interaction came back null (p = 0.571), unlike SPIROMICS AIR's individual-level finding — likely a resolution issue (county-average vs. individual/neighborhood-level design), not a contradiction of that literature.

## AI Use Transparency

Claude (Anthropic) was used to help draft this project's R analysis scripts, debug environment/data issues encountered while running them, structure this research brief and README, identify peer-reviewed background literature, and clarify statistical concepts (VIF, cross-validation, partial dependence) during method planning. All claims, citations, and results were independently run and verified by the author in RStudio before being included here. The author takes full responsibility for the final submission. Full statement in `research_brief_draft.md`.

## Author

Solo entry — Hertzan D. Alquizola II, hertzan.alquizola@gmail.com

## License

*(Add a license if you want this reusable — MIT is a common default for research code.)*
