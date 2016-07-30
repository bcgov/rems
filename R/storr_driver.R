## This is a modified version of https://github.com/richfitz/storr/blob/master/R/driver_rds.R,
## along with some utility functions to make it work. It is modified to use readRDS instead of
## readBin due to this issue: https://github.com/richfitz/storr/issues/25

storr_rds2 <- function(path, compress=TRUE, mangle_key=NULL,
                      default_namespace="objects") {
  storr(driver_rds2(path, compress, mangle_key), default_namespace)
}

driver_rds2 <- function(path, compress=TRUE, mangle_key=NULL) {
  .R6_driver_rds2$new(path, compress, mangle_key)
}

.R6_driver_rds2 <- R6::R6Class(
  "driver_rds",
  public=list(
    path=NULL,
    compress=NULL,
    mangle_key=NULL,
    traits=list(accept_raw=TRUE),
    initialize=function(path, compress, mangle_key) {
      dir_create(path)
      dir_create(file.path(path, "data"))
      dir_create(file.path(path, "keys"))
      dir_create(file.path(path, "config"))
      self$path <- path
      self$compress <- compress

      ## This attempts to check that we are connecting to a storr of
      ## appropriate mangledness.  There's a lot of logic here, but
      ## it's actually pretty simple in practice and tested in
      ## test-driver-rds.R:
      ##
      ##   if mangle_key is NULL we take the mangledless of the
      ##   existing storr or set up for no mangling.
      ##
      ##   if mangle_key is not NULL then it is an error if it differs
      ##   from the existing storr's mangledness.
      if (!is.null(mangle_key)) {
        assert_scalar_logical(mangle_key)
      }
      path_mangled <- file.path(path, "config", "mangle_key")
      if (file.exists(path_mangled)) {
        mangle_key_prev <- as.logical(readLines(path_mangled))
        if (is.null(mangle_key)) {
          mangle_key <- mangle_key_prev
        } else if (mangle_key != mangle_key_prev) {
          stop(sprintf("Incompatible mangledness (existing: %s, requested: %s)",
                       mangle_key_prev, mangle_key))
        }
      } else {
        if (is.null(mangle_key)) {
          mangle_key <- FALSE
        }
        writeLines(as.character(mangle_key), path_mangled)
      }
      self$mangle_key <- mangle_key
    },

    type=function() {
      "rds"
    },
    destroy=function() {
      unlink(self$path, recursive=TRUE)
    },

    get_hash=function(key, namespace) {
      readLines(self$name_key(key, namespace))
    },
    set_hash=function(key, namespace, hash) {
      dir_create(self$name_key("", namespace))
      writeLines(hash, self$name_key(key, namespace))
    },
    get_object=function(hash) {
      unserialize(readRDS(self$name_hash(hash)))
    },
    set_object=function(hash, value) {
      assert_raw(value)
      saveRDS(value, self$name_hash(hash), compress=self$compress)
    },

    exists_hash=function(key, namespace) {
      file.exists(self$name_key(key, namespace))
    },
    exists_object=function(hash) {
      file.exists(self$name_hash(hash))
    },

    del_hash=function(key, namespace) {
      file_remove(self$name_key(key, namespace))
    },
    del_object=function(hash) {
      file_remove(self$name_hash(hash))
    },

    list_hashes=function() {
      sub("\\.rds$", "", dir(file.path(self$path, "data")))
    },
    list_namespaces=function() {
      dir(file.path(self$path, "keys"))
    },
    list_keys=function(namespace) {
      ret <- dir(file.path(self$path, "keys", namespace))
      if (self$mangle_key) decode64(ret, TRUE) else ret
    },

    name_hash=function(hash) {
      file.path(self$path, "data", paste0(hash, ".rds"))
    },
    name_key=function(key, namespace) {
      if (self$mangle_key) {
        key <- encode64(key)
      }
      file.path(self$path, "keys", namespace, key)
    }
  ))

dir_create <- function(path) {
  if (!file.exists(path)) {
    dir.create(path, FALSE, TRUE)
  }
}

file_remove <- function(path) {
  exists <- file.exists(path)
  if (exists) {
    file.remove(path)
  }
  invisible(exists)
}

assert_raw <- function(x, name=deparse(substitute(x))) {
  if (!is.raw(x)) {
    stop(sprintf("%s must be raw", name), call.=FALSE)
  }
}

assert_scalar <- function(x, name=deparse(substitute(x))) {
  if (length(x) != 1) {
    stop(sprintf("%s must be a scalar", name), call.=FALSE)
  }
}

assert_logical <- function(x, name=deparse(substitute(x))) {
  if (!is.logical(x)) {
    stop(sprintf("%s must be logical", name), call.=FALSE)
  }
}

assert_scalar_logical <- function(x, name=deparse(substitute(x))) {
  assert_scalar(x, name)
  assert_logical(x, name)
}