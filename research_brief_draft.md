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

## Abstract (247 words)

**Background.** COPD is driven predominantly by smoking but increasingly linked to ambient air pollution, particularly ozone — a secondary pollutant that inflames airway tissue on contact and is understudied for adult COPD. **Objective.** This study tested whether county-level ozone predicts adult COPD prevalence, and how much it contributes relative to smoking, poverty, and age. **Methods.** We merged EPA ozone, CDC PLACES COPD/smoking prevalence, and Census ACS poverty/age data (N = 684 of 3,222 counties; 78.8% dropped, mostly for lack of an ozone monitor — only 754 counties nationwide have one), fit an OLS baseline with a VIF check, benchmarked it against a 10-fold cross-validated random forest on identical folds, and tested whether ozone's effect survived adding PM2.5 on a smaller (N = 444) subsample. **Results.** Ozone significantly predicted COPD prevalence (coefficient = 18.9, p < 0.001) net of the other covariates, though its standardized effect (0.08) was far smaller than smoking's (1.19). The random forest ranked predictors in the same order — smoking > age > poverty > ozone — and performed slightly worse out-of-sample than the linear model (CV R² 0.87 vs 0.90), consistent with a near-linear relationship. Ozone's coefficient was essentially unchanged (27.0 to 26.3, both p < 0.0001) after adding PM2.5. **Conclusions.** Ozone is a real but modest, confirmed predictor of county-level COPD burden, secondary to smoking and demographic structure; poverty's dual confounding role and the ecological-inference limitation — county-level association does not establish individual-level risk — bound how these findings should be read.

---

## Research Question

> Does county-level ambient ozone exposure predict adult COPD prevalence in the United States, and how much does it contribute relative to smoking prevalence and poverty rate?

---

## Motivation

Ground-level ozone is a *secondary* pollutant — formed when NOx and VOCs react in sunlight, not emitted directly like PM2.5. As a reactive gas, it inflames airway tissue directly at the point of contact, rather than depositing deep in the lungs/bloodstream the way particulates do. In COPD, where airways are already chronically damaged, this oxidative irritation can trigger exacerbations and, with chronic exposure, is linked to disease progression.

This distinguishes the project from prior asthma-focused pollution work in two ways: COPD is progressive and largely irreversible, mostly adult-onset, and overwhelmingly smoking-driven — which is exactly why smoking prevalence gets treated with the same seriousness as the exposure variable itself. Without it, ozone could get credit or blame for what is actually a smoking effect. Poverty cuts in both directions: it may raise *true* COPD burden (higher smoking rates, worse occupational/indoor air exposure) while simultaneously lowering *diagnosed* prevalence through reduced healthcare access — a diagnostic-capacity confound addressed head-on in the Discussion rather than waved off with a generic caveat.

Age structure is a fourth necessary covariate: COPD prevalence is heavily age-graded, with counties that have older populations showing higher prevalence largely independent of air quality, and omitting age risks ozone's estimated contribution partly reflecting where older populations happen to live.

**A note on what this design can and can't show:** this is a county-level (ecological) analysis of an individual-level disease mechanism. A county-level association between ozone and COPD prevalence does not establish that ozone exposure affects COPD risk for any individual within that county — that inferential gap (the ecological fallacy) shapes how every result below should be read, and is addressed as such throughout, rather than appended as a closing caveat.

**This is a real, if underexplored, question in the literature.** A few directly relevant anchors, each checked directly against its source (title, DOI, and findings) before this final draft:

- **SPIROMICS AIR** (2022): ozone and neighborhood poverty interact — poorer-neighborhood COPD patients respond worse to the same ozone exposure — so an ozone×poverty interaction is fit directly here (Method, Evidence/Output), not just cited as motivation.
- A **Bayesian hierarchical county-level mortality study** (*AJRCCM*) found a modest, significant ozone–CLRD mortality association controlling for county poverty, smoking, obesity, and temperature — methodologically close to this project.
- The 2025 ***All of Us*** analysis (medRxiv, ~849,000 participants) found a positive, non-monotonic ozone–incident-COPD relationship, concentrated in the highest exposure quartile; this project tests the same question at the county rather than individual level.
- A **systematic review** (~26 studies) linked short-term ozone spikes to a small rise in COPD hospitalizations, but focused on acute exposure rather than the long-term prevalence question this project targets.

