library(dplyr)
dbdir <- write_db_path(tempdir())

test_that("duckdb is created from a csv file", {
  expect_true(create_rems_duckdb("test_historic.csv", dbdir))
})

test_that("connecting and attaching historic duckdb works",{
  con <- connect_historic_db(dbdir)
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

withr::defer(unlink(dbdir, recursive = TRUE), teardown_env())


