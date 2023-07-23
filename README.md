Use https://github.com/geomarker-io/parcel instead

<!-- README.md is generated from README.Rmd. Please edit that file -->

# hamilton

> Offline parcel-based geocoding for addresses in Hamilton County, Ohio,
> USA

This package is designed to geocode address strings using an offline
copy of the Cincinnati Area Geographic Information System
([CAGIS](http://cagismaps.hamilton-co.org/cagisportal)) master
address/parcel files. This drastically improves geocoding accuracy, but
is only available for addresses that have a zipcode beginning with 450,
451, or 452, i.e. the Greater Cincinnati Area.

Its major functions include:

  - `parse_address()`
      - parse an address string into individual components
      - converts all letters to lower case
      - replaces consecutive whitespace with one whitespace character
      - removes non-alphanumeric characters
      - takes an address string and returns a tibble of address
        components
  - `geocodeCAGIS()`
      - parcel-based geocoding based on included CAGIS address database
      - fuzzy text matching on street will return the best match and its
        similarity score
      - return CAGIS parcel id to link with other extant databases
        including Hamilton County Auditor

## Installation

Install the package by running the following in `R`:

`remotes::install_github('cole-brokamp/hamilton')`

The package relies on python to parse the address, which means that both
`python` and the `usaddress` python library must be installed (`pip
install usaddress`). Alternative installation methods are available
depending on your operating system; seek instructions online.

## Usage

### Geocoding

Geocode a single address string using `geocodeCAGIS()`. This will
automatically take care of parsing the address string and will return
the latitude and longitude, the CAGIS parcel identifier, and optionally,
some additional diagnostic information regarding the geocoding match
process.

``` r
geocodeCAGIS('3333 Burnet Ave, Cincinnati, OH 45229')
#> # A tibble: 1 x 5
#>     lat   lon PARCELID     score match               
#>   <dbl> <dbl> <chr>        <dbl> <chr>               
#> 1  39.1 -84.5 010400020052     1 3333 burnet av 45229
```

#### Address String Formatting

  - An address must be submitted as a single string
  - The city and state are optional and not used for geocoding.
  - Street number, street name, and zip code must be in the address
    string.
  - Street numbers must be numeric (i.e. “18”, not “Eighteen”).

### Batch Geocoding

Geocoding an address string requires a significant amount of
computational time, so it may be useful to memoise results, provide a
progress bar, implement graceful error handling, and/or use parallel
processing with `CB::mappp()`:

``` r
addrs <- c('3333 Burnet Ave, Cincinnati, OH 45229',
           '222 E Central Pkwy, Cincinnati, OH 45202',
           '1600 Pennsylvania Ave NW Washington, DC 20500')

CB::mappp(addrs, geocodeCAGIS)
#> 
...  :what (  0%)   [ ETA:  ?s | Elapsed:  0s ]
...  processing 1 of 3 ( 33%)   [ ETA:  0s | Elapsed:  0s ]
...  processing 2 of 3 ( 67%)   [ ETA:  0s | Elapsed:  1s ]
...  processing 3 of 3 (100%)   [ ETA:  0s | Elapsed:  1s ]
#> warning: zip code does not begin with 450, 451, or 452; returning NA
#> [[1]]
#> # A tibble: 1 x 5
#>     lat   lon PARCELID     score match               
#>   <dbl> <dbl> <chr>        <dbl> <chr>               
#> 1  39.1 -84.5 010400020052     1 3333 burnet av 45229
#> 
#> [[2]]
#> # A tibble: 1 x 5
#>     lat   lon PARCELID     score match                   
#>   <dbl> <dbl> <chr>        <dbl> <chr>                   
#> 1  39.1 -84.5 007500040247     0 222 central pkwy 45202 e
#> 
#> [[3]]
#> [1] NA
```