---

## Method

1. **Build the dataset, report final N.** Merge EPA AirData (ozone), CDC PLACES (COPD + smoking prevalence), and Census ACS (poverty + median age) on FIPS code for the most recent complete year, using **annual mean ozone** (the standard chronic-exposure metric) rather than the regulatory design value. EPA ozone monitors cover only 754 of 3,222 U.S. counties, and placement is not random, so this bounds how much weight the results can carry (final N = 684 — see Evidence/Output).
2. **Linear regression baseline + VIF check.** OLS predicting COPD prevalence from ozone + smoking + poverty + age, with VIF run on all four predictors before interpreting anything.
3. **Ozone×poverty interaction.** SPIROMICS AIR (above) argues poverty modifies ozone's effect, not just confounds it — a mean-centered `ozone×poverty` term is fit and interpreted regardless of whether it reaches significance.
4. **Predictive ML model, compared directly against the linear model.** Random forest, same four predictors, 10-fold CV (same folds as the linear model, for a fair comparison) for R²/RMSE, feature importance with cross-fold variance rather than a single ranking, and a partial dependence plot for ozone. Agreement between the two models is a robustness signal; disagreement would flag a nonlinear/threshold relationship worth discussing.
5. **PM2.5 sensitivity check.** Re-run the OLS with PM2.5 added as a fifth predictor on the PM2.5-monitored subsample, framed as a robustness appendix rather than a redesign of the primary model.
6. **Two primary visuals** (feature importance + ozone partial dependence); all coefficient/VIF/sensitivity tables live in the Appendix.
7. **Supplementary multi-outcome check.** The identical specification re-fit on adult current-asthma (a second respiratory outcome) and diabetes prevalence (a falsification check — no known ozone mechanism, so a null result there supports specificity rather than generic confounding).
8. **STROBE reporting guidelines**, R (tidyverse, car, randomForest, caret, pdp, janitor, broom), all scripts version-controlled for full reproducibility.

### Data Sources

| Source | Provides | Link |
|---|---|---|
| EPA AirData | County-level daily ozone and PM2.5 → annual means (ozone is the primary exposure variable; PM2.5 is sensitivity-only) | epa.gov/outdoor-air-quality-data/download-daily-data |
| CDC PLACES | County-level adult COPD, smoking, current-asthma, and diabetes prevalence | cdc.gov/places/index.html |
| Census ACS 5-Year Estimates | County-level poverty rate + median age | data.census.gov |

Join key: county FIPS code.

### Deliberately cut (state explicitly, don't omit silently)
- **No multi-year panel** — single most-recent-year cross-section instead, to avoid a rushed three-dataset multi-year join; named as future work.
- **No independent validation dataset** — no fast equivalent available for a U.S. nationwide analysis in this timeframe.
- **PM2.5 scoped to a sensitivity check, not a full covariate** — a multi-pollutant model would be stronger but is more than a 5-day sprint supports well.
- **No individual-level data** — a county-level (ecological) design by timeframe; the resulting ecological-inference limitation is discussed explicitly, not treated as solved by adding covariates.

---

## Ethical Considerations

This study used only publicly available, de-identified, aggregate secondary data: EPA ambient air monitoring records, CDC PLACES modeled population-level prevalence estimates, and Census ACS estimates. No individual human subjects were contacted, surveyed, or identifiable in any dataset used, so no institutional review board approval was required.

---

## Evidence / Output
*Full tables for every result below are in the Appendix, referenced inline, so this section stays prose-first.*

### Final sample

