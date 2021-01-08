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
  if (!is.null(from_date)) from_date <- set_ems_tz(from_date)
  if (!is.null(to_date)) to_date <- set_ems_tz(to_date)
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

#' Set a date-time to the timezone used by EMS
#'
#' Sets the timezone to PST (UTC -8 hrs; Etc/GMT+8), which is what is used
#' in EMS. Does not change the clock time of the input, rather
#' forces the timezone to be UTC -8 hrs.
#'
#' @param x a date-time-like object or character string
#' in a standard unambiguous format (e.g., `"YYYY/MM/DD"`).
#'
#' @seealso [lubridate::force_tz()], [OlsonNames()]
#'
#' @return `POSIXct` in the updated timezone.
#' @export
set_ems_tz <- function(x) {
  if (is.character(x)) {
    return(as.POSIXct(x, tz = ems_tz()))
  }
  lubridate::force_tz(x, tzone = ems_tz())
}
