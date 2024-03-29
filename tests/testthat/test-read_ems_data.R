context("read_ems_data")

test_that("read_ems_data works with current", {
  test <- read_ems_data("test_current.csv")
  expect_is(test, "data.frame")
  expect_equal(dim(test), c(10, 60))
  expect_equal(names(test),
    c("EMS_ID", "MONITORING_LOCATION", "LATITUDE", "LONGITUDE", "LOCATION_TYPE",
      "COLLECTION_START", "COLLECTION_END", "LOCATION_PURPOSE", "PERMIT",
      "PERMIT_RELATIONSHIP", "DISCHARGE_TO", "REQUISITION_ID", "SAMPLING_AGENCY",
      "ANALYZING_AGENCY", "COLLECTION_METHOD", "SAMPLE_CLASS", "SAMPLE_STATE",
      "SAMPLE_DESCRIPTOR", "PARAMETER_CODE", "PARAMETER", "ANALYTICAL_METHOD_CODE",
      "ANALYTICAL_METHOD", "RESULT_LETTER", "RESULT", "UNIT", "METHOD_DETECTION_LIMIT",
      "MDL_UNIT",
      "QA_INDEX_CODE", "UPPER_DEPTH", "LOWER_DEPTH", "TIDE", "AIR_FILTER_SIZE",
      "AIR_FLOW_VOLUME", "FLOW_UNIT", "COMPOSITE_ITEMS", "CONTINUOUS_AVERAGE",
      "CONTINUOUS_MAXIMUM", "CONTINUOUS_MINIMUM", "CONTINUOUS_UNIT_CODE",
      "CONTINUOUS_DURATION", "CONTINUOUS_DURATION_UNIT", "CONTINUOUS_DATA_POINTS",
      "TISSUE_TYPE", "SAMPLE_SPECIES", "SEX", "LIFE_STAGE", "BIO_SAMPLE_VOLUME",
      "VOLUME_UNIT", "BIO_SAMPLE_AREA", "AREA_UNIT", "BIO_SIZE_FROM",
      "BIO_SIZE_TO", "SIZE_UNIT", "BIO_SAMPLE_WEIGHT", "WEIGHT_UNIT",
      "BIO_SAMPLE_WEIGHT_FROM", "BIO_SAMPLE_WEIGHT_TO", "WEIGHT_UNIT_1",
      "SPECIES", "RESULT_LIFE_STAGE"))
  expect_equal(unname(lapply(test, class)),
    list("character", "character", "numeric", "numeric", "character",
      c("POSIXct", "POSIXt"), c("POSIXct", "POSIXt"), "character",
      "character", "character", "character", "character", "character",
      "character", "character", "character", "character", "character",
      "character", "character", "character", "character", "character",
      "numeric", "character", "numeric", "character", "character", "numeric",
      "numeric", "character", "numeric", "numeric", "character",
      "numeric", "numeric", "numeric", "numeric", "character",
      "numeric", "character", "numeric", "character", "character",
      "character", "character", "numeric", "character", "numeric",
      "character", "numeric", "numeric", "character", "numeric",
      "character", "numeric", "numeric", "character", "character",
      "character"))

  expect_equal(attributes(test$COLLECTION_START)[["tzone"]], "Etc/GMT+8")
  expect_equal(attributes(test$COLLECTION_END)[["tzone"]], "Etc/GMT+8")
})

test_that("read_ems_data works with options", {
  test <- read_ems_data("test_current.csv", n = 1)
  expect_is(test, "data.frame")
  expect_equal(dim(test), c(1, 60))

  test2 <- read_ems_data("test_current.csv", cols = wq_cols())
  expect_is(test2, "data.frame")
  expect_equal(dim(test2), c(10, 24))
  expect_equal(names(test2),
    c("EMS_ID",
      "MONITORING_LOCATION",
      "LATITUDE",
      "LONGITUDE",
      "LOCATION_TYPE",
      "COLLECTION_START",
      "LOCATION_PURPOSE",
      "PERMIT",
      "REQUISITION_ID",
      "SAMPLE_CLASS",
      "SAMPLE_STATE",
      "SAMPLE_DESCRIPTOR",
      "PARAMETER_CODE",
      "PARAMETER",
      "ANALYTICAL_METHOD_CODE",
      "ANALYTICAL_METHOD",
      "RESULT_LETTER",
      "RESULT",
      "UNIT",
      "METHOD_DETECTION_LIMIT",
      "MDL_UNIT",
      "QA_INDEX_CODE",
      "UPPER_DEPTH",
      "LOWER_DEPTH"))
})

test_that("read_ems_data fails correctly", {
  expect_error(read_ems_data("test_current.csv", cols = c("foo", "bar")),
    "foo, bar not in data file")
})

test_that("col_spec and friends work", {
  expect_equal_to_reference(col_spec()$cols, "col_struct.RDS")
  expect_equal_to_reference(col_spec(wq_cols())$cols, "wq_col_str.RDS")
  expect_equal(col_spec(), col_spec(col_specs("names_only")))
})

test_that("ems_tz works", {
  expect_true(ems_tz() %in% OlsonNames())
  expect_equal(ems_tz(), "Etc/GMT+8")
})

test_that("pad_emsid works", {
  expect_equal(pad_emsid(c("E1234", "12345", "123456", "1234567", "E123456")),
    c("00E1234", "0012345", "0123456", "1234567", "E123456"))
  expect_error(pad_emsid(c("12345678", "E123456")),
    "emsid should be max 7 characters long")
})
