library(duckdb)
con <- DBI::dbConnect(duckdb::duckdb(), dbdir = "local_database")

dbExecute(con, paste0(
  "CREATE TABLE ems_manual_import(",
  paste(col_specs("names_only"), col_specs("sql"), sep = " ", collapse = ", "),
  ")"))

dbExecute(con,
          paste0("COPY ems_manual_import from '",
                 normalizePath("tests/testthat/test_current.csv"),
                 "' ( HEADER, TIMESTAMPFORMAT '%Y%m%d%H%M%S' )")
)

dbGetQuery(con, "select * from ems_manual_import")
