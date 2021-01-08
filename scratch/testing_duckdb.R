library(dplyr)

con <- connect_historic_db()

hist_tbl <- attach_historic_data(con)
four_year <- get_ems_data("4yr")

four_yr_20170101 <- filter(four_year, COLLECTION_START == as.POSIXct("2017-01-01")) %>%
  arrange(EMS_ID, PERMIT, PARAMETER_CODE, RESULT)

hist_20170101 <- hist_tbl %>%
  select(all_of(names(four_yr_20170101))) %>%
  filter(COLLECTION_START == as.POSIXct("2017-01-01")) %>%
  collect() %>%
  mutate(COLLECTION_START = set_ems_tz(COLLECTION_START)) %>%
  arrange(EMS_ID, PERMIT, PARAMETER_CODE, RESULT)

all.equal(hist_20170101, four_yr_20170101, check.attributes = FALSE)

disconnect_historic_db(con)
rm(hist_tbl, con)
