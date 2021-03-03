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

  try_test <- try(
    units::install_conversion_constant("S", "mho", 1),
    silent = TRUE
  )

  if (!inherits(try_test, "try-error")) {
    units::install_symbolic_unit("MPN")
    units::install_conversion_constant("MPN", "CFU", 1)
    units::install_symbolic_unit("NTU")
    units::install_conversion_constant("NTU", "JTU", 1)
    units::install_conversion_constant("US_liquid_gallon", "USG", 1)
    units::install_conversion_constant("UK_liquid_gallon", "IG", 1)
    # These petroleum measures are actually only ever used
    # as volumes (1m3 = 0.001 E3m3 = 1e-6), but can't use E3m3
    # to install the unit so have to do it as m, units takes
    # care of the rest when it is m3 <=> E3m3 etc.
    units::install_conversion_constant("t", "adt", 1)
    units::install_conversion_constant("m", "E3m", .1)
    units::install_conversion_constant("m", "E6m", .01)
    units::install_conversion_constant("L", "E6L", 1e-6)
    units::install_conversion_constant("UK_liquid_gallon", "E6IG", 1e-6)
    #> set_units(set_units(1, "m3"), "E3m3")
    # 0.001 [E3m3]
    #> set_units(set_units(1, "m3"), "E6m3")
    # 1e-06 [E6m3]
  }
}

.onLoad <- function(libname, pkgname) {
  write_cache()
  register_ems_units()
}
