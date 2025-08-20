#' Get Route Directions from 'Azure Maps'
#'
#' Requests route directions from 'Azure Maps' API using origin, destination, waypoints, and route parameters.
#'
#' @param origin A numeric vector of length 2 with origin coordinates (longitude, latitude), or an `sf` object with a single POINT geometry.
#' @param destination A numeric vector of length 2 with destination coordinates (longitude, latitude), or an `sf` object with a single POINT geometry.
#' @param waypoints Optional. A numeric vector, a matrix of coordinates, or an `sf` object with POINT geometries representing intermediate stops.
#' @param params A list of route parameters (e.g., `optimizeRoute`, `routeOutputOptions`, `maxRouteCount`, `travelMode`). See the [API documentation](https://learn.microsoft.com/en-us/rest/api/maps/route/post-route-directions?view=rest-maps-2025-01-01&tabs=HTTP)
#' @param tz A string specifying the timezone. Defaults to the system's timezone.
#' @param api_key The 'Azure Maps' API key. Defaults to the value retrieved by `get_azuremaps_token()`.
#' @param api_version The API version to use. Defaults to "2025-01-01".
#'
#' @return An `httr2_response` object from the 'Azure Maps' API.
#' @export
#'
#' @examples
#' \dontrun{
#' origin <- c(-122.201399, 47.608678)
#' destination <- c(-122.201669, 47.615076)
#' waypoints <- c(-122.20687, 47.612002)
#'
#' params <- list(
#'   optimizeRoute = "fastestWithTraffic",
#'   routeOutputOptions = "routePath",
#'   maxRouteCount = 3,
#'   travelMode = "driving"
#' )
#'
#' response <- req_route_directions(origin, destination, waypoints, params)
#' }
#'
req_route_directions <- function(origin,
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

  req <- httr2::request(base_url) |>
    httr2::req_url_query(!!!api_params) |>
    httr2::req_headers_redacted(!!!header) |>
    httr2::req_body_raw(full_body, type = "application/geo+json")

  resp <- req |> httr2::req_perform()

  resp

}


#' Extract and Combine Routes from an 'Azure Maps' Response
#'
#' This function takes a successful response object from the 'Azure Maps' API,
#' extracts the main route and any alternative routes, and combines them into a
#' single `sf` object.
#'
#' @param resp An `httr2_response` object, typically from a successful call to
#'   `req_route_directions`.
#'
#' @return An `sf` object containing the combined main and alternative routes.
#'   If the request was not successful (status code is not 200), the function
#'   will stop with an error.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Assuming 'response' is a successful response from req_route_directions
#' all_routes_sf <- get_routes(response)
#' plot(sf::st_geometry(all_routes_sf))
#' }
get_routes <- function(resp){
  if(resp$status_code != 200) {
    stop("Request was not succesfull",call. = FALSE)
  }

  body <- resp |> httr2::resp_body_json()

  main_route <- json_to_sf(body)
  alt_routes <- json_to_sf(body, main_route = FALSE)

  rbind(main_route,alt_routes)

}




