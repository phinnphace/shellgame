## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  eval = FALSE,
  message = FALSE,
  warning = FALSE,
  error = FALSE
)

## ----libs---------------------------------------------------------------------
# library(shellgame)
# library(geoDeltaAudit)
# library(dplyr)
# library(stringr)
# library(janitor)
# 
# # vignette-only dependency; keep in Suggests
# if (!requireNamespace("readr", quietly = TRUE)) {
#   stop("Package 'readr' is required to run this vignette. Install it with install.packages('readr').")
# }

## ----eval=FALSE---------------------------------------------------------------
# acs_path  <- system.file("extdata", "toy_acs_zcta_hennepin.csv", package = "geoDeltaAudit")
# hud_path  <- system.file("extdata", "toy_zip_county_hud_hennepin.csv", package = "geoDeltaAudit")
# 
# stopifnot(nchar(acs_path) > 0, nchar(hud_path) > 0)
# 
# acs <- readr::read_csv(acs_path, show_col_types = FALSE) |>
#   janitor::clean_names() |>
#   dplyr::mutate(zcta = stringr::str_pad(as.character(.data$zcta), 5, pad = "0"))
# 
# hud <- readr::read_csv(hud_path, show_col_types = FALSE) |>
#   janitor::clean_names()
# 
# # Toy assoc: 1:1 ZCTA -> ZIP so the example always runs
# assoc <- acs |>
#   dplyr::distinct(.data$zcta) |>
#   dplyr::transmute(zcta = .data$zcta, zip = .data$zcta) |>
#   dplyr::distinct()
# 
# list(
#   acs_rows = nrow(acs),
#   assoc_rows = nrow(assoc),
#   hud_rows = nrow(hud)
# )

## ----run-audit, eval=FALSE, echo=TRUE-----------------------------------------
# # example only (not executed during vignette build)
# steps <- list(
#   geoDeltaAudit::step_zcta_to_zip_equal(assoc),
#   geoDeltaAudit::step_zip_to_county_totratio(hud = hud)
# )
# 
# out <- geoDeltaAudit::audit_transform(
#   df = acs,
#   geo_col = "zcta",
#   var_col = "pop",
#   steps = steps
# )

