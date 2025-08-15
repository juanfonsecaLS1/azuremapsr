## code to prepare `sample_response` dataset goes here

library(azuremapsr)

origin <- c(-122.201399, 47.608678)
destination <- c(-122.201669, 47.615076)
waypoints <- c(-122.20687, 47.612002)

params <- list(
  optimizeRoute = "fastestWithTraffic",
  routeOutputOptions = "routePath",
  maxRouteCount = 3,
  travelMode = "driving"
)

sample_response <- get_route_directions(origin, destination, waypoints, params)

usethis::use_data(sample_response, overwrite = TRUE)
