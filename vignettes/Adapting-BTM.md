---
title: "Adapting BTM to Stan"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Adapting-BTM}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

# Adapting BTM to Stan

## Biterm Topic Model

In the Biterm Topic Model paper, Yan et al define the biterm generating 
process is described as:

1. Sample topic simplex $\theta \sim \mathrm{Dirichlet}(\alpha)$.
2. For each topic $k$ sample $\phi_k \sim \mathrm{Dirichlet}(\beta)$.
3. 

## Marginals

For more info on this topic, see the 
(Latent Dirichlet Allocation)[https://mc-stan.org/docs/2_18/stan-users-guide/latent-dirichlet-allocation.html] 
section on Stan User's Guide.

We can calculate the marginal distribution over the continuous parameters 
$\theta, \phi$ by summing out the discrete parameters:

$$\begin{aligned}
p(\theta, \phi | \alpha, \beta, b) 
&\propto p(\theta | \alpha)p(\phi | \beta)p(b | \theta, \phi) \\
&= p(\theta | \alpha) \prod_k p(\phi_k | \beta) \prod_{(i,j)}p(w_i, w_j | \theta, \phi) \\ 
&= p(\theta | \alpha) \prod_k p(\phi_k | \beta) \prod_{(i,j)} \sum_z p(z, w_i, w_j | \theta, \phi) \\
&= p(\theta | \alpha) \prod_k p(\phi_k | \beta) \prod_{(i,j)} \sum_z p(z | \theta) p(w_i | \phi_z) p(w_j | \phi_z) \\
\end{aligned}$$

$$\begin{aligned}
\log p(\theta, \phi | \alpha, \beta, b) 
&\propto \log p(\theta | \alpha) + \sum_k \log p(\phi_k | \beta) + \sum_{(i,j)} \log \Big(\sum_z p(z | \theta) p(w_i | \phi_z) p(w_j | \phi_z)\Big) \\
&\propto 
\log \mathrm{Dirichlet}(\theta | \alpha) +
\sum_k \log \mathrm{Dirichlet}(\phi_k | \beta) + 
\sum_{(i,j)} \log \Big(
\sum_z \mathrm{Categorical}(z | \theta) 
\mathrm{Categorical}(w_i | \phi_z) \mathrm{Categorical}(w_j | \phi_z)
\Big) \\
\end{aligned}$$

## Stan implementation


```stan
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
```

