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

library(readxl)
library(dplyr)
library(tibble)
library(magrittr)
library(stringr)

download_and_read_dict <- function(filename) {
  base_url <- "https://www2.gov.bc.ca/assets/gov/environment/research-monitoring-and-reporting/reporting/reporting-documents/environmental-monitoring-docs"
  dest_file <- tempfile(fileext = ".xls")
  download.file(file.path(base_url, filename), destfile = dest_file, mode = "wb")
  read_excel(dest_file)
}

trim_all_ws <- function(tbl) {
  as_tibble(lapply(tbl, str_trim, side = "both"))
}

ems_parameters <- download_and_read_dict("dict-num.xls")

ems_parameters %<>%
  select(PARAMETER_CODE = `Parameter Code`,
         PARAMETER = `Parameter`,
         ANALYTICAL_METHOD = `Analytical Method`,
         ANALYTICAL_METHOD_CODE = `Analytical Method Code`,
         METHOD_DETECTION_LIMIT = `Method Detection Limit`,
         UNIT = Unit,
         UNIT_CODE = `Unit Code`) %>%
  trim_all_ws()

dict_units <- download_and_read_dict("units-alpha.xls")

ems_units <- dict_units %>%
  select(UNIT_CODE = `UNIT CODE`, UNIT, UNIT_DESCRIPTION = `MEASUREMENT UNIT DESCRIPTION`) %>%
  trim_all_ws()

st_sd_dict <- download_and_read_dict("type-st-ds.xls")

ems_location_samples <- st_sd_dict %>%
  select(LOCATION_TYPE_CODE = `LOCATION TYPE CODE`,
         LOCATION_TYPE = `LOCATION TYPE`,
         SAMPLE_STATE_CODE = `SAMPLE STATE CODE`,
         SAMPLE_STATE = `SAMPLE STATE DESCRIPTION`,
         SAMPLE_DESCRIPTOR_CODE = `SAMPLE DESCRIPTOR CODE`,
         SAMPLE_DESCRIPTOR = `SAMPLE DESCRIPTOR`) %>%
  trim_all_ws()

col_method_dict <- download_and_read_dict("col-method.xls")

ems_coll_methods <- col_method_dict %>%
  select(COLLECTION_METHOD_CODE = CODE,
         COLLECTION_METHOD = `COLLECTION METHOD`) %>%
  trim_all_ws()

class_dict <- download_and_read_dict("class.xls")

ems_sample_classes <- class_dict %>%
  select(SAMPLE_CLASS_CODE = CODE,
         SAMPLE_CLASS = DESCRIPTION) %>%
  trim_all_ws()

species_dict <- download_and_read_dict("species.xls")

ems_species <- species_dict %>%
  select(SPECIES_CODE = CODE,
         SPECIES = `SPECIES DESCRIPTION`,
         SPECIES_CLASSIFICATION_LEVEL = `CLASSIFICATION LEVEL`) %>%
  trim_all_ws()

devtools::use_data(
  ems_coll_methods,
  ems_parameters,
  ems_sample_classes,
  ems_location_samples,
  ems_species,
  ems_units,
  compress = "xz",
  overwrite = TRUE)

## Documented in R/data_dictionaries.R
