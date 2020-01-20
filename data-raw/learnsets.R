library(tidyverse)
library(rvest)


# Start session and extract table of links -------------------------------------
s <- html_session("https://bulbapedia.bulbagarden.net/wiki/Gdex")

urls <-
  s %>%
  html_nodes("h3 + table") %>%
  map(~ html_table(.x) %>%
        setNames(c("gdexno", "ndexno", "img", "name", "type1", "type2")) %>%
        transmute(
          gdexno = as.integer(str_sub(gdexno, 2)),
          img    = html_nodes(.x, "img") %>% html_attr("src"),
          url    = html_nodes(.x, "tr td:nth-child(4) a") %>% html_attr("href")
        ) %>%
        as_tibble()
  ) %>%
  do.call(bind_rows, .)


# Helper functions -------------------------------------------------------------
get_learnset_section <- function(session) {
  content_nodes <- html_nodes(session, "div#mw-content-text.mw-content-ltr > *")
  idx1 <- cumany(map_lgl(content_nodes, ~ length(html_nodes(.x, "span#Learnset")) != 0))
  idx2 <- cumall(map_lgl(content_nodes[idx1][-1], ~ !html_name(.x) %in% c("h3", "h2", "h1")))
  content_nodes[c(rep(FALSE, sum(!idx1) + 1), idx2)]
}

get_moves <- function(tbl_html) {
  idx <- which(names(html_table(tbl_html)) == "Move")
  html_text(html_nodes(tbl_html, str_c("tr td:nth-child(", idx, ") a")))
}


# TODO
s %>%
  jump_to(urls$url[1]) %>%
  html_nodes("h4 + table.roundy table.sortable") %>%
  map(~ get_moves(.x))

s %>%
  jump_to("/wiki/Meowstic_(Pok%C3%A9mon)") %>%
  get_learnset_section()
