# Copyright 2019 Province of British Columbia
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

download_file_from_release <- function(file, path, release = "latest",
                                       force = FALSE, httr_config = list()) {
  the_release <- get_gh_release(release)
  assets <- the_release$assets

  the_asset <- which(vapply(assets, function(x) x$name, FUN.VALUE = character(1)) == file)

  if (!length(the_asset)) {
    stop("No assets matching filename ", file, " in ", release, " release.")
  } else if (length(the_asset) > 1) {
    stop("More than one asset matching filename ", file, " in ", release, " release.")
  }

  the_asset_url <- assets[[the_asset]][["url"]]

  the_asset_id <- as.character(assets[[the_asset]][["id"]])
  asset_id_file <- gsub("rds$", "gh_asset_id", path)

  if (file.exists(asset_id_file) && !force) {
    # Read the asset id of the previously written file
    old_asset_id <- as.character(readLines(asset_id_file, n = 1L, warn = FALSE))
    if (old_asset_id == the_asset_id) {
      # the current one on disk is the same asset as on GH so don't download again
      download <- FALSE
    } else {
      ans <- utils::askYesNo(paste0("There is a newer version of ", basename(file),
                        " available. Would you like to download it and store it at ",
                        path, "?"))
      download <- ans
    }
  } else {
    # Hasn't been downloaded before, so must download it now
    download <- TRUE
  }

  if (download) {
    message("Downloading ", file, "...\n")
    # write the github release asset id to a file for checking version
    cat(the_asset_id,
        file = asset_id_file)
    download_release_asset(the_asset_url, path, httr_config = httr_config)
  } else {
    message("Loading file from cache...\n")
  }
  invisible(path)
}

get_gh_release <- function(release = "latest") {
  # List releases
  sep <- ifelse(release == "latest", "/", "/tags/")
  url <- paste(gh_base_url(), release, sep = sep)
  rels_resp <- httr::GET(auth_url(url))
  httr::stop_for_status(rels_resp)

  jsonlite::fromJSON(httr::content(rels_resp, as = "text",
                                   type = "application/json",
                                   encoding = "UTF-8"),
                     simplifyVector = FALSE, simplifyDataFrame = FALSE,
                     simplifyMatrix = FALSE, flatten = FALSE)
}

download_release_asset <- function(asset_url, path, httr_config = list()) {
  resp <- httr::GET(auth_url(asset_url),
                    config = httr_config,
                    httr::add_headers(Accept = "application/octet-stream"),
                    httr::write_disk(path, overwrite = TRUE),
                    httr::progress("down"))

  httr::stop_for_status(resp)

  invisible(path)
}

auth_url <- function(url) {
  pat <- Sys.getenv("GITHUB_PAT")
  if (nzchar(pat)) {
    return(paste0(url, "?access_token=", pat))
  }
  url
}

get_sqlite_gh_date <- function(release = "latest") {
  rel <- get_gh_release(release)
  as.POSIXct(rel$assets[[1]]$updated_at)
}

upload_release_asset <- function(files, release_url = get_gh_release()$url) {
  stopifnot(requireNamespace("httr"))
  stopifnot(requireNamespace("devtools"))

  for (f in path.expand(files)) {
    message("uploading ", f)
    r <- httr::POST(gsub("\\{.+\\}$", "", release_url),
                    query = list(name = basename(f)),
                    body = httr::upload_file(f),
                    httr::authenticate(devtools::github_pat(), ""),
                    httr::progress("up"))

    httr::stop_for_status(r, task = paste0("upload ", f))
  }
  invisible(TRUE)
}

gh_base_url <- function() "https://api.github.com/repos/bcgov/rems/releases"

save_historic_data <- function(csv_file, db_path, n) {
  message("Saving historic data at ", db_path)
  data <- read_ems_data(csv_file, n = n, cols = NULL, verbose = FALSE,
                        progress = FALSE)
  col_names <- col_specs("names_only")

  #setting up sqlite

  con <- DBI::dbConnect(RSQLite::SQLite(), dbname = db_path)
  on.exit(DBI::dbDisconnect(con))
  tbl_name <- "historic"

  i <- 1
  cat("|")
  while (nrow(data) == n) { # if not reached the end of line
    cat("=")
    skip <- i * n + 1
    if (i == 1) {
      DBI::dbWriteTable(con, data, name = tbl_name, overwrite = TRUE,
                        field.types = col_specs(type = "sql"))
    } else {
      DBI::dbWriteTable(con, data, name = tbl_name, append = TRUE) #write to sqlite
    }
    data <- read_ems_data(csv_file, n = n, cols = col_names, verbose = FALSE, skip = skip,
                          col_names = col_names, progress = FALSE)
    i <- i + 1
  }

  if (nrow(data) > 0 ) {
    DBI::dbWriteTable(con, data, name = tbl_name, append = TRUE)
  }

  cat("=")
  add_sql_index(con, colname = 'EMS_ID')
  cat("=")
  add_sql_index(con, colname = 'COLLECTION_START')
  cat("=")
  add_sql_index(con, colname = 'COLLECTION_END')
  cat("=")
  add_sql_index(con, colname = 'LOCATION_PURPOSE')
  cat("=")
  add_sql_index(con, colname = 'SAMPLE_CLASS')
  cat("=")
  add_sql_index(con, colname = 'SAMPLE_STATE')
  cat("=")
  add_sql_index(con, colname = 'PARAMETER')
  cat("=")
  add_sql_index(con, colname = 'PARAMETER_CODE')

  cat("| 100%\n")

  invisible(TRUE)
}
