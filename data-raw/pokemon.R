library(tidyverse)
library(rvest)


base_url <- "https://bulbapedia.bulbagarden.net/wiki/"

# Load wiki pages
base_stats_html <- read_html(str_c(base_url, "LPBBS"))
galar_dex_html  <- read_html(str_c(base_url, "Gdex"))
abilities_html  <- read_html(str_c(base_url, "List_of_Pokémon_by_Ability"))
egg_groups_html <- read_html(str_c(base_url, "List_of_Pokémon_by_Egg_Group"))

# Table with base stats
base_stats_tbl <-
  base_stats_html %>%
  html_node("table.sortable") %>%
  html_table() %>%
  setNames(c("ndexno", "img", "name", "hp", "atk", "def", "spa", "spd", "spe", "total", "avg")) %>%
  as_tibble() %>%
  mutate(
    alt  = str_extract(name, "(?<=\\().+(?=\\))"),
    name = str_replace(name, " \\(.+\\)", ""),
    img  = base_stats_html %>% html_nodes("table.sortable td img") %>% html_attr("src"),
    id   = basename(img) %>% str_sub(end = -5)
  )

# Table with Galar Dex number and types
galar_dex_tbl <-
  galar_dex_html %>%
  html_nodes("table") %>%
  .[2:9] %>%
  map(~ html_table(.x) %>%
        setNames(c("gdexno", "ndexno", "img", "name", "type1", "type2")) %>%
        mutate(
          id     = html_nodes(.x, "img") %>% html_attr("src") %>% basename() %>% str_sub(end = -5),
          gdexno = as.integer(str_sub(gdexno, 2)),
          type2  = if_else(type1 != type2, type2, NA_character_)
        ) %>%
        select(id, gdexno, starts_with("type")) %>%
        as_tibble()
      ) %>%
  do.call(bind_rows, .)

# Table with abilities
abilities_tbl <-
  abilities_html %>%
  html_nodes("table.sortable") %>%
  map(~ html_table(.x) %>%
        setNames(c("ndexno", "img", "name", "ability1", "ability2", "ability_hidden")) %>%
        mutate(id = html_nodes(.x, "img") %>% html_attr("src") %>% basename() %>% str_sub(end = -5)) %>%
        select(id, starts_with("ability")) %>%
        as_tibble()
      ) %>%
  do.call(bind_rows, .)

# Table with egg groups
egg_groups_html %>%
  html_node("table.sortable") %>%
  html_table() %>%
  setNames(c("ndexno", "img", "name", "egg_group1", "egg_group2")) %>%
  as_tibble() %>%
  mutate(
    id = egg_groups_html %>% html_nodes("table.sortable img") %>% html_attr("src") %>% basename() %>% str_sub(end = -5),
    egg_group2 = if_else(egg_group2 != "", egg_group2, NA_character_)
  ) %>%
  select(id, starts_with("egg"))

# TODO: collect tables into one `pokemon` table
usethis::use_data("pokemon", overwrite = TRUE)
