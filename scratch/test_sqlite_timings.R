library(tictoc)
library(rems)
library(dplyr)

start <- tic("download")
download_historic_data(TRUE, FALSE)
toc()
tic("connect")
con <- connect_historic_db()
toc()
tic("attach")
hist_tbl <- attach_historic_data(con)
toc()
tic("dplyr")
hist_df <- hist_tbl %>%
  select(EMS_ID, PARAMETER, COLLECTION_START, RESULT) %>%
  filter(EMS_ID %in% c("0121580", "0126400"),
         PARAMETER %in% c("Aluminum Total", "Cadmium Total",
                          "Copper Total", " Zinc Total",
                          "Turbidity")) %>%
  collect()
toc()
tic("disconnect")
disconnect_historic_db(con)
end <- toc()

# Total time:
end$toc - start
