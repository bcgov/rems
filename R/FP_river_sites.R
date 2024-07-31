# Copyright 2024 Province of British Columbia
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

#' Canada-BC Long-term river monitoring sites
#'
#' Get the EMS_IDs of all of the Canada-BC long-term river monitoring sites.
#'
#' @return a character vector of ems ids
#' @export

FP_river_sites <- function() {

  sites <- unique(c("E285129", "E269864", "E255962", "0200003", "E252119","0200559", "E206106", "0600042",

                    "0200016", "0200102", "0121580", "E271643", "E206581", "0600011", "E236796", "E256314",

                    "0920125", "0920673", "0200084", "E333673", "E206587", "E333672", "0200038", "E317790",

                    "0500046", "E279733", "E332551", "E206583", "E216848", "E255013", "0500073", "E206585",

                    "0200021", "E282116", "E282116", "E285533", "E299950", "0126400", "E206092", "E237496",

                    "E284949", "0500629", "0500073", "0920092", "0300038", "E333095", "E206586", "0600005",

                    "E310948", "E280016"))

  sites
}

