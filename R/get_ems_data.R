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
#' @param n how many rows of the data do you want to load? Defaults to all (\code{n = Inf}).
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
get_ems_data <- function(which = "current", n = Inf, cols = "wq", force = FALSE) {
  which <- match.arg(which, c("current"))

  update <- FALSE # Don't update by default
  if (force || !._remsCache_$exists(which)) {
    update <- TRUE
  } else if (._remsCache_$exists("update_dates")) {
    update_date <- get_update_date(which)
    if (update_date > Sys.time()) {
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
    permission <- write_permission(paste0("rems would like to store a copy of the current ems data at",
                                          rems_data_dir(), ". Is that okay?"))

    if (!permission) stop("Permission denied. Exiting", call. = FALSE)
    ret <- update_cache(which = which, n = n, cols = cols)
  } else {
    message("Fetching data from cache...")
    ret <- ._remsCache_$get(which)[, cols]
  }
  ret
}

update_cache <- function(which, n, cols) {
  file_meta <- get_file_metadata()[which,]
  url <- paste(base_url(), file_meta[["filename"]], sep = "/")
  message("Downloading latest '", which,
          "' EMS data from BC Data Catalogue (url:", url, ")")
  csv_file <- download_ems_data(url)
  data_obj <- read_ems_data(csv_file, n = n, cols = NULL)

  message("Caching data on disk...")
  ._remsCache_$set(which, data_obj)
  set_update_date(which = which, value = file_meta[["date_upd"]])

  message("Loading data...")
  data_obj[, cols]
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



#' @importFrom httr GET content
get_file_metadata <- function() {
  url <- base_url()
  res <- httr::GET(url)
  res_text <- httr::content(res, "text")
  res_text_split <- unlist(strsplit(res_text, "</A>(<br>){1,2}\\s*|<A HREF=\"/datasets/949f2233-9612-4b06-92a9-903e817da659/ems.+?\\.zip\">"))
  res_text_split <- res_text_split[2:(length(res_text_split) - 1)]
  res_text_split <- gsub("<br>\\s*|^\\s+|\\s+$", "", res_text_split)
  res_text_split <- unlist(strsplit(res_text_split, "\\s{3,}"))
  files_df <- data.frame(matrix(res_text_split, ncol = 3, byrow = TRUE))
  colnames(files_df) <- c("date_upd", "size", "filename")
  files_df <- files_df[grepl("expanded", files_df[[3]]), ]
  rownames(files_df) <- ifelse(grepl("\\d.+_current", files_df$filename), "3yr_current", ifelse(grepl("current", files_df$filename), "current", "historic"))
  files_df$date_upd <- strptime(files_df$date_upd, format = "%m/%d/%Y %R %p")
  files_df
}

set_update_date <- function(which, value) {
  if (._remsCache_$exists("update_dates")) {
    update_dates <- ._remsCache_$get("update_dates")
  } else {
    update_dates <- list()
  }
  if (!is.null(value)) value <- as.numeric(value)
  update_dates[which] <- value # store time as a numeric value

  ._remsCache_$set("update_dates", update_dates)
}

#' Get the date(s) when ems data was last updated.
#'
#' @param which The data for which you want to check it's update date. "current" or "historic
#'
#' @return The date the data was last updated (if it exists in your cache)
#' @export
get_update_date <- function(which) {
  if (!._remsCache_$exists("update_dates")) return(-Inf)
  update_date <- ._remsCache_$get("update_dates")[[which]]
  if (is.null(update_date)) return(-Inf)
  as.POSIXct(update_date, origin = "1970/01/01") # converted numeric to POSIXct
}