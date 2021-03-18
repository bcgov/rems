dbdir <- tempdir()
op <- options(rems.historic.path = dbdir, rems.cache.dir = dbdir)

cleanup <- function() {
  options(op)
  unlink(dbdir, recursive = TRUE)
}

file_to_cache("test_current.csv", which = "2yr", cache_date = Sys.Date(), n = 10)
file_to_cache("test_current.csv", which = "4yr", cache_date = Sys.Date(), n = 10)

