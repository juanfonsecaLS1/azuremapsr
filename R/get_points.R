
#' Produce a sfc object from inputs
#'
#' @param x a pair of coordinates, a matrix with coordinates or an sf object POINT
#'
#' @returns an sfc object with the standard coordinates for being used in as the geojson body
#' @export
#'
#' @examples
#' get_point(c(-122.201399,47.608678))

get_point <- function(x){
  UseMethod("get_point")
}


#' @name get_point
#' @inheritParams get_point
#' @export

get_point.default <- function(x){
  stop("Points should be either numeric vectors with coordinates or sf objects")
}


#' @name get_point
#' @inheritParams get_point
#' @export

get_point.numeric <- function(x){
  if (length(x)!=2) {
    stop("Point coordinates should be a vector with two values!")
  }

  sf::st_sfc(sf::st_point(x), crs = 4326)

}


#' @name get_point
#' @inheritParams get_point
#' @export

get_point.matrix <- function(x){
  do.call(c,lapply(1:nrow(x),\(i) get_point(x[i,])))
}


#' @name get_point
#' @inheritParams get_point
#' @export

get_point.sf <- function(x){
  get_point(sf::st_geometry(x))
}


#' @name get_point
#' @inheritParams get_point
#' @export

get_point.sfc <- function(x){

  if (length(x)>1) {
    warning("Provided point contains more than one feature, taking the first one",call. = FALSE)
    x <- x[1]
  }

  if (is.na(sf::st_crs(x))){
    sf::st_set_crs(x) <- 4326
  }

  if (sf::st_crs(x)!=4326){
    x <- sf::st_transform(x,4326)
  }

  x
}
