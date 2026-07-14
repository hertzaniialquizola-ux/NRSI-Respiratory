# =============================================================================
# build_dataset.R
#
# Builds a county-level dataset for: ozone / PM2.5 exposure vs. adult COPD
# prevalence, controlling for smoking, poverty, and age.
#
# Data sources (all pulled live -- run this on a machine with internet access):
#   1. EPA AirData Annual Summary, 2025
#      https://aqs.epa.gov/aqsweb/airdata/download_files.html
#      -> annual_conc_by_monitor_2025.zip
#   2. CDC PLACES County Data (GIS-Friendly Format), 2025 release
#      https://chronicdata.cdc.gov/500-Cities-Places/PLACES-County-Data-GIS-Friendly-Format-2025-releas/i46a-9kgh
#      Also pulls CASTHMA_CrudePrev and DIABETES_CrudePrev, used only by
#      R/robustness_outcomes.R (not the main COPD analysis) as a second
#      respiratory outcome and a falsification/specificity check.
#   3. Census ACS 5-Year Estimates, 2019-2023 vintage (table release year 2023)
#      https://api.census.gov/data/2023/acs/acs5
#      Variables: B17001_002E, B17001_001E (poverty), B01002_001E (median age)
#
# Output:
#   data/county_ozone_copd_merged.csv   -- analytic sample (complete cases)
#   data/dropped_counties.csv           -- counties excluded + reason (for
#                                           your limitations section)
#
# Project: ~/copd-ozone-hackathon (GitHub: NRSI-Respiratory)
# =============================================================================

## ---- 0. Setup --------------------------------------------------------------

required_pkgs <- c("readr", "dplyr", "tidyr", "stringr", "httr", "jsonlite")
missing_pkgs  <- setdiff(required_pkgs, rownames(installed.packages()))
if (length(missing_pkgs) > 0) install.packages(missing_pkgs)

library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(httr)
library(jsonlite)

# ---- Census API key ----------------------------------------------------
# Get a free key at https://api.census.gov/data/key_signup.html
# Set it once (e.g. in your project's .Renviron, or right here for now):
#   Sys.setenv(CENSUS_API_KEY = "your_key_here")
census_key <- Sys.getenv("CENSUS_API_KEY")
if (identical(census_key, "")) {
  stop(
    "No Census API key found.\n",
    "Run Sys.setenv(CENSUS_API_KEY = 'your_key_here') (or add ",
    "CENSUS_API_KEY=your_key_here to your .Renviron and restart R), ",
    "then re-source this script.\n",
    "Free key: https://api.census.gov/data/key_signup.html"
  )
}

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

## ---- 1. EPA AirData: ozone (44201) and PM2.5 (88101) -----------------------

## ---- 1. EPA AirData: ozone (44201) and PM2.5 (88101) -----------------------

epa_zip_url  <- "https://aqs.epa.gov/aqsweb/airdata/annual_conc_by_monitor_2025.zip"
epa_zip_path <- "data/raw/annual_conc_by_monitor_2025.zip"
epa_csv_path <- "data/raw/annual_conc_by_monitor_2025.csv"

# Skip download/unzip entirely if the CSV is already sitting in data/raw
# (e.g. Safari auto-unzipped it for you on download, like it did here).
if (!file.exists(epa_csv_path)) {
  if (!file.exists(epa_zip_path)) {
    message("Downloading EPA AirData annual summary (~3.2 MB)...")
    download.file(epa_zip_url, destfile = epa_zip_path, mode = "wb", method = "libcurl")
  }
  unzip(epa_zip_path, exdir = "data/raw", overwrite = TRUE)
}

