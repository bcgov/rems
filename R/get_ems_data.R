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
#' This function downloads the chosen data ('historic' - 1964-2014, or '2yr' or '4yr') and imports it into your R session. It also caches the data so
#' subsequent loads are much faster - if the data in the Data Catalogue are more
#' current than that in your cache, you will be prompted to update it.
#'
#' @param which Defaults to \code{"2yr"} (past 2 years). You can also specify "4yr"
#' to get the past four years of data. If you want historic data, use the
#' \code{\link{download_historic_data}} and \code{\link{read_historic_data}} functions.
#' @param n how many rows of the data do you want to load? Defaults to all (\code{n = Inf}).
#' @param cols which subset of columns to read. Can be \code{"all"} which reads all
#' columns, \code{"wq"} (default) which returns a predefined subset of columns common
#' for water quality analysis, or a character vector of column names (see details below).
#' @param force Default \code{FALSE}. Setting to \code{TRUE} will download new data even
#' if it's not out of date on your computer.
#' @param ask should the function ask for your permission to cache data on your computer?
#' Default \code{TRUE}
#' @param dont_update should the function avoid updating the data even if there is a newer
#' version available? Default \code{FALSE}
#' @return a data frame
#' @details cols can specify any of the following column names as a character vector:
#'
#' \code{"EMS_ID", "MONITORING_LOCATION", "LATITUDE", "LONGITUDE", "LOCATION_TYPE",
#' "COLLECTION_START", "COLLECTION_END", "LOCATION_PURPOSE", "PERMIT",
#' "PERMIT_RELATIONSHIP", "DISCHARGE_TO", "REQUISITION_ID", "SAMPLING_AGENCY",
#' "ANALYZING_AGENCY", "COLLECTION_METHOD", "SAMPLE_CLASS", "SAMPLE_STATE",
#' "SAMPLE_DESCRIPTOR", "PARAMETER_CODE", "PARAMETER", "ANALYTICAL_METHOD_CODE",
#' "ANALYTICAL_METHOD", "RESULT_LETTER", "RESULT", "UNIT", "METHOD_DETECTION_LIMIT",
#' "QA_INDEX_CODE", "UPPER_DEPTH", "LOWER_DEPTH", "TIDE", "AIR_FILTER_SIZE",
#' "AIR_FLOW_VOLUME", "FLOW_UNIT", "COMPOSITE_ITEMS", "CONTINUOUS_AVERAGE",
#' "CONTINUOUS_MAXIMUM", "CONTINUOUS_MINIMUM", "CONTINUOUS_UNIT_CODE",
#' "CONTINUOUS_DURATION", "CONTINUOUS_DURATION_UNIT", "CONTINUOUS_DATA_POINTS",
#' "TISSUE_TYPE", "SAMPLE_SPECIES", "SEX", "LIFE_STAGE", "BIO_SAMPLE_VOLUME",
#' "VOLUME_UNIT", "BIO_SAMPLE_AREA", "AREA_UNIT", "BIO_SIZE_FROM",
#' "BIO_SIZE_TO", "SIZE_UNIT", "BIO_SAMPLE_WEIGHT", "WEIGHT_UNIT",
#' "BIO_SAMPLE_WEIGHT_FROM", "BIO_SAMPLE_WEIGHT_TO", "WEIGHT_UNIT_1",
#' "SPECIES", "RESULT_LIFE_STAGE"}
#'
#' The default value of \code{cols} is \code{"wq"}, which will return a data
#' frame with the following columns:
#'
#' \code{"EMS_ID", "MONITORING_LOCATION", "LATITUDE", "LONGITUDE",
#' "LOCATION_TYPE", "COLLECTION_START", "LOCATION_PURPOSE", "PERMIT",
#' "SAMPLE_CLASS", "SAMPLE_STATE", "SAMPLE_DESCRIPTOR", "PARAMETER_CODE",
#' "PARAMETER", "ANALYTICAL_METHOD_CODE", "ANALYTICAL_METHOD", "RESULT_LETTER",
#' "RESULT", "UNIT", "METHOD_DETECTION_LIMIT", "QA_INDEX_CODE", "UPPER_DEPTH",
#' "LOWER_DEPTH"}
#'
#' @export
#'
#' @import httr
#' @import readr
#' @import storr
#' @import rappdirs
get_ems_data <- function(which = "2yr", n = Inf, cols = "wq", force = FALSE, ask = TRUE, dont_update = FALSE) {
  which <- match.arg(which, c("2yr", "4yr"))

  update <- FALSE # Don't update by default
  if (force || !._remsCache_$exists(which)) {
    update <- TRUE
  } else if (._remsCache_$exists("cache_dates")) {
    cache_date <- get_cache_date(which)
    file_meta <- get_file_metadata(which)

    if (cache_date < file_meta[["server_date"]]) {
      if (dont_update) {
        update <- FALSE
        warning("There is a newer version of ", which,
                ", however you have asked not to update it by setting 'dont_update' to TRUE.")
      } else {
        ans <- readline(paste0("Your version of ", which, " is dated ",
                               cache_date, " and there is a newer version available. Would you like to download it? (y/n)"))
        if (tolower(ans) == "y") update <- TRUE
      }
    }
  }

  if (cols == "wq") {
    cols <- wq_cols()
  } else if (cols == "all") {
    cols <- col_specs("names_only")
  }

  if (update) {
    if (ask) {
      stop_for_permission(paste0("rems would like to store a copy of the ", which,
                                 " ems data at", rems_data_dir(), ". Is that okay?"))
    }
    ret <- update_cache(which = which, n = n, cols = cols)
  } else {
    message("Fetching data from cache...")
    ret <- ._remsCache_$get(which)[, cols]
  }
  add_rems_type(ret, which)
}

