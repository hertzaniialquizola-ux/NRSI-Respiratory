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

## Method

1. **Build the dataset, report final N.** Merge EPA AirData ozone (annual mean, computed from daily data — not the regulatory design value), CDC PLACES (COPD + smoking prevalence), and Census ACS (poverty rate + median age) on FIPS code. EPA ozone monitors cover roughly 600–1,000 of ~3,100 counties, so the final N is reported up front, prominently, since it bounds how much weight the results can carry.
2. **Linear regression baseline + VIF check.** OLS predicting COPD prevalence from ozone + smoking + poverty + age. VIF is checked across all four predictors before interpreting any coefficient.
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
│   ├── raw/            # unmodified EPA / CDC / Census downloads
│   └── processed/      # merged, FIPS-joined analysis dataset
├── notebooks/           # exploratory analysis (.Rmd)
├── R/
│   ├── build_dataset.R      # merge + clean the four sources (ozone, PM2.5, PLACES, ACS)
│   ├── linear_model.R       # OLS + VIF (ozone, smoking, poverty, age)
│   ├── ml_model.R           # random forest + CV + importance variance
│   ├── pm25_sensitivity.R   # robustness check: does ozone survive with PM2.5 added?
│   └── figures.R            # feature importance + partial dependence plots
├── figures/              # output visuals
├── NRSI-Respiratory.Rproj  # open this in RStudio to set the working directory
├── install_packages.R      # run once to install all required R packages
├── research_brief.pdf    # final submission
└── README.md
```

*(Structure is a starting scaffold — update as the actual repo takes shape.)*

## Reproducing This Analysis

Open `NRSI-Respiratory.Rproj` in RStudio first — this sets the working directory automatically, so relative paths (`data/...`, `figures/...`) work without edits.

```r
# One-time setup
source("install_packages.R")

# Build the merged dataset
source("R/build_dataset.R")

# Run models
source("R/linear_model.R")
source("R/ml_model.R")
source("R/pm25_sensitivity.R")

# Generate figures
source("R/figures.R")
```

*(Fill in `requirements.txt` once the analysis environment is finalized.)*

## Limitations

- **Ecological inference limitation (leads the list).** This is a county-level aggregate analysis speaking to an individual-level disease mechanism. A county-level association does not establish that ozone exposure affects COPD risk at the individual level.
- EPA ozone monitors don't cover every U.S. county (~600–1,000 of ~3,100); final N will be smaller than the full county count, and monitor placement is not random — likely biased toward higher-population/higher-pollution areas.
- Annual mean ozone is used as the exposure metric rather than the EPA regulatory design value — standard for chronic-exposure research, but itself a simplification.
- PM2.5 is a sensitivity check only, not a full covariate — if ozone and PM2.5 are highly correlated at the county level, the check may not cleanly separate their effects.
- Single-year cross-section — no ability to establish temporal precedence.
- No independent validation dataset for this analysis.
- CDC PLACES COPD prevalence is *diagnosed* prevalence, not true prevalence — the poverty/healthcare-access confound applies directly here.
- With ~600–900 counties in the final sample, ML feature-importance rankings can be unstable — cross-fold variance is reported rather than a single ranking.

## AI Use Transparency

Claude (Anthropic) was used to assist with structuring this project's research brief and README, identifying peer-reviewed background literature, and clarifying statistical concepts (VIF, partial dependence) during method planning. All claims, citations, and results are independently verified by the author, who takes full responsibility for the final submission. Full statement in `research_brief.pdf`.

## Author

Solo entry — [Your name / contact info]

## License

*(Add a license if you want this reusable — MIT is a common default for research code.)*
