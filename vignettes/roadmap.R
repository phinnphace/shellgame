## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## ----eval=FALSE---------------------------------------------------------------
# # Get your free key at: https://api.census.gov/data/key_signup.html
# # Then install it:
# tidycensus::census_api_key("YOUR_KEY_HERE", install = TRUE)

## ----eval=FALSE---------------------------------------------------------------
# library(zctaCrosswalk)
# 
# # Replace with your county FIPS code
# zctas <- get_zctas_by_county("27053") # Hennepin County, MN

## ----eval=FALSE---------------------------------------------------------------
# library(shellgame)
# 
# # Get total population (B01001_001)
# baseline_data <- get_zcta_baseline(
#     variable = "B01001_001",
#     year = 2022,
#     zctas = zctas
# )
# 
# # Or try other variables:
# # B19013_001 - Median household income
# # B25001_001 - Total housing units
# # B08201_001 - Households by vehicles available

## ----eval=FALSE---------------------------------------------------------------
# # Read the file
# zip_zcta_raw <- read.csv("ZiptoZCTA-Table 1.csv")
# 
# # Clean and standardize
# zip_zcta <- prep_zip_zcta(zip_zcta_raw)

## ----eval=FALSE---------------------------------------------------------------
# # Read the file
# hud_raw <- read.csv("ZIP_COUNTY_122024.csv")
# 
# # Clean and standardize
# hud <- prep_hud_crosswalk(hud_raw)
# 
# # Optional: use different ratio
# hud_res <- prep_hud_crosswalk(hud_raw, ratio_col = "RES_RATIO")

## ----eval=FALSE---------------------------------------------------------------
# result <- audit_transformation(
#     baseline_data = baseline_data,
#     zip_zcta_map = zip_zcta,
#     hud_crosswalk = hud,
#     county_fips = "27053",
#     variable_name = "population",
#     value_col = "estimate"
# )
# 
# summary(result)

## ----eval=FALSE---------------------------------------------------------------
# library(shellgame)
# library(zctaCrosswalk)
# library(tidycensus)
# 
# # Set your Census API key (one time)
# census_api_key("YOUR_KEY_HERE", install = TRUE)
# 
# # 1. Identify ZCTAs for your county
# zctas <- get_zctas_by_county("YOUR_COUNTY_FIPS")
# 
# # 2. Get baseline data
# baseline_data <- get_zcta_baseline(
#     variable = "B01001_001", # Total population
#     year = 2022,
#     zctas = zctas
# )
# 
# # 3. Prepare crosswalks
# zip_zcta <- prep_zip_zcta(read.csv("path/to/ZiptoZCTA.csv"))
# hud <- prep_hud_crosswalk(read.csv("path/to/ZIP_COUNTY.csv"))
# 
# # 4. Run audit
# result <- audit_transformation(
#     baseline_data = baseline_data,
#     zip_zcta_map = zip_zcta,
#     hud_crosswalk = hud,
#     county_fips = "YOUR_COUNTY_FIPS",
#     variable_name = "population"
# )
# 
# # 5. View results
# summary(result)
# plot_transformation_loss(result)

## ----eval=FALSE---------------------------------------------------------------
# # Example error:
# # Error: ZIP-ZCTA crosswalk is missing required columns: zcta

