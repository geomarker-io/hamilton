# # filter out known incorrect residential addresses
# foster_char_strings <- c('Ronald McDonald House',
#                          '350 Erkenbrecher Ave',
#                          '350 Erkenbrecher Avenue',
#                          '350 Erkenbrecher Av',
#                          '222 East Central Parkway',
#                          '222 East Central Pkwy',
#                          '222 East Central Pky',
#                          '222 Central Parkway',
#                          '222 Central Pkwy',
#                          '222 Central Pky',
#                          '3333 Burnet Ave',
#                          '3333 Burnet Avenue',
#                          '3333 Burnet Av')
#
# d <- d %>%
#   mutate(foster = map(address, ~ str_detect(.x, coll(foster_char_strings, ignore_case=TRUE)))) %>%
#   mutate(foster = map_lgl(foster, any)) %>%
#   filter(!foster) %>%
#   select(-foster)
#
# no_no_regex_strings <- c('(10722\\sWYS)',
#                          '\\bP(OST)*\\.*\\s*[O|0](FFICE)*\\.*\\sB[O|0]X',
#                          '(3333\\s*BURNETT*\\s*A.*452[12]9)')
#
# d <- d %>%
#   mutate(foster = map(address, ~ str_detect(.x, regex(no_no_regex_strings, ignore_case=TRUE)))) %>%
#   mutate(foster = map_lgl(foster, any)) %>%
#   filter(!foster) %>%
#   select(-foster)
