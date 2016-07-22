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

#' get EMS data from BC Data Catalogue
#'
#' @param which Do you want current (past 2 years) or historic data?
#' @return a data frame
#' @export
#'
#' @import httr
#' @import readr
get_ems_data <- function(which = "current") {
  which <- match.arg(which, c("current", "historic"))
  url <- get_data_url(which)
  zipfile <- download_ems_data(url)
  read_ems_data(zipfile)
}

download_ems_data <- function(url) {
  tfile <- tempfile(fileext = ".zip")
  res <- httr::GET(url, httr::write_disk(tfile))
  httr::stop_for_status(res)
  res$request$output$path
}

get_data_url <- function(which) {
  data_urls <- c(historic = "https://pub.data.gov.bc.ca/datasets/949f2233-9612-4b06-92a9-903e817da659/ems_sample_results_historic_expanded.zip",
                 current = "https://pub.data.gov.bc.ca/datasets/949f2233-9612-4b06-92a9-903e817da659/ems_sample_results_current_expanded.zip")
  data_urls[which]
}

read_ems_data <- function(file) {
  readr::read_csv(file, col_types = col_spec(), locale = readr::locale(tz = "Etc/GMT+8"))
}

col_spec <- function() {
  readr::cols(COLLECTION_START = readr::col_datetime("%Y%m%d%H%M%S"),
              COLLECTION_END = readr::col_datetime("%Y%m%d%H%M%S"))
}
