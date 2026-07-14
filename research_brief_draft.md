# Research Brief — Working Draft
**NSRI Summer Research Hackathon 2026 | Track: Health & Life Sciences**

> ✅ **Verified against the actual event slide deck (Beige_Illustrated_Research_Presentation.pdf):**
> - Rubric confirmed: 100 pts, 5 categories, exactly as in md_1. The public website's 120-pt version was stale/generic.
> - Track sponsor confirmed: **NexGen BioLab** sponsors Health and Life Sciences (not "The Insilico Lab" — that was the public site's listing for a different partner mapping).
> - Team rules: individual or teams of **2–3** (not 1–4 as the public site said). You've gone solo — "solo participants are not at a disadvantage" per the deck.
>
> ⚠️ **Still open:** I couldn't verify what NexGen BioLab actually is or what resources they offer. Public search mostly turns up a Tampa, FL supplement company by a similar name, which doesn't look like a natural research-data sponsor — possibly unrelated, possibly a small/newer org with no public footprint. Ask in a live session or check the Participant Guide's sponsor section before assuming any specific tool/dataset/API is available.

---

## Title
**Does County-Level Ozone Exposure Predict Adult COPD Prevalence? A Regression and Machine Learning Analysis Controlling for Smoking, Poverty, and Age**

## Track
Health & Life Sciences

## Author(s)
Solo entry — [Your name / contact info here]

---

## Abstract (241 words)

Chronic obstructive pulmonary disease (COPD) is driven predominantly by smoking but increasingly linked to ambient air pollution, particularly ozone — a secondary pollutant that inflames airway tissue on contact and is understudied for adult COPD. This project asks whether county-level ozone predicts adult COPD prevalence, and how much it contributes relative to smoking, poverty, and age. Merging EPA ozone, CDC PLACES COPD/smoking prevalence, and Census ACS poverty/age data yields N = 684 of roughly 3,100 U.S. counties (78.8% dropped, mostly for lack of an ozone monitor — only 754 counties nationwide have one). An OLS model finds ozone significantly predicts COPD prevalence (coefficient = 18.9, p < 0.001) net of the other covariates, though its standardized effect (0.08) is far smaller than smoking's (1.19). A 10-fold cross-validated random forest ranks predictors in the same order — smoking > age > poverty > ozone — and performs slightly worse out-of-sample than the linear model (CV R² 0.87 vs 0.90), suggesting a near-linear relationship rather than a threshold effect. Ozone's coefficient is essentially unchanged (27.0 to 26.3, both p < 0.0001) after adding PM2.5 on a smaller (N = 444) sensitivity subsample, so its effect does not depend on omitted PM2.5 confounding. Poverty's dual role — raising true COPD burden while potentially suppressing diagnosed prevalence through reduced healthcare access — is a key limitation, alongside the ecological-inference caveat that a county-level association does not establish individual-level risk. This is a single-year cross-section without independent validation, both explicit scope decisions.

---

## Research Question

> Does county-level ambient ozone exposure predict adult COPD prevalence in the United States, and how much does it contribute relative to smoking prevalence and poverty rate?

---

## Motivation

Ground-level ozone is a *secondary* pollutant — formed when NOx and VOCs react in sunlight, not emitted directly like PM2.5. As a reactive gas, it inflames airway tissue directly at the point of contact, rather than depositing deep in the lungs/bloodstream the way particulates do. In COPD, where airways are already chronically damaged, this oxidative irritation can trigger exacerbations and, with chronic exposure, is linked to disease progression.

This distinguishes the project from prior asthma-focused pollution work in two ways: COPD is progressive and largely irreversible, mostly adult-onset, and overwhelmingly smoking-driven — which is exactly why smoking prevalence has to be a covariate, not an afterthought. Without it, ozone could get credit or blame for what is actually a smoking effect. Poverty cuts in both directions: it may raise *true* COPD burden (higher smoking rates, worse occupational/indoor air exposure) while simultaneously lowering *diagnosed* prevalence through reduced healthcare access — a diagnostic-capacity confound that has to be addressed head-on in the discussion, not hedged around generically.

Age structure is a fourth necessary covariate, not a nicety. COPD prevalence is heavily age-graded — counties with older populations show higher prevalence largely independent of air quality. Since ozone monitor placement and population age skew are both non-random across counties, omitting age risks ozone's estimated contribution partly reflecting where older populations happen to live rather than ozone's own effect.

**A note on what this design can and can't show:** this is a county-level (ecological) analysis of an individual-level disease mechanism. A county-level association between ozone and COPD prevalence does not establish that ozone exposure affects COPD risk for any individual within that county — that inferential gap (the ecological fallacy) is treated as a first-order limitation throughout this brief, not a footnote.

**This is a real, if underexplored, question in the literature.** A few directly relevant anchors (verify full citations before final submission — see References):

- A SPIROMICS AIR cohort analysis (ScienceDirect, 2022) modeled ozone's respiratory effects alongside neighborhood poverty and found the two interact — COPD patients in poorer neighborhoods responded worse to the same ozone exposure than those in wealthier ones. Direct support for treating poverty as an effect-modifier, not just a control-and-forget covariate.
- A Bayesian hierarchical county-level mortality study (published in *AJRCCM*) modeled chronic lower respiratory disease deaths against ozone and PM2.5 while controlling for county-level poverty, smoking, obesity, and temperature — methodologically close to what this project attempts, and found a modest but statistically meaningful increase in respiratory mortality risk per unit increase in ozone.
- A 2025 *All of Us* Research Program analysis (medRxiv) looked at whether ozone levels below the current U.S. regulatory limit predict newly-diagnosed COPD, and noted the existing literature on ozone-COPD risk has been inconsistent across studies. This project's contribution is testing that open question at a national county level rather than individual-cohort level.
- A systematic review and meta-analysis (PMC, ~26 studies) linked short-term spikes in maximum 8-hour ozone concentration to a small but measurable rise in COPD hospitalizations — but that literature clusters on acute/short-term exposure rather than long-term prevalence, which is the gap this project targets.

---

## Method

1. **Build the dataset, report final N.** Merge EPA AirData (ozone), CDC PLACES (adult COPD + smoking prevalence), and Census ACS 5-Year Estimates (poverty rate + median age / %65+) on FIPS code for the most recent complete year. Use **annual mean ozone concentration** computed from EPA's daily monitor data, rather than the regulatory design value (4th-highest daily max, 3-year average) — annual mean is the standard exposure metric in chronic-exposure health literature; the design value is a NAAQS-compliance construct and would need explicit justification if used instead. State the final county count up front, prominently (abstract, not just methods) — EPA ozone monitors cover only 754 of 3,222 U.S. counties, and monitor placement is not random, so this bounds how much weight the results can carry. (Final analytic sample: N = 684 — see Evidence/Output.)
2. **Linear regression baseline + VIF check.** OLS predicting COPD prevalence from ozone + smoking + poverty + age. Run variance inflation factor diagnostics on all four predictors before interpreting anything — smoking, poverty, and age are all plausibly correlated with each other, and unchecked multicollinearity undermines any feature-importance claim.
3. **Predictive ML model.** Gradient boosting or random forest, same four predictors, k-fold cross-validation for R²/RMSE, feature importance (or SHAP) **reported with cross-fold variance, not just a single point-estimate ranking** — with ~600–900 rows a boosted tree's importance ranking can be unstable, and showing that variance is more credible than hiding it. Include a partial dependence plot for ozone specifically — showing *how* the relationship behaves (linear, threshold, plateau), not just how much it matters.
4. **Compare the two models directly.** Agreement = robustness signal. Disagreement = evidence of a nonlinear/threshold relationship worth discussing.
5. **PM2.5 sensitivity check.** Pull PM2.5 from the same EPA AirData source and re-run the OLS (and ideally the ML model) with PM2.5 added as a fifth predictor. Report whether ozone's coefficient/importance holds, shrinks, or flips — PM2.5 is the more established COPD risk factor and often co-varies with ozone, so this directly tests whether ozone's estimated effect is really its own or is partly absorbing PM2.5's. Framed as a robustness appendix, not a redesign of the primary model — if time is short, this is the first thing to cut back to "one paragraph noting it as a limitation" rather than dropped silently.
6. **Two primary visuals:** feature importance/SHAP summary (with variance shown) + ozone partial dependence plot. PM2.5 sensitivity result can be a small table rather than a third full visual.
7. **Discussion**, led by the poverty confounding-direction ambiguity and the ecological-inference caveat, then explicit named scope decisions rather than generic hedging.

### Data Sources

| Source | Provides | Link |
|---|---|---|
| EPA AirData | County-level daily ozone → annual mean (primary exposure variable) | epa.gov/outdoor-air-quality-data/download-daily-data |
| EPA AirData | County-level PM2.5 (sensitivity check only) | epa.gov/outdoor-air-quality-data/download-daily-data |
| CDC PLACES | County-level adult COPD prevalence + adult smoking prevalence | cdc.gov/places/index.html |
| Census ACS 5-Year Estimates | County-level poverty rate + median age / %65+ | data.census.gov |

Join key: county FIPS code.

### Deliberately cut (state explicitly in the brief, don't omit silently)
- **No multi-year panel** — single most-recent-year cross-section instead. A clean multi-year merge across three independently-sourced datasets risks a rushed, error-prone join in this timeframe. Name "extending to a panel design" as future work.
- **No independent validation dataset** — no fast equivalent available for a U.S. nationwide analysis in this timeframe.
- **PM2.5 scoped to a sensitivity check, not a full covariate** — a genuine multi-pollutant model would be stronger, but adding it properly (co-linearity diagnostics, joint interpretation) is more than a 5-day sprint supports well. Named explicitly as a scope decision.
- **No individual-level data** — this remains a county-level (ecological) analysis by design/timeframe; the ecological-inference limitation this creates is discussed explicitly rather than treated as solved by adding covariates.

---

## Evidence / Output

### Final sample

Merging EPA AirData ozone, CDC PLACES COPD/smoking prevalence, and Census ACS poverty/median age on FIPS code yielded **N = 684 counties**, out of 3,222 total U.S. counties/county-equivalents — **2,538 dropped (78.8%)**. The dropped-county breakdown (full detail in `data/dropped_counties.csv`):

| Reason dropped | Counties |
|---|---|
| No ozone monitor | 2,477 |
| COPD prevalence suppressed (PLACES, small population) | 61 |
| **Total dropped** | **2,538** |

EPA ozone monitor coverage is the dominant constraint by far: only **754 of 3,222 U.S. counties** have any ozone monitor (643 have PM2.5). Monitor placement is not random — it skews toward higher-population and higher-pollution areas — so N=684 should be read as a monitored-county sample, not a representative national sample. This is the single biggest limitation of the analysis and is treated as such throughout (see Limitations).

### Linear model (OLS baseline)

`copd ~ ozone + smoking + poverty + age`, N = 684, adjusted R² = 0.902 (in-sample):

| Predictor | Coefficient | Std. error | p-value |
|---|---|---|---|
| Ozone | 18.90 | 5.39 | 0.0005 |
| Smoking | 0.407 | 0.009 | < 0.001 |
| Poverty | 8.67 | 0.61 | < 0.001 |
| Age | 0.161 | 0.005 | < 0.001 |

**VIF check** (all predictors): ozone 1.01, smoking 1.62, poverty 1.68, age 1.18 — all well below the conventional concern threshold (5–10), so multicollinearity does not distort these coefficient estimates.

**Standardized coefficients** (needed to compare predictors measured in different units — ozone in ppm, smoking/poverty in %, age in years):

| Predictor | Standardized coefficient |
|---|---|
| Smoking | 1.19 |
| Age | 0.82 |
| Poverty | 0.40 |
| Ozone | 0.08 |

Ozone is a statistically significant predictor of COPD prevalence net of smoking, poverty, and age — but its standardized effect is roughly **1/15th the size of smoking's**. It matters, but it is not close to the dominant driver.

### Random forest + 10-fold cross-validation

Both models were cross-validated on the *same* 10 folds so the comparison is apples-to-apples out-of-sample, not the random forest's CV score against the linear model's in-sample R² above:

| Model | CV R² (mean ± SD) | CV RMSE (mean ± SD) |
|---|---|---|
| Linear | 0.899 ± 0.031 | 0.561 ± 0.071 |
| Random forest | 0.869 ± 0.031 | 0.645 ± 0.095 |

The linear model modestly **outperforms** the more flexible random forest out-of-sample. Since a random forest can capture nonlinearities a linear model cannot, its failure to beat OLS here is itself evidence that the true ozone–COPD relationship is close to linear, rather than a shortcoming of the ML approach.

**Feature importance** (random forest, %IncMSE, mean ± cross-fold SD across the 10 folds — Figure 1):

| Predictor | Mean %IncMSE | Cross-fold SD |
|---|---|---|
| Smoking | 63.7 | 1.2 |
| Age | 59.5 | 2.7 |
| Poverty | 33.0 | 1.0 |
| Ozone | 5.1 | 1.8 |

This is the **same rank order** as the standardized OLS coefficients above. Two structurally different models — one linear and one a flexible ensemble — agreeing on both which predictors matter and roughly how much is a robustness signal for the ranking, not just a coincidence of one method. Cross-fold SDs are also small relative to their means (largest: age at ±2.7 on a mean of 59.5), so this ranking is stable across folds rather than an artifact of any one training split.

**Ozone partial dependence** (Figure 2): predicted COPD prevalence rises from about 7.05% at the lowest observed county ozone levels to roughly 7.3–7.4% at the highest — essentially monotonically increasing, with local noise rather than a clean flat region, a sharp inflection, or a plateau. This shape is consistent with the CV comparison above: no strong nonlinear/threshold structure for the random forest to have exploited. The data-density rug on Figure 2 shows most counties cluster between ozone ≈ 0.038–0.05; the curve's upward spike above ≈0.055 falls in a comparatively data-sparse region and should be read cautiously rather than as a confirmed acceleration.

### PM2.5 sensitivity check

On the smaller subsample of counties with a monitored PM2.5 value (N = 444, vs. 684 in the main sample), two models were fit on the *identical* rows to isolate the effect of adding PM2.5 from the effect of the smaller sample:

| | Ozone coefficient | p-value |
|---|---|---|
| Without PM2.5 | 27.0 | < 0.0001 |
| With PM2.5 added | 26.3 | < 0.0001 |

Ozone's coefficient changes by about 2.6% and stays highly significant — its estimated effect on COPD prevalence is **not an artifact of omitted PM2.5 confounding**. VIF on the 5-variable model (ozone 1.02, smoking 1.85, poverty 1.89, age 1.41, PM2.5 1.18) confirms this holds without multicollinearity distorting it, despite ozone and PM2.5 both being pollutants.

One unresolved finding worth flagging rather than explaining away: PM2.5 itself comes out **negative** in this model (coefficient −0.080, p < 0.0001) once ozone/smoking/poverty/age are controlled — counterintuitive given PM2.5's established role as a respiratory risk factor. Since PM2.5 is scoped here as a sensitivity check rather than a fully interpreted covariate, this is named as an open question (see Limitations) rather than unpacked further.

### Figures

- **Figure 1** (`output/figure1_feature_importance.png`) — random forest variable importance, mean %IncMSE ± cross-fold SD, 10-fold CV.
- **Figure 2** (`output/figure2_ozone_pdp.png`) — partial dependence of predicted COPD prevalence on ozone, with a rug showing the actual ozone distribution.

---

## Limitations

- **Ecological inference limitation (leads the list, as planned).** This is a county-level aggregate analysis being used to speak to an individual-level disease mechanism — ozone inflaming individual airway tissue. A county-level association between ozone and COPD prevalence does not establish that ozone exposure affects COPD risk at the individual level (the ecological fallacy). Any causal-sounding language in the Conclusion needs to be checked against this before submission.
- **EPA ozone monitor coverage is the dominant limitation, with exact figures.** Only 754 of 3,222 U.S. counties have any ozone monitor (643 have PM2.5); the final analytic sample is N = 684 after also requiring non-suppressed COPD prevalence — 2,538 counties (78.8%) were dropped, 2,477 for no ozone monitor and 61 for suppressed COPD prevalence. Monitor placement is not random — it's likely biased toward higher-population/higher-pollution areas — so this is a coverage bias that bounds how far the results generalize, not just a sample-size note.
- **Annual mean ozone is used as the exposure metric** rather than the EPA design value; this is the standard choice in chronic-exposure literature but is itself a simplification of year-round, sub-daily exposure variation.
- **PM2.5 is only a sensitivity check, not a full covariate.** Ozone's coefficient held up well (27.0 → 26.3, both p < 0.0001) after adding PM2.5 on the smaller N = 444 monitored subsample, with low VIF throughout (max 1.89) — so ozone and PM2.5 do not appear to be highly collinear at the county level in this data, and the sensitivity check does cleanly separate their effects. However, **PM2.5 itself came out with a counterintuitive negative coefficient** (−0.080, p < 0.0001) in that same model, which is not explained by anything in this analysis and is flagged here as an open question rather than resolved by assertion.
- Single-year cross-section — no ability to establish temporal precedence or rule out reverse/confounded time trends. Named as a scope decision, not an oversight.
- No independent validation dataset for this analysis.
- CDC PLACES COPD prevalence is *diagnosed* prevalence, not true prevalence — the poverty/healthcare-access confound applies directly here and should be discussed, not just disclosed.
- **ML feature-importance ranking turned out to be stable, not unstable, across folds** — cross-fold SDs were small relative to their means (largest: age at ±2.7 on a mean of 59.5 %IncMSE), and the ranking (smoking > age > poverty > ozone) matched the standardized OLS coefficients exactly. Reporting cross-fold variance rather than a single point estimate was still the right call methodologically — it's simply that the variance turned out to be low, which is itself worth stating rather than assuming.
- Multicollinearity was checked and is not a concern: VIF stayed below 1.7 across all four main-model predictors (below 1.9 in the 5-variable PM2.5 sensitivity model), so smoking, poverty, age, and ozone are not so correlated with each other that their individual coefficients become uninterpretable.

---

## Conclusion / Impact

Ozone is a real, statistically robust predictor of county-level adult COPD prevalence — but a modest one. Its contribution, by standardized coefficient, is roughly one-fifteenth the size of smoking's, and that ranking is confirmed independently by a structurally different model (random forest feature importance) and survives a PM2.5-controlled sensitivity check on a separate subsample. For county-level public health resource allocation, this argues against treating ozone reduction as a lever comparable to smoking-cessation investment for closing COPD disparities — smoking and age structure remain, by a wide margin, the dominant explainers of which counties carry the heaviest COPD burden. It also argues against expecting a sharp "safe" ozone threshold: the near-identical performance of the linear and machine-learning models, and the roughly monotonic (not plateaued or threshold-shaped) partial dependence curve, suggest that whatever risk ozone poses accumulates gradually rather than switching on above some cutoff — at least at the resolution county-level data can resolve. The defensible takeaway is a ranked one, not a binary one: ozone is a real, non-negligible, and independently-confirmed contributor to county-level COPD prevalence, worth continued monitoring and worth a place in a multi-pollutant public health model — but not a substitute for smoking-reduction and demographic-targeting efforts as the primary levers.

---

## References
*Partial — add full citations in final format before submission. Real sources identified so far:*

1. SPIROMICS AIR — Ambient ozone effects on respiratory outcomes among smokers modified by neighborhood poverty. ScienceDirect, 2022. https://www.sciencedirect.com/science/article/abs/pii/S0048969722017879
2. Ozone, Fine Particulate Matter, and Chronic Lower Respiratory Disease Mortality in the United States. *American Journal of Respiratory and Critical Care Medicine*. https://www.atsjournals.org/doi/10.1164/rccm.201410-1852OC
3. Residential Ozone and Risk of Chronic Obstructive Pulmonary Disease in the United States: Demographic Differences in the All of Us Research Program. medRxiv, 2025. https://www.medrxiv.org/content/10.1101/2025.05.13.25327336v1.full
4. A Systematic Review and Meta-Analysis of Short-Term Ambient Ozone Exposure and COPD Hospitalizations. PMC. https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7143242/
5. Long-Term Exposure to Ozone and Cause-Specific Mortality Risk in the United States. PMC. https://pmc.ncbi.nlm.nih.gov/articles/PMC6794108/
6. Data sources: EPA AirData, CDC PLACES, Census ACS 5-Year Estimates (see Method section for links).

*Still needed: 2-3 more sources specifically on ozone atmospheric chemistry/formation (for the mechanism paragraph) and one on CDC PLACES diagnosed-vs-true-prevalence methodology, if available.*

---

## AI Use Transparency Statement

Per slide 16, the statement must cover: which AI tools were used, what each was used for, which parts received AI assistance, how claims/citations were verified, how outputs were checked for accuracy, and who takes responsibility.

**Final statement:**

We used Claude (Anthropic) to help draft this project's R analysis scripts (`build_dataset.R`, `linear_model.R`, `ml_model.R`, `pm25_sensitivity.R`, `figures.R`), debug environment, package, and data issues encountered while running them (e.g. a CRAN-archived package requiring an r-universe install, column-name mismatches against the actual merged dataset), structure this research brief around the hackathon's required framework, identify peer-reviewed background literature on ozone and COPD, and clarify statistical concepts (variance inflation factor, k-fold cross-validation, partial dependence plots, standardized coefficients) during method planning and interpretation. Claude was not used to generate results, fabricate citations, or produce analysis the author cannot personally explain. Every script was run locally by the author in RStudio, and every number quoted in this brief — sample sizes, coefficients, VIF values, cross-validated R²/RMSE, feature importance, and the PM2.5 sensitivity comparison — was checked against that console output before being included, not taken on faith from any AI-drafted summary. The author takes full responsibility for the final submission.

---

## Checklist (per event timeline)
- [x] Track: Health & Life Sciences
- [x] Solo/team status — **Solo**
- [x] Research question
- [x] Initial method plan
- [x] Dataset built, final N reported (684, from 3,222 counties)
- [x] Linear model + VIF check
- [x] ML model + cross-validation + feature importance + partial dependence
- [x] PM2.5 sensitivity check
- [x] Final figures (Figure 1, Figure 2)
- [x] Abstract, Evidence/Output, Limitations, Conclusion drafted with real numbers
- [ ] Author name/contact info (still a placeholder below — fill in before submitting)
- [ ] Full reference list finalized (2–3 more sources still flagged as needed — see References)
- [ ] Final proofread pass and page-count check (2–5 pages, excluding references/appendix)
