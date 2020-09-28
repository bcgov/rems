# Copyright 2016 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#' Combine rows from different EMS data sets
#'
#' Mostly used to combine '2yr' and 'historic' data obtained through
#' \link{get_ems_data} and \link{read_historic_data}.
#'
#' @param ... the datasets you want to combine
#'
#' @return a data frame with rows of inputs combined
#' @export
#' @importFrom dplyr bind_rows
bind_ems_data <- function(...) {
  dplyr::bind_rows(...)
}

#' Simple filtering of ems data by emsid and or dates.
#'
#' @param x The ems data frame to filter
#' @param emsid A character vector of the ems id(s) of interest
#' @param parameter a character vector of parameter names
#' @param param_code a character vector of parameter codes
#' @param from_date A `Date`, `POSIXct`, `POSIXlt`, or a `character` string in a standard unambiguous format (e.g., `"YYYY/MM/DD"`)
#' @param to_date A `Date`, `POSIXct`, `POSIXlt`, or a `character` string in a standard unambiguous format (e.g., `"YYYY/MM/DD"`)
#'
#' @return A filtered data frame
#' @export
filter_ems_data <- function(x, emsid = NULL, parameter = NULL, param_code = NULL,
                            from_date = NULL, to_date = NULL) {
  # convert
  if (!is.null(from_date)) from_date <- ems_posixct(from_date)
  if (!is.null(to_date)) to_date <- ems_posixct(to_date)
  # Create the dots objects to be passed in to filter_, then remove the elements
  # didn't get passed a value, and remove names

  emsid <- pad_emsid(emsid)

  if (!is.null(emsid)) x <- x[x$EMS_ID %in% emsid, , drop = FALSE]
  if (!is.null(parameter)) x <- x[x$PARAMETER %in% parameter, , drop = FALSE]
  if (!is.null(param_code)) x <- x[x$PARAMETER_CODE %in% param_code, , drop = FALSE]
  if (!is.null(from_date)) x <- x[x$COLLECTION_START >= from_date, , drop = FALSE]
  if (!is.null(to_date)) x <- x[x$COLLECTION_START <= to_date, , drop = FALSE]

  x
}

ems_posixct <- function(x) {
  UseMethod("ems_posixct")
}

ems_posixct.default <- function(x) {
  stop("No ems_posixct method defined for objects of class '", class(x), "'",
    call. = FALSE)
}

ems_posixct.Date <- function(x) {
  ems_posixct(as.character(x))
}

ems_posixct.character <- function(x) {
  as.POSIXct(x, tz = ems_tz())
}

ems_posixct.POSIXct <- function(x) {
  attr(x, "tzone") <- ems_tz()
  x
}

ems_posixct.POSIXlt <- function(x) {
  ems_posixct(as.POSIXct(x))
}

ems_posixct.numeric <- function(x) {
  as.POSIXct(as.numeric(x), origin = "1970/01/01", tz = ems_tz())
}
