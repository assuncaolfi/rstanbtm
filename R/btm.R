#' Bayesian Biterm Topic Model with Stan
#'
#' @export
#' @param k Number of topics.
#' @param alpha Hyperparameter vector for the Dirirchlet topic prior.
#' @param beta Hyperparameter vector for the Dirirchlet term priors.
#' @param ... Arguments passed to `rstan::sampling` (e.g. iter, chains).
#' @return An object of class `stanfit` returned by `rstan::sampling`
#'
btm <- function(biterms, k = 5, alpha = 50 / k, beta = 0.01, ...) {
  term1 <- biterms$term1
  term2 <- biterms$term2
  V <- max(c(term1, term2))
  standata <- list(
    K = k,
    V = V,
    N = length(term1),
    ti = term1,
    tj = term2,
    alpha = rep(alpha, k),
    beta = rep(beta, V)
  )
  out <- rstan::sampling(stanmodels$btm, data = standata, ...)
  return(out)
}
