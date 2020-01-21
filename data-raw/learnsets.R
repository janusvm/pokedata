library(tidyverse)
library(rvest)
library(here)


# Prerequisites ----------------------------------------------------------------
if (!exists("tm_moves") || !exists("tr_moves"))
  source(here("data-raw", "moves.R"))


# Start session and extract table of links -------------------------------------
s <- html_session("https://bulbapedia.bulbagarden.net/wiki/Gdex")

dat <-
  s %>%
  html_nodes("h3 + table") %>%
  map(~ html_table(.x) %>%
        setNames(c("gdexno", "ndexno", "img", "name", "type1", "type2")) %>%
        transmute(
          gdexno = as.integer(str_sub(gdexno, 2)),
          img    = html_nodes(.x, "img") %>% html_attr("src"),
          url    = html_nodes(.x, "tr td:nth-child(4) a") %>% html_attr("href"),
          moves  = list(list())
        ) %>%
        as_tibble()
  ) %>%
  do.call(bind_rows, .)


# Helper functions -------------------------------------------------------------
sec_map <- c(
  "By leveling up"       = "lvl",
  "By TM/TR"             = "tmtr",
  "By breeding"          = "egg",
  "By tutoring"          = "tutor",
  "By a prior evolution" = "prior",
  "By events"            = "event",
  "TCG-only moves"       = "tcg",
  "Anime-only moves"     = "anime"
)

get_learnset_sections <- function(session) {
  content_nodes <- html_nodes(session, "div#mw-content-text.mw-content-ltr > *")
  idx1 <- cumany(map_lgl(content_nodes, ~ length(html_nodes(.x, "span#Learnset")) != 0))
  idx2 <- cumall(map_lgl(content_nodes[idx1][-1], ~ html_name(.x) != "h3"))
  content_nodes[c(rep(FALSE, sum(!idx1) + 1), idx2)] %>%
    keep(~ html_name(.x) %in% c("h4", "h5", "table")) %>%
    split(cumsum(c(TRUE, diff(html_name(.) == "h4") > 0))) %>%
    setNames(map(., ~ sec_map[html_text(.x[1])])) %>%
    .[names(.[1:4])] %>%
    map(~ .x[-1]) %>%
    map(~ if (any(html_name(.x) == "h5")) {
      split(.x, cumsum(c(TRUE, diff(html_name(.x) == "h5") > 0))) %>%
        setNames(map(., ~ html_text(.x[1]))) %>%
        map(~ keep(., ~ html_name(.x) == "table"))

    } else keep(.x, ~ html_name(.x) == "table"))
}

get_moves <- function(outer_tbl) {
  tbl_html <- html_node(outer_tbl, "table.sortable")
  if (!is.na(tbl_html)) {
    idx <- which(names(html_table(tbl_html[[1]], fill = TRUE)) == "Move")
    html_text(html_nodes(tbl_html, str_glue("tr td:nth-child({idx}) a")))
  } else character(0)
}

get_moves_list <- function(learnset_sections) {
    map(learnset_sections, ~ if (length(.x) > 1) map(.x, get_moves) else get_moves(.x))
}


# Scrape away ------------------------------------------------------------------
for (i in seq_len(nrow(dat))) {
  cat(str_c("Scraping ", dat$url[i], " ...\n"))
  moves <- tryCatch({
    s %>%
      jump_to(dat$url[i]) %>%
      get_learnset_sections() %>%
      get_moves_list()
  }, error = function(e) {
    "ERROR"
  })
  dat$moves[i] <- list(moves)
}

# Manual handling of the Kingler page, which learnset sections are wrongly organised
kingler <- s %>%
  jump_to(dat$url[103]) %>%
  html_nodes("div#mw-content-text.mw-content-ltr > *")
kidx1 <- cumany(map_lgl(kingler, ~ length(html_nodes(.x, "span#Learnset")) != 0))
kidx2 <- cumall(map_lgl(kingler[idx1][-1], ~ html_name(.x) != "h3"))
kingler_moves <-
  kingler[c(rep(FALSE, sum(!kidx1) + 1), kidx2)] %>%
  html_nodes("table.sortable") %>%
  map(~ html_text(html_nodes(.x, str_c("tr td:nth-child(", which(names(html_table(.x, fill = TRUE)) == "Move"), ") a")))) %>%
  setNames(c("lvl", "tmtr", "egg", "tutor"))

dat$moves[103] <- list(kingler_moves)


# Species with form differences in learnset:
form_map <- c(
  "263MS"   = "Zigzagoon",
  "263GMS"  = "Galarian Zigzagoon",
  "264MS"   = "Linoone",
  "264GMS"  = "Galarian Linoone",
  "037MS"   = "Vulpix",
  "037AMS"  = "Alolan Vulpix",
  "038MS"   = "Ninetales",
  "038AMS"  = "Alolan Ninetales",
  "050MS"   = "Diglett",
  "050AMS"  = "Alolan Diglett",
  "051MS"   = "Dugtrio",
  "051AMS"  = "Alolan Dugtrio",
  "052MS"   = "Meowth",
  "052AMS"  = "Alolan Meowth",
  "052GMS"  = "Galarian Meowth",
  "053MS"   = "Persian",
  "053AMS"  = "Alolan Persian",
  "026MS"   = "Raichu",
  "026AMS"  = "Alolan Raichu",
  "678MS"   = "Male Meowstic",
  "678FMS"  = "Female Meowstic",
  "083MS"   = "Farfetch'd",
  "083GMS"  = "Galarian Farfetch'd",
  "618MS"   = "Stunfisk",
  "618GMS"  = "Galarian Stunfisk",
  "222MS"   = "Corsola",
  "222GMS"  = "Galarian Corsola",
  "110MS"   = "Weezing",
  "110GMS"  = "Galarian Weezing",
  "849MS"   = "Amped Form",
  "849LMS"  = "Low Key Form",
  "562MS"   = "Yamask",
  "562GMS"  = "Galarian Yamask",
  "077MS"   = "Ponyta",
  "077GMS"  = "Galarian Ponyta",
  "078XYMS" = "Rapidash",
  "078GMS"  = "Galarian Rapidash",
  "876MS"   = "Male",
  "876FMS"  = "Female",
  "122XYMS" = "Mr. Mime",
  "122GMS"  = "Galarian Mr. Mime",
  "554MS"   = "Darumaka",
  "554GMS"  = "Galarian Darumaka",
  "555MS"   = "Darmanitan",
  "555GMS"  = "Galarian Darmanitan"
)

# Manual addition of Rotom's form-specific moves
rotom_map <- list(
  "479OMS" = "Overheat",
  "479WMS" = "Hydro Pump",
  "479RMS" = "Blizzard",
  "479FMS" = "Air Slash",
  "479LMS" = "Leaf Storm"
)

# Unnest lists of moves
learnsets <- dat %>%
  rowwise() %>%
  transmute(
    id            = basename(img) %>% str_sub(end = -5),
    level_moves   = list(unique(c(rotom_map[[id]], moves$lvl))),
    tm_moves      = list(moves$tmtr[moves$tmtr %in% tm_moves$name]),
    tr_moves      = list(moves$tmtr[moves$tmtr %in% tr_moves$name]),
    egg_moves     = list(moves$egg),
    tutor_moves   = list(moves$tutor)
  ) %>%
  mutate_at(vars(level_moves:tutor_moves), ~ if (is.list(.)) list(.[[form_map[id]]]) else list(.)) %>%
  ungroup()
