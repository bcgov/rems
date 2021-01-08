context("utils")

test_that("set_ems_tz works with all classes", {
  datestring <- "2019-11-18"
  expected <- as.POSIXct(datestring, tz = "Etc/GMT+8")
  expect_equal(set_ems_tz(datestring), expected)
  expect_equal(set_ems_tz(as.Date(datestring)), expected)
  expect_equal(set_ems_tz(expected), expected)
  expect_equal(set_ems_tz(as.POSIXlt(datestring, tz = "Etc/GMT+8")), expected)
})
