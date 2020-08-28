#' Convert terms to integers
#'
#' @export
#' @param x A data.frame of biterms, with at least two columns: term1 and term2.
#' @return The same data.frame, with terms converted to integers for Stan.
#'
id_terms <- function(x) {
  N <- length(x$term1)
  terms <- c(x$term1, x$term2)
  ids <- as.integer(as.factor(terms))
  x$term1 <- ids[1:N] 
  x$term2 <- ids[(N + 1):(N * 2)]
  x
}
