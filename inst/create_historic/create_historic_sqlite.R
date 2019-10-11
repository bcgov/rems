
url <- "https://pub.data.gov.bc.ca/datasets/949f2233-9612-4b06-92a9-903e817da659/ems_sample_results_historic_expanded.csv"

csv_file <- rems:::download_ems_data(url)

db_file <- "/Users/ateucher/ems_historic_2019-10-11.sqlite"

rems:::save_historic_data(csv_file, db_file, 1e6)

zip(paste0(db_file, ".zip"), db_file)


# Test getting it
rems:::download_file_from_release("ems_historic.sqlite.zip",
                                  file.path(dirname(rems:::write_db_path()),
                                            "ems_historic.sqlite.zip"))
