``` r
library(tictoc)
library(rems)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

start <- tic("download")
download_historic_data(TRUE, FALSE)
#> This is going to take a while...
#> Downloading latest 'historic' EMS data
#> Unzipping...
#> Saving historic data at /Users/ateucher/Library/Application Support/rems/ems_historic.sqlite
#> Creating indexes
#> Successfully downloaded and stored the historic EMS data.
#> You can access and subset it with the 'read_historic_data' function, or
#>         attach it as a remote data.frame with 'connect_historic_db()' and
#>         'attach_historic_data()' which you can then query with dplyr
toc()
#> download: 1144.59 sec elapsed
tic("connect")
con <- connect_historic_db()
#> Please remember to use 'disconnect_historic_db()' when you are finished querying the historic database.
toc()
#> connect: 0.112 sec elapsed
tic("attach")
hist_tbl <- attach_historic_data(con)
toc()
#> attach: 0.67 sec elapsed
tic("dplyr")
hist_df <- hist_tbl %>%
  select(EMS_ID, PARAMETER, COLLECTION_START, RESULT) %>%
  filter(EMS_ID %in% c("0121580", "0126400"),
         PARAMETER %in% c("Aluminum Total", "Cadmium Total",
                          "Copper Total", " Zinc Total",
                          "Turbidity")) %>%
  collect()
toc()
#> dplyr: 0.666 sec elapsed
tic("disconnect")
disconnect_historic_db(con)
end <- toc()
#> disconnect: 0.002 sec elapsed

# Total time:
end$toc - start
#>  elapsed 
#> 1146.055
```

<sup>Created on 2021-01-25 by the [reprex package](https://reprex.tidyverse.org) (v0.3.0)</sup>
