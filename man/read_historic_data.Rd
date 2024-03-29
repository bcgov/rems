% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ems_duckdb.R
\name{read_historic_data}
\alias{read_historic_data}
\title{Read historic ems data into R.}
\usage{
read_historic_data(
  emsid = NULL,
  parameter = NULL,
  param_code = NULL,
  from_date = NULL,
  to_date = NULL,
  cols = "wq",
  check_db = TRUE
)
}
\arguments{
\item{emsid}{A character vector of the ems id(s) of interest}

\item{parameter}{a character vector of parameter names}

\item{param_code}{a character vector of parameter codes}

\item{from_date}{A date string in a standard unambiguous format (e.g., "YYYY/MM/DD")}

\item{to_date}{A date string in a standard unambiguous format (e.g., "YYYY/MM/DD")}

\item{cols}{colums. Default "wq". See \code{link{get_ems_data}} for further documentation.}

\item{check_db}{should the function check for cached data or updates? Default \code{TRUE}.}
}
\value{
a data frame of the results
}
\description{
You will need to have run \code{\link{download_historic_data}} before you
can use this function
}
\examples{
\dontrun{
read_historic_data(emsid = "0400203", from_date = as.Date("1984-11-20"),
  to_date = as.Date("1991-05-11"))
}
}
