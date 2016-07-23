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
#' @param which Do you want "current" (past 2 years; default) or "historic" data?
#'  Currently only supports current as the historic files are really big and
#'  need special handling that hasn't been implemented yet
#' @return a data frame
#' @export
#'
#' @import httr
#' @import readr
#' @import storr
#' @import rappdirs
get_ems_data <- function(which = "current") {
  which <- match.arg(which, c("current", "historic"))
  if (which == "historic") {
    stop("Only downloading current data is currently supported")
  }

  cache <- write_cache()
  if (cache$exists(which) && cache$exists("update_dates")) {
      update_date <- cache$get("update_dates")[[which]]
      update_which <- "n"
      if (update_date < Sys.Date()) {
        update_which <- readline(paste0("Your version of ", which, " is dated ",
                                        update_date, " and there is a newer version available. Would you like to download it? (y/n)"))
        if (update_which == "y") {
          update_cache(which)
        }
      }
  } else {
    update_cache(which)
  }

  cache$get(which)
}

update_cache <- function(which) {
  url <- get_data_url(which)
  message("Downloading latest '", which,
          "' EMS data from BC Data Catalogue (url:", url, ")")
  zipfile <- download_ems_data(url)
  data_obj <- read_ems_data(zipfile)
  cache <- write_cache()
  cache$set(which, data_obj)

  if (cache$exists("update_dates")) {
    update_dates <- cache$get(update_dates)
  } else {
    update_dates <- list()
  }
  update_dates[which] <- Sys.Date()

  cache$set("update_dates", update_dates)
  return(invisible(NULL))
}

write_cache <- function() {
  path <- rappdirs::user_data_dir("rems")
  cache <- storr::storr_rds(path, mangle_key = TRUE, default_namespace = "rems")
  cache
}

download_ems_data <- function(url) {
  tfile <- tempfile(fileext = ".zip")
  res <- httr::GET(url, httr::write_disk(tfile), httr::progress("down"))
  cat("\n")
  httr::stop_for_status(res)
  res$request$output$path
}

get_data_url <- function(which) {
  data_urls <- c(historic = "https://pub.data.gov.bc.ca/datasets/949f2233-9612-4b06-92a9-903e817da659/ems_sample_results_historic_expanded.zip",
                 current = "https://pub.data.gov.bc.ca/datasets/949f2233-9612-4b06-92a9-903e817da659/ems_sample_results_current_expanded.zip")
  data_urls[which]
}

read_ems_data <- function(file) {
  message("Reading data from file...")
  readr::read_csv(file, col_types = col_spec(), locale = readr::locale(tz = "Etc/GMT+8"))
}

col_spec <- function() {
  readr::cols(COLLECTION_START = readr::col_datetime("%Y%m%d%H%M%S"),
              COLLECTION_END = readr::col_datetime("%Y%m%d%H%M%S"))
}

#' Remove cached EMS data from your computer
#'
#' @return NULL
#' @export
remove_data_cache <- function() {
  cache <- write_cache()
  cache$destroy()
  invisible(NULL)
}
