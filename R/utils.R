write_cache <- function() {
  path <- rappdirs::user_data_dir("rems")
  cache <- storr::storr_rds(path, compress = FALSE, default_namespace = "rems")
  cache
}

#' Destroy data cache
#'
#' Use this if you are getting odd errors when trying to get data or update dates
#' from the cache
#'
#' @return TRUE
#' @noRd
burn_it_down <- function() {
  if (file.exists(rappdirs::user_data_dir("rems"))) {
    ._remsCache_$destroy()
  }
  unlockBinding("._remsCache_", getNamespace("rems"))
  ._remsCache_ <<- write_cache()
  lockBinding("._remsCache_", getNamespace("rems"))
  invisbile(TRUE)
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
    cache <- ._remsCache_
    cache$del(which)
  }
  set_update_date(which, value = NULL)
}

base_url <- function() {
  "https://pub.data.gov.bc.ca/datasets/949f2233-9612-4b06-92a9-903e817da659"
}

ems_posix_numeric <- function(x) {
  as.POSIXct(x, origin = "1970/01/01", tz = ems_tz())
}
