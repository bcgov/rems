context("get_ems_data")

test_that("reading metadata works", {
  skip_on_cran()
  ret <- get_databc_metadata()
  expect_is(ret, "data.frame")
  expect_equal(ncol(ret), 4)
  expect_equal(lapply(ret, class),
    list(filename = "character",
      server_date = c("POSIXct", "POSIXt"),
      label = "character",
    filetype = "character"))
  expect_false(any(duplicated(ret$filename)))

  # Test extracting for each
  expect_equal(nrow(get_file_metadata("historic")), 1L)

  expect_equal(nrow(get_file_metadata("2yr")), 1L)

  expect_equal(nrow(get_file_metadata("4yr")), 1L)

  expect_error(get_file_metadata("foo"), "'which' needs to be one of")
})

test_that("httr_progress works", {
  # Need to figure out a way to pretend in interactive mode
  expect_is(httr_progress(), "NULL")
})

test_that("making file hash works", {
  expect_equal(nchar(make_file_hash("sha1test")), 40)
})
