context("get_ems_data")

test_that("read_ems_data works", {
  test <- read_ems_data("current_expanded_test.csv")
  expect_is(test, "data.frame")
  expect_length(dim(test), c(4,55))
  expect_equal(names(test),
               c("EMS_ID", "MONITORING_LOCATION", "LATITUDE", "LONGITUDE", "LOCATION_TYPE",
                 "COLLECTION_START", "COLLECTION_END", "REQUISITION_ID", "SAMPLING_AGENCY",
                 "ANALYZING_AGENCY", "COLLECTION_METHOD", "SAMPLE_CLASS", "SAMPLE_STATE",
                 "SAMPLE_DESCRIPTOR", "PARAMETER_CODE", "PARAMETER", "ANALYTICAL_METHOD_CODE",
                 "ANALYTICAL_METHOD", "RESULT_LETTER", "RESULT", "UNIT", "METHOD_DETECTION_LIMIT",
                 "QA_INDEX_CODE", "UPPER_DEPTH", "LOWER_DEPTH", "TIDE", "AIR_FILTER_SIZE",
                 "AIR_FLOW_VOLUME", "FLOW_UNIT", "COMPOSITE_ITEMS", "CONTINUOUS_AVERAGE",
                 "CONTINUOUS_MAXIMUM", "CONTINUOUS_MINIMUM", "CONTINUOUS_UNIT_CODE",
                 "CONTINUOUS_DURATION", "CONTINUOUS_DURATION_UNIT", "CONTINUOUS_DATA_POINTS",
                 "TISSUE_TYPE", "SAMPLE_SPECIES", "SEX", "LIFE_STAGE", "BIO_SAMPLE_VOLUME",
                 "VOLUME_UNIT", "BIO_SAMPLE_AREA", "AREA_UNIT", "BIO_SIZE_FROM",
                 "BIO_SIZE_TO", "SIZE_UNIT", "BIO_SAMPLE_WEIGHT", "WEIGHT_UNIT",
                 "BIO_SAMPLE_WEIGHT_FROM", "BIO_SAMPLE_WEIGHT_TO", "WEIGHT_UNIT_1",
                 "SPECIES", "RESULT_LIFE_STAGE"))
})
