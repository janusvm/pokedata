library(tidyverse)
library(rvest)

base_url <- "https://bulbapedia.bulbagarden.net/wiki/"

gen8_moves_html <- read_html(str_c(base_url, "List_of_moves_by_availability_(Generation_VIII)"))
tms_html        <- read_html(str_c(base_url, "TM"))
trs_html        <- read_html(str_c(base_url, "TR"))

usethis::use_data("moves")
