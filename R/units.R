# Copyright 2021 Province of British Columbia
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

#' Standardize MDL
#'
#' There are many cases in EMS where the RESULT UNIT is
#' displayed differently than the METHOD_DETECTION_LIMIT.
#' This function uses the `units` package to convert the
#' `METHOD_DETECTION_LIMIT` values to the same unit as `RESULT`.
#'
#' @param data an ems data frame containing at least the
#' columns `"UNIT", "METHOD_DETECTION_LIMIT", "MDL_UNIT"`
#'
#' @return data frame with MDLs standardized to UNITs (where possible)
#' @importFrom rlang .data
#' @export
standardize_mdl_units <- function(data) {
  if (!all(c("UNIT", "METHOD_DETECTION_LIMIT", "MDL_UNIT") %in% names(data))) {
    stop("'data' must contain columns 'UNIT', 'METHOD_DETECTION_LIMIT', 'MDL_UNIT'")
  }

  if (!any(data[["UNIT"]] != data[["MDL_UNIT"]])) return(data)

  data <- dplyr::group_by(data, .data$MDL_UNIT, .data$UNIT)
  data <- dplyr::mutate(
    data,
    converted_val = convert_unit_values(.data$METHOD_DETECTION_LIMIT,
                                        .data$MDL_UNIT[1],
                                        .data$UNIT[1])
  )

  fixed <- !is.na(data[["converted_val"]])
  # update MDL and MDL_UNIT for those that were converted
  # and remove the temporary converted_val column
  data[["METHOD_DETECTION_LIMIT"]][fixed] <- data[["converted_val"]][fixed]
  data[["MDL_UNIT"]][fixed] <- data[["UNIT"]][fixed]
  data[["converted_val"]] <- NULL

  data
}

convert_unit_values <- function(x, from, to) {
  stopifnot(length(from) == 1)
  stopifnot(length(to) == 1)

  clean_to <- clean_unit(to)
  clean_from <- clean_unit(from)

  # only return a non-NA value for those that are converted
  if (
    any(is.na(c(clean_from, clean_to))) ||
    clean_from == clean_to
  ) {
    return(NA_real_)
  }

  ret <- tryCatch(
    units::set_units(
      units::set_units(x, clean_from, mode = "standard"),
      clean_to, mode = "standard"
    ),
    error = function(e) {
      warning("Could not convert ", from, " to ", to,
              call. = FALSE)
      NA_real_
    }
  )

  as.numeric(ret)
}

clean_unit <- function(x) {
  x[x == "N/A"] <- NA_character_
  # Remove trailing A, W, wet etc. as well as percent type (V/V, W/W, Mortality)
  # Assuming they are not important in the unit conversion??
  gsub("\\s*(W|wet|A|\\(?W/W\\)?|\\(?V/V\\)?|\\(?Mortality\\)?)\\s*$", "", x)
}