Merging EPA AirData ozone, CDC PLACES COPD/smoking prevalence, and Census ACS poverty/median age on FIPS code yielded **N = 684 counties** of 3,222 total — **2,538 dropped (78.8%)**: 2,477 for no ozone monitor, 61 for suppressed COPD prevalence (Appendix Table 1; full detail in `data/dropped_counties.csv`). EPA ozone monitor coverage is the dominant constraint by far: only **754 of 3,222 U.S. counties** have any ozone monitor (643 have PM2.5), and placement is not random — it skews toward higher-population, higher-pollution areas — so N=684 is a sample of monitored counties, not a representative national one. This is the single biggest limitation of the analysis and is treated as such throughout (see Limitations).

### Linear model (OLS baseline)

`copd ~ ozone + smoking + poverty + age`, N = 684, adjusted R² = 0.902 (in-sample). Ozone significantly predicts COPD prevalence (coefficient = 18.90, SE = 5.39, p = 0.0005) net of the other covariates (Appendix Table 2). VIF stays well below the conventional concern threshold for every predictor (max 1.68), so multicollinearity does not distort these estimates (Appendix Table 3). Standardized coefficients — needed to compare predictors measured in different units (ozone in ppm, smoking/poverty in %, age in years) — rank smoking (1.19) > age (0.82) > poverty (0.40) > ozone (0.08) (Appendix Table 4): ozone matters, but at roughly **1/15th the size of smoking's** effect.

**Ozone × poverty interaction:** *[pending — R re-run in progress; SPIROMICS AIR's cited finding that poverty modifies ozone's effect is tested directly here with a mean-centered interaction term, interpreted either way it lands. See Appendix Table 9 once available.]*

### Random forest + 10-fold cross-validation

Both models were cross-validated on the *same* 10 folds for an apples-to-apples out-of-sample comparison (Appendix Table 5). The linear model (CV R² 0.899 ± 0.031) modestly outperforms the random forest (0.869 ± 0.031) — suggestive of, but not decisive proof of, a near-linear relationship, since the forest was not hyperparameter-tuned (see Limitations).

Feature importance (Appendix Table 6; Figure 1) matches the standardized OLS ranking exactly, with cross-fold SDs small relative to their means — two structurally different models agreeing on both which predictors matter and how much is a robustness signal neither model could provide alone.

Ozone's partial dependence (Figure 2) rises from about 7.05% at the lowest observed county ozone levels to roughly 7.3–7.4% at the highest — essentially monotonic, with local noise rather than a clean flat region, sharp inflection, or plateau, consistent with the CV comparison above. The data-density rug shows most counties cluster between ozone ≈ 0.038–0.05; the curve's upward spike above ≈0.055 sits in a comparatively data-sparse region and should be read cautiously rather than as a confirmed acceleration.

### PM2.5 sensitivity check

On the N = 444 PM2.5-monitored subsample, two models were fit on the *identical* rows (Appendix Table 7) to isolate the effect of adding PM2.5 from the effect of the smaller sample: ozone's coefficient moves only from 27.0 to 26.3 (both p < 0.0001) once PM2.5 is added — its estimated effect holds up whether or not PM2.5 is in the model. VIF stays low throughout (max 1.89 with PM2.5 added), despite ozone and PM2.5 both being pollutants.

