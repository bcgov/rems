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

#' Long-term lake monitoring sites
#'
#' Get the EMS_IDs of all of the long-term lake monitoring sites.
#'
#' @param which which sites do you want returned? One of `"all"` (default),
#' `"active"`, or `"inactive"`?
#'
#' @return a character vector of site ids (EMS IDs)
#' @export
lt_lake_sites <- function(which = c("active", "all", "inactive")) {
  which <- match.arg(which)

  sites <- list(
    active = c(
      "0200078", "E215758", "0500461",
      "0500847", "0500246", "0500118",
      "0500117", "E285689", "0500128",
      "0500239", "0500236", "0500730",
      "0500454", "0500728", "0500248",
      "E220540", "0500615", "0500846",
      "0500453", "0500119", "0500848",
      "0500265", "E275463", "1100862",
      "E217507", "E217508", "E217509",
      "1100844", "1100953", "E207466",
      "E206283", "E303413", "0300037",
      "0200434", "E301590", "E301591",
      "E303250", "1130218", "1130219",
      "1131186", "0200052", "0400379",
      "1130618", "E223304", "E271703",
      "E224946", "E224945", "1131007",
      "E206616", "1131112", "E216924",
      "0400390", "0400502", "0400411",
      "E105973", "E207907", "E206956",
      "0400935", "0400336", "0400489",
      "E206955", "0500124", "0500123",
      "E228889", "0603071", "0603006",
      "0603097", "0603017", "0603100",
      "0803038", "0603019", "E262699",
      "E275784", "1132490"
    ),
    inactive = c(
      "1131080","1170009","1170011",
      "E207062","E219178","E213033",
      "E206793","E219459", "E216693",
      "E206789","E303412", "1199901",
      "1199902","1199904", "1199903",
      "E208723","E208721", "E208718",
      "E208722","E308528", "0603082",
      "0500129","E223053"
    )
  )

  if (which == "all") return(unname(unlist(sites)))

  sites[[which]]
}


#' Long-term lake monitoring sites
#'
#' Get the REQ_IDs of all of the long-term lake monitoring sites.
#'
#' @param data loads a site ID lookup table
#'
#' @return a character vector of req ids (EMS IDs)
#' @export
#'
lt_lake_req <- function(data=NULL) {

  if (!exists("lt_lake_ids")) load("data/lt_lake_ids.RData")
  sites <- unique(lt_lake_ids$REQUISITION_ID)

  sites
}


