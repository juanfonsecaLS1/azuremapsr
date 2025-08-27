## code to prepare `sample_response_leeds` dataset goes here

library(azuremapsr)

leeds_centre <- c(-1.5427986713738182, 53.80016154590421)
headingley <- c(-1.5808117852550565, 53.82341045649981)

# Define route parameters
params <- list(
  optimizeRoute = "fastestWithTraffic",
  routeOutputOptions = "routePath",
  travelMode = "driving"
)

sample_response_leeds <- req_route_directions(leeds_centre, headingley,params = params)

usethis::use_data(sample_response_leeds, overwrite = TRUE)
