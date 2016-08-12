._remsCache_ <- NULL

write_cache <- function() {
  path <- rappdirs::user_data_dir("rems")
  cache <- storr_rds2(path, compress = FALSE, default_namespace = "rems")
  cache
}

.onLoad <- function(libname, pkgname) {
  ._remsCache_ <<- write_cache()
}