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
#' Mostly used to combine 'current' and 'historic' data obtained through
#' \link{get_ems_data}
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
#' @param x The ems dat frame to filter
#' @param emsid A character string of the ems id of interest
#' @param from_date A date string in a standard unambiguos format (e.g., "YYYY/MM/DD")
#' @param to_date A date string in a standard unambiguos format (e.g., "YYYY/MM/DD")
#'
#' @return A filtered data frame
#' @export
#' @importFrom dplyr filter_
filter_ems_data <- function(x, emsid = NULL, from_date = NULL, to_date = NULL) {
  # See which arguments have been given a value
  argslist <- names(as.list(match.call()))[c(-1,-2)]
  if (!is.null(from_date)) from_date <- as.POSIXct(from_date, tz = ems_tz())
  if (!is.null(to_date)) to_date <- as.POSIXct(to_date, ems_tz())
  # Create the dots objects to be passed in to filter_, then remove the elements
  # didn't get passed a value, and remove names
  dots <- list(emsid = ~EMS_ID == emsid,
               from_date = ~COLLECTION_START >= from_date,
               to_date = ~COLLECTION_END >= to_date)
  dots <- unname(dots[argslist])
  dplyr::filter_(x, .dots = dots)
}
