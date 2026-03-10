#' Audit geographic transformation
#'
#' Main function to audit a complete geographic transformation pipeline.
#' Quantifies the error introduced at each hop and reveals the shell game.
#'
#' @param baseline_data Data frame with baseline data at source geography
#' @param zip_zcta_map ZIP-ZCTA association crosswalk
#' @param hud_crosswalk HUD ZIP-County crosswalk
#' @param county_fips Target county FIPS code
#' @param variable_name Name of the variable being tracked (for reporting)
#' @param value_col Name of the value column in baseline_data
#' @return An object of class "shellgame_audit" with audit results
#' @export
#' @examples
#' \dontrun{
#' result <- audit_transformation(
#'     baseline_data = hennepin_zcta_baseline,
#'     zip_zcta_map = hennepin_zip_zcta_map,
#'     hud_crosswalk = hennepin_hud_crosswalk,
#'     county_fips = "27053",
#'     variable_name = "population"
#' )
#' summary(result)
#' }
audit_transformation <- function(baseline_data, zip_zcta_map, hud_crosswalk,
                                 county_fips, variable_name = "value",
                                 value_col = "estimate") {
    # Calculate baseline total
    baseline_total <- sum(baseline_data[[value_col]], na.rm = TRUE)
    baseline_n_units <- nrow(baseline_data)

    # Run transformation pipeline
    transformed <- run_full_transformation(
        baseline_data = baseline_data,
        zip_zcta_map = zip_zcta_map,
        hud_crosswalk = hud_crosswalk,
        value_col = value_col,
        county_fips = county_fips
    )

    # Calculate recovered total
    recovered_total <- sum(transformed$county_level$value, na.rm = TRUE)

    # Calculate perturbation
    absolute_perturbation <- recovered_total - baseline_total
    percent_perturbation <- 100 * absolute_perturbation / baseline_total

    # Count units at each stage
    n_zips <- nrow(transformed$zip_level)

    # Calculate pre-allocation expansion
    pre_alloc_expansion <- (n_zips - baseline_n_units) / baseline_n_units * 100

    # Identify where population was perturbed
    perturbed_pop <- transformed$county_level %>%
        dplyr::filter(county != county_fips) %>%
        dplyr::arrange(dplyr::desc(value))

    # Create result object
    result <- list(
        # Summary metrics
        baseline_total = baseline_total,
        baseline_n_units = baseline_n_units,
        recovered_total = recovered_total,
        absolute_perturbation = absolute_perturbation,
        percent_perturbation = percent_perturbation,

        # Transformation details
        n_zips = n_zips,
        pre_alloc_expansion = pre_alloc_expansion,

        # Data at each stage
        baseline_data = baseline_data,
        zip_level = transformed$zip_level,
        county_level = transformed$county_level,
        perturbed_to_other_counties = perturbed_pop,

        # Metadata
        county_fips = county_fips,
        variable_name = variable_name,
        value_col = value_col,

        # Crosswalks used
        zip_zcta_map = zip_zcta_map,
        hud_crosswalk = hud_crosswalk
    )

    class(result) <- "shellgame_audit"
    result
}

#' Print method for shellgame_audit
#'
#' @param x A shellgame_audit object
#' @param ... Additional arguments (ignored)
#' @export
print.shellgame_audit <- function(x, ...) {
    cat("\\n=== The Shell Game: Transformation Audit ===\\n\\n")
    cat("Variable:", x$variable_name, "\\n")
    cat("Target County:", x$county_fips, "\\n\\n")

    cat("--- Baseline (Observed Data) ---\\n")
    cat("  Units:", x$baseline_n_units, "ZCTAs\\n")
    cat("  Total:", format(round(x$baseline_total), big.mark = ","), "\\n\\n")

    cat("--- After Transformation (Imputed Data) ---\\n")
    cat("  Intermediate: ", x$n_zips, " ZIPs\\n")
    cat("  Recovered:", format(round(x$recovered_total), big.mark = ","), "\\n\\n")

    cat("--- The Shell Game Result ---\\n")
    cat(
        "  Perturbation:", format(round(x$absolute_perturbation), big.mark = ","),
        sprintf("(%.1f%%)\\n", x$percent_perturbation)
    )
    cat("\\n")
    cat("  Same column name.\\n")
    cat("  Different underlying quantity.\\n")
    cat("  That's the shell game.\\n\\n")

    invisible(x)
}

#' Summary method for shellgame_audit
#'
#' @param object A shellgame_audit object
#' @param ... Additional arguments (ignored)
#' @export
summary.shellgame_audit <- function(object, ...) {
    print(object)

    cat("--- Pre-Allocation Expansion ---\\n")
    cat(sprintf(
        "%d ZCTAs -> %d ZIPs (+%.1f%%)\n",
        object$baseline_n_units,
        object$n_zips,
        object$pre_alloc_expansion
    ))
    cat("  This happens BEFORE any allocation or weighting.\\n")
    cat("  The analytical surface has already shifted.\\n\\n")

    if (nrow(object$perturbed_to_other_counties) > 0) {
        cat("--- Top Counties Receiving Perturbed Population ---\\n")
      top_perturbed <- utils::head(object$perturbed_to_other_counties, 5)
        for (i in seq_len(nrow(top_perturbed))) {
            cat(sprintf(
                "  %s: %s\\n",
                top_perturbed$county[i],
                format(round(top_perturbed$value[i]), big.mark = ",")
            ))
        }
    }

    invisible(object)
}

#' Extract perturbed population details
#'
#' @param audit_result A shellgame_audit object
#' @param top_n Number of top counties to return (default: 10)
#' @return Data frame of counties that received population from target county
#' @export
extract_perturbed_population <- function(audit_result, top_n = 10) {
    audit_result$perturbed_to_other_counties %>%
    utils::head(top_n)
}
