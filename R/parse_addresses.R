#' parse an address into components
#'
#' Note that this relies on python usaddress library. See the README for more details
#'
#' @param X an address as a character string
#'
#' @return data.frame of address parsing results
#' @export
#' @examples
#' parse_address('3333 Burnet Ave, Cincinnati, OH 45229')
parse_address <- function(address) {
  address <- address %>%
  stringr::str_to_lower() %>% # make text lower case
  stringr::str_replace_all("[^[:alnum:]]", " ") %>% # remove non-alphanumeric symbols
  stringr::str_replace_all("\\s+", " ") # collapse multiple spaces
  ## usaddress <- reticulate::import('usaddress')
  py_out <- usaddress$parse(address)
  out <- tibble(value = map_chr(py_out, 1),
                label = map_chr(py_out, 2))
  out %>% # combine separate values with the same label
    group_by(label) %>%
    summarise(value = toString(unique(value))) %>%
    mutate(value = stringr::str_replace_all(value, ',', '')) %>%
    spread(label, value)
}



