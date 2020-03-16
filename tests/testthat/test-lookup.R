test_that("lookup creation works", {
  test <- read_ems_data("test_current.csv")
  lup <- make_lookup(test)
  expect_is(lup, "data.frame")
  expect_identical(names(lup),
    c("EMS_ID", "MONITORING_LOCATION", "PERMIT", "PARAMETER_CODE",
      "PARAMETER", "LONGITUDE", "LATITUDE", "FROM_DATE", "TO_DATE"))
  expect_identical(nrow(lup), 10L)
})
