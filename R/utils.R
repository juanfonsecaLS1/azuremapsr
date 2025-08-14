pkg.env <- new.env(parent = emptyenv())

pkg.env$template_params_directions <- list(
  arriveAt = list(values = lubridate::as_datetime("2020-01-01 10:30:00"),
                  required = FALSE,
                  multiple = FALSE),

  avoid = list(
    values = c(
      "limitedAccessHighways",
      "tollRoads",
      "ferries",
      "tunnels",
      "borderCrossings",
      "lowEmissionZones",
      "unpavedRoads"
    ),
    required = FALSE,
    multiple = TRUE
  ),

  departAt = list(values = lubridate::as_datetime("2020-01-01 10:30:00"),
                  required = FALSE,
                  multiple = FALSE),

  heading = list(values = 0:364,
                 required = FALSE,
                 multiple = FALSE),

  maxRouteCount = list(values = 1:6,
                       required = TRUE,
                       multiple = FALSE),

  optimizeRoute = list(
    values = c(
      "fastestWithoutTraffic",
      "shortest",
      "fastestAvoidClosureWithoutTraffic",
      "fastestWithTraffic"
    ),
    required = FALSE,
    multiple = FALSE
  ),

  optimizeWaypointOrder = list(values = c(FALSE, TRUE),
                               required = FALSE,
                               multiple = FALSE),

  routeOutputOptions = list(
    values = c("routeSummary", "routePath", "itinerary"),
    required = TRUE,
    multiple = TRUE
  ),

  travelMode = list(
    values = c("driving", "truck", "walking"),
    required = TRUE,
    multiple = FALSE
  )
  # vehicleSpec = list(values = NULL, required = FALSE, multiple = FALSE)
)

#' check conformity of parameters for JSON section
#'
#' @param test_params list of parameters from input
#' @param template_params list of parameters hardcoded in package
#' @param tz timezone from input
#'
#' @export
#'
#' @returns NULL
#'
#' @examples
#' \dontrun{
#' check_params(params,template_params,"UTC")
#' }

check_params <- function(test_params, template_params,tz){

  if (sum(duplicated(names(test_params)))>0){
    dupl_names <- unique(names(test_params)[duplicated(names(test_params))])
    stop("There are some duplicated names in params",
         paste(dupl_names,collapse = ", "),call. = FALSE)
  }

  if (!all(names(test_params) %in% names(template_params))){
    different_names <- names(test_params)[!(names(test_params) %in% names(template_params))]
    stop("Elements in the params list do not match allowed arguments:",
         paste(different_names,collapse = ", "),call. = FALSE)
  }

  check_classes <- vapply(
    names(test_params), function(i) {
      # check type
      template_class <- class(template_params[[i]]$value)

      if (template_class == "integer") {
        test_params[[i]] <- as.integer(test_params[[i]], quiet = T)
      }

      if (any(template_class == "POSIXct")) {
        test_params[[i]] <- lubridate::as_datetime(test_params[[i]], quiet = T)
      }

      input_class <- class(test_params[[i]])
      template_class == input_class
    }, logical(1))

  # Stop if any is false
  if (any(!check_classes)) {
    stop(
      "The class of at least one parameter is not valid.\nCheck: ",
      paste(names(test_params)[!check_classes], collapse = ", "),
      call. = FALSE
    )
  }

  check_values <- vapply(
    names(test_params), function(i) {
      # check type
      template_class <- class(template_params[[i]]$value)
      logical_multiple <- template_params[[i]]$multiple

      if (template_class == "integer") {
        test_params[[i]] <- as.integer(test_params[[i]], quiet = T)
      }

      if (any(template_class == "POSIXct")) {
        test_params[[i]] <- lubridate::as_datetime(test_params[[i]],
                                                   quiet = T,
                                                   tz = tz)

        test_params[[i]] <- lubridate::with_tz(test_params[[i]],"UTC")

        std_time <- lubridate::with_tz(Sys.time(),"UTC")

        future_check <- std_time < test_params[[i]]
        check_match <- !is.na(test_params[[i]]) & future_check

      } else {
        if (logical_multiple) {
          check_match <- all(test_params[[i]] %in% template_params[[i]]$value)
        } else {
          check_match <- (length(test_params[[i]]) == 1) &
            (test_params[[i]] %in% template_params[[i]]$value)
        }

      }

      check_match

    }, logical(1))

  # Stop if any is false
  if (any(!check_classes)) {
    stop(
      "The value of at least one parameter is not valid.\nCheck: ",
      paste(names(test_params)[!check_classes], collapse = ", "),
      call. = FALSE
    )
  }

  if(sum(c("departAt","arriveAt") %in% names(test_params))>1){
    stop("departAt  and arriveAt cannot be provided at the same time")
  }

  return(NULL)

}
