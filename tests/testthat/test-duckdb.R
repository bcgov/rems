dbdir <- write_db_path(tempdir())

test_that("duckdb is created from a csv file", {
  expect_true(create_rems_duckdb("test_historic.csv", dbdir))
})

withr::defer(unlink(dbdir, recursive = TRUE), teardown_env())