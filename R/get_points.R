#' Create sfc Object from Coordinates or sf Object
#'
#' Converts a pair of coordinates, a matrix of coordinates, or an sf POINT object into an sfc object for use in GeoJSON bodies.
#'
#' @param x A numeric vector of length 2, a matrix with coordinates, or an sf object of POINT type.
#'
#' @return An sfc object with coordinates in EPSG:4326.
#' @export
#'
#' @examples
#' get_point(c(-122.201399,47.608678))
get_point <- function(x){
  UseMethod("get_point")
}


#' @rdname get_point
#' @export
get_point.default <- function(x){
  stop("Points should be either numeric vectors with coordinates or sf objects")
}


#' @rdname get_point
#' @export
get_point.numeric <- function(x){
  if (length(x)!=2) {
    stop("Point coordinates should be a vector with two values!")
  }

  sf::st_sfc(sf::st_point(x), crs = 4326)

}


#' @rdname get_point
#' @export
get_point.matrix <- function(x){
  do.call(c,lapply(1:nrow(x),function(i) get_point(x[i,])))
}


#' @rdname get_point
#' @export
get_point.sf <- function(x){
  get_point(sf::st_geometry(x))
}


#' @rdname get_point
#' @export
get_point.sfc <- function(x){

  if (length(x)>1) {
    warning("Provided point contains more than one feature, taking the first one",call. = FALSE)
    x <- x[1]
  }

  if (is.na(sf::st_crs(x))){
    sf::st_crs(x) <- 4326
  }

  if (sf::st_crs(x)!=4326){
    x <- sf::st_transform(x,4326)
  }

  x
}
