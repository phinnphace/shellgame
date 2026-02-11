#' Prepare ZIP-ZCTA crosswalk data
#'
#' Standardizes ZIP-ZCTA crosswalk data with proper column names and formatting.
#'
#' @param data Raw ZIP-ZCTA crosswalk data frame
#' @param zip_col Name of the ZIP code column (default: "ZIP_CODE" or "zip")
#' @param zcta_col Name of the ZCTA column (default: "zcta")
#' @return Data frame with standardized columns: zcta, zip
#' @export
#' @examples
#' \dontrun{
#' zip_zcta_raw <- read.csv("ZiptoZCTA-Table 1.csv")
#' zip_zcta <- prep_zip_zcta(zip_zcta_raw)
#' }
prep_zip_zcta <- function(data, zip_col = NULL, zcta_col = "zcta") {
    # Clean column names
    data <- janitor::clean_names(data)

    # Auto-detect ZIP column if not specified
    if (is.null(zip_col)) {
        if ("zip_code" %in% names(data)) {
            zip_col <- "zip_code"
        } else if ("zip" %in% names(data)) {
            zip_col <- "zip"
        } else {
            stop("Could not auto-detect ZIP column. Please specify zip_col.", call. = FALSE)
        }
    }

    # Validate required columns exist
    validate_columns(data, c(zip_col, zcta_col), "ZIP-ZCTA crosswalk")

    # Standardize and return
    result <- data %>%
        dplyr::transmute(
            zcta = pad_geoid(!!rlang::sym(zcta_col)),
            zip  = pad_geoid(!!rlang::sym(zip_col))
        ) %>%
        dplyr::distinct()

    # Remove rows with NA ZCTAs
    n_na <- sum(is.na(result$zcta))
    if (n_na > 0) {
        message("Removing ", n_na, " rows with missing ZCTA values")
        result <- result %>% dplyr::filter(!is.na(zcta))
    }

    result
}

#' Prepare HUD ZIP-County crosswalk data
#'
#' Standardizes HUD crosswalk data with proper column names and formatting.
#'
#' @param data Raw HUD crosswalk data frame
#' @param ratio_col Name of the ratio column to use (default: "TOT_RATIO")
#' @return Data frame with standardized columns: zip, county, tot_ratio
#' @export
#' @examples
#' \dontrun{
#' hud_raw <- read.csv("HUD_ZIP_COUNTY.csv")
#' hud <- prep_hud_crosswalk(hud_raw)
#' }
prep_hud_crosswalk <- function(data, ratio_col = "TOT_RATIO") {
    # Clean column names
    data <- janitor::clean_names(data)

    # Convert ratio_col to lowercase for matching
    ratio_col_clean <- tolower(ratio_col)

    # Validate required columns
    required <- c("zip", "county", ratio_col_clean)
    validate_columns(data, required, "HUD crosswalk")

    # Standardize and return
    data %>%
        dplyr::transmute(
            zip = pad_geoid(zip),
            county = as.character(county),
            tot_ratio = as.numeric(!!rlang::sym(ratio_col_clean))
        )
}

#' Get ACS baseline data for ZCTAs
#'
#' Fetches ACS 5-year estimates for specified variable and ZCTAs.
#'
#' @param variable ACS variable code (e.g., "B01001_001" for total population)
#' @param year ACS year (default: 2022)
#' @param zctas Optional character vector of ZCTAs to filter to
#' @return Data frame with columns: zcta, estimate, moe
#' @export
#' @examples
#' \dontrun{
#' # Get population for all ZCTAs
#' pop_data <- get_zcta_baseline("B01001_001", year = 2022)
#'
#' # Get population for specific ZCTAs
#' hennepin_zctas <- c("55401", "55402", "55403")
#' pop_data <- get_zcta_baseline("B01001_001", zctas = hennepin_zctas)
#' }
get_zcta_baseline <- function(variable, year = 2022, zctas = NULL) {
    check_census_key()

    # Fetch data from Census API
    acs_raw <- tidycensus::get_acs(
        geography = "zcta",
        variables = variable,
        year = year,
        survey = "acs5",
        cache_table = TRUE
    )

    # Standardize
    result <- acs_raw %>%
        dplyr::transmute(
            zcta = pad_geoid(GEOID),
            estimate = as.numeric(estimate),
            moe = as.numeric(moe)
        )

    # Filter to specific ZCTAs if provided
    if (!is.null(zctas)) {
        zctas_padded <- pad_geoid(zctas)
        result <- result %>%
            dplyr::filter(zcta %in% zctas_padded)
    }

    result
}
