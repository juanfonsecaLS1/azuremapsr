



library(httr2)

body_geojson <- '{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "coordinates": [
          -122.201399,
          47.608678
        ],
        "type": "Point"
      },
      "properties": {
        "pointIndex": 0,
        "pointType": "waypoint"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "coordinates": [
          -122.20687,
          47.612002
        ],
        "type": "Point"
      },
      "properties": {
        "pointIndex": 1,
        "pointType": "viaWaypoint"
      }
    },
    {
      "type": "Feature",
      "geometry": {
        "coordinates": [
          -122.201669,
          47.615076
        ],
        "type": "Point"
      },
      "properties": {
        "pointIndex": 2,
        "pointType": "waypoint"
      }
    }
  ],
  "optimizeRoute": "fastestWithTraffic",
  "routeOutputOptions": [
    "routePath"
  ],
  "maxRouteCount": 3,
  "travelMode": "driving"
}'

base_url <- "https://atlas.microsoft.com/route/directions"

params <- list(`api-version` = "2025-01-01")

header <- list(`Content-Type` = "application/geo+json",`subscription-key` = get_azuremaps_token())

req <- request(base_url) |>
  req_url_query(!!!params) |>
  req_headers_redacted(!!!header) |>
  req_body_raw(stringr::str_squish(body_geojson),type = "application/geo+json")

resp <- req |> req_perform()

body <- resp |> resp_body_json()
