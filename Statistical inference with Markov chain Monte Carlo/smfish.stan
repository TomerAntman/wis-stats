/*
log10_alpha ~ Norm(0, 1.5)
log10_b ~ Norm(3, 1.5)
beta = 1/b
n ~ NBinom(alpha, beta)
g(alpha,b)|n) = ( f(n|alpha, b) * g(alpha,b) ) / f(n)
*/
data {
    int<lower=1> N;
    array[N] int<lower=0> n;
}

parameters {
    // log of burst freq
    real log10_alpha;

    // log of burst size
    real log10_b;
}

transformed parameters {
    real alpha = 10 ^ log10_alpha;
    real b = 10 ^ log10_b;
    real beta_ = 1/b;
}

model {
    // Priors
    log10_alpha ~ normal(0.0, 1.5);
    log10_b ~ normal(3.0,1.5);

    // Likelihood
    n ~ neg_binomial(alpha, beta_);
}