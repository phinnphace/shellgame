#' Run a Standard Transformation Audit
#'
#' Orchestrates a complete spatial transformation audit using the \code{geoDeltaAudit} engine,
#' hiding the underlying step generation from the user. This function provides a simple
#' user-facing contract to run a standard ZCTA -> ZIP -> County pipeline.
#'
#' @param data Input dataframe containing baseline data
#' @param zip_zcta_map Dataframe containing the ZCTA to ZIP crosswalk
#' @param hud_crosswalk Dataframe containing the HUD ZIP to County crosswalk (requires a 'tot_ratio' column)
#' @param geo_col String name of the column containing the source geography IDs (e.g. "zcta")
#' @param var_col String name of the column containing the numeric variable to audit
#'
#' @return An \code{audit_result} object containing the output of \code{geoDeltaAudit::audit_transform()}
#' 
#' @examples
#' \dontrun{
#' result <- evaluate_transformation(
#'   data = my_acs_data,
#'   zip_zcta_map = my_crosswalk,
#'   hud_crosswalk = my_hud_weights,
#'   geo_col = "zcta",
#'   var_col = "population"
#' )
#' }
#' @export
evaluate_transformation <- function(data, 
                                    zip_zcta_map, 
                                    hud_crosswalk, 
                                    geo_col, 
                                    var_col) {
  
  # Hide the complexity: Auto-generate the steps list
  steps <- list(
    geoDeltaAudit::step_zcta_to_zip_equal(zip_zcta_map),
    geoDeltaAudit::step_zip_to_county_totratio(hud = hud_crosswalk)
  )
  
  # Call the engine
  result <- geoDeltaAudit::audit_transform(
    df = data,
    geo_col = geo_col,
    var_col = var_col,
    steps = steps
  )
  
  return(result)
}
