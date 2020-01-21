#' @importFrom tibble tibble
NULL

#' Pokémon
#'
#' A dataset containing various information about Pokémon available in the
#' Galar Pokédex in Pokémon Sword & Shield.
#'
#' @format A data frame with 424 rows and 23 variables:
#' \describe{
#'   \item{gdexno}{Galar Pokédex number}
#'   \item{ndexno}{national Pokédex number}
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
#'   \item{level_moves}{moves learnt on levelup, evolution, or form change}
#'   \item{tm_moves}{moves learnt from Technical Machines (TMs)}
#'   \item{tr_moves}{moves learnt from Technical Records (TRs)}
#'   \item{egg_moves}{moves learnt through breeding}
#'   \item{tutor_moves}{moves learnt from Move Tutors}
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

#' Moves
#'
#' Pokémon moves available in Pokémon Sword & Shield.
#'
#' @format A data frame with 652 rows and 6 variables:
#' \describe{
#'   \item{name}{name of the move}
#'   \item{type}{type of the move}
#'   \item{category}{whether the move is a physical, special, or status move}
#'   \item{pp}{base Power Points of the move}
#'   \item{power}{Base Power, if it is a damaging move}
#'   \item{accuracy}{accuracy of the move (in percentage)}
#' }
#'
#' @source \url{https://bulbapedia.bulbagarden.net/wiki/List_of_moves_by_availability_(Generation_VIII)}
"moves"

#' TM Moves
#'
#' Moves that are available via Technical Machines (TM).
#'
#' @format A data frame with 100 rows and 2 variables:
#' \describe{
#'   \item{tmno}{number of the TM}
#'   \item{name}{name of the move}
#' }
#'
#' @source \url{https://bulbapedia.bulbagarden.net/wiki/TM}
"tm_moves"


#' TR Moves
#'
#' Moves that are available via Technical Records (TR).
#'
#' @format A data frame with 100 rows and 2 variables:
#' \describe{
#'   \item{trno}{number of the TR}
#'   \item{name}{name of the move}
#' }
#'
#' @source \url{https://bulbapedia.bulbagarden.net/wiki/TR}
"tr_moves"


#' Tutor Moves
#'
#' Moves that are available via Move Tutor.
#'
#' @format A data frame with 8 rows and 2 variables:
#' \describe{
#'   \item{name}{name of the move}
#'   \item{location}{in-game location of the tutor teaching the move}
#' }
#'
#' @source \url{https://bulbapedia.bulbagarden.net/wiki/Move_Tutor}
"tutor_moves"
