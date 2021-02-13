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

httr_progress <- function() {
  if (interactive()) {
    return(httr::progress("down"))
  }
}

base_url <- function() {
  "https://pub.data.gov.bc.ca/datasets/949f2233-9612-4b06-92a9-903e817da659/"
}

#' Convert an integer representing a Unix date/time to POSIXct (R date/time) class
#'
#' @param x Datetime integer
#'
#' @return POSIXct vector
#' @export
ems_posix_numeric <- function(x) {
  ems_posixct.numeric(x)
}

stop_for_permission <- function(question) {
  permission <- get_write_permission(question)
  if (!permission) stop("Permission denied. Exiting", call. = FALSE)
  invisible(NULL)
}

#' @importFrom utils menu
get_write_permission <- function(question) {
  ans <- menu(choices = c("Yes", "No"), title = question)
  permission <- ans == 1L
  permission
}

# Add leading zeroes to emsids to make sure they are 7 characters wide.
# Could use string::stri_pad_left, but didn't want extra dependency
pad_emsid <- function(x) {
  lens <- nchar(x)
  if (all(lens == 7)) return(x)
  if (any(lens > 7)) stop("emsid should be max 7 characters long", call. = FALSE)
  x <- sprintf("%07s", x) # On some systems pads with a space, so need the
  gsub("\\s", "0", x)     # gsub to put zeros in
}

## CReate a sha1 hash for a file for comparing
make_file_hash <- function(file) {
  file <- normalizePath(file, winslash = "/")
  os <- find_os()
  if (os == "windows") {
    certutil_output <- system(sprintf("CertUtil -hashfile %s", file), intern = TRUE)
    ret <- gsub("\\s+", "", certutil_output[2])
  } else if (os == "osx") {
    shasum_output <- system(sprintf("shasum %s", file), intern = TRUE)
    ret <- strsplit(shasum_output, "\\s+")[[1]][1]
  } else if (os == "unix") {
    sha1sum_output <- system(sprintf("sha1sum %s", file), intern = TRUE)
    ret <- strsplit(sha1sum_output, "\\s+")[[1]][1]
  }
  ret
}

add_rems_type <- function(obj, which) {
  if (!which %in% c("2yr", "4yr", "historic")) {
    stop("Cannot add rems type ", which)
  }
  structure(obj, rems_type = which)
}

find_os <- function() {
  if (.Platform$OS.type == "windows") {
    "windows"
  } else if (Sys.info()["sysname"] == "Darwin") {
    "osx"
  } else if (.Platform$OS.type == "unix") {
    "unix"
  } else {
    stop("Could not find oprating system")
  }
}

cat_if_interactive <- function(...) {
  if (interactive()) cat(...)
}

#' Standardize MDL
#'
#' @param data an ems data frame containing at least the
#' columns `"UNIT", "METHOD_DETECTION_LIMIT", "MDL_UNIT"`
#'
#' @return data frame with MDLs standardized to UNITs (where possible)
#' @export
standardize_mdl_units <- function(data) {
  if (!all(c("UNIT", "METHOD_DETECTION_LIMIT", "MDL_UNIT") %in% names(data))) {
    stop("'data' must contain columns 'UNIT', 'METHOD_DETECTION_LIMIT', 'MDL_UNIT'")
  }

  rows_to_fix <- which(data[["UNIT"]] != data[["MDL_UNIT"]])

  if (!any(length(rows_to_fix))) return(data)

  new_vals <- rep(NA_real_, nrow(data))

  for (i in rows_to_fix) {
    val <- data[["METHOD_DETECTION_LIMIT"]][i]
    from_unit <- data[["MDL_UNIT"]][i]
    to_unit <- data[["UNIT"]][i]

    new_val <- try(
      convert_unit_values(x = val, from = from_unit, to = to_unit),
      silent = TRUE
    )

    if (inherits(new_val, "try-error") || !is.numeric(new_val)) {
      warning("Could not convert from '", from_unit, "' to '", to_unit, "' on row ", i, call. = FALSE)
    } else {
      new_vals[i] <- new_val
    }
  }

  fixed <- !is.na(new_vals)
  data[["METHOD_DETECTION_LIMIT"]][fixed] <- new_vals[fixed]
  data[["MDL_UNIT"]][fixed] <- data[["UNIT"]][fixed]
  data
}

convert_unit_values <- function(x, from, to) {
  to <- clean_unit(to)
  from <- clean_unit(from)
  units(x) <- from
  units(x) <- to
  as.numeric(x)
}

clean_unit <- function(x) {
  x[x == "N/A"] <- NA_character_
  # Remove trailing A, W, wet etc. as well as percent type (V/V, W/W, Moratlity)
  # Assuming they are not imporant in the unit conversion??
  gsub("\\s*(W|wet|A|\\(W/W\\)|\\(V/V\\)|\\(Mortality\\))\\s*$", "", x)
}