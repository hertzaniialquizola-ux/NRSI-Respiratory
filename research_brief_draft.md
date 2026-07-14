# Research Brief — Working Draft
**NSRI Summer Research Hackathon 2026 | Track: Health & Life Sciences**

> ✅ **Verified against the actual event slide deck (Beige_Illustrated_Research_Presentation.pdf):**
> - Rubric confirmed: 100 pts, 5 categories, exactly as in md_1. The public website's 120-pt version was stale/generic.
> - Track sponsor confirmed: **NexGen BioLab** sponsors Health and Life Sciences (not "The Insilico Lab" — that was the public site's listing for a different partner mapping).
> - Team rules: individual or teams of **2–3** (not 1–4 as the public site said). You've gone solo — "solo participants are not at a disadvantage" per the deck.
>
> ⚠️ **Still open:** I couldn't verify what NexGen BioLab actually is or what resources they offer. Public search mostly turns up a Tampa, FL supplement company by a similar name, which doesn't look like a natural research-data sponsor — possibly unrelated, possibly a small/newer org with no public footprint. Ask in a live session or check the Participant Guide's sponsor section before assuming any specific tool/dataset/API is available.

---

## Title *(draft — refine after results are in)*
**Does County-Level Ozone Exposure Predict Adult COPD Prevalence? A Regression and Machine Learning Analysis Controlling for Smoking, Poverty, and Age**

## Track
Health & Life Sciences

## Author(s)
Solo entry — [Your name / contact info here]

---

## Abstract *(draft skeleton, 250-word max — DO NOT submit until bracketed placeholders are filled with real results)*

Chronic obstructive pulmonary disease (COPD) is a leading cause of morbidity in the United States, driven predominantly by smoking but increasingly linked to ambient air pollution. While particulate matter's role in respiratory disease is well studied, ground-level ozone — a secondary pollutant that inflames airway tissue on contact — is comparatively understudied at the population level, particularly for adult COPD rather than pediatric asthma. This project asks whether county-level ozone exposure predicts adult COPD prevalence in the U.S., and how much it contributes relative to smoking prevalence, poverty rate, and age structure. We merge EPA AirData annual mean ozone concentration, CDC PLACES COPD and smoking prevalence, and Census ACS poverty rate and median age at the county (FIPS) level for the most recent complete year, covering **N = [TBD] of ~3,100 U.S. counties** (final N depends on EPA monitor coverage — reported here up front since it bounds how much weight the results can carry). We fit an OLS baseline with variance inflation factor (VIF) diagnostics, then a gradient boosting / random forest model with k-fold cross-validation, feature importance (with cross-fold variance reported, not just point estimates), and a partial dependence plot isolating ozone's functional relationship with COPD prevalence. A PM2.5 sensitivity check tests whether ozone's estimated contribution survives alongside the more established particulate-matter risk factor. [Result placeholder: linear model R² = X, ML model R² = Y; ozone's relative importance = Z; partial dependence shape = linear/threshold/plateau]. [Placeholder: agreement or divergence between linear and ML models, and what that implies]. Poverty's dual role — potentially raising true COPD burden while suppressing diagnosed prevalence through reduced healthcare access — is discussed as a key interpretive limitation, alongside the ecological-inference caveat: a county-level association does not establish that ozone exposure affects COPD risk at the individual level. The analysis is a single-year cross-section, not a panel, and has no independent validation dataset; both are named explicitly as scope decisions rather than omissions. [Placeholder: one-sentence takeaway once findings are in].

*(Longer than 250 words at current draft length with all placeholders spelled out — trim once real numbers replace the brackets; the N and ecological-fallacy sentences should survive the cut.)*

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

1. **Build the dataset, report final N.** Merge EPA AirData (ozone), CDC PLACES (adult COPD + smoking prevalence), and Census ACS 5-Year Estimates (poverty rate + median age / %65+) on FIPS code for the most recent complete year. Use **annual mean ozone concentration** computed from EPA's daily monitor data, rather than the regulatory design value (4th-highest daily max, 3-year average) — annual mean is the standard exposure metric in chronic-exposure health literature; the design value is a NAAQS-compliance construct and would need explicit justification if used instead. State the final county count up front, prominently (abstract, not just methods) — EPA ozone monitors cover roughly 600–1,000 of ~3,100 U.S. counties, and monitor placement is not random, so this bounds how much weight the results can carry.
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
*TBD — Day 15 (build day). Populate with: final N after merge, VIF values, OLS coefficients, ML model R²/RMSE, feature importance ranking, partial dependence plot description, and the two visuals.*

---

## Limitations
*Partial draft — expand after Day 15 build:*
- **Ecological inference limitation (name this explicitly, first).** This is a county-level aggregate analysis being used to speak to an individual-level disease mechanism — ozone inflaming individual airway tissue. A county-level association between ozone and COPD prevalence does not establish that ozone exposure affects COPD risk at the individual level (the ecological fallacy). Any causal-sounding language in the Conclusion needs to be checked against this before submission.
- EPA ozone monitors do not cover every U.S. county (roughly 600–1,000 of ~3,100); final N will be smaller than the full county count, and monitor placement is not random — likely biased toward higher-population/higher-pollution areas. This is a coverage bias, not just a sample-size note, and it bounds how far the results generalize.
- **Annual mean ozone is used as the exposure metric** rather than the EPA design value; this is the standard choice in chronic-exposure literature but is itself a simplification of year-round, sub-daily exposure variation.
- **PM2.5 is only a sensitivity check, not a full covariate** — if ozone and PM2.5 turn out to be highly correlated at the county level, the sensitivity check may not cleanly separate their effects, and that ambiguity should be reported rather than resolved by assertion.
- Single-year cross-section — no ability to establish temporal precedence or rule out reverse/confounded time trends. Named as a scope decision, not an oversight.
- No independent validation dataset for this analysis.
- CDC PLACES COPD prevalence is *diagnosed* prevalence, not true prevalence — the poverty/healthcare-access confound applies directly here and should be discussed, not just disclosed.
- With ~600–900 counties in the final sample, ML feature-importance rankings can be unstable — this is why cross-fold variance is reported for feature importance (see Method), not just a single ranking. If variance across folds is high, that itself is a finding to report, not a result to hide.
- [Add: anything specific that surfaces once VIF/model results are in — e.g., if smoking, poverty, and age show high collinearity, that limits how cleanly their individual coefficients can be interpreted.]

---

## Conclusion / Impact
*TBD — write last, after Evidence and Limitations are final. One paragraph: does ozone add predictive value beyond smoking/poverty, and what would that mean for county-level public health resource allocation?*

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

## AI Use Transparency Statement *(draft — follows the deck's required format)*

Per slide 16, the statement must cover: which AI tools were used, what each was used for, which parts received AI assistance, how claims/citations were verified, how outputs were checked for accuracy, and who takes responsibility.

**Draft:**

We used Claude (Anthropic) to assist with structuring this research brief around the hackathon's required framework, identifying peer-reviewed background literature on ozone and COPD, and clarifying statistical concepts (variance inflation factor, partial dependence plots) during method planning. Claude was not used to generate results, fabricate citations, or produce analysis the author cannot personally explain. All claims, citations, calculations, and outputs were reviewed and independently verified by the author. The author takes full responsibility for the final submission.

*(Finalize after the analysis is run — explicitly note whether AI was used for debugging code, and confirm every number in the brief was checked against actual model output before submission.)*

---

## Day 1 Checklist (per event timeline)
- [x] Track: Health & Life Sciences
- [x] Solo/team status — **Solo**
- [x] Research question
- [x] Initial method plan
