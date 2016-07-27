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
#' \code{"historic"} data? Currently only supports current as the historic
#' files are really big and need special handling that hasn't yet been implemented.
#' @return a data frame
#' @export
#'
#' @import httr
#' @import readr
#' @import storr
#' @import rappdirs
get_ems_data <- function(which = "current") {
  which <- match.arg(which, c("current", "historic"))
  if (which == "historic" && packageVersion("readr") < "0.2.2.9000") {
    stop("Only downloading current data is currently supported")
  }

  cache <- write_cache()
  if (cache$exists(which) && cache$exists("update_dates")) {
    update <- FALSE
    update_date <- cache$get("update_dates")[[which]]
    if (update_date < Sys.Date()) {
      ans <- readline(paste0("Your version of ", which, " is dated ",
                             update_date, " and there is a newer version available. Would you like to download it? (y/n)"))
      if (ans == "y") update <- TRUE
    }
  } else {
    update <- TRUE
  }

  if (update) {
    ret <- update_cache(which)
  } else {
    ret <- cache$get(which)
  }
  ret
}

update_cache <- function(which) {
  url <- get_data_url(which)
  message("Downloading latest '", which,
          "' EMS data from BC Data Catalogue (url:", url, ")")
  zipfile <- download_ems_data(url)
  data_obj <- read_ems_data(zipfile)
  cache <- write_cache()
  cache$set(which, data_obj)

  set_update_date(which)
  data_obj
}

write_cache <- function() {
  path <- rappdirs::user_data_dir("rems")
  cache <- storr::storr_rds(path, default_namespace = "rems")
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

set_update_date <- function(which, value = Sys.Date()) {
  cache <- write_cache()
  if (cache$exists("update_dates")) {
    update_dates <- cache$get("update_dates")
  } else {
    update_dates <- list()
  }
  update_dates[which] <- value

  cache$set("update_dates", update_dates)
}

#' Remove cached EMS data from your computer
#'
#' @param which which data to remove? Either \code{"current"}, \code{"historic"},
#' or \code{"all"}.
#'
#' @return NULL
#' @export
remove_data_cache <- function(which = c("all", "current", "historic")) {
  cache <- write_cache()
  if (which == "all") {
    cache$destroy()
  } else {
    cache$del(which)
    set_update_date(which, NULL)
  }

  invisible(NULL)
}
