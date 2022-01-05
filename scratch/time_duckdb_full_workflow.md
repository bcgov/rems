Test timing with duckdb backend
================
2021-02-03 23:03:09

``` r
library(tictoc)
library(rems)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
packageVersion("duckdb") # 0.2.5, unreleased commit 57ed79e8ff17eedde0483509d4202e9e716e16ab
```

    ## [1] '0.2.5'

``` r
start <- tic("download")
download_historic_data(TRUE, FALSE)
```

    ## This is going to take a while...

    ## Downloading latest 'historic' EMS data

    ## Unzipping...

    ## Saving historic data at /Users/ateucher/Library/Application Support/rems/duckdb/ems_historic.duckdb

    ## Adding database indexes

    ## Successfully downloaded and stored the historic EMS data.
    ## You can access and subset it with the 'read_historic_data' function, or
    ##         attach it as a remote data.frame with 'connect_historic_db()' and
    ##         'attach_historic_data()' which you can then query with dplyr

``` r
toc()
```

    ## download: 552.625 sec elapsed

``` r
tic("connect")
con <- connect_historic_db()
```

    ## Please remember to use 'disconnect_historic_db()' when you are finished querying the historic database.

``` r
toc()
```

    ## connect: 0.078 sec elapsed

``` r
tic("attach")
hist_tbl <- attach_historic_data(con)
toc()
```

    ## attach: 0.559 sec elapsed

``` r
tic("dplyr")
hist_df <- hist_tbl %>%
  select(EMS_ID, PARAMETER, COLLECTION_START, RESULT) %>%
  filter(EMS_ID %in% c("0121580", "0126400"),
         PARAMETER %in% c("Aluminum Total", "Cadmium Total",
                          "Copper Total", " Zinc Total",
                          "Turbidity")) %>%
  collect()
toc()
```

    ## dplyr: 2.924 sec elapsed

``` r
tic("disconnect")
disconnect_historic_db(con)
end <- toc()
```

    ## disconnect: 0.107 sec elapsed

``` r
# Total time:
end$toc - start
```

    ## elapsed 
    ## 556.302
