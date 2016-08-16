._remsCache_ <- NULL

write_cache <- function() {
  path <- rappdirs::user_data_dir("rems")
  cache <- storr::storr_rds(path, compress = FALSE, default_namespace = "rems")
  cache
}

.onLoad <- function(libname, pkgname) {
  ._remsCache_ <<- write_cache()
}

#' Destroy data cache
#'
#' Use this if you are getting odd errors when trying to get data or update dates
#' from the cache
#'
#' @return TRUE
#' @export
burn_it_down <- function() {
  if (file.exists(rappdirs::user_data_dir("rems"))) {
    ._remsCache_$destroy()
  }
  ._remsCache_ <<- write_cache()
  invisible(TRUE)
}
