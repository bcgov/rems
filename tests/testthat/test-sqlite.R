library(dplyr)
dbdir <- tempdir()

test_that("duckdb is created from a csv file", {
  expect_true(save_historic_data("test_historic.csv", write_db_path(dbdir), n = 3))
})

test_that("connecting and attaching historic duckdb works",{
  con <- connect_historic_db(write_db_path(dbdir))
  on.exit(disconnect_historic_db(con))
  tbl <- attach_historic_data(con)
  expect_s3_class(tbl, "tbl_SQLiteConnection")
  collected <- collect(tbl)
  ref <- read_ems_data("test_historic.csv")
  expect_equal(dim(collected), dim(ref))
  expect_equal(names(collected), names(ref))
})

test_that("read_historic_data works", {
  withr::local_options(list(rems.historic.path = dbdir))
  dat <- read_historic_data(emsid = "0400034", from_date = as.Date("1975-07-27"),
                            to_date = as.Date("1975-07-29"), check_db = FALSE)
  expect_s3_class(dat, "data.frame")
  expect_equal(nrow(dat), 2L)
})

withr::defer(unlink(dbdir, recursive = TRUE), teardown_env())