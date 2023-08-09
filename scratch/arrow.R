library(arrow)
library(dplyr)
#
# f <- "~/Desktop/foo.csv"
# f2 <- "~/Desktop/foobar.csv"
#
# download.file("https://github.com/bcgov/rems/raw/master/tests/testthat/test_historic.csv",
#               destfile = f)

# simple out of the box open: EMS_ID all NA
tictoc::tic()
# try with setting the schema:
schema <- schema(EMS_ID = string(), MONITORING_LOCATION = string(), LATITUDE = float64(),
            LONGITUDE = float64(), LOCATION_TYPE = string(), COLLECTION_START = timestamp("s"),
            COLLECTION_END = timestamp("s"), LOCATION_PURPOSE = string(), PERMIT = string(),
            PERMIT_RELATIONSHIP = string(), DISCHARGE_TO = string(), REQUISITION_ID = string(),
            SAMPLING_AGENCY = string(), ANALYZING_AGENCY = string(), COLLECTION_METHOD = string(),
            SAMPLE_CLASS = string(), SAMPLE_STATE = string(), SAMPLE_DESCRIPTOR = string(),
            PARAMETER_CODE = string(), PARAMETER = string(), ANALYTICAL_METHOD_CODE = string(),
            ANALYTICAL_METHOD = string(), RESULT_LETTER = string(), RESULT = float64(),
            UNIT = string(), METHOD_DETECTION_LIMIT = float64(), MDL_UNIT = string(),
            QA_INDEX_CODE = string(), UPPER_DEPTH = float64(), LOWER_DEPTH = float64(),
            TIDE = string(), AIR_FILTER_SIZE = float64(), AIR_FLOW_VOLUME = float64(),
            FLOW_UNIT = string(), COMPOSITE_ITEMS = float64(), CONTINUOUS_AVERAGE = float64(),
            CONTINUOUS_MAXIMUM = float64(), CONTINUOUS_MINIMUM = float64(),
            CONTINUOUS_UNIT_CODE = string(), CONTINUOUS_DURATION = float64(),
            CONTINUOUS_DURATION_UNIT = string(), CONTINUOUS_DATA_POINTS = float64(),
            TISSUE_TYPE = string(), SAMPLE_SPECIES = string(), SEX = string(),
            LIFE_STAGE = string(), BIO_SAMPLE_VOLUME = float64(), VOLUME_UNIT = string(),
            BIO_SAMPLE_AREA = float64(), AREA_UNIT = string(), BIO_SIZE_FROM = float64(),
            BIO_SIZE_TO = float64(), SIZE_UNIT = string(), BIO_SAMPLE_WEIGHT = float64(),
            WEIGHT_UNIT = string(), BIO_SAMPLE_WEIGHT_FROM = float64(), BIO_SAMPLE_WEIGHT_TO = float64(),
            WEIGHT_UNIT_1 = string(), SPECIES = string(), RESULT_LIFE_STAGE = string()
)

# EMS_ID still all NA
arrow::open_csv_dataset(
  # f,
  "ems_sample_results_historic_expanded.csv",
  schema = schema,
  col_names = names(schema),
  skip = 1,
  timestamp_parsers = "%Y%m%d%H%M%S"
) |>
  # mutate(
  #   COLLECTION_START = force_tz(COLLECTION_START, "UTC"),
  #   COLLECTION_END = force_tz(COLLECTION_END, "UTC")
  # ) |>
  write_dataset(
    "~/Desktop/ems-parquet",
    format = "parquet" #,
    # partitioning = "PARAMETER_CODE"
  )
tictoc::toc()

tictoc::tic()
arrow::open_dataset("~/Desktop/ems-parquet/") |>
  mutate(
    COLLECTION_START = force_tz(COLLECTION_START, "UTC"),
    COLLECTION_END = force_tz(COLLECTION_END, "UTC")
  ) |>
  write_dataset(
    "~/Desktop/ems-parquet-2",
    format = "parquet",
    partitioning = "PARAMETER_CODE"
  )
tictoc::toc()
