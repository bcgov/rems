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
#'
#' @return a character vector of ems ids
#' @export
#'
#'
lt_lake_sites <- function() {

  sites <- unique(lt_lake_ids$EMS_ID)

  sites
}


#' Long-term lake monitoring sites
#'
#' Get the REQ_IDs of all of the long-term lake monitoring sites.
#'
#'
#' @return a character vector of requisition ids
#' @export
#'
lt_lake_req <- function() {

  sites <- unique(lt_lake_ids$REQUISITION_ID)

  sites
}