*[Pending — R re-run in progress: a descriptive comparison of this N=444 subsample against the N=240 counties dropped from it (ozone, smoking, poverty, age, COPD means), to characterize why the baseline (no-PM2.5) ozone coefficient here is higher than the N=684 model's 18.90 — see Appendix Table 10.]*

One unresolved finding flagged rather than explained away: PM2.5 itself comes out **negative** (coefficient −0.080, p < 0.0001) once ozone/smoking/poverty/age are controlled — counterintuitive given its established role as a respiratory risk factor. Since PM2.5 is scoped here as a sensitivity check, not a fully interpreted covariate, this is named as an open question (see Limitations) rather than unpacked further.

### Supplementary: multi-outcome robustness check

The identical specification was re-fit on two additional CDC PLACES outcomes, same N = 684 counties (Appendix Table 8), to test whether the ozone–COPD finding is specific to COPD or reflects generic county-level confounding. Only COPD's ozone effect is statistically distinguishable from zero. **Asthma** is positive (same direction as COPD) but non-significant (p = 0.142) — most likely a model-fit mismatch, not a failed confirmation: this covariate set is smoking-heavy and well-suited to COPD, while adult asthma is more allergic/immune-driven (see Motivation), and the model's adjusted R² collapses from 0.902 to 0.225 for asthma. **Diabetes**, the falsification check, is the more informative result: it shares COPD's confounders (poverty, age) but has no plausible ozone mechanism, and shows **no reliable ozone association at all** (p = 0.135, 95% CI spans zero) — exactly the null pattern a real, respiratory-specific effect should produce, since generic "unhealthy county" confounding would have shown up here too.

This check is appendix/robustness material, kept separate from the brief's two primary visuals per the method plan's scope. Full detail: `output/robustness_outcomes_comparison.csv`; supplementary figure: `output/figure_supplementary_robustness_outcomes.png`.

### Figures

- **Figure 1** (`output/figure1_feature_importance.png`) — random forest variable importance, mean %IncMSE ± cross-fold SD, 10-fold CV.
- **Figure 2** (`output/figure2_ozone_pdp.png`) — partial dependence of predicted COPD prevalence on ozone, with a rug showing the actual ozone distribution.

---

## Limitations

- **Ecological inference limitation (leads the list, as planned).** This is a county-level aggregate analysis being used to speak to an individual-level disease mechanism — ozone inflaming individual airway tissue. A county-level association between ozone and COPD prevalence does not establish that ozone exposure affects COPD risk at the individual level (the ecological fallacy). Any causal-sounding language in the Conclusion needs to be checked against this before submission.
- **EPA ozone monitor coverage is the dominant limitation, with exact figures.** Only 754 of 3,222 U.S. counties have any ozone monitor (643 have PM2.5); the final analytic sample is N = 684 after also requiring non-suppressed COPD prevalence — 2,538 counties (78.8%) were dropped, 2,477 for no ozone monitor and 61 for suppressed COPD prevalence. Monitor placement is not random — it's likely biased toward higher-population/higher-pollution areas — making this a coverage bias that bounds how far the results generalize, well beyond a simple sample-size caveat.
- **Annual mean ozone**, not the EPA design value, is a simplification of year-round exposure variation; **single-year cross-section** and **no independent validation dataset** are both deliberate scope decisions detailed in Method's "Deliberately cut," not repeated here.
- **PM2.5 is only a sensitivity check, not a full covariate.** Ozone's coefficient held up well (27.0 → 26.3, both p < 0.0001) with PM2.5 added on the N = 444 monitored subsample, VIF low throughout (max 1.89) — but **PM2.5 itself came out with a counterintuitive negative coefficient** (−0.080, p < 0.0001), unexplained here and flagged as an open question.
- CDC PLACES COPD prevalence is *diagnosed*, not true, prevalence — the poverty/healthcare-access confound applies directly here and is unpacked above (Motivation, Evidence/Output).
- **The random forest was not hyperparameter-tuned** (default `mtry`, `ntree` = 500) — its underperformance vs. OLS is suggestive of a near-linear relationship, not decisive proof; a tuned-forest comparison is the more rigorous version of this check that time did not allow.
- **ML feature-importance ranking turned out to be stable across folds** (cross-fold SDs small relative to their means; largest: age at ±2.7 on 59.5), matching the standardized OLS ranking exactly — reporting cross-fold variance was still the right call, the variance simply turned out to be low.
- Multicollinearity is not a concern (VIF < 1.7, all predictors). **The multi-outcome check's asthma result is inconclusive, not a clean replication** — adjusted R² collapses from 0.902 (COPD) to 0.225 (asthma), since this smoking-heavy covariate set fits COPD far better than asthma's more allergic/immune-driven mechanism.

---

## Conclusion / Impact

Ozone is a real but modest predictor of county-level adult COPD prevalence — about one-fifteenth the size of smoking's effect, confirmed by a random forest, a PM2.5 sensitivity check, and a diabetes falsification check. This argues against ozone reduction as a lever comparable to smoking-cessation investment, and against a sharp "safe" threshold given the roughly monotonic partial dependence curve. The takeaway is ranked, not binary: a real, confirmed contributor to a multi-pollutant model, secondary to smoking-reduction and demographic-targeting efforts.

---

## References
*All five sources below were checked directly against the original publication (title, DOI/link, and reported findings) before this final draft — none are AI-fabricated or taken on faith from a summary.*

1. Ambient ozone effects on respiratory outcomes among smokers modified by neighborhood poverty: an analysis of SPIROMICS AIR. *Science of the Total Environment*, 2022. https://www.sciencedirect.com/science/article/abs/pii/S0048969722017879
2. Hao, Y., et al. Ozone, Fine Particulate Matter, and Chronic Lower Respiratory Disease Mortality in the United States. *American Journal of Respiratory and Critical Care Medicine*, 2015. https://www.atsjournals.org/doi/10.1164/rccm.201410-1852OC
3. Residential Ozone and Risk of Chronic Obstructive Pulmonary Disease in the United States: Demographic Differences in the All of Us Research Program. medRxiv, 2025. https://www.medrxiv.org/content/10.1101/2025.05.13.25327336v1.full
4. A Systematic Review and Meta-Analysis of Short-Term Ambient Ozone Exposure and COPD Hospitalizations. *International Journal of Environmental Research and Public Health*, 2020. https://pmc.ncbi.nlm.nih.gov/articles/PMC7143242/
5. Lim, C. C., et al. Long-Term Exposure to Ozone and Cause-Specific Mortality Risk in the United States. *American Journal of Respiratory and Critical Care Medicine*, 200(8):1022–31, 2019. https://pmc.ncbi.nlm.nih.gov/articles/PMC6794108/
6. Data sources: EPA AirData, CDC PLACES, Census ACS 5-Year Estimates (see Method section for links).

*Still needed: 2-3 more sources specifically on ozone atmospheric chemistry/formation (for the mechanism paragraph) and one on CDC PLACES diagnosed-vs-true-prevalence methodology, if available.*

---

## AI Use Transparency Statement

Per slide 16, the statement must cover: which AI tools were used, what each was used for, which parts received AI assistance, how claims/citations were verified, how outputs were checked for accuracy, and who takes responsibility.

**Final statement:**

We used Claude (Anthropic) to help draft this project's R analysis scripts (`build_dataset.R`, `linear_model.R`, `ml_model.R`, `pm25_sensitivity.R`, `figures.R`, `robustness_outcomes.R`), debug environment, package, and data issues encountered while running them (e.g. a CRAN-archived package requiring an r-universe install, column-name mismatches against the actual merged dataset), structure this research brief around the hackathon's required framework, identify and verify peer-reviewed background literature on ozone and COPD, and clarify statistical concepts (variance inflation factor, k-fold cross-validation, partial dependence plots, standardized coefficients, interaction terms) during method planning and interpretation. Claude was not used to generate results, fabricate citations, or produce analysis the author cannot personally explain. Every script was run locally by the author in RStudio, and every number quoted in this brief was checked against that console output before being included here, independent of whatever any AI-drafted summary said. The author takes full responsibility for the final submission.

---

## Appendix: Full Results Tables

**Table 1. Dropped-county breakdown** (N = 2,538 of 3,222 total)

| Reason dropped | Counties |
|---|---|
| No ozone monitor | 2,477 |
| COPD prevalence suppressed (PLACES, small population) | 61 |
| **Total dropped** | **2,538** |

**Table 2. OLS coefficients** (`copd ~ ozone + smoking + poverty + age`, N = 684, adjusted R² = 0.902)

| Predictor | Coefficient | Std. error | p-value |
|---|---|---|---|
| Ozone | 18.90 | 5.39 | 0.0005 |
| Smoking | 0.407 | 0.009 | < 0.001 |
| Poverty | 8.67 | 0.61 | < 0.001 |
| Age | 0.161 | 0.005 | < 0.001 |

**Table 3. VIF, primary model** — ozone 1.01, smoking 1.62, poverty 1.68, age 1.18 (all well below the conventional 5–10 concern threshold).

**Table 4. Standardized coefficients**

| Predictor | Standardized coefficient |
|---|---|
| Smoking | 1.19 |
| Age | 0.82 |
| Poverty | 0.40 |
| Ozone | 0.08 |

**Table 5. Random forest vs. linear, 10-fold CV (same folds)**

| Model | CV R² (mean ± SD) | CV RMSE (mean ± SD) |
|---|---|---|
| Linear | 0.899 ± 0.031 | 0.561 ± 0.071 |
| Random forest | 0.869 ± 0.031 | 0.645 ± 0.095 |

**Table 6. Random forest feature importance** (%IncMSE, mean ± cross-fold SD, 10 folds)

| Predictor | Mean %IncMSE | Cross-fold SD |
|---|---|---|
| Smoking | 63.7 | 1.2 |
| Age | 59.5 | 2.7 |
| Poverty | 33.0 | 1.0 |
| Ozone | 5.1 | 1.8 |

**Table 7. PM2.5 sensitivity check** (N = 444, identical rows for both models)

| | Ozone coefficient | p-value |
|---|---|---|
| Without PM2.5 | 27.0 | < 0.0001 |
| With PM2.5 added | 26.3 | < 0.0001 |

VIF (5-variable model): ozone 1.02, smoking 1.85, poverty 1.89, age 1.41, PM2.5 1.18.

**Table 8. Multi-outcome robustness check** (same N = 684, same predictors)

| Outcome | Ozone coefficient | Standardized 95% CI | p-value | Adjusted R² |
|---|---|---|---|---|
| COPD prevalence (primary) | 18.90 | [0.033, 0.118] | 0.0005 | 0.902 |
| Current asthma prevalence (2nd respiratory outcome) | 11.34 | [−0.015, 0.106] | 0.142 | 0.225 |
| Diabetes prevalence (falsification check) | −19.15 | [−0.177, 0.024] | 0.135 | 0.668 |

**Table 9. Ozone×poverty interaction** — *pending R re-run, to be added once available.*

**Table 10. N=444 (PM2.5-monitored) vs. N=240 (dropped) subsample comparison** — *pending R re-run, to be added once available.*

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
- [x] Supplementary multi-outcome robustness check (asthma + diabetes falsification), benchmarked against the author's prior NHSJS paper's multi-outcome strategy
- [x] All citations verified against original sources; repetitive phrasing copyedited; RF-linearity claim softened; results tables moved to Appendix for page count
- [ ] Ozone×poverty interaction term (code written, pending R re-run) — Appendix Table 9
- [ ] N=444 vs N=240 subsample characterization (code written, pending R re-run) — Appendix Table 10
- [ ] Author name/contact info (still a placeholder above — fill in before submitting)
- [ ] Full reference list finalized (2–3 more sources still flagged as needed — see References)
- [x] Page-count check: body (Research Question through Conclusion) is ~2,350 words, confirmed to render in 5 pages at 10.5pt/1in margins or 11pt/0.75in margins (both standard for a research brief); renders at 6 pages only under the most generous possible defaults (11pt, 1in margins). Re-check once the two pending Appendix tables (9, 10) are folded in — they'll add ~1-2 sentences each to Evidence/Output.
- [ ] Final proofread pass in whatever tool/template is used for actual submission
