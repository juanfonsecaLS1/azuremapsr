#' Title
#'
#' @param origin
#' @param destination
#' @param waypoints
#'
#' @returns
#' @export
#'
#' @examples
POSTbody_builder_directions_geojson <- function(origin,
                                                destination,
                                                waypoints = NULL){

  sfc_origin <- get_point(origin)

  sfc_destination <- get_point(destination)

  if(!is.null(waypoints)){
    sfc_waypoints <- get_point(waypoints)
  }

  sf_body <- sf::st_as_sf(c(sfc_origin,sfc_waypoints,sfc_destination))
  sf_body$pointIndex <- rownames(sf_body) |> as.integer()
  sf_body$pointIndex <- sf_body$pointIndex - 1

  sf_body$pointType <- "waypoint"

  if(nrow(sf_body)>2){
    sf_body$pointType[2:(nrow(sf_body)-1)] <- "viaWaypoint"
  }

  geojson_body <- geojsonsf::sf_geojson(sf_body[,c("pointIndex","pointType","x")])

  geojson_list <- stringr::str_remove_all(geojson_body,"(?<=pointIndex\":\\d{1,2})\\.0") |>
    jsonlite::fromJSON() |>
    as.list()

  geojson_list[["type"]] <- jsonlite::unbox(geojson_list[["type"]])

  geojson_list
}


#' Title
#'
#' @param params
#' @param tz
#'
#' @returns
#' @export
#'
#' @examples
POSTbody_builder_directions_json <- function(params,tz){

  template_params <- pkg.env$template_params_directions

  initial_check <- check_params(params,template_params,tz)

  # Date formatting
  datecols <- c("departAt","arriveAt")

  datecols_check <- datecols %in% names(params)

  if(any(datecols_check)){
    tmp_date <- lubridate::as_datetime(params[[datecols[datecols_check]]],tz = tz) |> lubridate::with_tz("UTC")
    params[[datecols[datecols_check]]] <- strftime(tmp_date,format = "%Y-%Om-%dT%H:%M:%OS3Z")
  }

  default_list_names <- names(template_params)[vapply(template_params,function(x){x$required},logical(1))]

  default_list_names <- default_list_names[!(default_list_names %in% names(params))]

  if (length(default_list_names)>0){

  default_list <- lapply(default_list_names,function(j){template_params[[j]]$value[1]})
  names(default_list) <- default_list_names

  params <- c(params,default_list)
  }

  ## Unboxing to match the JSON structure of the API
  final_list_names <- names(params)

  to_unbox_names <- final_list_names[vapply(final_list_names,function(x){!template_params[[x]]$multiple},logical(1))]

  for (i in to_unbox_names) {
    params[[i]] <- jsonlite::unbox(params[[i]])
  }

  params
}





