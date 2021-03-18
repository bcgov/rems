dbdir <- tempdir()
op <- options(rems.historic.path = dbdir)

cleanup <- function() {
  options(op)
  unlink(dbdir, recursive = TRUE)
}
