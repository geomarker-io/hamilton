#' Geocode Cincinnati, OH area address using an offline and parcel-based method
#'
#' Geocode an address using offline shapefile from CAGIS.
#'
#' This function parses a given address string into address components and
#' attempts to match the address to CAGIS data.  The best match is returned and
#' the score represents how many insertions/deletions/rearrangements were needed
#' to match the input string to the address data.
#'
#' The \code{sysdata.rda} file comes bundled with the package. Alternatively,
#' build the system data file on your own, using updated CAGIS files. See
#' the vignette for details on this operation.
#'
#' This function will return NA if the zip code of the address string
#' does not begin with 450, 451, or 452.
#'
#' Requires a sufficient python binary and the usaddress module.
#' See \link{addr_parse} for more details.
#'
#' @param address_string a single string that will be geocoded
#' @param return.score logical, return method and matching score?
#' @param return.call logical, return the original address string?
#' @param return.match logical, return the best address text match from CAGIS?
#'
#' @return data.frame with lat/lon coords, CAGIS parcel id, and optionally method score, original call, or matched CAGIS record
#' @export
#'
#' @examples
#' # geocodeCAGIS('3333 Burnet Ave, Cincinnati, OH 45229')
#' # geocodeCAGIS('1456 Main St. 23566')
#' # geocodeCAGIS('3131 Mary Jane Dr 45211')

geocodeCAGIS <- function(addr_string,return.score=TRUE,return.call=FALSE,return.match=TRUE) {

  stopifnot(class(addr_string)=='character')

  address.p <- parser_call(addr_string)

  if(!substr(address.p$ZipCode,1,3) %in% c(450,451,452)) {
	  message('warning: zip code does not begin with 450, 451, or 452; returning NA')
	  return(NA)
  }

  # remove city and state
  address.p$PlaceName <- NULL
  address.p$StateName <- NULL
  # remove missing fields
  address.p <- address.p[!sapply(address.p,is.na)]

  # make candidates based on fuzzy join
  common.names <- intersect(names(cagis_parsed),names(address.p))
  osa.candidates <- fuzzyjoin::stringdist_left_join(address.p,
                                                    na.omit(cagis_parsed[ ,c(common.names, 'lat', 'lon', 'PARCELID')]),
                                                    by = common.names,
                                                    method='osa',ignore_case=TRUE)
  candidates <- osa.candidates[ ,c(grep('.y',names(osa.candidates),value=TRUE,fixed=TRUE), 'lat', 'lon', 'PARCELID')] # keep just matches
  if (is.na(candidates$lat[1])) return(NA) # return NA if no matches
  names(candidates) <- gsub('.y','',names(candidates),fixed=TRUE) # remove .y from names
  candidates <- as.data.frame(sapply(candidates,function(x) tolower(as.character(x))),
                              stringsAsFactors=FALSE) # make all char

  # find best match within candidates
  dist.matrix <- sapply(names(candidates)[!names(candidates) %in% c('lat','lon', 'PARCELID')],function(x){
    x.dist <- stringdist::stringdist(as.character(candidates[ ,x]),as.character(address.p[ ,x]),method='osa')
  })
  dist.matrix <- as.data.frame(dist.matrix)
  dist.matrix$total.weighted.distance <- apply(dist.matrix,1,sum)
  best.candidate <- which.min(dist.matrix$total.weighted.distance)
  out <- data.frame('lat'=candidates[best.candidate,'lat'],
                    'lon'=candidates[best.candidate,'lon'],
                    'parcel_id'=candidates[best.candidate, 'PARCELID'])
  if (return.score) {
    out$score <- dist.matrix[best.candidate,'total.weighted.distance']
  }
  if (return.call) out$call <- addr_string
  if (return.match) out$match <- paste(candidates[best.candidate,common.names],collapse=' ')
  return(out)
}


