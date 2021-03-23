dbdir <- tempdir()
op <- options(rems.historic.path = dbdir, rems.cache.dir = dbdir)

cleanup <- function() {
  options(op)
  unlink(dbdir, recursive = TRUE)
}

cache_test_files <- function(which = c("2yr", "4yr")) {
  for (w in which) {
    file_to_cache("test_current.csv", which = w, cache_date = Sys.time() + 1, n = 10)
  }
}

cache_test_files()
