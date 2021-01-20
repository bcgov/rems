context("get_ems_data")

test_that("reading metadata works", {
  skip_on_cran()
  ret <- get_databc_metadata()
  expect_is(ret, "data.frame")
  expect_equal(dim(ret), c(5, 4))
  expect_equal(lapply(ret, class),
    list(filename = "character",
      server_date = c("POSIXct", "POSIXt"),
      label = "character",
      filetype = "character"))
  expect_false(any(duplicated(ret$filename)))

  # Test extracting for each
  expect_equal(get_file_metadata("historic")[["filetype"]], "csv")
  expect_equal(get_file_metadata("historic", "zip")[["filetype"]], "zip")

  expect_equal(get_file_metadata("2yr")[["filetype"]], "csv")

  expect_equal(get_file_metadata("4yr")[["filetype"]], "csv")
  expect_equal(get_file_metadata("4yr", "zip")[["filetype"]], "zip")

  expect_error(get_file_metadata("foo"), "'which' needs to be one of")
})

test_that("httr_progress works", {
  # Need to figure out a way to pretend in interactive mode
  expect_is(httr_progress(), "NULL")
})

test_that("making file hash works", {
  expect_equal(nchar(make_file_hash("sha1test")), 40)
})

test_that("handle_zip works", {
  test_zip <- withr::local_file(tempfile(fileext = ".zip"))
  zip::zip(test_zip, "test_historic.csv")
  expect_equal(
    read_csv(handle_zip(test_zip)),
    read_csv(handle_zip("test_historic.csv"))
  )
  expect_error(handle_zip("not_zip_or_csv.txt"))
})
