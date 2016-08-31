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
read_ems_data <- function(file, n = Inf, cols = NULL, verbose = TRUE, ...) {
  if (verbose) message("Reading data from file...")

  ret <- readr::read_csv(file, col_types = col_spec(cols), n_max = n,
                         locale = readr::locale(tz = ems_tz()), ...)
  readr::stop_for_problems(ret)
  tibble::as_tibble(ret)
}

col_spec <- function(subset = NULL) {

  if (!is.null(subset)) {
    diff_cols <- setdiff(subset, all_cols())
    if (length(diff_cols) > 0 ) {
      stop("Column(s): ", paste(diff_cols, collapse = ", "), " not in data file",
           call. = FALSE)
    }
  }

  spec <- readr::cols_only(
    EMS_ID = col_character(),
    MONITORING_LOCATION = col_character(),
    LATITUDE = col_double(),
    LONGITUDE = col_double(),
    LOCATION_TYPE = col_character(),
    COLLECTION_START = col_datetime(format = "%Y%m%d%H%M%S"),
    COLLECTION_END = col_datetime(format = "%Y%m%d%H%M%S"),
    REQUISITION_ID = col_character(),
    SAMPLING_AGENCY = col_character(),
    ANALYZING_AGENCY = col_character(),
    COLLECTION_METHOD = col_character(),
    SAMPLE_CLASS = col_character(),
    SAMPLE_STATE = col_character(),
    SAMPLE_DESCRIPTOR = col_character(),
    PARAMETER_CODE = col_character(),
    PARAMETER = col_character(),
    ANALYTICAL_METHOD_CODE = col_character(),
    ANALYTICAL_METHOD = col_character(),
    RESULT_LETTER = col_character(),
    RESULT = col_double(),
    UNIT = col_character(),
    METHOD_DETECTION_LIMIT = col_double(),
    QA_INDEX_CODE = col_character(),
    UPPER_DEPTH = col_double(),
    LOWER_DEPTH = col_double(),
    TIDE = col_character(),
    AIR_FILTER_SIZE = col_double(),
    AIR_FLOW_VOLUME = col_double(),
    FLOW_UNIT = col_character(),
    COMPOSITE_ITEMS = col_double(),
    CONTINUOUS_AVERAGE = col_double(),
    CONTINUOUS_MAXIMUM = col_double(),
    CONTINUOUS_MINIMUM = col_double(),
    CONTINUOUS_UNIT_CODE = col_character(),
    CONTINUOUS_DURATION = col_double(),
    CONTINUOUS_DURATION_UNIT = col_character(),
    CONTINUOUS_DATA_POINTS = col_double(),
    TISSUE_TYPE = col_character(),
    SAMPLE_SPECIES = col_character(),
    SEX = col_character(),
    LIFE_STAGE = col_character(),
    BIO_SAMPLE_VOLUME = col_double(),
    VOLUME_UNIT = col_character(),
    BIO_SAMPLE_AREA = col_double(),
    AREA_UNIT = col_character(),
    BIO_SIZE_FROM = col_double(),
    BIO_SIZE_TO = col_double(),
    SIZE_UNIT = col_character(),
    BIO_SAMPLE_WEIGHT = col_double(),
    WEIGHT_UNIT = col_character(),
    BIO_SAMPLE_WEIGHT_FROM = col_double(),
    BIO_SAMPLE_WEIGHT_TO = col_double(),
    WEIGHT_UNIT_1 = col_character(),
    SPECIES = col_character(),
    RESULT_LIFE_STAGE = col_character()
  )
  if (!is.null(subset)) {
    spec$cols <- spec$cols[subset]
  }
  spec
}

wq_cols <- function() {
  c("EMS_ID"
    , "MONITORING_LOCATION"
    , "LATITUDE"
    , "LONGITUDE"
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

#' Save EMS data as a csv file
#'
#' You must specify either an object in your environment (via \code{obj}), or one of \code{"current"}
#' or \code{"historic"} (via \code{which}), but not both.
#'
#' @param obj The name of an object in your environment
#' @param which "current" or "historic"
#' @param filename the name of the file you are writing to
#' @param ... other options passed on to \code{read_csv}
#'
#' @importFrom readr write_csv
#'
#' @return the object, invisibly
#' @export
save_ems_data <- function(obj = NULL, which = NULL, filename = NULL, ...) {
  if (!is.null(obj) && !is.null(which)) {
    stop("You must only specify one of 'obj' or 'which'. see ?save_ems_data")
  }

  if (is.null(filename)) stop("You must specify a filename")

  if (is.null(obj)) {
    if (!which %in% c("current", "historic")) {
      stop("which must be one of 'current' or 'historic'")
    }
    obj <- get_ems_data(which)
  }

  message("saving data at ", filename)
  readr::write_csv(x = obj, path = filename, ...)
}