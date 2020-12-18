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

cache_exists <- function() exists("._remsCache_")

rems_data_dir <- function() rappdirs::user_data_dir("rems")

set_cache_date <- function(which, value) {
  stopifnot(cache_exists())

  if (._remsCache_$exists("cache_dates")) {
    cache_dates <- ._remsCache_$get("cache_dates")
  } else {
    cache_dates <- list()
  }
  if (!is.null(value)) value <- as.numeric(value)
  cache_dates[which] <- value # store time as a numeric value

  ._remsCache_$set("cache_dates", cache_dates)
}

#' Get the date(s) when ems data was last updated locally.
#'
#' @param which The data for which you want to check it's cache date. "2yr", "4yr", or "historic
#'
#' @return The date the data was last updated (if it exists in your cache)
#' @export
get_cache_date <- function(which) {
  stopifnot(cache_exists())

  if (!._remsCache_$exists("cache_dates")) return(-Inf)
  cache_date <- ._remsCache_$get("cache_dates")[[which]]
  if (is.null(cache_date)) return(-Inf)
  as.POSIXct(cache_date, origin = "1970/01/01") # converted numeric to POSIXct
}

#' Destroy data cache
#'
#' Use this if you are getting odd errors when trying to get data or update dates
#' from the cache
#'
#' @return TRUE
#' @noRd
burn_it_down <- function() {
  if (file.exists(rems_data_dir()) && cache_exists()) {
    ._remsCache_$destroy()
    message("Removed rems cache. Please restart R and reload rems before continuing.")
  } else {
    write_cache()
  }
  invisible(TRUE)
}

#' Remove cached EMS data from your computer
#'
#' @param which which data to remove? Either \code{"2yr"}, \code{"4yr"},
#' \code{"historic"}, or \code{"all"}.
#'
#' @return NULL
#' @export
remove_data_cache <- function(which) {
  if (!which %in% c("all", "2yr", "4yr", "historic")) {
    stop("'which' must be one of 'all', '2yr', '4yr', 'historic'")
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
      unlink(dirname(fpath), recursive = TRUE)
    }
  } else if (which %in% c("2yr", "4yr")) {
    stopifnot(cache_exists())
    ._remsCache_$del(which)
  }
  set_cache_date(which, value = NULL)
}
