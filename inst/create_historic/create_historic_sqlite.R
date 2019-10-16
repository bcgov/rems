
# Download csv, create sqlite, and zip it.
url <- "https://pub.data.gov.bc.ca/datasets/949f2233-9612-4b06-92a9-903e817da659/ems_sample_results_historic_expanded.csv"
csv_file <- rems:::download_ems_data(url)
db_file <- path.expand("~/Desktop/ems_historic.sqlite")
rems:::save_historic_data(csv_file, db_file, 1e6)
zipfile <- paste0(db_file, ".zip")
zip::zipr(zipfile, db_file, include_directories = FALSE)

# Then manually attach to release (can change to doing it via api a la bcmapsdata)
# This isn't working as errors with 413 (file too large)
rems:::upload_release_asset(zipfile)

# Test getting it
rems:::download_file_from_release("ems_historic.sqlite.zip",
                                  file.path(dirname(rems:::write_db_path()),
                                            "ems_historic.sqlite.zip"))
