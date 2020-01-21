library(tidyverse)
library(rvest)
library(here)


# Prerequisites ----------------------------------------------------------------
if (!exists("learnsets"))
  source(here("data-raw", "learnsets.R"))


# Download data ----------------------------------------------------------------
base_url <- "https://bulbapedia.bulbagarden.net/wiki/"

# Load wiki pages
base_stats_html <- read_html(str_c(base_url, "LPBBS"))
galar_dex_html  <- read_html(str_c(base_url, "Gdex"))
abilities_html  <- read_html(str_c(base_url, "List_of_Pokémon_by_Ability"))
egg_groups_html <- read_html(str_c(base_url, "List_of_Pokémon_by_Egg_Group"))


# Extract tables --------------------------------------------------------------
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
    img  = base_stats_html %>% html_nodes("table.sortable td img") %>% html_attr("src")
  ) %>%
  select(ndexno, img, name, alt, hp:spe)

# Table with Galar Dex number and types
galar_dex_tbl <-
  galar_dex_html %>%
  html_nodes("table") %>%
  .[2:9] %>%
  map(~ html_table(.x) %>%
        setNames(c("gdexno", "ndexno", "img", "name", "type1", "type2")) %>%
        mutate(
          ndexno = as.integer(str_sub(ndexno, 2)),
          gdexno = as.integer(str_sub(gdexno, 2)),
          img    = html_nodes(.x, "img") %>% html_attr("src"),
          type2  = if_else(type1 != type2, type2, NA_character_)
        ) %>%
        select(ndexno, gdexno, img, starts_with("type")) %>%
        as_tibble()
      ) %>%
  do.call(bind_rows, .)

# Table with abilities
abilities_tbl <-
  abilities_html %>%
  html_nodes("table.sortable") %>%
  map(~ html_table(.x) %>%
        setNames(c("ndexno", "img", "name", "ability1", "ability2", "ability_hidden")) %>%
        mutate(
          ndexno = as.integer(ndexno),
          img    = html_nodes(.x, "img") %>% html_attr("src")
        ) %>%
        filter(name != "Spiky-eared Pichu") %>%  # Only alt form that uses same sprite
        select(ndexno, img, starts_with("ability")) %>%
        as_tibble()
      ) %>%
  do.call(bind_rows, .)

# Table with egg groups
egg_groups_tbl <-
  egg_groups_html %>%
  html_node("table.sortable") %>%
  html_table() %>%
  setNames(c("ndexno", "img", "name", "egg_group1", "egg_group2")) %>%
  as_tibble() %>%
  mutate(
    ndexno = as.integer(ndexno),
    img    = egg_groups_html %>% html_nodes("table.sortable img") %>% html_attr("src")
  ) %>%
  select(ndexno, img, starts_with("egg"))


# Put it all together -----------------------------------------------------
miss_forms <- c(
  "422EMS" = "East Sea",
  "423EMS" = "East Sea",
  "550MS"  = "Red-Striped Form",
  "550BMS" = "Blue-Striped Form",
  "678MS"  = "Male",
  "678FMS" = "Female"
)
del_forms <- c(
  "025CoMS",
  "025OMS",
  "025HMS",
  "025SMS",
  "025UMS",
  "025KMS",
  "025AMS",
  "025PMS",
  "077MS",
  "078XYMS",
  "083MS",
  "110MS",
  "122XYMS",
  "222MS",
  "263MS",
  "264MS",
  "421SMS",
  "422MS",
  "423MS",
  "554MS",
  "555MS",
  "555ZMS",
  "618MS"
)

form_join <- function(x, y) {
  full_join(x, y, by = "img", suffix = c("_x_join", "_y_join")) %>%
    filter(xor(is.na(ndexno_x_join), is.na(ndexno_y_join)) | (ndexno_x_join == ndexno_y_join)) %>%
    mutate(ndexno = if_else(is.na(ndexno_x_join), ndexno_y_join, ndexno_x_join)) %>%
    select(ndexno, everything(), -ends_with("join"))
}

pokemon <-
  base_stats_tbl %>%
  form_join(abilities_tbl) %>%
  form_join(galar_dex_tbl) %>%
  form_join(egg_groups_tbl) %>%
  mutate_if(is.character, ~ if_else(. != "", str_replace(., "\\*", ""), NA_character_)) %>%
  mutate(
    id  = basename(img) %>% str_sub(end = -5),
    img = str_c("https:", img)
  ) %>%
  arrange(ndexno, name) %>%
  group_by(ndexno) %>%
  fill(gdexno, name, hp:spe,
       starts_with("ability"), starts_with("type"), starts_with("egg_group")) %>%
  rowwise() %>%
  mutate(alt = if_else(is.na(alt), miss_forms[id], alt)) %>%
  ungroup() %>%
  filter(
    !is.na(gdexno),
    !id %in% del_forms,
    is.na(alt) | !grepl("Mega|Partner|Alolan", alt)
  ) %>%
  arrange(gdexno) %>%
  left_join(learnsets, by = "id") %>%
  select(gdexno, ndexno, name, alt, hp:spe,
         starts_with("ability"), starts_with("type"), starts_with("egg_group"),
         level_moves, tm_moves, tr_moves, egg_moves, tutor_moves, img)


usethis::use_data(pokemon, overwrite = TRUE)
