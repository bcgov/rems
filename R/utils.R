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

write_cache <- function() {
  path <- rems_data_dir()
  ._remsCache_ <<- storr::storr_rds(path, compress = FALSE, default_namespace = "rems")
}

rems_data_dir <- function() rappdirs::user_data_dir("rems")

#' Destroy data cache
#'
#' Use this if you are getting odd errors when trying to get data or update dates
#' from the cache
#'
#' @return TRUE
#' @noRd
burn_it_down <- function() {
  if (file.exists(rems_data_dir())) {
    ._remsCache_$destroy()
  }
  write_cache()
  invisible(TRUE)
}

httr_progress <- function() {
  if (interactive()) {
    return(httr::progress("down"))
  }
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
    burn_it_down()
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
    ._remsCache_$del(which)
  }
  set_update_date(which, value = NULL)
}

base_url <- function() {
  "https://pub.data.gov.bc.ca/datasets/949f2233-9612-4b06-92a9-903e817da659"
}

ems_posix_numeric <- function(x) {
  as.POSIXct(x, origin = "1970/01/01", tz = ems_tz())
}

write_permission <- function(question) {
  ans <- menu(choices = c("Yes", "No"), title = question)
  permission <- ans == 1L
  permission
}
