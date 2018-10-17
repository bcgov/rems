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

#' Download and store the large historic ems dataset
#'
#' @param n the chunk size to use to iteratively read and store the historic data (default 1 million)
#' @param force Force downloading the dataset, even if it's not out of date (default \code{FALSE})
#' @param ask should the function ask for your permission to cache data on your computer?
#' Default \code{TRUE}
#' @param dont_update should the function avoid updating the data even if there is a newer
#' version available? Default \code{FALSE}
#'
#' @return The path where the sqlite database is stored (invisibly).
#' @export
#'
#' @importFrom DBI dbConnect dbWriteTable dbDisconnect
#' @importFrom RSQLite SQLite
#'
download_historic_data <- function(n = 1e6, force = FALSE, ask = TRUE, dont_update = FALSE) {

  file_meta <- get_file_metadata("historic")
  cache_date <- get_cache_date("historic")

  db_path <- write_db_path()

  if (file.exists(db_path) && !force) {
    if (cache_date >= file_meta[["server_date"]]) {
      message("It appears that you already have the most up-to date version of the",
              " historic ems data.")
      return(invisible(db_path))
    }

    if (dont_update) {
      warning("There is a newer version of the historic ems data ",
              ", however you have asked not to update it by setting 'dont_update' to TRUE.")
      return(invisible(db_path))
    }
  }

  if (ask) {
    stop_for_permission(paste0("rems would like to store a copy of the historic ems data at ",
                                              db_path, ". Is that okay?"))
  }

  message("This is going to take a while...")

  url <- paste0(base_url(), file_meta[["filename"]])
  message("Downloading latest 'historic' EMS data from BC Data Catalogue (url:", url, ")")
  csv_file <- download_ems_data(url)
  on.exit(unlink(csv_file))

  save_historic_data(csv_file, db_path, n)

  set_cache_date("historic", file_meta[["server_date"]])

  message("Successfully downloaded and stored the historic EMS data.\n",
          "You can access and subset it with the 'read_historic_data' function, or
          attach it as a remote data.frame with 'attach_historic_data()'
          which you can then query with dplyr")
  invisible(db_path)
}

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

#' Read historic ems data into R.
#'
#' You will need to have run \code{\link{download_historic_data}} before you
#' can use this function
#'
#' @param emsid A character vector of the ems id(s) of interest
#' @param parameter a character vector of parameter names
#' @param param_code a character vector of parameter codes
#' @param from_date A date string in a standard unambiguous format (e.g., "YYYY/MM/DD")
#' @param to_date A date string in a standard unambiguous format (e.g., "YYYY/MM/DD")
#' @param cols colums. Default "wq". See \code{link{get_ems_data}} for further documentation.
#'
#' @return a data frame of the results
#' @export
#'
#' @importFrom DBI dbConnect dbDisconnect dbGetQuery
read_historic_data <- function(emsid = NULL, parameter = NULL, param_code = NULL,
                               from_date = NULL, to_date = NULL, cols = "wq") {

  file_meta <- get_file_metadata("historic")
  cache_date <- get_cache_date("historic")
  db_path <- write_db_path()

  ## Check for missing or outdated historic database
  exit_fun <- FALSE
  if (!file.exists(db_path)) {
    exit_fun <- TRUE
  } else if (cache_date < file_meta[["server_date"]] && file.exists(db_path)) {
    ans <- readline(paste("Your version of the historic dataset is out of date.",
                          "Would you like to continue with the version you have (y/n)? ",
                          sep = "\n"))
    if (tolower(ans) != "y") exit_fun <- TRUE
  }
  if (exit_fun) stop("Please download the historic data with\n",
                 " the 'download_historic_data' function.")

  qry <- construct_historic_sql(emsid = emsid, parameter = parameter,
                                param_code = param_code, from_date = from_date,
                                to_date = to_date, cols = cols)

  con <- DBI::dbConnect(RSQLite::SQLite(), dbname = db_path)
  on.exit(DBI::dbDisconnect(con))

  res <- DBI::dbGetQuery(con, qry)

  if (!is.null(res$COLLECTION_START))
    res$COLLECTION_START <- ems_posix_numeric(res$COLLECTION_START)
  if (!is.null(res$COLLECTION_END))
    res$COLLECTION_END <- ems_posix_numeric(res$COLLECTION_END)

  ret <- tibble::as_tibble(res)

  add_rems_type(ret, "historic")

}

#' Load the historic ems sqlite database as a tbl
#'
#' You can then use dplyr verbs such as \code{\link[dplyr]{filter}},
#' \code{\link[dplyr]{select}}, \code{\link[dplyr]{summarize}}, etc. For basic
#' importing of historic data based on \code{ems_id}, \code{date}, and \code{parameter},
#' you can use the function \code{\link{read_historic_data}}
#'
#' @return A dplyr connection to the sqlite database. See \code{\link[dplyr]{src_sqlite}} for more.
#'
#' @details Note that the dates are stored in the sqlite database as integers.
#' This number is the number of seconds since midnight on January 1, 1970, PST. Convert the dates
#' to a \code{POSIXct} object with \code{as.POSIXct(x, origin = "1970/01/01", tz = "Etc/GMT+8")}.
#' If you use \code{\link{read_historic_data}}, this will be done for you.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#' foo <- attach_historic_data()
#' bar <- foo %>%
#'   group_by(EMS_ID) %>%
#'   summarise(max_date = max(COLLECTION_START))
#' baz <- collect(bar)
#' baz$max_date <- as.POSIXct(baz$max_date, origin = "1970/01/01", tz = "Etc/GMT+8")
#' }
attach_historic_data <- function() {
  db_path <- write_db_path()
  if (!file.exists(db_path)) {
    stop("Please download the historic data with\n",
         " the 'download_historic_data' function.", call. = FALSE)
  }
  db <- dplyr::src_sqlite(db_path)
  tbl <- dplyr::tbl(db, "historic")
  tbl
}

construct_historic_sql <- function(emsid = NULL, parameter = NULL, param_code = NULL,
                                   from_date = NULL, to_date = NULL, cols = NULL) {
  emsid_qry <- parameter_qry <- param_cd_qry <- from_date_qry <- to_date_qry <- col_query <- NULL
  if (!is.null(emsid)) {
    emsid <- pad_emsid(emsid)
    emsid_qry <- sprintf("EMS_ID IN (%s)", stringify_vec(emsid))
  }
  if (!is.null(parameter)) {
    parameter_qry <- sprintf("PARAMETER IN (%s)", stringify_vec(parameter))
  }
  if (!is.null(param_code)) {
    param_cd_qry <- sprintf("PARAMETER_CODE IN (%s)", stringify_vec(param_code))
  }

  if (!is.null(from_date)) {
    from_date <- as.integer(as.POSIXct(from_date, tz = ems_tz()))
    from_date_qry <- sprintf("COLLECTION_START >= %s", from_date)
  }
  if (!is.null(to_date)) {
    to_date <- as.integer(as.POSIXct(to_date, tz = ems_tz()))
    to_date_qry <- sprintf("COLLECTION_START <= %s", to_date)
  }
  row_query_vec <- c(emsid_qry, parameter_qry, param_cd_qry, from_date_qry, to_date_qry)
  row_query_vec <- row_query_vec[!is.null(row_query_vec)]
  row_query <- paste(row_query_vec, collapse = " AND ")

  if (is.null(cols) || cols == "all") {
    cols <- "*"
  } else if (cols == "wq") {
    cols <- wq_cols()
  }

  col_query <- paste(cols, collapse = ", ")

  if (row_query == "") {
    sql <- sprintf("SELECT %s FROM historic", col_query)
  } else {
    sql <- sprintf("SELECT %s FROM historic WHERE %s", col_query, row_query)
  }

  sql
}

#' Turn a character vector into a string with items surrounded by quotes and
#' separated by commas
#'
#' @param vec
#'
#' @return character
#' @noRd
stringify_vec <- function(vec) {
  paste(shQuote(vec, "sh"), collapse = ",")
}

write_db_path <- function() {
  file.path(rems_data_dir(), "ems.sqlite")
}

#' Add an index to a column in a sqlite database
#'
#' @param con sqlite connection
#' @param idxname desired name for the index
#' @param tblname table in the database
#' @param colname col on which to create an index
#'
#' @return NULL
#'
#' @noRd
add_sql_index <- function(con, tbl = "historic", colname,
                          idxname = paste0(tolower(colname), "_idx")) {
  sql_str <- sprintf('CREATE INDEX %s ON %s(%s)', idxname, tbl, colname)
  DBI::dbClearResult(DBI::dbSendQuery(con, sql_str))
  invisible(NULL)
}
