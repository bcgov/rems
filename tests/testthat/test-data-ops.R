test_that("filter_ems_data works", {
  d <- read_ems_data("test_current.csv")

  expect_known_value(
    filter_ems_data(d, emsid = "0121580", param_code = "0002",
                    from_date = "2018-01-01", req_id = "L2040722"),
    "filter-test1.rds"
  )

  d2 <- read_ems_data("test_historic.csv")
  expect_known_value(
    filter_ems_data(d2, emsid = c("0400203", "0400340", "0400341"),
                    to_date = as.Date("1982-01-01"),
                    parameter = c("Nitrogen NO3 Total", "Oxygen Dissolved"),
                    req_id = c("Q015047W", NA)),
    "filter-test2.rds"
  )
})
