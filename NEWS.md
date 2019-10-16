# rems 0.4.2.00009

* The historic sqlite database is now available as a direct download from a rems
release on GitHub, which should be much faster and more reliable for the user.
* User can now specify/customize the location of the sqlite database via an
option `rems.historic.path`. This is best set in your `.Rprofile` file as
`options(rems.historic.path = "path_to_file")`

# rems 0.4.2

* Added new `MDL_UNIT` column to denote the units of the minimum detection limit.

# rems 0.4.1

* Added data dictionaries (lookup tables for parameters, sample classes, units, etc)
* Added `dont_update` argument to `get_ems_data()` and `download_historic_data()` to 
bypass the check to update data (#21).
* Added `lt_lake_sites()` function t get the EMS_IDs of all of the long-term lake monitoring sites (ac34dbd)
* Added `check_only` argument (default `FALSE`) to `get_ems_data()` to allow just checking the currency 
of a rems dataset (#35 @sebdalgarno)
* Added `check_db` argument (default `TRUE`) to `read_historic_data()` so that
a user can skip checking the currency of the historic dataset (#35 @sebdalgarno)


# rems 0.4.0

* Added indexes to several key columns in the 'historic' sqlite database. This makes
loading the data slower, but makes queries and the `read_historic_data` function much faster.
* Added `param_code` argument to `filter_ems_data` and `read_historic_data`
* Added PERMIT, SAMPLE_CLASS, SAMPLE_DESCRIPTOR to default `"wq"` columns
* Renamed `load_histori_data()` to `attach_historic_data()`

# rems 0.3.0

* You can now dowload the four most recent years of data, in addition to the 
most recent two years of data, as before.
      - This is a breaking change, as previous code that called 
      `get_ems_data(which = "current")` will now throw an error. It now needs to be 
      `get_ems_data(which = "2yr")` to achieve the same result as before, or it now 
      can be `get_ems_data(which = "4yr")` to get four years of data.

# rems 0.2.0

* Added new columns to data that were added in server files (#12)
* Added LOCATION_PURPOSE and SAMPLE_STATE to 'wq' columns (#13)
* Renamed `get_update_date()` to `get_cache_date()` along with some refactoring of code for getting/setting update dates (#11)
* Added `ask` parameter to `get_ems_data()` and `download_historic_data()` to optionally bypass download confirmation dialogue (#10)

# rems 0.1.2

* Fixed bug where changes in file listings in DataBC catalogue would cause errors

# rems 0.1.1

* Fixed bug where changes in file listings in DataBC catalogue would cause errors

# rems 0.1.0

* Initial release
