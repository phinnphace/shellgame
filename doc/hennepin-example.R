## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)

## ----setup--------------------------------------------------------------------
library(shellgame)
library(dplyr)
library(ggplot2)

## ----eval=FALSE---------------------------------------------------------------
# # Load crosswalks
# zip_zcta_path <- system.file("extdata", "ZiptoZCTA-Table 1.csv", package = "shellgame")
# if (zip_zcta_path == "") {
# 
#   zip_zcta_path <- file.path("..", "inst", "extdata", "ZiptoZCTA-Table 1.csv")
# }
# 
# hud_path <- system.file("extdata", "HUD_ZIP_COUNTY.csv", package = "shellgame")
# if (hud_path == "") {
#   hud_path <- file.path("..", "inst", "extdata", "HUD_ZIP_COUNTY.csv")
# }
# 
# zip_zcta_raw <- read.csv(zip_zcta_path)
# hud_raw      <- read.csv(hud_path)
# # Get baseline population data from ACS
# # First, set your Census API key
# tidycensus::census_api_key("YOUR_KEY_HERE", install = TRUE, overwrite = TRUE)
# 
# # Get ZCTAs for Hennepin County
# library(zctaCrosswalk)
# zctas_hennepin <- get_zctas_by_county("27053")
# 
# # Fetch population data
# acs_data <- get_zcta_baseline(
#   variable = "B01001_001", # Total population
#   year = 2022,
#   zctas = zctas_hennepin
# )
# 

## ----load-toy-data------------------------------------------------------------
# For this demo vignette, we use toy data instead of live Census API calls
acs_path <- system.file("extdata", "toy_acs_zcta_hennepin.csv", package = "shellgame")
if (acs_path == "") {
  acs_path <- file.path("..", "inst", "extdata", "toy_acs_zcta_hennepin.csv")
}
acs_data <- read.csv(acs_path)

## ----eval=FALSE---------------------------------------------------------------
# result <- audit_transformation(
#   baseline_data = acs_data,
#   zip_zcta_map = zip_zcta,
#   hud_crosswalk = hud,
#   county_fips = "27053",
#   variable_name = "population",
#   value_col = "estimate"
# )

## ----eval=FALSE---------------------------------------------------------------
# # Print summary
# summary(result)

## ----eval=FALSE---------------------------------------------------------------
# extract_lost_population(result, top_n = 5)

## ----eval=FALSE---------------------------------------------------------------
# plot_transformation_loss(result)

