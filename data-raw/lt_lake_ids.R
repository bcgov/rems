## code to prepare `lt_lake_ids` dataset

library(dplyr)
library(magrittr)
library(readr)
library(stringr)

trim_all_ws <- function(tbl) {
  as_tibble(lapply(tbl, str_trim, side = "both"))
}

lt_lake_ids <- read_csv("data-raw/all_reqs.csv") %>%
  trim_all_ws()


usethis::use_data(lt_lake_ids, overwrite = TRUE)

