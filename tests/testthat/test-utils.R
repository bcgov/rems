context("sqlite")

test_that("ems_posix_numeric works with integer, integer64, numeric", {
  dt <- as.POSIXct("2018-02-05 14:35", tz = "Etc/GMT+8")
  dt_int <- as.integer(dt)
  expect_equal(ems_posix_numeric(dt_int), dt)
  dt_int64 <- bit64::as.integer64(dt_int)
  expect_equal(ems_posix_numeric(dt_int64), dt)
  dt_numeric <- as.double(dt)
  expect_equal(ems_posix_numeric(dt_numeric), dt)
})
