#' Is this date winter?
#'
#' Is this date winter?
#' @param x a date-time object
#' @return logical
#' @export
is_winter <- function(x){
  !dplyr::between(lubridate::month(x), 4, 9)
}

#' Get winter years component of a date-time
#'
#' Dates within 2000-10-01 -- 2001-03-31 belong to 2000/01 winter season.
#' @param x a date-time object
#' @return winter season (chr)
#' @examples
#' x <- lubridate::ymd(c("1999-10-30", "1999-01-03", "2000-10-30", "2001-01-03", "2000-09-01", "20o0-01-0l"))
#' winter_year(x)
#' @export
winter_year <- function(x){
  calendar_year <- lubridate::year(x)
  jan_feb_mar <- lubridate::month(x) < 4
  oct_nov_dec <- lubridate::month(x) > 9
  dplyr::case_when(jan_feb_mar ~ paste0(calendar_year - 1, "/", calendar_year),
                   oct_nov_dec ~ paste0(calendar_year, "/", calendar_year + 1),
                   TRUE        ~ as.character(calendar_year))
}

#' Get continuous day-of-year index
#'
#' DOY index continues to the following Jan-Feb-Mar.
#' @param x a date-time object
#' @return doy
#' @examples
#' x <- lubridate::ymd(c("1999-10-30", "1999-01-03", "2000-10-30", "2001-01-03", "2000-09-01", "20o0-01-0l"))
#' winter_doy(x)
#' @export
winter_doy <- function(x){
  jan_feb_mar <- lubridate::month(x) < 4
  is_leap_year <- lubridate::leap_year(x - lubridate::years(1))
  dplyr::if_else(jan_feb_mar,
                 lubridate::yday(x) + 365 + is_leap_year, # if(former year == leaf year) add 1 day
                 lubridate::yday(x))
}
