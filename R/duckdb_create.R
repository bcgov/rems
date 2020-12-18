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

#' Create historic table in duckdb
#'
#' @param csv_file path to csv file
#' @param db_path where to create the duckdb
#'
#' @return `TRUE` (invisibly)
#'
#' @import duckdb
#' @importFrom glue glue
create_rems_duckdb <- function(csv_file, db_path) {
  message("Saving historic data at ", db_path)

  csv_file <- normalizePath(csv_file, mustWork = TRUE)

  con <- DBI::dbConnect(duckdb::duckdb(), dbdir = db_path)
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))

  tbl_name <- "historic"

  DBI::dbExecute(con, glue("DROP TABLE IF EXISTS {tbl_name}"))

  # Wrap column names in double quotes to preserve case
  historic_col_names <- paste0('"', col_specs("names_only"), '"')
  historic_col_sql_types <- col_specs("sql")

  DBI::dbExecute(con, glue(
    'CREATE TABLE {tbl_name}(',
    paste(historic_col_names, historic_col_sql_types, collapse = ', '),
    ')'))

  DBI::dbExecute(con,
            glue("COPY {tbl_name} from '{csv_file}' ( HEADER, TIMESTAMPFORMAT '{ems_timestamp_format()}' )")
  )

  message("Adding database indexes")
  cat("=")
  add_sql_index(con, colname = "EMS_ID")
  cat("=")
  add_sql_index(con, colname = "COLLECTION_START")
  cat("=")
  add_sql_index(con, colname = "COLLECTION_END")
  cat("=")
  add_sql_index(con, colname = "LOCATION_PURPOSE")
  cat("=")
  add_sql_index(con, colname = "SAMPLE_CLASS")
  cat("=")
  add_sql_index(con, colname = "SAMPLE_STATE")
  cat("=")
  add_sql_index(con, colname = "PARAMETER")
  cat("=")
  add_sql_index(con, colname = "PARAMETER_CODE")

  cat("| 100%\n")

  invisible(TRUE)
}
