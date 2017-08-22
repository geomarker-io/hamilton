#' parse addresses into components
#'
#' Note that this relies on python with the ...
#'
#' @param X a list or vector of addresses
#' @param ... additional arguments passed to \code{CB::mappp}; set options for
#'   cache and parallel operation here
#'
#' @return list of address parsing results with one address per element
#' @export
#' @examples
#' parse_addresses(c('3333 Burnet Ave, Cincinnati, OH 45229', '737 US 50 Cincinnati OH 45150'))
parse_addresses <- function(X, ...){
  CB::mappp(X, hamilton:::parser_call, ...)
}


#' call usaddress parser from python
#' @importFrom rPython python.exec python.call
#' @importFrom stringr str_to_lower str_replace_all
#' @export
parser_call <- function(address) {
  address <- address %>%
  stringr::str_to_lower() %>% # make text lower case
  stringr::str_replace_all("[^[:alnum:]]", " ") %>% # remove non-alphanumeric symbols
  stringr::str_replace_all("\\s+", " ") # collapse multiple spaces

  rPython::python.exec('import usaddress')
  # rPython::python.call('usaddress.tag', address)
  py_out <- rPython::python.call('usaddress.parse', address)
  out <- tibble(value = map_chr(py_out, 1),
                label = map_chr(py_out, 2))
  out %>% # combine separate values with the same label
    group_by(label) %>%
    summarise(value = toString(unique(value))) %>%
    mutate(value = stringr::str_replace_all(value, ',', '')) %>%
    spread(label, value)
}
# parser_call('4101 Spring Grove Ave Unit 105 Cincinnati, Ohio 45223')


