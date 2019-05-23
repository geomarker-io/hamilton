# global reference to usaddress (will be initialized in .onLoad)
usaddress <- NULL

.onLoad <- function(libname, pkgname) {
  # use superassignment to update global reference to scipy
  usaddress <<- reticulate::import('usaddress', delay_load = TRUE)
}
