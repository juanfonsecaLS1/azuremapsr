#' Saves an Authentication Token for the Azure Maps API
#'
#' @param token a \code{string} with the token
#'
#' @return TRUE if token correctly set
#' @export
#'
#' @examples
#' \dontrun{
#' mytoken <- "your token goes here"
#'
#' set_azuremaps_token(mytoken)
#' }
#'
set_azuremaps_token <- function(token) {
  if (is.null(token)) {
    stop("No token provided")
  }
  return(Sys.setenv(azure_maps = token))
}

#' Title
#'
#' @returns
#' @export
#'
#' @examples
#'
#' #' \dontrun{
#' #' get_azuremaps_token()
#' }

get_azuremaps_token <- function() {
  PAT <- Sys.getenv("azure_maps")
  if (PAT == "") {
    stop("Azure maps token has not been set. Use set_azuremaps_token")
  }
  return(PAT)
}
