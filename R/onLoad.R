# Copyright 2016 Province of British Columbia
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

._remsCache_ <- NULL

register_ems_units <- function() {

  # Test if one is installed - if it is, it means the
  # package has been loaded once already so don't try
  # to do it again
  try_test <- try(
    units::install_unit("MPN", "unitless", name = "Most Probable Number"),
    silent = TRUE
  )

  if (!inherits(try_test, "try-error")) {
    units::install_unit("mho", "1 S")
    units::install_unit("CFU", "1 MPN", "Colony-Forming Unit")
    units::install_unit("NTU", name = "Nephelometric Turbidity Unit")
    units::install_unit("JTU", "1 NTU", "Jackson Turbidity Unit")
    units::install_unit("USG", "1 US_liquid_gallon", "US Gallon")
    units::install_unit("IG", "1 UK_liquid_gallon", "Imperial Gallon")
    # These petroleum measures are actually only ever used
    # as volumes (1m3 = 0.001 E3m3 = 1e-6), but can't use E3m3
    # to install the unit so have to do it as m, units takes
    # care of the rest when it is m3 <=> E3m3 etc.
    units::install_unit("adt", "1 t", "Air Dry Tonne")
    units::install_unit("E3m", "10 m")
    units::install_unit("E6m", "100 m")
    units::install_unit("E6L", "1e6 L")
    units::install_unit("E6IG", "1e6 UK_liquid_gallon")
    #> set_units(set_units(1, "m3"), "E3m3")
    # 0.001 [E3m3]
    #> set_units(set_units(1, "m3"), "E6m3")
    # 1e-06 [E6m3]
  }
  invisible(NULL)
}

.onLoad <- function(libname, pkgname) {
  write_cache()
  register_ems_units()
}
