test_that("audit_transformation returns a shellgame_audit object", {
  acs_path <- system.file("extdata", "toy_acs_zcta_hennepin.csv", package = "geoDeltaAudit")
  hud_path <- system.file("extdata", "toy_zip_county_hud_hennepin.csv", package = "geoDeltaAudit")

  skip_if(nchar(acs_path) == 0, "geoDeltaAudit toy data not available")

  acs <- readr::read_csv(acs_path, show_col_types = FALSE) |>
    janitor::clean_names() |>
    dplyr::mutate(zcta = stringr::str_pad(as.character(zcta), 5, pad = "0"))

  hud <- readr::read_csv(hud_path, show_col_types = FALSE) |>
    janitor::clean_names() |>
    dplyr::mutate(zip = stringr::str_pad(as.character(zip), 5, pad = "0"))

  assoc <- acs |>
    dplyr::distinct(zcta) |>
    dplyr::transmute(zcta = zcta, zip = zcta)

  result <- audit_transformation(
    baseline_data  = acs,
    zip_zcta_map   = assoc,
    hud_crosswalk  = hud,
    county_fips    = "27053",
    variable_name  = "population",
    value_col      = "pop"
  )

  expect_s3_class(result, "shellgame_audit")
})

test_that("audit_transformation result contains expected fields", {
  acs_path <- system.file("extdata", "toy_acs_zcta_hennepin.csv", package = "geoDeltaAudit")
  hud_path <- system.file("extdata", "toy_zip_county_hud_hennepin.csv", package = "geoDeltaAudit")

  skip_if(nchar(acs_path) == 0, "geoDeltaAudit toy data not available")

  acs <- readr::read_csv(acs_path, show_col_types = FALSE) |>
    janitor::clean_names() |>
    dplyr::mutate(zcta = stringr::str_pad(as.character(zcta), 5, pad = "0"))

  hud <- readr::read_csv(hud_path, show_col_types = FALSE) |>
    janitor::clean_names() |>
    dplyr::mutate(zip = stringr::str_pad(as.character(zip), 5, pad = "0"))

  assoc <- acs |>
    dplyr::distinct(zcta) |>
    dplyr::transmute(zcta = zcta, zip = zcta)

  result <- audit_transformation(
    baseline_data  = acs,
    zip_zcta_map   = assoc,
    hud_crosswalk  = hud,
    county_fips    = "27053",
    variable_name  = "population",
    value_col      = "pop"
  )

  expect_true(is.numeric(result$baseline_total))
  expect_true(is.numeric(result$recovered_total))
  expect_true(is.numeric(result$percent_perturbation))
  expect_true(is.numeric(result$absolute_perturbation))
  expect_true(result$baseline_total > 0)
  expect_equal(result$county_fips, "27053")
  expect_equal(result$variable_name, "population")
})

test_that("print and summary run without error", {
  acs_path <- system.file("extdata", "toy_acs_zcta_hennepin.csv", package = "geoDeltaAudit")
  hud_path <- system.file("extdata", "toy_zip_county_hud_hennepin.csv", package = "geoDeltaAudit")

  skip_if(nchar(acs_path) == 0, "geoDeltaAudit toy data not available")

  acs <- readr::read_csv(acs_path, show_col_types = FALSE) |>
    janitor::clean_names() |>
    dplyr::mutate(zcta = stringr::str_pad(as.character(zcta), 5, pad = "0"))

  hud <- readr::read_csv(hud_path, show_col_types = FALSE) |>
    janitor::clean_names() |>
    dplyr::mutate(zip = stringr::str_pad(as.character(zip), 5, pad = "0"))

  assoc <- acs |>
    dplyr::distinct(zcta) |>
    dplyr::transmute(zcta = zcta, zip = zcta)

  result <- audit_transformation(
    baseline_data  = acs,
    zip_zcta_map   = assoc,
    hud_crosswalk  = hud,
    county_fips    = "27053",
    variable_name  = "population",
    value_col      = "pop"
  )

  expect_no_error(print(result))
  expect_no_error(summary(result))
})

test_that("extract_perturbed_population returns a data frame respecting top_n", {
  acs_path <- system.file("extdata", "toy_acs_zcta_hennepin.csv", package = "geoDeltaAudit")
  hud_path <- system.file("extdata", "toy_zip_county_hud_hennepin.csv", package = "geoDeltaAudit")

  skip_if(nchar(acs_path) == 0, "geoDeltaAudit toy data not available")

  acs <- readr::read_csv(acs_path, show_col_types = FALSE) |>
    janitor::clean_names() |>
    dplyr::mutate(zcta = stringr::str_pad(as.character(zcta), 5, pad = "0"))

  hud <- readr::read_csv(hud_path, show_col_types = FALSE) |>
    janitor::clean_names() |>
    dplyr::mutate(zip = stringr::str_pad(as.character(zip), 5, pad = "0"))

  assoc <- acs |>
    dplyr::distinct(zcta) |>
    dplyr::transmute(zcta = zcta, zip = zcta)

  result <- audit_transformation(
    baseline_data  = acs,
    zip_zcta_map   = assoc,
    hud_crosswalk  = hud,
    county_fips    = "27053",
    variable_name  = "population",
    value_col      = "pop"
  )

  perturbed <- extract_perturbed_population(result, top_n = 3)

  expect_true(is.data.frame(perturbed))
  expect_lte(nrow(perturbed), 3)
})
