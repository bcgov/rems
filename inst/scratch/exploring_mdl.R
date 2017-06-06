library(rems)
library(dplyr)
library(readr)

foo <- read_historic_data(emsid = "E206585", cols = "all", param_code = "LA-T")

bar <- foo %>% left_join(ems_parameters, by = c("ANALYTICAL_METHOD_CODE", "PARAMETER_CODE"),
                         suffix = c(".results_tbl", ".param_lu_tbl")) %>%
  select(PARAMETER.results_tbl, PARAMETER_CODE, RESULT, RESULT_LETTER, ANALYTICAL_METHOD_CODE,
         starts_with("METHOD_DETECTION_LIMIT"), starts_with("UNIT")) %>%
  arrange(RESULT, RESULT_LETTER) %>%
  head(50) %>%
  write_csv("ems_mdl.csv")
