# TODO

- implement example that uses multiple addresses
	- don't require CB package to install
	- show example using `CB::mappp` in the README
	- also suggest alternatives
	- convert README into Rmd file with additional examples
- when ready, deprecate `geocodeCAGIS`

# hamilton

> Offline parcel-based geocoding for addresses in Hamilton County, Ohio, USA

This package is designed to geocode address strings using an offline copy of the Cincinnati Area Geographic Information System ([CAGIS](http://cagismaps.hamilton-co.org/cagisportal)) master address/parcel files. This drastically improves geocoding accuracy, but is only available for addresses that have a zipcode beginning with 450, 451, or 452, i.e. the Greater Cincinnati Area.

Its major features include:

1. Address Parsing
  - converts all to lower case
  - replaces consecutive whitespace with one whitespace character
  - removes non-alphanumeric characters
  - returns a tibble of address components as columns along with their respective values

2. Hamilton Specific Address Cleaning
    - flag Foster addresses, Ronald McDonald houses, etc.
    - translate Post Office boxes to missing for address value

2. Parcel-based Geocoding based on fuzzy text matching
    - fuzzy text matching
    - return CAGIS parcel id to link with hamilton county auditors database (need to use aud database)

## Installation

Install the package by running the following in `R`:

`remotes::install_github('cole-brokamp/geocodeCAGIS')`

The package relies on python to parse the address, which means that both `python` and the `usaddress` python library must be installed (`pip install usaddress`). Alternative installation methods are available depending on your operating system, seek instructions online.

## Usage

### Geocoding

Geocode by supplying a list or vector of address strings to `geocodeCAGIS()`. This will return the latitude and longitude, the CAGIS parcel identifier, and optionally, some additional diagnostic information regarding the geocoding match process. Note that this can be one address string, or if a list or vector of address strings is provided, it will be vectorized over and a progress bar is used.

```
geocodeCAGIS('3333 Burnet Ave, Cincinnati, OH 45229')
```

#### Address String Formatting

- An address must be submitted as a single string
- The city and state are optional and not used for geocoding.
- Street number, street name, and zip code must be in the address string.
- Street numbers must be numeric (i.e. "18", not "Eighteen").
