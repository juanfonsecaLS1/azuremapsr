##' Set Azure Maps API Authentication Token
##'
##' Saves an authentication token for the Azure Maps API in the environment.
##'
##' @param token A character string containing the Azure Maps API token.
##'
##' @return Logical TRUE if the token is correctly set.
##' @export
##'
##' @examples
##' \dontrun{
##' set_azuremaps_token("your_token_here")
##' }
set_azuremaps_token <- function(token) {
  if (is.null(token)) {
    stop("No token provided")
  }
  return(Sys.setenv(azure_maps = token))
}

##' Get Azure Maps API Authentication Token
##'
##' Retrieves the Azure Maps API token from the environment.
##'
##' @return A character string containing the Azure Maps API token.
##' @export
##'
##' @examples
##' \dontrun{
##' get_azuremaps_token()
##' }
get_azuremaps_token <- function() {
  PAT <- Sys.getenv("azure_maps")
  if (PAT == "") {
    stop("Azure maps token has not been set. Use set_azuremaps_token")
  }
  return(PAT)
}
