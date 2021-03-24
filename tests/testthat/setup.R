dbdir <- tempdir()
op <- options(rems.historic.path = dbdir, rems.cache.dir = dbdir)

cleanup <- function() {
  options(op)
  unlink(dbdir, recursive = TRUE)
}

cache_test_files <- function(which = c("2yr", "4yr")) {
  for (w in which) {
    # set cache date to future so we never run into an interactive prompt to update during tests
    file_to_cache("test_current.csv", which = w, cache_date = Sys.time() + 1)
  }
}

# re-write cache in tempdir with options
write_cache()

# Create cache with mock 2yr and 4-yr data
cache_test_files()

# Get back to original state when finished
withr::defer(cleanup(), envir = teardown_env())
