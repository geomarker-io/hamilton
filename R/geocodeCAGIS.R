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
#' build the system data file on your own, using updated CAGIS files. See the
#' vignette for details on this operation.
#'
#' This function will return NA if the zip code of the address string does not
#' begin with 450, 451, or 452.
#'
#' Requires a sufficient python binary and the usaddress module. See
#' \link{parse_address} for more details.
#'
#' @param address_string a single string that will be geocoded
#'
#' @return data.frame with lat/lon coords, CAGIS parcel id, matching score, and
#'   matched CAGIS record (note that the `match` field returns only address
#'   components from the CAGIS database that were used to match the supplied
#'   address)
#' @export
#'
#' @examples
#' geocodeCAGIS('224 Woolper Ave, Cincinnati, OH 45220')
#' geocodeCAGIS('3333 Burnet Ave, Cincinnati, OH 45229')
#' geocodeCAGIS('1456 Main St. 23566')
#' geocodeCAGIS('3131 Mary Jane Dr 45211')
geocodeCAGIS <-
  function(addr_string){

    stopifnot(class(addr_string) == 'character')

    address.p <- parse_address(addr_string)

    if(!substr(address.p$ZipCode,1,3) %in% c(450,451,452)) {
      message('warning: zip code does not begin with 450, 451, or 452; returning NA')
      return(NA)
    }

    address.p$PlaceName <- NULL
    address.p$StateName <- NULL

    address.p <- address.p[!sapply(address.p,is.na)]

    common.names <- intersect(names(cagis_parsed), names(address.p))

    cagis_parsed_common <-
      cagis_parsed[ ,c(common.names, 'lat', 'lon', 'PARCELID')] %>%
      stats::na.omit()

    dists <-
      map_dfc(names(address.p),
              ~ stringdist::stringdist(pull(address.p, .),
                                       pull(cagis_parsed_common, .))) %>%
      set_names(names(address.p))

    best_match <- which.min(rowSums(dists))
    best_score <- rowSums(dists[best_match, ])

    out <- cagis_parsed_common[best_match, c('lat', 'lon', 'PARCELID')]
    out$score <- best_score
    out$match <- paste(cagis_parsed_common[best_match, common.names], collapse = ' ')

    return(out)
  }


