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

## Compare date range with 2yr
max_dt <- dbGetQuery(con, "SELECT max(COLLECTION_START) max_dt from historic;")

set_ems_tz(max_dt[[1]])
# [1] "2019-12-31 23:59:00 -08"

two_year <- get_ems_data("2yr")

min(two_year$COLLECTION_START)
# [1] "2020-01-01 -08"

disconnect_historic_db(con)
rm(hist_tbl, con)
