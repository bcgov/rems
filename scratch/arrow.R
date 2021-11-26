library(arrow)
library(dplyr)

f <- "~/Desktop/foo.csv"
f2 <- "~/Desktop/foobar.csv"

download.file("https://github.com/bcgov/rems/raw/master/tests/testthat/test_historic.csv",
              destfile = f2)

# simple out of the box open: EMS_ID all NA
arrow::open_dataset(f, format = "csv") |>
  head() |>
  collect()


# try with setting the schema:
schema <- schema(EMS_ID = string(), MONITORING_LOCATION = string(), LATITUDE = float64(),
            LONGITUDE = float64(), LOCATION_TYPE = string(), COLLECTION_START = timestamp("s", timezone = "UTC"),
            COLLECTION_END = timestamp("s", timezone = "UTC"), LOCATION_PURPOSE = string(), PERMIT = string(),
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
arrow::open_dataset(f,
                    format = FileFormat$create("csv", timestamp_parsers = "%Y%m%d%H%M%S"),
                    schema = schema) |>
  head() |>
  collect()

# EMS_ID skip first row with and set names
ds <- arrow::open_dataset("~/Desktop/ems_hist.csv",
                    format = FileFormat$create("csv", skip_rows = 1, column_names = names(schema), timestamp_parsers = "%Y%m%d%H%M%S"),
                    schema = schema)

ems_id_summary <- ds |>
  group_by(EMS_ID) |>
  summarise(n = n()) |>
  collect()

ds |> group_by(PARAMETER_CODE) |>
  write_dataset("~/Desktop/ems_parquet/")

library(arrow)
library(dplyr)
writeLines('\xef\xbb\xbfa,b\n1,2\n', con = "testfile.csv")

read_csv_arrow("testfile.csv")
open_dataset("testfile.csv", format = "csv") |>
  collect()
