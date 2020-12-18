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
#' @param force Force downloading the dataset, even if it's not out of date (default \code{FALSE})
#' @param ask should the function ask for your permission to cache data on your computer?
#' Default \code{TRUE}
#' @param dont_update should the function avoid updating the data even if there is a newer
#' version available? Default \code{FALSE}
#' @param httr_config configuration settings passed on to [httr::GET()],
#' such as [httr::timeout()]
#'
#' @return The path where the duckdb database is stored (invisibly).
#' @export
#'
#' @importFrom DBI dbConnect dbWriteTable dbDisconnect
#' @importFrom duckdb duckdb
#'
download_historic_data <- function(force = FALSE, ask = TRUE, dont_update = FALSE, httr_config = list()) {

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

  message("Downloading latest 'historic' EMS data")
  url <- paste0(base_url(), file_meta[["filename"]])
  csv_file <- download_ems_data(url)

  create_rems_duckdb(csv_file, db_path)

  set_cache_date("historic", file_meta[["server_date"]])

  message("Successfully downloaded and stored the historic EMS data.\n",
    "You can access and subset it with the 'read_historic_data' function, or
          attach it as a remote data.frame with 'attach_historic_data()'
          which you can then query with dplyr")
  invisible(db_path)
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
#' @param check_db should the function check for cached data or updates? Default \code{TRUE}.
#'
#' @return a data frame of the results
#' @export
#'
#' @importFrom DBI dbConnect dbDisconnect dbGetQuery
#' @examples
#' \dontrun{
#' read_historic_data(emsid = "0400203", from_date = as.Date("1984-11-20"),
#'   to_date = as.Date("1991-05-11"))
#' }
read_historic_data <- function(emsid = NULL, parameter = NULL, param_code = NULL,
                               from_date = NULL, to_date = NULL, cols = "wq", check_db = TRUE) {

  db_path <- write_db_path()
  exit_fun <- FALSE
  if (!file.exists(db_path)) {
    exit_fun <- TRUE
  }

  ## Check for missing or outdated historic database
  if (check_db) {
    server_date <- file_meta <- get_file_metadata("historic")[["server_date"]]
    cache_date <- get_cache_date("historic")
    if (cache_date < server_date && file.exists(db_path)) {
      ans <- readline(paste("Your version of the historic dataset is out of date.",
        "Would you like to continue with the version you have (y/n)? ",
        sep = "\n"))
      if (tolower(ans) != "y")
        exit_fun <- TRUE
    }
  }

  if (exit_fun) stop("Please download the historic data with\n",
    " the 'download_historic_data' function.")

  qry <- construct_historic_sql(emsid = emsid, parameter = parameter,
    param_code = param_code, from_date = from_date,
    to_date = to_date, cols = cols)

  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = db_path)
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))

  res <- DBI::dbGetQuery(con, qry)

  # if (!is.null(res$COLLECTION_START))
  #   res$COLLECTION_START <- ems_posix_numeric(res$COLLECTION_START)
  # if (!is.null(res$COLLECTION_END))
  #   res$COLLECTION_END <- ems_posix_numeric(res$COLLECTION_END)

  ret <- tibble::as_tibble(res)

  add_rems_type(ret, "historic")

}

#' Load the historic ems database as a tbl
#'
#' You can then use dplyr verbs such as \code{\link[dplyr]{filter}},
#' \code{\link[dplyr]{select}}, \code{\link[dplyr]{summarize}}, etc. For basic
#' importing of historic data based on \code{ems_id}, \code{date}, and \code{parameter},
#' you can use the function \code{\link{read_historic_data}}
#'
#' @return A dplyr connection to the duckdb database. See \code{\link[dplyr]{src_sql}} for more.
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
  con <- DBI::dbConnect(duckdb::duckdb(), db_path, read_only = TRUE)
  tbl <- dplyr::tbl(con, "historic")
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
    from_date <- format(as.POSIXct(from_date, tz = ems_tz()), "%Y/%m/%d")
    from_date_qry <- sprintf("COLLECTION_START >= '%s'", from_date)
  }
  if (!is.null(to_date)) {
    to_date <- format(as.POSIXct(to_date, tz = ems_tz()), "%Y/%m/%d")
    to_date_qry <- sprintf("COLLECTION_START <= '%s' ", to_date)
  }
  where_clause_vec <- c(emsid_qry, parameter_qry, param_cd_qry, from_date_qry, to_date_qry)
  where_clause_vec <- where_clause_vec[!is.null(where_clause_vec)]
  where_clause <- paste(where_clause_vec, collapse = " AND ")

  if (is.null(cols) || cols == "all") {
    cols <- "*"
  } else if (cols == "wq") {
    cols <- wq_cols()
  }

  select_clause <- paste(cols, collapse = ", ")

  if (where_clause == "") {
    sql <- sprintf("SELECT %s FROM historic", select_clause)
  } else {
    sql <- sprintf("SELECT %s FROM historic WHERE %s", select_clause, where_clause)
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

write_db_path <- function(path = getOption("rems.historic.path",
                            default = rems_data_dir())) {
  fpath <- normalizePath(file.path(path, "duckdb/ems_historic.duckdb"),
                        mustWork = FALSE)
  dir.create(dirname(fpath), showWarnings = FALSE)
  fpath
}

#' Add an index to a column in a DBI database
#'
#' @param con DBI connection
#' @param idxname desired name for the index
#' @param tblname table in the database
#' @param colname col on which to create an index
#'
#' @return NULL
#'
#' @noRd
add_sql_index <- function(con, tbl = "historic", colname,
                          idxname = paste0(tolower(colname), "_idx")) {
  sql_str <- sprintf("CREATE INDEX %s ON %s(%s)", idxname, tbl, colname)
  DBI::dbExecute(con, sql_str)
  invisible(NULL)
}