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

#' @importFrom readr cols_only
col_spec <- function(subset = NULL) {
  cols <- col_specs("readr", subset = subset)
  spec <- do.call("cols_only", cols)
  spec
}

wq_cols <- function() {
  c("EMS_ID",
    "MONITORING_LOCATION",
    "LATITUDE",
    "LONGITUDE",
    "LOCATION_TYPE",
    "COLLECTION_START",
    "LOCATION_PURPOSE",
    "PERMIT",
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
    "QA_INDEX_CODE",
    "UPPER_DEPTH",
    "LOWER_DEPTH")
}

col_specs <- function(type = c("readr", "sql", "all", "names_only"), subset = NULL) {

  type = match.arg(type)

  specs <- list(
    "EMS_ID" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "MONITORING_LOCATION" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "LATITUDE" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "LONGITUDE" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "LOCATION_TYPE" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "COLLECTION_START" = list(readr_fun = col_datetime(format = "%Y%m%d%H%M%S"), sql_type = "INTEGER"),
    "COLLECTION_END" = list(readr_fun = col_datetime(format = "%Y%m%d%H%M%S"), sql_type = "INTEGER"),
    "LOCATION_PURPOSE" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "PERMIT" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "PERMIT_RELATIONSHIP" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "DISCHARGE_TO" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "REQUISITION_ID" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "SAMPLING_AGENCY" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "ANALYZING_AGENCY" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "COLLECTION_METHOD" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "SAMPLE_CLASS" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "SAMPLE_STATE" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "SAMPLE_DESCRIPTOR" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "PARAMETER_CODE" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "PARAMETER" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "ANALYTICAL_METHOD_CODE" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "ANALYTICAL_METHOD" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "RESULT_LETTER" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "RESULT" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "UNIT" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "METHOD_DETECTION_LIMIT" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "QA_INDEX_CODE" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "UPPER_DEPTH" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "LOWER_DEPTH" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "TIDE" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "AIR_FILTER_SIZE" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "AIR_FLOW_VOLUME" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "FLOW_UNIT" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "COMPOSITE_ITEMS" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "CONTINUOUS_AVERAGE" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "CONTINUOUS_MAXIMUM" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "CONTINUOUS_MINIMUM" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "CONTINUOUS_UNIT_CODE" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "CONTINUOUS_DURATION" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "CONTINUOUS_DURATION_UNIT" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "CONTINUOUS_DATA_POINTS" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "TISSUE_TYPE" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "SAMPLE_SPECIES" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "SEX" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "LIFE_STAGE" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "BIO_SAMPLE_VOLUME" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "VOLUME_UNIT" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "BIO_SAMPLE_AREA" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "AREA_UNIT" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "BIO_SIZE_FROM" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "BIO_SIZE_TO" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "SIZE_UNIT" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "BIO_SAMPLE_WEIGHT" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "WEIGHT_UNIT" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "BIO_SAMPLE_WEIGHT_FROM" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "BIO_SAMPLE_WEIGHT_TO" = list(readr_fun = col_double(), sql_type = "DOUBLE"),
    "WEIGHT_UNIT_1" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "SPECIES" = list(readr_fun = col_character(), sql_type = "TEXT"),
    "RESULT_LIFE_STAGE" = list(readr_fun = col_character(), sql_type = "TEXT")
  )

  if (type == "readr") {
    ret <- lapply(specs, `[[`, "readr_fun")
  } else if (type == "sql") {
    ret <- vapply(specs, `[[`, "sql_type", FUN.VALUE = character(1))
  } else {
    ret <- specs
  }

  if (!is.null(subset)) {
    diff_cols <- setdiff(subset, names(specs))
    if (length(diff_cols) > 0 ) {
      stop("Column(s): ", paste(diff_cols, collapse = ", "), " not in data file",
           call. = FALSE)
    }
    ret <- ret[subset]
  }

  if (type == "names_only") {
    ret <- names(ret)
  }

  ret
}

ems_tz <- function() {
  "Etc/GMT+8"
}

#' Save EMS data as a csv file
#'
#' You must specify either an object in your environment (via \code{obj}),
#' or one of \code{"2yr"}, \code{"4yr"}, or \code{"historic"} (via \code{which}),
#' but not both.
#'
#' @param obj The name of an object in your environment
#' @param which "2yr", "4yr", or "historic"
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
    if (!which %in% c("2yr", "4yr", "historic")) {
      stop("which must be one of '2yr', '4yr', or 'historic'")
    }
    obj <- get_ems_data(which)
  }

  message("saving data at ", filename)
  readr::write_csv(x = obj, path = filename, ...)
}