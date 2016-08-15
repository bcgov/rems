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
#' @param which Defaults to \code{"current"} (past 2 years) - this is the only option available right now.
#' If you want historic data, use the \code{\link{download_historic_data}} and
#' \code{\link{read_historic_data}} functions.
#' @param n how many rows of the data do you want to load? Defaults to all (\code{n = -1}).
#' @param cols which subset of columns to read. Can be \code{"all"} which reads all
#' columns, \code{"wq"} (default) which returns a predefined subset of columns common
#' for water quality analysis, or a character vector of column names (see details below).
#' @param force Default \code{FALSE}. Setting to \code{TRUE} will download new data even
#' if it's not out of date on your computer.
#' The 'current' dataset contains about 1 million rows.
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
  which <- match.arg(which, c("current"))

  cache <- ._remsCache_

  update <- FALSE # Don't update by default
  if (force || !cache$exists(which)) {
    update <- TRUE
  } else if (cache$exists("update_dates")) {
    update_date <- get_update_date(which)
    if (update_date < Sys.Date()) {
      ans <- readline(paste0("Your version of ", which, " is dated ",
                             update_date, " and there is a newer version available. Would you like to download it? (y/n)"))
      if (tolower(ans) == "y") update <- TRUE
    }
  }

  if (cols == "wq") {
    cols <- wq_cols()
  } else if (cols == "all") {
    cols <- all_cols()
  }

  if (update) {
    ret <- update_cache(which = which, n = n, cols = cols)
  } else {
    message("Fetching data from cache...")
    ret <- cache$get(which)[, cols]
  }
  ret
}

update_cache <- function(which, n, cols) {
  cache <- ._remsCache_
  file_meta <- get_file_metadata()[which,]
  url <- paste(base_url(), file_meta[["filename"]], sep = "/")
  message("Downloading latest '", which,
          "' EMS data from BC Data Catalogue (url:", url, ")")
  csv_file <- download_ems_data(url)
  data_obj <- read_ems_data(csv_file, n = n, cols = cols)

  message("Caching data on disk...")
  cache$set(which, data_obj)
  set_update_date(which = which, value = file_meta[["date_upd"]])

  message("Loading data...")
  data_obj
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

#' @importFrom httr GET content
get_file_metadata <- function() {
  url <- base_url()
  res <- httr::GET(url)
  res_text <- httr::content(res, "text")
  res_text_split <- unlist(strsplit(res_text, "</A>(<br>){1,2}\\s*|<A HREF=\"/datasets/949f2233-9612-4b06-92a9-903e817da659/ems.+?\\.zip\">"))[2:9]
  res_text_split <- gsub("<br>\\s*|^\\s+|\\s+$", "", res_text_split)
  res_text_split <- unlist(strsplit(res_text_split, "\\s{2,}"))
  files_df <- data.frame(matrix(res_text_split, nrow = 4, byrow = TRUE))[c(2,4),]
  colnames(files_df) <- c("date_upd", "time_upd", "size", "filename")
  rownames(files_df) <- ifelse(grepl("current", files_df$filename), "current", "historic")
  files_df$date_upd <- as.Date(files_df$date_upd, format = "%m/%d/%Y")
  files_df
}

base_url <- function() {
  "https://pub.data.gov.bc.ca/datasets/949f2233-9612-4b06-92a9-903e817da659"
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
  if (which == "all") {
    remove_it("historic")
    remove_it("current")
  } else {
    remove_it(which)
  }

  invisible(NULL)
}

remove_it <- function(which) {
  if (which == "historic") {
    fpath <- write_db_path()
    if (file.exists(fpath)) {
      file.remove(write_db_path())
    }
  } else if (which == "current") {
    cache <- ._remsCache_
    cache$del(which)
  }
  lapply(c("historic", "current"), set_update_date, value = NULL)
}

set_update_date <- function(which, value) {
  cache <- ._remsCache_
  if (cache$exists("update_dates")) {
    update_dates <- cache$get("update_dates")
  } else {
    update_dates <- list()
  }
  update_dates[which] <- value

  cache$set("update_dates", update_dates)
}

#' Get the date(s) when ems data was last updated.
#'
#' @param which The data for which you want to check it's update date. "current" or "historic
#'
#' @return The date the data was last updated (if it exists in your cache)
#' @export
get_update_date <- function(which) {
  cache <- ._remsCache_
  if (!cache$exists("update_dates")) return(-Inf)
  update_date <- cache$get("update_dates")[[which]]
  if (is.null(update_date)) return(-Inf)
  as.Date(update_date, origin = "1970/01/01")
}