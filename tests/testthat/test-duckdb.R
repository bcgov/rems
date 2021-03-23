library(dplyr)

test_that("duckdb is created from a csv file", {
  expect_true(create_rems_duckdb("tests/testthat/test_historic.csv", write_db_path()))
})

test_that("connecting and attaching historic duckdb works",{
  con <- connect_historic_db(write_db_path())
  on.exit(disconnect_historic_db(con))
  tbl <- attach_historic_data(con)
  expect_s3_class(tbl, "tbl_duckdb_connection")
  collected <- collect(tbl)
  ref <- read_ems_data("test_historic.csv")
  expect_equal(dim(collected), dim(ref))
  expect_equal(names(collected), names(ref))

  # Test set_ems_tz
  expect_equal(collected %>% mutate(across(where(~ inherits(.x, "POSIXct")), set_ems_tz)),
               read_ems_data("test_historic.csv"))
})

test_that("read_historic_data works", {
  dat <- read_historic_data(emsid = "0400034", from_date = as.Date("1975-07-27"),
                     to_date = as.Date("1975-07-29"), cols = "all", check_db = FALSE)
  expect_s3_class(dat, "data.frame")
  expect_equal(dim(dat), c(2L, 60L))
  expect_equal(attributes(dat$COLLECTION_START)[["tzone"]], "Etc/GMT+8")
  expect_equal(attributes(dat$COLLECTION_END)[["tzone"]], "Etc/GMT+8")
})

test_that("removing historic works works", {
    expect_equal(._remsenv_$cache$list(), c("2yr", "4yr", "cache_dates"))
  remove_data_cache("historic")
  expect_error(connect_historic_db(write_db_path()), "Please download the historic data")
})
