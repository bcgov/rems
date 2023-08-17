
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rems 0.8.1

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/bcgov/rems/branch/master/graph/badge.svg)](https://codecov.io/gh/bcgov/rems?branch=master)
[![License](https://img.shields.io/badge/License-Apache2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![CRAN
status](https://www.r-pkg.org/badges/version/rems)](https://cran.r-project.org/package=rems)
[![R build
status](https://github.com/bcgov/rems/workflows/R-CMD-check/badge.svg)](https://github.com/bcgov/rems/actions)
[![img](https://img.shields.io/badge/Lifecycle-Maturing-007EC6)](https://github.com/bcgov/repomountie/blob/master/doc/lifecycle-badges.md)
[![R-CMD-check](https://github.com/bcgov/rems/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bcgov/rems/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Overview

An [R](https://www.r-project.org) package to download, import, and
filter data from [B.C.’s Environmental Monitoring System
(EMS)](http://www2.gov.bc.ca/gov/content?id=47D094EF8CF94B5A85F62F03D4956C0C)
into R.

The package pulls data from the [B.C. Data Catalogue EMS
Results](https://catalogue.data.gov.bc.ca/dataset/949f2233-9612-4b06-92a9-903e817da659),
which is licenced under the [Open Government Licence - British
Columbia](http://www2.gov.bc.ca/gov/content?id=A519A56BC2BF44E4A008B33FCF527F61).

## Installation

The package is not available on CRAN, but can be installed using the
[devtools](https://github.com/hadley/devtools) package:

``` r
# install.packages("devtools") # if not already installed

library(devtools)
install_github("bcgov/rems")
```

If you are asked during installation *“Would you like to install from
source the packages which require compilation”*, choose **“No”**.

## Usage

**NOTE:** If you are using Windows, you must be running the 64-bit
version of R, as the 32-bit version cannot handle the size of the EMS
data. In RStudio, click on Tools -\> Global Options and ensure the 64
bit version is chosen in the *R version* box.

You can use the `get_ems_data()` function to get last two years of data
(you can also specify `which = "4yr"` to get the last four years of
data):

``` r
library(rems)
two_year <- get_ems_data(which = "2yr", ask = FALSE)
#> Downloading latest '2yr' EMS data from BC Data Catalogue (url: https://pub.data.gov.bc.ca/datasets/949f2233-9612-4b06-92a9-903e817da659/ems_sample_results_current_expanded.csv)
#> Reading data from file...
#> Caching data on disk...
#> Loading data...
nrow(two_year)
#> [1] 2231866
head(two_year)
#> # A tibble: 6 × 24
#>   EMS_ID  REQUISITION_ID MONITORING_LOCATION    LATITUDE LONGITUDE LOCATION_TYPE
#>   <chr>   <chr>          <chr>                     <dbl>     <dbl> <chr>        
#> 1 0120802 6983960101     COWICHAN RIVER AT HIG…     48.8     -124. RIVER,STREAM…
#> 2 0120802 6983960101     COWICHAN RIVER AT HIG…     48.8     -124. RIVER,STREAM…
#> 3 0120802 6983960101     COWICHAN RIVER AT HIG…     48.8     -124. RIVER,STREAM…
#> 4 0120802 6983960101     COWICHAN RIVER AT HIG…     48.8     -124. RIVER,STREAM…
#> 5 0120802 6983960101     COWICHAN RIVER AT HIG…     48.8     -124. RIVER,STREAM…
#> 6 0120802 6983960101     COWICHAN RIVER AT HIG…     48.8     -124. RIVER,STREAM…
#> # ℹ 18 more variables: COLLECTION_START <dttm>, LOCATION_PURPOSE <chr>,
#> #   PERMIT <chr>, SAMPLE_CLASS <chr>, SAMPLE_STATE <chr>,
#> #   SAMPLE_DESCRIPTOR <chr>, PARAMETER_CODE <chr>, PARAMETER <chr>,
#> #   ANALYTICAL_METHOD_CODE <chr>, ANALYTICAL_METHOD <chr>, RESULT_LETTER <chr>,
#> #   RESULT <dbl>, UNIT <chr>, METHOD_DETECTION_LIMIT <dbl>, MDL_UNIT <chr>,
#> #   QA_INDEX_CODE <chr>, UPPER_DEPTH <dbl>, LOWER_DEPTH <dbl>
```

By default, `get_ems_data` imports only a subset of columns that are
useful for water quality analysis. This is controlled by the `cols`
argument, which has a default value of `"wq"`. This can be set to
`"all"` to download all of the columns, or a character vector of column
names (see `?get_ems_data` for details).

You can filter the data to just get the records you want:

``` r
filtered_2yr <- filter_ems_data(two_year, emsid = c("0121580", "0126400"),
  parameter = c("Aluminum Total", "Cadmium Total",
    "Copper Total", " Zinc Total",
    "Turbidity"),
  from_date = "2011/02/06",
  to_date = "2015/12/31")
```

## Historic data

You can also get the entire historic dataset, which has records back to
1964.

First download the dataset using `download_historic_data`, which
downloads the data and stores it in a [**DuckDB**](https://duckdb.org/)
database:

``` r
download_historic_data(ask = FALSE)
```

There are two ways to pull data from the historic dataset into R:

### 1. `read_historic_data()`

Read in the historic data, supplying constraints to only import the
records you want:

``` r
filtered_historic <- read_historic_data(emsid = c("0121580", "0126400"),
  parameter = c("Aluminum Total", "Cadmium Total",
    "Copper Total", "Zinc Total",
    "Turbidity"),
  from_date = "2001/02/05",
  to_date = "2011/12/31",
  check_db = FALSE)
```

### 2. `dplyr`

You can also query the historic database using `dplyr`, which ultimately
gives you more flexibility than using `read_historic_data`:

First, create a connection to the database using
`connect_historic_db()`, then attach the historic database table to your
R session using `attach_historic_data()`. This creates an object which
behaves like a data frame, which you can query with dplyr. The advantage
is that the computation is done in the database rather than importing
all of the records into R (which would likely be impossible). This is
illustrated below:

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
hist_db_con <- connect_historic_db()
#> Warning in connect_historic_db(): This version of rems running under R 4.3
#> causes the time component of COLLECTION_START and COLLECTION_END to be omitted
#> when query results are returned. This will be fixed soon via the next release
#> of the duckdb package (See https://github.com/bcgov/rems/issues/79).
#> Please remember to use 'disconnect_historic_db()' when you are finished querying the historic database.
hist_tbl <- attach_historic_data(hist_db_con)
```

You can then query this object with dplyr:

``` r
filtered_historic2 <- hist_tbl %>%
  select(EMS_ID, PARAMETER, COLLECTION_START, RESULT) %>%
  filter(EMS_ID %in% c("0121580", "0126400"),
    PARAMETER %in% c("Aluminum Total", "Cadmium Total",
      "Copper Total", " Zinc Total",
      "Turbidity"))
```

Finally, to get the results into your R session as a regular data frame,
you must `collect()` it. Note that date/times are returned to R in the
Pacific Standard Time timezone (PST; UTC-8).

You can combine the previously imported historic and two_year data sets
using `bind_ems_data`:

``` r
all_data <- bind_ems_data(filtered_2yr, filtered_historic)
head(all_data)
#> # A tibble: 6 × 24
#>   EMS_ID  REQUISITION_ID MONITORING_LOCATION    LATITUDE LONGITUDE LOCATION_TYPE
#>   <chr>   <chr>          <chr>                     <dbl>     <dbl> <chr>        
#> 1 0126400 08195503       QUINSAM RIVER AT THE …     50.0     -125. RIVER,STREAM…
#> 2 0126400 08308654       QUINSAM RIVER AT THE …     50.0     -125. RIVER,STREAM…
#> 3 0126400 <NA>           QUINSAM RIVER AT THE …     50.0     -125. RIVER,STREAM…
#> 4 0121580 08170541       ENGLISHMAN RIVER AT P…     49.3     -124. RIVER,STREAM…
#> 5 0126400 08120854       QUINSAM RIVER AT THE …     50.0     -125. RIVER,STREAM…
#> 6 0121580 08189653       ENGLISHMAN RIVER AT P…     49.3     -124. RIVER,STREAM…
#> # ℹ 18 more variables: COLLECTION_START <dttm>, LOCATION_PURPOSE <chr>,
#> #   PERMIT <chr>, SAMPLE_CLASS <chr>, SAMPLE_STATE <chr>,
#> #   SAMPLE_DESCRIPTOR <chr>, PARAMETER_CODE <chr>, PARAMETER <chr>,
#> #   ANALYTICAL_METHOD_CODE <chr>, ANALYTICAL_METHOD <chr>, RESULT_LETTER <chr>,
#> #   RESULT <dbl>, UNIT <chr>, METHOD_DETECTION_LIMIT <dbl>, MDL_UNIT <chr>,
#> #   QA_INDEX_CODE <chr>, UPPER_DEPTH <dbl>, LOWER_DEPTH <dbl>
```

## Units

There are many cases in EMS data where the unit of the `RESULT` (in the
`UNIT` column) is different from that of `METHOD_DETECTION_LIMIT`
(`MDL_UNIT` column). The `standardize_mdl_units()` function converts the
`METHOD_DETECTION_LIMIT` values to the same unit as `RESULT`, and
updates the `MDL_UNIT` column accordingly:

``` r
# look at data with mismatched units:
filter(all_data, UNIT != MDL_UNIT) %>% 
  select(RESULT, UNIT, METHOD_DETECTION_LIMIT, MDL_UNIT) %>% 
  head()
#> # A tibble: 6 × 4
#>    RESULT UNIT  METHOD_DETECTION_LIMIT MDL_UNIT
#>     <dbl> <chr>                  <dbl> <chr>   
#> 1 0.00113 mg/L                    0.02 ug/L    
#> 2 0.00036 mg/L                    0.05 ug/L    
#> 3 0.00142 mg/L                    0.02 ug/L    
#> 4 0.897   mg/L                    0.2  ug/L    
#> 5 0.19    mg/L                    0.2  ug/L    
#> 6 0.00068 mg/L                    0.05 ug/L

all_data <- standardize_mdl_units(all_data)
#> Successfully converted units in 2172 rows.

# Check again
filter(all_data, UNIT != MDL_UNIT) %>% 
  select(RESULT, UNIT, METHOD_DETECTION_LIMIT, MDL_UNIT) %>% 
  head()
#> # A tibble: 4 × 4
#>     RESULT UNIT  METHOD_DETECTION_LIMIT MDL_UNIT
#>      <dbl> <chr>                  <dbl> <chr>   
#> 1 0.00065  mg/L                      NA ug/L    
#> 2 0.000005 mg/L                      NA ug/L    
#> 3 0.00065  mg/L                      NA ug/L    
#> 4 0.0122   mg/L                      NA ug/L
```

Then you can plot your data with ggplot2:

``` r
library(ggplot2)

ggplot(all_data, aes(x = COLLECTION_START, y = RESULT)) +
  geom_point() +
  facet_grid(PARAMETER ~ EMS_ID, scales = "free_y")
```

![](fig/README-unnamed-chunk-11-1.png)<!-- -->

When you are finished querying the historic database, you should close
the database connection using `disconnect_historic_db()`:

``` r
disconnect_historic_db(hist_db_con)
```

When the data are downloaded from the B.C. Data Catalogue, they are
cached so that you don’t have to download it every time you want to use
it. If there is newer data available in the Catalogue, you will be
prompted the next time you use `get_ems_data` or
`download_historic_data`.

If you want to remove the cached data, use the function
`remove_data_cache`. You can remove all the data, or just the
“historic”, “2yr”, or “4yr”:

``` r
remove_data_cache("2yr")
#> Removing 2yr data from your local cache...
```

## Long-term lake monitoring site search functions

There are two ways to select active sites in the long-term lake
monitoring program. The `lt_lake_sites` function selects the `EMS_ID` of
active sites. The `lt_lake_req` function selects the `REQUISITION_ID` of
active sites. Using the `lt_lake_sites` will provide all data collected
under the `EMS_ID`, whereas using `lt_lake_req` will filter data
collected by the long-term lakes monitoring group. Both functions can be
used with `filter_ems_data` to easily pull data from active long-term
lake monitoring sites.

``` r
head(lt_lake_sites())
#> [1] "1100844" "1100953" "E207466" "E217509" "E217508" "E217507"
head(lt_lake_req())
#> [1] "50223257" "50223255" "50223254" "50223253" "50223252" "50223251"

#use with filter_ems_data
filtered_2yr_lt_lakes_ems <- filter_ems_data(two_year, emsid = lt_lake_sites(),
  parameter = c("Aluminum Total", "Cadmium Total",
    "Copper Total", " Zinc Total",
    "Turbidity"))
head(filtered_2yr_lt_lakes_ems)
#> # A tibble: 6 × 24
#>   EMS_ID  REQUISITION_ID MONITORING_LOCATION    LATITUDE LONGITUDE LOCATION_TYPE
#>   <chr>   <chr>          <chr>                     <dbl>     <dbl> <chr>        
#> 1 0200052 50257596       WINDERMERE L. OFF TIM…     50.5     -116. LAKE OR POND 
#> 2 0200052 50257596       WINDERMERE L. OFF TIM…     50.5     -116. LAKE OR POND 
#> 3 0200052 50257596       WINDERMERE L. OFF TIM…     50.5     -116. LAKE OR POND 
#> 4 0200052 50257596       WINDERMERE L. OFF TIM…     50.5     -116. LAKE OR POND 
#> 5 0200052 50257596       WINDERMERE L. OFF TIM…     50.5     -116. LAKE OR POND 
#> 6 0200052 50257596       WINDERMERE L. OFF TIM…     50.5     -116. LAKE OR POND 
#> # ℹ 18 more variables: COLLECTION_START <dttm>, LOCATION_PURPOSE <chr>,
#> #   PERMIT <chr>, SAMPLE_CLASS <chr>, SAMPLE_STATE <chr>,
#> #   SAMPLE_DESCRIPTOR <chr>, PARAMETER_CODE <chr>, PARAMETER <chr>,
#> #   ANALYTICAL_METHOD_CODE <chr>, ANALYTICAL_METHOD <chr>, RESULT_LETTER <chr>,
#> #   RESULT <dbl>, UNIT <chr>, METHOD_DETECTION_LIMIT <dbl>, MDL_UNIT <chr>,
#> #   QA_INDEX_CODE <chr>, UPPER_DEPTH <dbl>, LOWER_DEPTH <dbl>

filtered_2yr_lt_lakes_req <- filter_ems_data(two_year, req_id = lt_lake_req(),
  parameter = c("Aluminum Total", "Cadmium Total",
    "Copper Total", " Zinc Total",
    "Turbidity"))
head(filtered_2yr_lt_lakes_req)
#> # A tibble: 0 × 24
#> # ℹ 24 variables: EMS_ID <chr>, REQUISITION_ID <chr>,
#> #   MONITORING_LOCATION <chr>, LATITUDE <dbl>, LONGITUDE <dbl>,
#> #   LOCATION_TYPE <chr>, COLLECTION_START <dttm>, LOCATION_PURPOSE <chr>,
#> #   PERMIT <chr>, SAMPLE_CLASS <chr>, SAMPLE_STATE <chr>,
#> #   SAMPLE_DESCRIPTOR <chr>, PARAMETER_CODE <chr>, PARAMETER <chr>,
#> #   ANALYTICAL_METHOD_CODE <chr>, ANALYTICAL_METHOD <chr>, RESULT_LETTER <chr>,
#> #   RESULT <dbl>, UNIT <chr>, METHOD_DETECTION_LIMIT <dbl>, MDL_UNIT <chr>, …
```

## Project Status

Under development, but stable. Unlikely to break or change
substantially.

## Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an
[issue](https://github.com/bcgov/rems/issues).

## How to Contribute

If you would like to contribute to the package, please see our
[CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of
Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree
to abide by its terms.

## License

    Copyright 2016 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at 

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

This repository is maintained by [Environmental Reporting
BC](http://www2.gov.bc.ca/gov/content?id=FF80E0B985F245CEA62808414D78C41B).
Click [here](https://github.com/bcgov/EnvReportBC-RepoList) for a
complete list of our repositories on GitHub.
