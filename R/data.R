#' @importFrom tibble tibble
NULL

#' Pokémon
#'
#' A dataset containing various information about Pokémon available in the
#' Galar Pokédex in Pokémon Sword & Shield.
#'
#' @format A data frame with 429 rows and 19 variables:
#' \describe{
#'   \item{id}{unique identifier}
#'   \item{ndexno}{national Pokédex number}
#'   \item{gdexno}{Galar Pokédex number}
#'   \item{name}{name of the Pokémon}
#'   \item{alt}{name of the Pokémon's form, if it has alternate forms}
#'   \item{hp}{base HP}
#'   \item{atk}{base Attack}
#'   \item{def}{base Defense}
#'   \item{spa}{base Special Attack}
#'   \item{spd}{base Special Defense}
#'   \item{spe}{base Speed}
#'   \item{ability1}{first normal ability}
#'   \item{ability2}{second normal ability, if it has more than one}
#'   \item{ability_hidden}{hidden ability, if it has one}
#'   \item{type1}{primary type}
#'   \item{type2}{secondary type, if it has one}
#'   \item{egg_group1}{primary egg group}
#'   \item{egg_group2}{secondary egg group, if it has one}
#'   \item{img}{URL for in-game sprite}
#' }
#'
#' @source
#' \itemize{
#'   \item \url{https://bulbapedia.bulbagarden.net/wiki/LPBBS}
#'   \item \url{https://bulbapedia.bulbagarden.net/wiki/Gdex}
#'   \item \url{https://bulbapedia.bulbagarden.net/wiki/List_of_Pokémon_by_Ability}
#'   \item \url{https://bulbapedia.bulbagarden.net/wiki/List_of_Pokémon_by_Egg_Group}
#' }
"pokemon"