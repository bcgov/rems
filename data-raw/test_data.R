library(rems)
library(dplyr)
library(readr)

## Create test column structures
col_spec()$cols %>% write_rds("tests/testthat/col_struct.RDS")
col_spec(wq_cols())$cols %>% write_rds("tests/testthat/wq_col_struct.RDS")

meta <- rems:::get_databc_metadata()

## Make a test csv of current and historic data
test_current_csv <- rems:::download_ems_data(paste0(rems:::base_url(),
                                            meta$filename[meta$label == "current"]))

read_lines(test_current_csv, n_max = 11) %>% write_lines("tests/testthat/test_current.csv")

test_historic_csv <- rems:::download_ems_data(paste0(rems:::base_url(),
                                                    meta$filename[meta$label == "historic"]))

read_lines(test_historic_csv, n_max = 11) %>% write_lines("tests/testthat/test_historic.csv")