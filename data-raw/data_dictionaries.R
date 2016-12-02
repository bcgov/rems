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
  base_url <- "http://www2.gov.bc.ca/assets/gov/environment/research-monitoring-and-reporting/reporting/reporting-documents/environmental-monitoring-docs/"
  dest_file <- tempfile(fileext = ".xls")
  download.file(paste0(base_url, filename), destfile = dest_file, mode = "wb")
  read_excel(dest_file)
}

trim_all_ws <- function(tbl) {
  as_tibble(lapply(tbl, str_trim))
}

dict_alpha <- download_and_read_dict("dict-alpha.xls")
dict_numeric <- download_and_read_dict("dict-num.xls")

dict_alpha %<>%
  select(PARAMETER_CODE = `Parameter Code`,
         PARAMETER_ABBR = `Parameter Name`,
         ANALYTICAL_METHOD = `Method Name`,
         ANALYTICAL_METHOD_CODE = `Method Code`,
         METHOD_DETECTION_LIMIT = `Method Detect Limit`,
         UNIT = Units,
         UNIT_CODE = `Unit Code`) %>%
  trim_all_ws()

dict_numeric %<>%
  select(PARAMETER_CODE = `Parameter Code`,
         PARAMETER = `Parameter Name`,
         ANALYTICAL_METHOD = `Method Name`,
         ANALYTICAL_METHOD_CODE = `Method Code`,
         METHOD_DETECTION_LIMIT = `Method Detect Limit`,
         UNIT = Units,
         UNIT_CODE = `Unit Code`) %>%
  trim_all_ws()

ems_parameters <- left_join(dict_alpha, dict_numeric) %>%
  mutate(PARAMETER = ifelse(is.na(PARAMETER), PARAMETER_ABBR, PARAMETER)) %>%
  select(PARAMETER, everything())

dict_units <- download_and_read_dict("units-alpha.xls")

ems_units <- dict_units %>%
  select(UNIT_CODE = Code,
         UNIT = `Short Name`,
         UNIT_DESCRIPTION = Description) %>%
  trim_all_ws()

st_sd_dict <- download_and_read_dict("type-st-ds.xls")

ems_location_samples <- st_sd_dict %>%
  select(LOCATION_TYPE_CODE = `Site Type Code`,
         LOCATION_TYPE = `Site Type Description`,
         SAMPLE_STATE_CODE = `Sample State Code`,
         SAMPLE_STATE = `Sample State Description`,
         SAMPLE_DESCRIPTOR_CODE = `Sample Descriptor Code`,
         SAMPLE_DESCRIPTOR = `Sample Descriptor Description`) %>%
  trim_all_ws()

col_method_dict <- download_and_read_dict("col-method.xls")

ems_coll_methods <- col_method_dict %>%
  select(COLLECTION_METHOD_CODE = CODE,
         COLLECTION_METHOD = DESCRIPTION) %>%
  trim_all_ws()

class_dict <- download_and_read_dict("class.xls")

ems_sample_classes <- class_dict %>%
  select(SAMPLE_CLASS_CODE = Code,
         SAMPLE_CLASS = Description) %>%
  trim_all_ws()

species_dict <- download_and_read_dict("species.xls")

ems_species <- species_dict %>%
  select(SPECIES_CODE = CODE,
         SPECIES = DESCRIPTION,
         SPECIES_CLASSIFICATION_LEVEL = CLASSIFICATION_LEVEL) %>%
  trim_all_ws()

devtools::use_data(
  ems_coll_methods,
  ems_parameters,
  ems_sample_classes,
  ems_location_samples,
  ems_species,
  ems_units)

## Documented in R/data_dictionaries.R
