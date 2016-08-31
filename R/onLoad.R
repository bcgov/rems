._remsCache_ <- NULL

.onLoad <- function(libname, pkgname) {
  ._remsCache_ <<- write_cache()
}