update_cache <- function(which, n, cols) {
  file_meta <- get_file_metadata(which)
  url <- paste0(base_url(), file_meta[["filename"]])
  message("Downloading latest '", which,
          "' EMS data from BC Data Catalogue (url: ", url, ")")
  csv_file <- download_ems_data(url)
  data_obj <- read_ems_data(csv_file, n = n, cols = NULL)

  message("Caching data on disk...")
  ._remsCache_$set(which, data_obj)
  set_cache_date(which = which, value = file_meta[["server_date"]])

  message("Loading data...")
  data_obj[, cols]
}

#' @importFrom utils unzip
#' @importFrom httr GET
#' @importFrom stringr str_extract
download_ems_data <- function(url) {
  ext <- stringr::str_extract(url, "\\.(csv|zip)$")
  tfile <- tempfile(fileext = ext)
  res <- httr::GET(url, httr::write_disk(tfile), httr_progress())
  cat("\n")
  httr::stop_for_status(res)

  if (ext == ".zip") {
    ret <- unzip(res$request$output$path, exdir = tempdir())
  } else if (ext == ".csv") {
    ret <- res$request$output$path
  }
  ret
}

#' @importFrom xml2 read_html as_list
#' @importFrom dplyr filter
get_databc_metadata <- function() {
  url <- base_url()
  html <- xml2::read_html(url)
  ## Convert xml to list and only extract the portion with the information
  res <- xml2::as_list(xml2::xml_find_first(html, "//pre"))
  res <- suppressWarnings(lapply(res, function(x) {
    url <- attr(x, "href")
    x$url <- url
    x
  }))
  res <- remove_zero_length(res[2:length(res)])
  res <- unname(unlist(res))
  res <- stringr::str_trim(res, side = "both")
  # Extract only elements with filename or dates
  res <- res[grepl("^ems_sample_results.+\\.(csv|zip)$|[0-9]{4}(-|/)[0-9]{2}(-|/)[0-9]{2}", res)]
  # Remove file size
  res <- gsub("\\s+[0-9]{1,3}(\\.[0-9]{1,})?(G|M)$", "", res)
  files_df <- data.frame(matrix(res, ncol = 2, byrow = TRUE),
                         stringsAsFactors = FALSE)
  colnames(files_df) <- c("filename", "server_date")
  # files_df$ext <- vapply(strsplit(files_df[["filename"]], "\\."), `[`, character(1), 2)
  files_df <- files_df[grepl("expanded", files_df[["filename"]]),]
  files_df$label <- ifelse(grepl("4yr", files_df[["filename"]]), "4yr",
                           ifelse(grepl("historic", files_df[["filename"]]),
                                  "historic",
                                  ifelse(grepl("results_current", files_df[["filename"]]),
                                         "2yr", "drop")))
  files_df <- files_df[files_df$label != "drop", ]
  files_df$server_date <- as.POSIXct(files_df$server_date, format = "%Y-%m-%d %R")
  files_df
}

remove_zero_length <- function(l) {
  out <- lapply(l, function(x) if (length(x) > 0) x)
  Filter(Negate(is.null), out)
}

get_file_metadata <- function(which) {
  choices <- c("2yr", "historic", "4yr")
  if (!which %in% choices) {
    stop("'which' needs to be one of: ", paste(choices, collapse = ", "),
         call. = FALSE)
  }

  all_meta <- get_databc_metadata()

  all_meta[all_meta$label == which, ]
}
