## Prepare FP river sites

library(rems)
hist_db_con <- connect_historic_db()
hist_tbl <- attach_historic_data(hist_db_con)

hist_EMS_ID_data <- hist_tbl %>%
  filter(EMS_ID %in% c("E285129", "E269864", "E255962", "0200003", "E252119","0200559", "E206106", "0600042",

                       "0200016", "0200102", "0121580", "E271643", "E206581", "0600011", "E236796", "E256314",

                       "0920125", "0920673", "0200084", "E333673", "E206587", "E333672", "0200038", "E317790",

                       "0500046", "E279733", "E332551", "E206583", "E216848", "E255013", "0500073", "E206585",

                       "0200021", "E282116", "E282116", "E285533", "E299950", "0126400", "E206092", "E237496",

                       "E284949", "0500629", "0500073", "0920092", "0300038", "E333095", "E206586", "0600005",

                       "E310948", "E280016"))


four_year_data <- get_ems_data(which = "4yr", ask = FALSE)


Four_year_EMS_ID_data <- filter_ems_data(four_year_data, emsid = c("E285129", "E269864", "E255962", "0200003", "E252119","0200559", "E206106", "0600042",

                                                                   "0200016", "0200102", "0121580", "E271643", "E206581", "0600011", "E236796", "E256314",

                                                                   "0920125", "0920673", "0200084", "E333673", "E206587", "E333672", "0200038", "E317790",

                                                                   "0500046", "E279733", "E332551", "E206583", "E216848", "E255013", "0500073", "E206585",

                                                                   "0200021", "E282116", "E282116", "E285533", "E299950", "0126400", "E206092", "E237496",

                                                                   "E284949", "0500629", "0500073", "0920092", "0300038", "E333095", "E206586", "0600005",

                                                                   "E310948", "E280016"))

all_EMS_ID_data <- bind_ems_data(as_tibble(hist_EMS_ID_data), Four_year_EMS_ID_data)

disconnect_historic_db(hist_db_con)

FP_river_ids<-all_EMS_ID_data %>%
  filter(!is.na(PARAMETER)) %>%
  select(EMS_ID, MONITORING_LOCATION, PARAMETER, REQUISITION_ID, LATITUDE, LONGITUDE, LOCATION_TYPE,
         COLLECTION_START, COLLECTION_END, UPPER_DEPTH, LOWER_DEPTH, SAMPLE_CLASS) %>%
  distinct(.keep_all = TRUE) %>%
  select(EMS_ID, MONITORING_LOCATION, REQUISITION_ID)

usethis::use_data(FP_river_ids, overwrite = TRUE)

