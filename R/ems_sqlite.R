#' Download and store the large historic ems data
#'
#' @param n the chunk size to use to iteratively read and store the historic data
#'
#' @return TRUE
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

  return(TRUE)
}

save_historic_data <- function(csv_file, db_path, n) {
  message("Loading chunk 1")
  data <- read_ems_data(csv_file, n = n, cols = NULL, verbose = FALSE)
  col_names <- all_cols()

  #setting up sqlite

  con <- DBI::dbConnect(RSQLite::SQLite(), dbname = db_path)
  on.exit(DBI::dbDisconnect(con))
  tbl_name <- "historic"

  i <- 1
  while (nrow(data) == n) { # if not reached the end of line
    message("Loading chunk ", i + 1)
    skip <- i * n + 1
    if (i == 1) {
      DBI::dbWriteTable(con, data, name = tbl_name, overwrite = TRUE)
    } else {
      DBI::dbWriteTable(con, data, name = tbl_name, append = TRUE) #write to sqlite
    }
    data <- read_ems_data(csv_file, n = n, skip = skip, cols = col_names,
                          col_names = col_names, verbose = FALSE)
    i <- i + 1
  }

  if (nrow(data) > 0 ) {
    DBI::dbWriteTable(con, data, name = tbl_name, append = TRUE)
  }
}

read_historic_data <- function(emsid = NULL, parameter = NULL, from_date = NULL,
                               to_date = NULL) {
  db <- dplyr::src_sqlite(write_db_path(), create = FALSE)
  tbl <- dplyr::tbl(db, "historic")
  filter_ems_data(x = tbl, emsid = emsid, parameter = parameter,
                  from_date = from_date, to_date = to_date)
}

write_db_path <- function() {
  file.path(rappdirs::user_data_dir("rems"), "ems.sqlite")
}
