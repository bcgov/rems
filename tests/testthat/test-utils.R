context("utils")

test_that("set_ems_tz works with all classes", {
  datestring <- "2019-11-18"
  expected <- as.POSIXct(datestring, tz = "Etc/GMT+8")
  expect_equal(set_ems_tz(datestring), expected)
  expect_equal(set_ems_tz(as.Date(datestring)), expected)
  expect_equal(set_ems_tz(expected), expected)
  expect_equal(set_ems_tz(as.POSIXlt(datestring, tz = "Etc/GMT+8")), expected)
})

test_that("basic utils work", {
  expect_equal(attr(add_rems_type(list(), "2yr"), "rems_type"), "2yr")
  expect_error(add_rems_type(list(), "hello"))

  skip_on_cran()
  skip_if_offline()
  expect_equal(httr::status_code(httr::GET(base_url())), 200)
})

test_that("find_os works", {
  # This is only set on GitHub Actions
  localos <- tolower(Sys.getenv("RUNNER_OS"))
  skip_if(!nzchar(localos))

  expect_equal(find_os(), localos)
})
