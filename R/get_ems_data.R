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
#' EMS data are distributed through the \href{https://catalogue.data.gov.bc.ca/dataset/bc-environmental-monitoring-system-results}{BC Data Catalogue}
#' under the \href{http://www.data.gov.bc.ca/local/dbc/docs/license/OGL-vbc2.0.pdf}{Open Government License - British Columbia}.
#' This function downloads the chosen data ('historic' - 1964-2014, or 'current'
#' - 2015 to now) and imports it into your R session. It also caches the data so
#' subsequent loads are much faster - if the data in the Data Catalogue are more
#' current than that in your cache, you will be prompted to update it.
#'
#' @param which Do you want \code{"current"} (past 2 years; default) or
#' \code{"historic"} data?
#' @param n how many rows of the data do you want to load? Defaults to all (\code{n = -1}).
#' @param cols which subset of columns to read. Can be \code{"all"} which reads all
#' columns, \code{"wq"} (default) which returns a predefined subset of columns common
#' for water quality analysis, or a character vector of column names (see details below).
#' @param force Default \code{FALSE}. Setting to \code{TRUE} will download new data even
#' if it's not out of date on your computer.
#' The 'current' dataset contains about 1 million rows, and the historic dataset contains about 10 million.
#' @return a data frame
#' @details cols can specify any of the following column names as a character vector:
#'
#' \code{"EMS_ID", "MONITORING_LOCATION", "LATITUDE", "LONGITUDE",
#' "LOCATION_TYPE", "COLLECTION_START", "COLLECTION_END", "REQUISITION_ID",
#' "SAMPLING_AGENCY", "ANALYZING_AGENCY", "COLLECTION_METHOD",
#' "SAMPLE_CLASS", "SAMPLE_STATE", "SAMPLE_DESCRIPTOR", "PARAMETER_CODE",
#' "PARAMETER", "ANALYTICAL_METHOD_CODE", "ANALYTICAL_METHOD", "RESULT_LETTER",
#' "RESULT", "UNIT", "METHOD_DETECTION_LIMIT", "QA_INDEX_CODE", "UPPER_DEPTH",
#' "LOWER_DEPTH", "TIDE", "AIR_FILTER_SIZE", "AIR_FLOW_VOLUME", "FLOW_UNIT",
#' "COMPOSITE_ITEMS", "CONTINUOUS_AVERAGE", "CONTINUOUS_MAXIMUM",
#' "CONTINUOUS_MINIMUM", "CONTINUOUS_UNIT_CODE", "CONTINUOUS_DURATION",
#' "CONTINUOUS_DURATION_UNIT", "CONTINUOUS_DATA_POINTS", "TISSUE_TYPE",
#' "SAMPLE_SPECIES", "SEX", "LIFE_STAGE", "BIO_SAMPLE_VOLUME", "VOLUME_UNIT",
#' "BIO_SAMPLE_AREA", "AREA_UNIT", "BIO_SIZE_FROM", "BIO_SIZE_TO", "SIZE_UNIT",
#' "BIO_SAMPLE_WEIGHT", "WEIGHT_UNIT", "BIO_SAMPLE_WEIGHT_FROM",
#' "BIO_SAMPLE_WEIGHT_TO", "WEIGHT_UNIT_1", "SPECIES", "RESULT_LIFE_STAGE"}
#'
#' The default value of \code{cols} is \code{"wq"}, which will return a data
#' frame with the following columns:
#'
#' \code{"EMS_ID", "MONITORING_LOCATION", "LATITUDE", "LONGITUDE",
#' "LOCATION_TYPE", "COLLECTION_START", "PARAMETER_CODE", "PARAMETER",
#' "ANALYTICAL_METHOD_CODE", "ANALYTICAL_METHOD", "RESULT_LETTER", "RESULT",
#' "UNIT", "METHOD_DETECTION_LIMIT", "QA_INDEX_CODE", "UPPER_DEPTH", "LOWER_DEPTH"}
#'
#' @export
#'
#' @import httr
#' @import readr
#' @import storr
#' @import rappdirs
get_ems_data <- function(which = "current", n = -1, cols = "wq", force = FALSE) {
  which <- match.arg(which, c("current", "historic"))

  cache <- write_cache()

  update <- FALSE # Don't update by default
  if (force || !cache$exists(which)) {
    update <- TRUE
  } else if (cache$exists("update_dates")) {
    update_date <- cache$get("update_dates")[[which]]
    if (update_date < Sys.Date()) {
      ans <- readline(paste0("Your version of ", which, " is dated ",
                             update_date, " and there is a newer version available. Would you like to download it? (y/n)"))
      if (tolower(ans) == "y") update <- TRUE
    }
  }

  if (update) {
    ret <- update_cache(cache, which = which, n = n, cols = cols)
  } else {
    message("Fetching data from cache...")
    ret <- cache$get(which)[cols]
  }
  ret
}

update_cache <- function(cache, which, n, cols) {
  url <- get_data_url(which)
  message("Downloading latest '", which,
          "' EMS data from BC Data Catalogue (url:", url, ")")
  csv_file <- download_ems_data(url)
  data_obj <- read_ems_data(csv_file, n = n, cols = cols)

  message("Caching data on disk...")
  cache$set(which, data_obj)

  set_update_date(cache, which)
  message("Loading data...")
  data_obj
}

write_cache <- function() {
  path <- rappdirs::user_data_dir("rems")
  cache <- storr_rds2(path, compress = TRUE, default_namespace = "rems")
  cache
}

#' @importFrom utils unzip
download_ems_data <- function(url) {
  tfile <- tempfile(fileext = ".zip")
  csvdir <- tempdir()
  res <- httr::GET(url, httr::write_disk(tfile), httr_progress())
  cat("\n")
  httr::stop_for_status(res)
  unzip(res$request$output$path, exdir = csvdir)
}

httr_progress <- function() {
  if (interactive()) {
    return(httr::progress("down"))
  }
}

get_data_url <- function(which) {
  data_urls <- c(historic = "https://pub.data.gov.bc.ca/datasets/949f2233-9612-4b06-92a9-903e817da659/ems_sample_results_historic_expanded.zip",
                 current = "https://pub.data.gov.bc.ca/datasets/949f2233-9612-4b06-92a9-903e817da659/ems_sample_results_current_expanded.zip")
  data_urls[which]
}

#' Remove cached EMS data from your computer
#'
#' @param which which data to remove? Either \code{"current"}, \code{"historic"},
#' or \code{"all"}.
#'
#' @return NULL
#' @export
remove_data_cache <- function(which) {
  if (!which %in% c("all", "current", "historic")) {
    stop("'which' must be one of 'all', 'current', 'historic'")
  }
  message("Removing ", which, " data from your local cache...")
  cache <- write_cache()
  if (which == "all") {
    cache$destroy()
  } else {
    cache$del(which)
    set_update_date(cache, which, NULL)
  }

  invisible(NULL)
}

set_update_date <- function(cache, which, value = Sys.Date()) {
  if (cache$exists("update_dates")) {
    update_dates <- cache$get("update_dates")
  } else {
    update_dates <- list()
  }
  update_dates[which] <- value

  cache$set("update_dates", update_dates)
}