# Merge EPA AirData (ozone annual mean, PM2.5), CDC PLACES (COPD + smoking
# prevalence), and Census ACS (poverty rate + median age) on county FIPS code.
#
# TODO:
# 1. Load raw EPA ozone daily data (data/raw/) -> compute annual mean per county
#    (NOT the regulatory design value -- see research_brief_draft.md Method).
# 2. Load raw EPA PM2.5 daily data -> compute annual mean per county
#    (sensitivity check only, see step 5 of Method).
# 3. Load CDC PLACES COPD prevalence + smoking prevalence (county level).
# 4. Load Census ACS 5-Year Estimates: poverty rate + median age / %65+.
# 5. Merge all sources on FIPS code (dplyr::left_join / inner_join as appropriate).
# 6. Print/report final N prominently (bounds how much weight results can carry).
# 7. Save merged dataset to data/processed/merged_county_data.csv (readr::write_csv)

library(dplyr)
library(readr)

build_dataset <- function() {
  stop("Day 2: pull and merge the four data sources.")
}

build_dataset()
