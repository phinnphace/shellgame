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

#' Plot transformation loss
#'
#' Creates a simple bar chart showing baseline vs recovered values.
#'
#' @param audit_result A shellgame_audit object
#' @return A ggplot2 object
#' @export
plot_transformation_loss <- function(audit_result) {
    plot_data <- data.frame(
        stage = c("Baseline\\n(Observed)", "After Transformation\\n(Imputed)"),
        value = c(audit_result$baseline_total, audit_result$recovered_total),
        type = c("Observed", "Imputed")
    )

    ggplot2::ggplot(plot_data, ggplot2::aes(x = stage, y = value, fill = type)) +
        ggplot2::geom_col() +
        ggplot2::geom_text(
            ggplot2::aes(label = format(round(value), big.mark = ",")),
            vjust = -0.5
        ) +
        ggplot2::scale_fill_manual(
            values = c("Observed" = "#4CAF50", "Imputed" = "#FF9800")
        ) +
        ggplot2::theme_minimal() +
        ggplot2::labs(
            title = "The Shell Game",
            subtitle = sprintf(
                "%s: Loss of %s (%.1f%%)",
                audit_result$variable_name,
                format(round(abs(audit_result$absolute_loss)), big.mark = ","),
                abs(audit_result$percent_loss)
            ),
            x = NULL,
            y = audit_result$variable_name,
            fill = "Data Type",
            caption = "Same column name. Different underlying quantity."
        ) +
        ggplot2::theme(
            legend.position = "bottom",
            plot.title.position = "plot",
            plot.title = ggplot2::element_text(margin = ggplot2::margin(b = 5)),
            plot.subtitle = ggplot2::element_text(margin = ggplot2::margin(b = 10)),
            plot.caption = ggplot2::element_text(margin = ggplot2::margin(t = 10))
        )
}

#' Create complete audit report
#'
#' Generates all visualizations for an audit.
#'
#' @param audit_result A shellgame_audit object
#' @param zcta_baseline_sf Optional: SF object with baseline ZCTAs
#' @param zcta_geometric_sf Optional: SF object with geometric ZCTAs
#' @param county_sf Optional: SF object with county boundary
#' @return List of ggplot2 objects
#' @export
create_audit_report <- function(audit_result, zcta_baseline_sf = NULL,
                                zcta_geometric_sf = NULL, county_sf = NULL) {
    plots <- list()

    # Always create the loss plot
    plots$loss <- plot_transformation_loss(audit_result)

    # Create spatial plots if geometries provided
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

