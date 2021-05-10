# Copyright 2019 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

## To update the sqlite database you must have write access to
## https://github.com/bcgov/rems, and have a GitHub personal access token (with
## necessary scope) saved as an environment variable (preferably GITHUB_PAT)

# Download csv, create sqlite, and zip it.
#nocov start
url <- "https://pub.data.gov.bc.ca/datasets/949f2233-9612-4b06-92a9-903e817da659/ems_sample_results_historic_expanded.csv"
csv_file <- rems:::download_ems_data(url)
db_file <- path.expand("~/Desktop/ems_historic.sqlite")
rems:::save_historic_data(csv_file, db_file, 1e6)
zipfile <- paste0(db_file, ".zip")
zip::zipr(zipfile, db_file, include_directories = FALSE)

# Then delete the old (if replacing on an existing release)
release <- get_gh_release("latest")
asset_id <- release$assets[[1]]$id[release$assets[[1]]$name == basename(zipfile)]
delete_release_asset(asset_id)

# And upload the new one
upload_release_asset(zipfile)

# Test getting it
rems:::download_file_from_release("ems_historic.sqlite.zip",
                                  file.path(dirname(rems:::write_db_path()),
                                            "ems_historic.sqlite.zip"))
#nocov end