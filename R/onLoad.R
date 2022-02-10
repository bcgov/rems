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

._remsenv_ <- new.env(parent = emptyenv()) # nocov

register_ems_units <- function() {

  # Clear these units first in case the package has already
  # been loaded and thus defined once
  units::remove_unit(
    symbol = c("mho", "MPN", "CFU", "NTU", "JTU", "USG", "IG",
      "adt", "E3m", "E6m", "E6L", "E6IG"),
    name = c("Most Probable Number", "Colony-Forming Unit",
             "Nephelometric Turbidity Unit", "Jackson Turbidity Unit")
  )

  # units::install_unit("mho", "1e-9 abmho") # == 1 S
  units::install_unit(symbol = c("MPN", "CFU"),
                      def = "unitless",
                      name = c("Most Probable Number", "Colony-Forming Unit"))
  units::install_unit(symbol = c("NTU", "JTU"),
                      name = c("Nephelometric Turbidity Unit",
                               "Jackson Turbidity Unit"))
  units::install_unit("USG", "1 US_liquid_gallon")
  units::install_unit("IG", "1 UK_liquid_gallon")
  # These petroleum measures are actually only ever used
  # as volumes (1m3 = 0.001 E3m3 = 1e-6), but can't use E3m3
  # to install the unit so have to do it as m, units takes
  # care of the rest when it is m3 <=> E3m3 etc.
  units::install_unit("adt", "1 t")
  units::install_unit("E3m", "10 m")
  units::install_unit("E6m", "100 m")
  units::install_unit("E6L", "1e6 L")
  units::install_unit("E6IG", "1e6 UK_liquid_gallon")
  #> set_units(set_units(1, "m3"), "E3m3")
  # 0.001 [E3m3]
  #> set_units(set_units(1, "m3"), "E6m3")
  # 1e-06 [E6m3]
  return(invisible(TRUE))
}

.onLoad <- function(libname, pkgname) {
  write_cache() # nocov
  register_ems_units() # nocov
}
