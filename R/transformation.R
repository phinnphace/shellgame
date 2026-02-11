#' Transform ZCTA data to ZIP level
#'
#' Performs the first hop: ZCTA → ZIP using association-based allocation.
#' This is where the first swap occurs: observed data → imputed data.
#'
#' @param baseline_data Data frame with columns: zcta, and a value column
#' @param zip_zcta_map Data frame with columns: zcta, zip
#' @param value_col Name of the value column in baseline_data (default: "estimate")
#' @return Data frame with columns: zip, value (allocated to ZIP level)
#' @export
#' @examples
#' \dontrun{
#' zip_data <- transform_zcta_to_zip(
#'     baseline_data = zcta_pop,
#'     zip_zcta_map = zip_zcta_assoc,
#'     value_col = "pop"
#' )
#' }
transform_zcta_to_zip <- function(baseline_data, zip_zcta_map, value_col = "estimate") {
    # Validate inputs
    validate_columns(baseline_data, c("zcta", value_col), "baseline_data")
    validate_columns(zip_zcta_map, c("zcta", "zip"), "zip_zcta_map")

    # Join baseline to ZIP-ZCTA map
    result <- baseline_data %>%
        dplyr::left_join(zip_zcta_map, by = "zcta") %>%
        # Count how many ZIPs each ZCTA maps to
        dplyr::group_by(zcta) %>%
        dplyr::mutate(n_zip_assoc = dplyr::n_distinct(zip)) %>%
        dplyr::ungroup() %>%
        # Allocate value equally across associated ZIPs
        dplyr::mutate(
            value_allocated = !!rlang::sym(value_col) / n_zip_assoc
        ) %>%
        # Sum to ZIP level (in case multiple ZCTAs map to same ZIP)
        dplyr::group_by(zip) %>%
        dplyr::summarise(
            value = sum(value_allocated, na.rm = TRUE),
            .groups = "drop"
        )

    result
}

#' Transform ZIP data to County level
#'
#' Performs the second hop: ZIP → County using HUD TOT_RATIO allocation.
#' This is where the second swap occurs: further imputation via proxy.
#'
#' @param zip_data Data frame with columns: zip, value
#' @param hud_crosswalk Data frame with columns: zip, county, tot_ratio
#' @param county_fips Optional FIPS code to filter to specific county
#' @return Data frame with columns: county, value (allocated to county level)
#' @export
#' @examples
#' \dontrun{
#' county_data <- transform_zip_to_county(
#'     zip_data = zip_pop,
#'     hud_crosswalk = hud,
#'     county_fips = "27053"
#' )
#' }
transform_zip_to_county <- function(zip_data, hud_crosswalk, county_fips = NULL) {
    # Validate inputs
    validate_columns(zip_data, c("zip", "value"), "zip_data")
    validate_columns(hud_crosswalk, c("zip", "county", "tot_ratio"), "hud_crosswalk")

    # Join ZIP data to HUD crosswalk
    result <- zip_data %>%
        dplyr::left_join(hud_crosswalk, by = "zip") %>%
        # Allocate value using TOT_RATIO
        dplyr::mutate(
            value_allocated = value * tot_ratio
        ) %>%
        # Sum to county level
        dplyr::group_by(county) %>%
        dplyr::summarise(
            value = sum(value_allocated, na.rm = TRUE),
            .groups = "drop"
        )

    # Filter to specific county if requested
    if (!is.null(county_fips)) {
        result <- result %>%
            dplyr::filter(county == county_fips)
    }

    result
}

#' Run full transformation pipeline
#'
#' Executes both hops: ZCTA → ZIP → County.
#' Tracks the complete swap from observed to imputed data.
#'
#' @param baseline_data Data frame with ZCTA-level baseline data
#' @param zip_zcta_map ZIP-ZCTA association table
#' @param hud_crosswalk HUD ZIP-County crosswalk
#' @param value_col Name of value column in baseline_data
#' @param county_fips Optional county FIPS to filter final result
#' @return List with intermediate and final results
#' @export
#' @examples
#' \dontrun{
#' result <- run_full_transformation(
#'     baseline_data = zcta_pop,
#'     zip_zcta_map = zip_zcta,
#'     hud_crosswalk = hud,
#'     value_col = "pop",
#'     county_fips = "27053"
#' )
#' }
run_full_transformation <- function(baseline_data, zip_zcta_map, hud_crosswalk,
                                    value_col = "estimate", county_fips = NULL) {
    # Hop 1: ZCTA → ZIP
    zip_data <- transform_zcta_to_zip(
        baseline_data = baseline_data,
        zip_zcta_map = zip_zcta_map,
        value_col = value_col
    )

    # Hop 2: ZIP → County
    county_data <- transform_zip_to_county(
        zip_data = zip_data,
        hud_crosswalk = hud_crosswalk,
        county_fips = county_fips
    )

    list(
        zip_level = zip_data,
        county_level = county_data
    )
}
