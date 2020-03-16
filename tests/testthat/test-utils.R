context("utils")

test_that("ems_posix_numeric works with integer, integer64, numeric", {
  dt <- as.POSIXct("2018-02-05 14:35", tz = "Etc/GMT+8")
  dt_int <- as.integer(dt)
  expect_equal(ems_posix_numeric(dt_int), dt)
  dt_int64 <- bit64::as.integer64(dt_int)
  expect_equal(ems_posix_numeric(dt_int64), dt)
  dt_numeric <- as.double(dt)
  expect_equal(ems_posix_numeric(dt_numeric), dt)
})

test_that("ems_posixct works with all classes", {
  datestring <- "2019-11-18"
  expected <- as.POSIXct(datestring, tz = "Etc/GMT+8")
  expect_equal(ems_posixct(datestring), expected)
  expect_equal(ems_posixct(as.Date(datestring)), expected)
  expect_equal(ems_posixct(expected), expected)
  expect_equal(ems_posixct(as.POSIXct("2019-11-18 08:00:00", tz = "UTC")),
    expected)
  expect_equal(ems_posixct(as.POSIXlt(datestring, tz = "Etc/GMT+8")), expected)
  expect_equal(ems_posixct(as.POSIXlt("2019-11-18 08:00:00", tz = "UTC")),
    expected)
  expect_equal(ems_posixct(1574064000), expected)
  expect_error(ems_posixct(list()), "No ems_posixct method defined for objects of class 'list'")
})
