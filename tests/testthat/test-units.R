test_that("convert_unit_values works", {
  expect_equal(convert_unit_values(1, "mg/L", "ug/L"), 1000)
  expect_equal(convert_unit_values(NA_real_, "mg/L", "ug/L"), NA_real_)
  expect_equal(convert_unit_values(1, NA_character_, "ug/L"), NA_real_)
  expect_equal(convert_unit_values(1, "mg/L", NA_character_), NA_real_)
  expect_equal(convert_unit_values(1, "E3m3", "L"), 1e6)
})

test_that("convert_unit_values fails and warns correctly", {
  expect_warning(convert_unit_values(1, "mg/L", "foo"))
  expect_warning(convert_unit_values(1, "foo", "ug/L"))
  expect_equal(suppressWarnings(convert_unit_values(1, "mg/L", "foo")), NA_real_)
  expect_equal(suppressWarnings(convert_unit_values(1, "foo", "ug/L")), NA_real_)
  expect_error(convert_unit_values(1:2, c("mg/L", "mg/L"), c("ug/L", "ug/L")))
})

test_that("clean_units works", {
  expect_equal(
    clean_unit(c("ppm A", "mg/L wet", "ppm W", "% (V/V)",
                 "% V/V", "% (Mortality)", "% Mortality",
                 "% (W/W)", "% W/W", "N/A")),
    c("ppm", "mg/L", "ppm", rep("%", 6),
      NA_character_)
  )
})

test_that("standardize_mdl_unit works", {
  testdata <- data.frame(
    UNIT = c("mg/L", "mg/L", "ug/g", "g/m2", "m3/d", "ug/m3",
             "t/d", "m3/min A", "m3/d", "mg/L", "ug/g", "%"),
    MDL_UNIT = c("ug/L", "ug/L", "mg/kg", "mg/m2", "E3m3/d",
                 "mg/m3", "kg/d", "m3/s A", "m3/min W",
                 "ng/L", "mg/L", "ppm (S)"),
    METHOD_DETECTION_LIMIT = c(NA_real_, rep(1, 11)))

  expect_warning(out <- standardize_mdl_units(testdata), "Could not convert")

  expect_equal(
    out$METHOD_DETECTION_LIMIT,
    c(NA_real_, 0.001, 1, 0.001, 1000, 1000, 0.001, 60, 1440,
      1e-06, 1, 1)
  )

  expect_equal(
    out$MDL_UNIT,
    c("ug/L", "mg/L", "ug/g", "g/m2", "m3/d", "ug/m3",
      "t/d", "m3/min A", "m3/d", "mg/L", "mg/L", "ppm (S)")
  )
})
