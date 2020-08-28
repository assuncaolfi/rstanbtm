data {
  int<lower=2> K;             // num topics
  int<lower=2> V;             // num terms
  int<lower=1> N;             // total biterm instances
  int<lower=1,upper=V> ti[N]; // term i
  int<lower=1,upper=V> tj[N]; // term j
  vector<lower=0>[K] alpha;   // topic prior
  vector<lower=0>[V] beta;    // term prior
}
parameters {
  simplex[K] theta;  // topic dist
  simplex[V] phi[K]; // word dist for topic k
}
model {
  // priors
  theta ~ dirichlet(alpha);
  for (k in 1:K)
    phi[k] ~ dirichlet(beta);
  // generative process
  for (n in 1:N) {
    real gamma[K];
    for (k in 1:K)
      gamma[k] = log(theta[k]) + log(phi[k, ti[n]]) + log(phi[k, tj[n]]);
    target += log_sum_exp(gamma);  // likelihood;
  }
}
