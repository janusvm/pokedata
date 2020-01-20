library(tidyverse)
library(rvest)


# Download data ---------------------------------------------------------------
base_url <- "https://bulbapedia.bulbagarden.net/wiki/"

gen8_moves_html  <- read_html(str_c(base_url, "List_of_moves_by_availability_(Generation_VIII)"))
tm_moves_html    <- read_html(str_c(base_url, "TM"))
tr_moves_html    <- read_html(str_c(base_url, "TR"))
tutor_moves_html <- read_html(str_c(base_url, "Move_Tutor"))


# Extract tables --------------------------------------------------------------
moves <-
  gen8_moves_html %>%
  html_nodes("table.sortable") %>%
  .[[2]] %>%
  html_table() %>%
  setNames(c("id", "name", "type", "category", "pp", "power", "accuracy", "swsh")) %>%
  filter(swsh != "") %>%
  mutate(
    pp       = as.integer(pp),
    power    = as.integer(power),
    accuracy = as.integer(str_sub(accuracy, end = -2))
  ) %>%
  select(name:accuracy) %>%
  as_tibble()

tm_moves <-
  tm_moves_html %>%
  html_nodes("table.roundtable") %>%
  .[[9]] %>%
  html_table() %>%
  setNames(c("tmno", "name", "type", "category")) %>%
  as_tibble() %>%
  select(tmno, name)

tr_moves <-
  tr_moves_html %>%
  html_node("table.roundtable") %>%
  html_table() %>%
  setNames(c("trno", "name", "type", "category")) %>%
  as_tibble() %>%
  select(trno, name)

tutor_moves <-
  tutor_moves_html %>%
  html_nodes("table.sortable") %>%
  .[[40]] %>%
  html_table() %>%
  setNames(c("name", "type", "category", "location")) %>%
  as_tibble() %>%
  select(name, location) %>%
  mutate(location = str_replace(location, " \\(.+\\)", ""))


usethis::use_data(moves, overwrite = TRUE)
usethis::use_data(tm_moves, overwrite = TRUE)
usethis::use_data(tr_moves, overwrite = TRUE)
usethis::use_data(tutor_moves, overwrite = TRUE)
