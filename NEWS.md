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
