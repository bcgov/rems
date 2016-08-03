# Copyright 2016 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#' @importFrom tibble as_tibble
read_ems_data <- function(file, n, cols) {
  message("Reading data from file...")

  ret <- readr::read_csv(file, col_types = col_spec(cols), n_max = n,
                  locale = readr::locale(tz = ems_tz()))
  tibble::as_tibble(ret)
}

col_spec <- function(subset = NULL) {
  spec <- readr::cols_only(EMS_ID = "c"
              , MONITORING_LOCATION = "c"
              , LONGITUDE = "d"
              , LATITUDE = "d"
              , LOCATION_TYPE = "c"
              , COLLECTION_START = readr::col_datetime("%Y%m%d%H%M%S")
              , COLLECTION_END = readr::col_datetime("%Y%m%d%H%M%S")
              , REQUISITION_ID = "c"
              , SAMPLING_AGENCY = "c"
              , ANALYZING_AGENCY = "c"
              , COLLECTION_METHOD = "c"
              , SAMPLE_CLASS = "c"
              , SAMPLE_STATE = "c"
              , SAMPLE_DESCRIPTOR = "c"
              , PARAMETER_CODE = "c"
              , PARAMETER = "c"
              , ANALYTICAL_METHOD_CODE = "c"
              , ANALYTICAL_METHOD = "c"
              , RESULT_LETTER = "c"
              , RESULT = "d"
              , UNIT = "c"
              , METHOD_DETECTION_LIMIT = "d"
              , QA_INDEX_CODE = "c"
              , UPPER_DEPTH = "d"
              , LOWER_DEPTH = "d"
              , TIDE = "c"
              , AIR_FILTER_SIZE = "d"
              , AIR_FLOW_VOLUME = "d"
              , FLOW_UNIT = "c"
              , COMPOSITE_ITEMS = "d"
              , CONTINUOUS_AVERAGE = "d"
              , CONTINUOUS_MAXIMUM = "d"
              , CONTINUOUS_MINIMUM = "d"
              , CONTINUOUS_UNIT_CODE = "c"
              , CONTINUOUS_DURATION = "d"
              , CONTINUOUS_DURATION_UNIT = "c"
              , CONTINUOUS_DATA_POINTS = "d"
              , TISSUE_TYPE = "c"
              , SAMPLE_SPECIES = "c"
              , SEX = "c"
              , LIFE_STAGE = "c"
              , BIO_SAMPLE_VOLUME = "d"
              , VOLUME_UNIT = "c"
              , BIO_SAMPLE_AREA = "d"
              , AREA_UNIT = "c"
              , BIO_SIZE_FROM = "d"
              , BIO_SIZE_TO = "d"
              , SIZE_UNIT = "c"
              , BIO_SAMPLE_WEIGHT = "d"
              , WEIGHT_UNIT = "c"
              , BIO_SAMPLE_WEIGHT_FROM = "d"
              , BIO_SAMPLE_WEIGHT_TO = "d"
              , WEIGHT_UNIT_1 = "c"
              , SPECIES = "c"
              , RESULT_LIFE_STAGE = "c")
  if (!is.null(subset)) {
    spec$cols <- spec$cols[subset]
  }
  spec
}

wq_cols <- function() {
  c("EMS_ID"
    , "MONITORING_LOCATION"
    , "LONGITUDE"
    , "LATITUDE"
    , "LOCATION_TYPE"
    , "COLLECTION_START"
    , "PARAMETER_CODE"
    , "PARAMETER"
    , "ANALYTICAL_METHOD_CODE"
    , "ANALYTICAL_METHOD"
    , "RESULT_LETTER"
    , "RESULT"
    , "UNIT"
    , "METHOD_DETECTION_LIMIT"
    , "QA_INDEX_CODE"
    , "UPPER_DEPTH"
    , "LOWER_DEPTH")
}

all_cols <- function() {
  c("EMS_ID", "MONITORING_LOCATION", "LATITUDE", "LONGITUDE",
    "LOCATION_TYPE", "COLLECTION_START", "COLLECTION_END", "REQUISITION_ID",
    "SAMPLING_AGENCY", "ANALYZING_AGENCY", "COLLECTION_METHOD",
    "SAMPLE_CLASS", "SAMPLE_STATE", "SAMPLE_DESCRIPTOR", "PARAMETER_CODE",
    "PARAMETER", "ANALYTICAL_METHOD_CODE", "ANALYTICAL_METHOD", "RESULT_LETTER",
    "RESULT", "UNIT", "METHOD_DETECTION_LIMIT", "QA_INDEX_CODE", "UPPER_DEPTH",
    "LOWER_DEPTH", "TIDE", "AIR_FILTER_SIZE", "AIR_FLOW_VOLUME", "FLOW_UNIT",
    "COMPOSITE_ITEMS", "CONTINUOUS_AVERAGE", "CONTINUOUS_MAXIMUM",
    "CONTINUOUS_MINIMUM", "CONTINUOUS_UNIT_CODE", "CONTINUOUS_DURATION",
    "CONTINUOUS_DURATION_UNIT", "CONTINUOUS_DATA_POINTS", "TISSUE_TYPE",
    "SAMPLE_SPECIES", "SEX", "LIFE_STAGE", "BIO_SAMPLE_VOLUME", "VOLUME_UNIT",
    "BIO_SAMPLE_AREA", "AREA_UNIT", "BIO_SIZE_FROM", "BIO_SIZE_TO", "SIZE_UNIT",
    "BIO_SAMPLE_WEIGHT", "WEIGHT_UNIT", "BIO_SAMPLE_WEIGHT_FROM",
    "BIO_SAMPLE_WEIGHT_TO", "WEIGHT_UNIT_1", "SPECIES", "RESULT_LIFE_STAGE")
}

ems_tz <- function() {
  "Etc/GMT+8"
}