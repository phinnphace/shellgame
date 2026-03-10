# Global variables used in NSE contexts
utils::globalVariables(c("ZCTA5CE10", "stage", "value", "type"))

#' @importFrom magrittr %>%
NULL

#' Plot baseline ZCTAs
#'
#' Creates a map showing the baseline ZCTAs used in the analysis.
#'
#' @param zcta_sf SF object with ZCTA geometries
#' @param county_sf SF object with county boundary
#' @param title Plot title
#' @return A ggplot2 object
#' @export
plot_baseline_zctas <- function(zcta_sf, county_sf,
                                title = "Baseline ZCTAs") {
    ggplot2::ggplot() +
        ggplot2::geom_sf(data = zcta_sf, alpha = 0.35, fill = "lightblue") +
        ggplot2::geom_sf(data = county_sf, fill = NA, linewidth = 1) +
        ggplot2::theme_minimal() +
        ggplot2::labs(
            title = title,
            subtitle = sprintf("n = %d ZCTAs", nrow(zcta_sf))
        ) +
        ggplot2::theme(
            plot.title.position = "plot",
            plot.title = ggplot2::element_text(margin = ggplot2::margin(b = 5)),
            plot.subtitle = ggplot2::element_text(margin = ggplot2::margin(b = 10))
        )
}

#' Plot geometric vs relationship membership
#'
#' Visualizes the discrepancy between geometric intersection and
#' relationship-based membership.
#'
#' @param zcta_baseline_sf SF object with baseline ZCTAs (relationship-based)
#' @param zcta_geometric_sf SF object with all geometrically intersecting ZCTAs
#' @param county_sf SF object with county boundary
#' @param title Plot title
#' @return A ggplot2 object
#' @export
plot_geometric_vs_relationship <- function(zcta_baseline_sf, zcta_geometric_sf,
                                           county_sf,
                                           title = "Geometric vs Relationship Membership") {
    # Find ZCTAs that are geometric-only (not in baseline)
    baseline_ids <- zcta_baseline_sf$ZCTA5CE10
    extra_zctas <- zcta_geometric_sf %>%
        dplyr::filter(!(ZCTA5CE10 %in% baseline_ids))

    ggplot2::ggplot() +
        ggplot2::geom_sf(data = zcta_baseline_sf, fill = NA, linewidth = 0.25) +
        ggplot2::geom_sf(data = extra_zctas, fill = "grey60", linewidth = 0.25) +
        ggplot2::geom_sf(data = county_sf, fill = NA, linewidth = 1.0) +
        ggplot2::theme_minimal() +
        ggplot2::labs(
            title = title,
            subtitle = sprintf(
                "Geometric: %d ZCTAs | Relationship: %d | Geometry-only: %d",
                nrow(zcta_geometric_sf),
                nrow(zcta_baseline_sf),
                nrow(extra_zctas)
            ),
            caption = "Grey polygons: appear only under geometric intersection"
        ) +
        ggplot2::theme(
            plot.title.position = "plot",
            plot.title = ggplot2::element_text(margin = ggplot2::margin(b = 5)),
            plot.subtitle = ggplot2::element_text(margin = ggplot2::margin(b = 10)),
            plot.caption = ggplot2::element_text(margin = ggplot2::margin(t = 10))
        )
}

#' Plot baseline vs transformed totals
#'
#' Simple comparison chart for a geoDeltaAudit::audit_transform() result.
#' No inference, no labels on bars.
#'
#' @param audit_result An audit_result object produced by geoDeltaAudit::audit_transform()
#' @param y_label Character. Label for y-axis (e.g., "Total population (persons)")
#' @return A ggplot2 object
#' @export
plot_transformation_perturbation <- function(audit_result, y_label = "Total (count)") {
  
  baseline_total <- as.numeric(audit_result$baseline_total)
  final_total    <- as.numeric(audit_result$final_total)
  
  plot_data <- data.frame(
    stage = factor(c("Observed", "After transform"), levels = c("Observed", "After transform")),
    value = c(baseline_total, final_total),
    stringsAsFactors = FALSE
  )
  
  ggplot2::ggplot(plot_data, ggplot2::aes(x = stage, y = value)) +
    ggplot2::geom_col() +
    ggplot2::theme_minimal() +
    ggplot2::scale_y_continuous(labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
    ggplot2::labs(
      title = "Baseline vs After Transformation",
      x = NULL,
      y = y_label
    ) +
    ggplot2::theme(
      plot.title.position = "plot",
      plot.title = ggplot2::element_text(margin = ggplot2::margin(b = 8))
    )
}
#' Create complete audit report
#'
#' Generates all visualizations for an audit.
#'
#' @param audit_result An audit_result object produced by geoDeltaAudit::audit_transform()
#' @param zcta_baseline_sf Optional: SF object with baseline ZCTAs
#' @param zcta_geometric_sf Optional: SF object with geometric ZCTAs
#' @param county_sf Optional: SF object with county boundary
#' @return List of ggplot2 objects
#' @export
create_audit_report <- function(audit_result, zcta_baseline_sf = NULL,
                                zcta_geometric_sf = NULL, county_sf = NULL) {
  plots <- list()
  
  plots$perturbation <- plot_transformation_perturbation(audit_result)
  
  if (!is.null(zcta_baseline_sf) && !is.null(county_sf)) {
    plots$baseline <- plot_baseline_zctas(zcta_baseline_sf, county_sf)
  }
  
  if (!is.null(zcta_baseline_sf) && !is.null(zcta_geometric_sf) && !is.null(county_sf)) {
    plots$membership <- plot_geometric_vs_relationship(
      zcta_baseline_sf, zcta_geometric_sf, county_sf
    )
  }
  
  plots
}