epa_county <- epa_raw %>%
  filter(`Parameter Code` %in% c(44201, 88101)) %>%
  mutate(
    FIPS      = str_c(str_pad(`State Code`, 2, pad = "0"),
                      str_pad(`County Code`, 3, pad = "0")),
    pollutant = case_when(
      `Parameter Code` == 44201 ~ "ozone_mean",
      `Parameter Code` == 88101 ~ "pm25_mean"
    )
  ) %>%
  group_by(FIPS, pollutant) %>%
  summarise(value = mean(`Arithmetic Mean`, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = pollutant, values_from = value)

message(sprintf(
  "EPA AirData: %d counties with an ozone (44201) monitor, %d with a PM2.5 (88101) monitor",
  sum(!is.na(epa_county$ozone_mean)), sum(!is.na(epa_county$pm25_mean))
))

## ---- 2. CDC PLACES County Data (GIS-Friendly Format), 2025 release ---------

places_url <- "https://chronicdata.cdc.gov/resource/i46a-9kgh.csv?$limit=50000"

places <- read_csv(places_url, show_col_types = FALSE) %>%
  rename_with(tolower) %>%              # Socrata CSV export lower-cases headers
  transmute(
    FIPS               = str_pad(as.character(countyfips), 5, pad = "0"),
    COPD_CrudePrev     = as.numeric(copd_crudeprev),
    COPD_AdjPrev       = as.numeric(copd_adjprev),
    CSMOKING_CrudePrev = as.numeric(csmoking_crudeprev),
    # Extra outcomes for R/robustness_outcomes.R -- not required for the main
    # analytic sample (see the filter() below), just carried along so that
    # script can build its own per-outcome complete-case subsamples:
    #   - CASTHMA: adult current asthma prevalence, a second respiratory
    #     outcome, direct analog to the primary COPD outcome
    #   - DIABETES: a falsification/specificity check -- ozone has no known
    #     mechanism affecting diabetes, so if ozone "predicted" this too,
    #     that would suggest the COPD result is picking up general
    #     county-level confounding rather than a real respiratory effect
    CASTHMA_CrudePrev  = as.numeric(casthma_crudeprev),
    DIABETES_CrudePrev = as.numeric(diabetes_crudeprev)
  )

message(sprintf(
  "CDC PLACES: %d counties total, %d with non-suppressed COPD data",
  nrow(places), sum(!is.na(places$COPD_AdjPrev))
))

## ---- 3. Census ACS 5-Year 2019-2023: poverty rate + median age -------------

acs_url <- modify_url(
  "https://api.census.gov/data/2023/acs/acs5",
  query = list(
    get    = "NAME,B17001_002E,B17001_001E,B01002_001E",
    `for`  = "county:*",
    `in`   = "state:*",
    key    = census_key
  )
)

acs_resp <- GET(acs_url)
stop_for_status(acs_resp)
acs_raw  <- fromJSON(content(acs_resp, as = "text", encoding = "UTF-8"))

acs <- as_tibble(acs_raw[-1, , drop = FALSE], .name_repair = "minimal")
names(acs) <- acs_raw[1, ]

acs <- acs %>%
  transmute(
    FIPS          = str_c(state, county),
    poverty_below = as.numeric(B17001_002E),
    poverty_total = as.numeric(B17001_001E),
    poverty_rate  = poverty_below / poverty_total,
    median_age    = as.numeric(B01002_001E)
  ) %>%
  select(FIPS, poverty_rate, median_age)

message(sprintf("Census ACS 2019-2023 5-year: %d counties", nrow(acs)))

## ---- 4. Merge all four sources on 5-digit FIPS -----------------------------

## ---- 4. Merge all four sources on 5-digit FIPS -----------------------------

merged_full <- acs %>%
  left_join(places,     by = "FIPS") %>%
  left_join(epa_county, by = "FIPS")

# Main analytic sample: complete cases on the actual model variables
# (PM2.5 is a sensitivity check only, per project scope, not a required covariate)
county_ozone_copd_merged <- merged_full %>%
  filter(
    !is.na(ozone_mean),
    !is.na(COPD_AdjPrev), !is.na(CSMOKING_CrudePrev),
    !is.na(poverty_rate), !is.na(median_age)
  )

# PM2.5 sensitivity subsample: same criteria, plus requires a PM2.5 monitor
county_ozone_copd_pm25_sensitivity <- county_ozone_copd_merged %>%
  filter(!is.na(pm25_mean))

## ---- 5. Report N and flag dropped counties (for your limitations section) --

n_universe <- nrow(merged_full)
n_final    <- nrow(county_ozone_copd_merged)

dropped <- merged_full %>%
  filter(!(FIPS %in% county_ozone_copd_merged$FIPS)) %>%
  mutate(
    reason = case_when(
      is.na(ozone_mean)                       ~ "no ozone monitor",
      is.na(COPD_AdjPrev)                     ~ "COPD prevalence suppressed (PLACES, small pop.)",
      is.na(CSMOKING_CrudePrev)               ~ "smoking prevalence suppressed (PLACES, small pop.)",
      is.na(poverty_rate) | is.na(median_age) ~ "missing ACS estimate",
      TRUE                                    ~ "other missing value"
    )
  ) %>%
  select(FIPS, reason)

message(sprintf(
  "\nCounty universe (ACS): %d\nFinal analytic sample: %d\nDropped: %d (%.1f%%)\n",
  n_universe, n_final, nrow(dropped), 100 * nrow(dropped) / n_universe
))
print(count(dropped, reason, sort = TRUE))

write_csv(dropped, "data/dropped_counties.csv")

## ---- 6. Save merged dataset -------------------------------------------------

write_csv(county_ozone_copd_merged, "data/county_ozone_copd_merged.csv")
message(sprintf(
  "\nSaved data/county_ozone_copd_merged.csv with N = %d counties\n", n_final
))
