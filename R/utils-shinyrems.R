#' get EMS data lookup table
#'
#' This function generates and caches a lookup table of the chosen data ('2yr' or '4yr') and imports it into your R session.
#' If the cached data are more current than than the lookup cache, you will be prompted to update it.
#'
#' @param which Defaults to \code{"2yr"} (past 2 years). You can also specify "4yr"
#' to get the past four years of data.
#' @param ask should the function ask for your permission to cache data on your computer?
#' Default \code{TRUE}
#' @return a data frame
#' @details this function is only used when running the ShinyRems app.
#'
#' \code{"EMS_ID", "MONITORING_LOCATION", "PERMIT", "PARAMETER_CODE", "PARAMETER",
#' "LONGITUDE" "LATITUDE", "FROM_DATE", "TO_DATE"}
#' @export
get_ems_lookup <- function(which = "2yr", ask = TRUE){

  if(!(which %in% c("2yr", "4yr")))
    stop("`which` must be either '2yr' or '4yr'")

  which_lup <- lookup_which(which)
  which_exists <- ._remsCache_$exists(which_lup)

  update <- FALSE
  if(!which_exists){
    update <- TRUE
  } else if(._remsCache_$exists("cache_dates")) {
    lup_cache_date <- get_cache_date(which_lup)
    data_cache_date <- get_cache_date(which)

    if (lup_cache_date < data_cache_date){
      update <- TRUE
    }
  }

  if (update) {
    if (ask) {
      stop_for_permission(paste0("rems would like to store a ", which,
                                 " data lookup table at ", rems_data_dir(), ". This is required to run the ShinyRems app. Is that okay?"))
    }

    message("Creating and caching lookup table ...")
    data <- try(._remsCache_$get(which), silent = TRUE)
    if(inherits(data, "try-error"))
      stop(which, " dataset must be cached before lookup table can be created. Run get_ems_data().")

    lookup <- make_lookup(data)
    update_lookup_cache(which = which, lookup)
  }

  lookup_from_cache(which_lup)
}

lookup_which <- function(x){
  paste(x, "lookup", sep = "_")
}

lookup_from_cache <- function(which){
  ._remsCache_$get(which)
}

make_lookup <- function(x){
  x <- dplyr::group_by(x, .data$EMS_ID, .data$MONITORING_LOCATION, .data$PERMIT,
                    .data$PARAMETER_CODE, .data$PARAMETER,
                    .data$LONGITUDE, .data$LATITUDE)
  x <- dplyr::arrange(x, .data$COLLECTION_START)
  x <- dplyr::summarise(x, FROM_DATE = dplyr::first(.data$COLLECTION_START),
                     TO_DATE = dplyr::last(.data$COLLECTION_START))
  x <- dplyr::ungroup(x)
  x
}

update_lookup_cache <- function(which, data){
  file_meta <- get_file_metadata(which)
  which_lup <- lookup_which(which)
  ._remsCache_$set(which_lup, data)
  set_cache_date(which = which_lup, value = file_meta[["server_date"]])
}


