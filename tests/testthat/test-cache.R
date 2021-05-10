test_that("getting and setting cache date works", {
  skip_on_cran()
  skip_if_offline()

  for (w in c("2yr", "4yr", "historic")) {
  # should return a date if cache exists, otherwise -Inf
    dt <- get_cache_date(w)
    expect_type(dt, "double")
    if (is.finite(dt)) expect_true(inherits(dt, "POSIXct"))
  }

  expect_error(set_cache_date("2yr", Sys.Date()))
  tm <- Sys.time() + 1
  expect_silent(set_cache_date("2yr", tm))
  expect_equal(get_cache_date("2yr"), tm)
})

test_that("deleting cache works", {
  on.exit(cache_test_files(), add = TRUE)

  burn_it_down()
  expect_equal(._remsenv_$cache$list(), character(0))
})

test_that("deleting single file from cache works", {
  on.exit(cache_test_files("2yr"), add = TRUE)

  expect_equal(._remsenv_$cache$list(), c("2yr", "4yr", "cache_dates"))
  remove_data_cache("2yr")
  expect_equal(._remsenv_$cache$list(), c("4yr", "cache_dates"))
  expect_equal(get_cache_date("2yr"), -Inf)
})
