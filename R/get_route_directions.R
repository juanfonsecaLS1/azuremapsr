#' Title
#'
#' @param origin
#' @param destination
#' @param waypoints
#' @param params
#' @param tz
#' @param api_key
#' @param api_version
#'
#' @returns
#' @export
#'
#' @examples
#' \dontrun{
#' origin <- c(-122.201399,47.608678)
#' destination <- c(-122.201669,47.615076)
#' waypoints <- c(-122.20687,47.612002)
#'
#'
#' params = list(
#'   optimizeRoute = "fastestWithTraffic",
#'   routeOutputOptions = "routePath",
#'   maxRouteCount = 3,
#'   travelMode = "driving"
#' )
#'
#' get_route_directions(origin, destination, waypoints, params)
#' }
#'
get_route_directions <- function(origin,
                                 destination,
                                 waypoints = NULL,
                                 params,
                                 tz = Sys.timezone(),
                                 api_key = get_azuremaps_token(),
                                 api_version = "2025-01-01"){


  # Essential Checks
  tz  <-  match.arg(tz,OlsonNames())
  api_version <- match.arg(api_version)

  #Run body builders

  ## Create the GEOJson part

  post_geojson <- POSTbody_builder_directions_geojson(origin, destination, waypoints)
  post_json <- POSTbody_builder_directions_json(params, tz)

  full_body <- c(post_geojson,post_json) |> jsonlite::toJSON(digits = 6) |> as.character()


  # jsonlite::prettify(full_body)

  # Create API POST query
  base_url <- "https://atlas.microsoft.com/route/directions"

  api_params <- list(`api-version` = api_version)

  header <- list(`Content-Type` = "application/geo+json",`subscription-key` = api_key)

  req <- request(base_url) |>
    req_url_query(!!!api_params) |>
    req_headers_redacted(!!!header) |>
    req_body_raw(full_body, type = "application/geo+json")

  resp <- req |> req_perform()

  resp
}
