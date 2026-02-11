#' Pad GEOID to 5 digits
#'
#' Ensures geographic identifiers are zero-padded to 5 digits.
#'
#' @param geoid Character or numeric vector of geographic identifiers
#' @return Character vector of 5-digit zero-padded GEOIDs
#' @export
#' @examples
#' pad_geoid(c("123", "45678", 789))
#' #> [1] "00123" "45678" "00789"
pad_geoid <- function(geoid) {
    stringr::str_pad(as.character(geoid), 5, pad = "0")
}

#' Check for Census API key
#'
#' Validates that a Census API key is available for tidycensus.
#'
#' @param install Logical, whether to install the key for future sessions
#' @return Invisible TRUE if key exists, stops with error if not
#' @export
check_census_key <- function(install = FALSE) {
    key <- Sys.getenv("CENSUS_API_KEY")

    if (key == "") {
        stop(
            "No Census API key found. ",
            "Get one at https://api.census.gov/data/key_signup.html\\n",
            "Then set it with: tidycensus::census_api_key('YOUR_KEY', install = TRUE)",
            call. = FALSE
        )
    }

    invisible(TRUE)
}

#' Validate required columns in data frame
#'
#' @param data Data frame to validate
#' @param required_cols Character vector of required column names
#' @param data_name Name of the data object (for error messages)
#' @return Invisible TRUE if valid, stops with error if not
#' @keywords internal
validate_columns <- function(data, required_cols, data_name = "data") {
    missing_cols <- setdiff(required_cols, names(data))

    if (length(missing_cols) > 0) {
        stop(
            data_name, " is missing required columns: ",
            paste(missing_cols, collapse = ", "),
            call. = FALSE
        )
    }

    invisible(TRUE)
}
