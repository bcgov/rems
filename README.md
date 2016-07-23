
<!-- README.md is generated from README.Rmd. Please edit that file -->
<a rel="Exploration" href="https://github.com/BCDevExchange/docs/blob/master/discussion/projectstates.md"><img alt="Being designed and built, but in the lab. May change, disappear, or be buggy." style="border-width:0" src="http://bcdevexchange.org/badge/2.svg" title="Being designed and built, but in the lab. May change, disappear, or be buggy." /></a>

------------------------------------------------------------------------

rems
====

### Features

-   Download and import data from EMS into R.

### Installation

The package is not available on CRAN, but can be installed using the [devtools](https://github.com/hadley/devtools) package:

``` r
install.packages("devtools") # if not already installed

library(devtools)
install_github("bcgov/rems")
```

### Usage

Currently there is only one function, `get_ems_data()`:

``` r
library(rems)
data <- get_ems_data()
head(data[1:22])
#>    EMS_ID          MONITORING_LOCATION LATITUDE LONGITUDE
#> 1 0121580 ENGLISHMAN R. AT HIGHWAY 19A  49.3011 -124.2756
#> 2 0121580 ENGLISHMAN R. AT HIGHWAY 19A  49.3011 -124.2756
#> 3 0121580 ENGLISHMAN R. AT HIGHWAY 19A  49.3011 -124.2756
#> 4 0121580 ENGLISHMAN R. AT HIGHWAY 19A  49.3011 -124.2756
#> 5 0121580 ENGLISHMAN R. AT HIGHWAY 19A  49.3011 -124.2756
#> 6 0121580 ENGLISHMAN R. AT HIGHWAY 19A  49.3011 -124.2756
#>           LOCATION_TYPE    COLLECTION_START      COLLECTION_END
#> 1 RIVER,STREAM OR CREEK 2015-01-05 08:55:00 2015-01-05 08:55:00
#> 2 RIVER,STREAM OR CREEK 2015-01-05 08:55:00 2015-01-05 08:55:00
#> 3 RIVER,STREAM OR CREEK 2015-01-05 08:55:00 2015-01-05 08:55:00
#> 4 RIVER,STREAM OR CREEK 2015-01-05 08:55:00 2015-01-05 08:55:00
#> 5 RIVER,STREAM OR CREEK 2015-01-05 08:55:00 2015-01-05 08:55:00
#> 6 RIVER,STREAM OR CREEK 2015-01-05 08:55:00 2015-01-05 08:55:00
#>   REQUISITION_ID SAMPLING_AGENCY      ANALYZING_AGENCY
#> 1       08402387   Water Quality Maxxam Analytics Inc.
#> 2       08402387   Water Quality Maxxam Analytics Inc.
#> 3       08402387   Water Quality Maxxam Analytics Inc.
#> 4       08402387   Water Quality Maxxam Analytics Inc.
#> 5       08402387   Water Quality Maxxam Analytics Inc.
#> 6       08402387   Water Quality Maxxam Analytics Inc.
#>         COLLECTION_METHOD SAMPLE_CLASS SAMPLE_STATE SAMPLE_DESCRIPTOR
#> 1 Grab - Discrete Samples      Regular  Fresh Water           General
#> 2 Grab - Discrete Samples      Regular  Fresh Water           General
#> 3 Grab - Discrete Samples      Regular  Fresh Water           General
#> 4 Grab - Discrete Samples      Regular  Fresh Water           General
#> 5 Grab - Discrete Samples      Regular  Fresh Water           General
#> 6 Grab - Discrete Samples      Regular  Fresh Water           General
#>   PARAMETER_CODE                     PARAMETER ANALYTICAL_METHOD_CODE
#> 1           0002                    Color True                   X106
#> 2           0004                            pH                   5065
#> 3           0008 Residue: Non-filterable (TSS)                   1071
#> 4           0011          Specific Conductance                   X330
#> 5           0015                     Turbidity                   XM08
#> 6           0020             Temperature (Air)                   XM02
#>                     ANALYTICAL_METHOD RESULT_LETTER RESULT     UNIT
#> 1           Lab Cent;Visual Compariso          <NA>  36.00 Col.unit
#> 2 Meter: Glass/Ref Low Ionic Strength          <NA>   7.33 pH units
#> 3             Grav; Subsamp Buch 105C          <NA>  12.80     mg/L
#> 4                               Meter          <NA>  56.90    uS/cm
#> 5                        Nephelometer          <NA>   7.30      NTU
#> 6                         Thermometer          <NA>   5.40        C
#>   METHOD_DETECTION_LIMIT
#> 1                    5.0
#> 2                     NA
#> 3                    1.0
#> 4                    1.0
#> 5                    0.1
#> 6                    0.0
```

### Project Status

The package is under active development.

### Getting Help or Reporting an Issue

To report bugs/issues/feature requests, please file an [issue](https://github.com/bcgov/rcaaqs/issues/).

### How to Contribute

If you would like to contribute to the package, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

### License

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

This repository is maintained by [Environmental Reporting BC](http://www2.gov.bc.ca/gov/content?id=FF80E0B985F245CEA62808414D78C41B). Click [here](https://github.com/bcgov/EnvReportBC-RepoList) for a complete list of our repositories on GitHub.
