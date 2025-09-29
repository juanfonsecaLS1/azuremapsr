#' Create sfc Object from Coordinates or sf POINT Object
#'
#' Converts a pair of coordinates (numeric vector), a matrix of coordinates, or an sf/sfc POINT object into an sfc object for use in GeoJSON bodies.
#' Only POINT geometries are supported. The output is always in EPSG:4326.
#'
#' @param x A numeric vector of length 2, a matrix with two columns (coordinates), or an sf/sfc object of POINT type.
#' @param multiple Logical; if TRUE, allows handling of multiple features (e.g., when input is an sfc or sf object with more than one POINT). Default is FALSE.
#'
#' @return An sfc object with coordinates in EPSG:4326.
#' @export
#'
#' @examples
#' get_point(c(-122.201399, 47.608678))
#' get_point(
#'   matrix(
#'     c(-122.201399, 47.608678, -122.202, 47.609),
#'     ncol = 2,
#'     byrow = TRUE
#'   ),
#'   multiple = TRUE
#' )
#' library(sf)
#' pt <- st_sf(
#'   geometry = st_sfc(st_point(c(-122.201399, 47.608678)), crs = 4326)
#' )
#' get_point(pt)
get_point <- function(x, multiple = FALSE) {
  UseMethod("get_point")
}


#' @rdname get_point
#' @export
get_point.default <- function(x, multiple = FALSE) {
  stop("Points should be provided as a numeric vector/matrix or sf object!")
}


#' @rdname get_point
#' @export
get_point.numeric <- function(x, multiple = FALSE) {
  if (length(x) != 2) {
    stop("Point coordinates must be a vector with two values!")
  }
  sf::st_sfc(sf::st_point(x), crs = 4326)
}


#' @rdname get_point
#' @export
get_point.matrix <- function(x, multiple = FALSE) {
  if (ncol(x) != 2) {
    stop("Matrix with coordinates must have two columns!")
  }

  if (!multiple && nrow(x) > 1) {
    warning(
      "Provided matrix contains more than one row, taking the first row",
      call. = FALSE
    )
    x <- x[1, , drop = FALSE]
  }

  do.call(c, lapply(1:nrow(x), function(i) get_point(x[i, ])))
}


#' @rdname get_point
#' @export
get_point.sf <- function(x, multiple = FALSE) {
  get_point(sf::st_geometry(x), multiple = multiple)
}


#' @rdname get_point
#' @export
get_point.sfc <- function(x, multiple = FALSE) {
  if (!multiple && length(x) > 1) {
    warning(
      "Provided point contains more than one feature, taking the first one",
      call. = FALSE
    )
    x <- x[1]
  }

  if (is.na(sf::st_crs(x))) {
    sf::st_crs(x) <- 4326
  }

  if (sf::st_crs(x) != 4326) {
    x <- sf::st_transform(x, 4326)
  }

  x
}
