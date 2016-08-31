#' Download and store the large historic ems dataset
#'
#' @param n the chunk size to use to iteratively read and store the historic data (default 1 million)
#' @param force Force downloading the dataset, even if it's not out of date (default \code{FALSE})
#'
#' @return The path where the sqlite database is stored (invisibly).
#' @export
#'
#' @importFrom DBI dbConnect dbWriteTable dbDisconnect
#' @importFrom RSQLite SQLite
#'
download_historic_data <- function(n = 1e6, force = FALSE) {
  message("This is going to take a while...")

  file_meta <- get_file_metadata()["historic",]
  update_date <- get_update_date("historic")

  db_path <- write_db_path()

  if (update_date >= file_meta[["date_upd"]] && file.exists(db_path) && !force) {
    stop("It appears that you already have the most up-to date version of the",
         "historic ems data.")
  }

  url <- paste(base_url(), file_meta[["filename"]], sep = "/")
  message("Downloading latest 'historic' EMS data from BC Data Catalogue (url:", url, ")")
  csv_file <- download_ems_data(url)
  save_historic_data(csv_file, db_path, n)

  set_update_date("historic", file_meta[["date_upd"]])

  message("Successfully downloaded and stored the historic EMS data.\n",
          "You can access it with the 'read_historic_data' function")
  invisible(db_path)
}

save_historic_data <- function(csv_file, db_path, n) {
  message("Saving historic data at ", db_path)
  data <- read_ems_data(csv_file, n = n, cols = NULL, verbose = FALSE,
                        progress = FALSE)
  col_names <- all_cols()

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
      DBI::dbWriteTable(con, data, name = tbl_name, overwrite = TRUE)
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
  cat("| 100%")
  invisible(TRUE)
}

#' Read historic ems data into R.
#'
#' You will need to have run \code{\link{download_historic_data}} before you
#' can use this function
#'
#' @param emsid the EMS_ID(s) of the stations you want
#' @param parameter the parameter(s) of the stations you want
#' @param from_date start date
#' @param to_date end date
#' @param cols colums. Default "wq". See \code{link{get_ems_data}} for further documentation.
#'
#' @return a data frame of the results
#' @export
#'
#' @importFrom DBI dbConnect dbDisconnect dbGetQuery
read_historic_data <- function(emsid = NULL, parameter = NULL, from_date = NULL,
                               to_date = NULL, cols = "wq") {

  file_meta <- get_file_metadata()["historic",]
  update_date <- get_update_date("historic")
  db_path <- write_db_path()

  ## Check for missing or outdated historic database
  exit_fun <- FALSE
  if (!file.exists(db_path)) {
    exit_fun <- TRUE
  } else if (update_date < file_meta[["date_upd"]] && file.exists(db_path)) {
    ans <- readline(paste("Your version of the historic dataset is out of date.",
                          "Would you like to continue with the version you have (y/n)? ",
                          sep = "\n"))
    if (tolower(ans) != "y") exit_fun <- TRUE
  }
  if (exit_fun) stop("Please download the historic data with\n",
                 " the 'download_historic_data' function.")

  qry <- construct_historic_sql(emsid = emsid, parameter = parameter,
                                from_date = from_date, to_date = to_date,
                                cols = cols)

  con <- DBI::dbConnect(RSQLite::SQLite(), dbname = db_path)
  on.exit(DBI::dbDisconnect(con))

  res <- DBI::dbGetQuery(con, qry)

  if (!is.null(res$COLLECTION_START))
    res$COLLECTION_START <- ems_posix_numeric(res$COLLECTION_START)
  if (!is.null(res$COLLECTION_END))
    res$COLLECTION_END <- ems_posix_numeric(res$COLLECTION_END)

  tibble::as_tibble(res)

}

construct_historic_sql <- function(emsid = NULL, parameter = NULL,
                                   from_date = NULL, to_date = NULL, cols = NULL) {
  emsid_qry <- parameter_qry <- from_date_qry <- to_date_qry <- col_query <- NULL
  if (!is.null(emsid)) {
    emsid_qry <- sprintf("EMS_ID IN (%s)", stringify_vec(emsid))
  }
  if (!is.null(parameter)) {
    parameter_qry <- sprintf("PARAMETER IN (%s)", stringify_vec(parameter))
  }
  if (!is.null(from_date)) {
    from_date <- as.integer(as.POSIXct(from_date, tz = ems_tz()))
    from_date_qry <- sprintf("COLLECTION_START >= %s", from_date)
  }
  if (!is.null(to_date)) {
    to_date <- as.integer(as.POSIXct(to_date, tz = ems_tz()))
    to_date_qry <- sprintf("COLLECTION_START <= %s", to_date)
  }
  row_query_vec <- c(emsid_qry, parameter_qry, from_date_qry, to_date_qry)
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

stringify_vec <- function(vec) {
  paste(shQuote(vec, "sh"), collapse = ",")
}

write_db_path <- function() {
  file.path(rappdirs::user_data_dir("rems"), "ems.sqlite")
}

ems_posix_numeric <- function(x) {
  as.POSIXct(x, origin = "1970/01/01", tz = ems_tz())
}
