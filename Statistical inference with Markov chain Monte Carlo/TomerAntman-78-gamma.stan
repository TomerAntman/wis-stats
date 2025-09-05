
data {
    // Number of events
    int<lower=1> N;

    // interspike intervals
    array[N] real<lower=0> y;
}

parameters {
//    real<lower=0> beta_;
    real log10_beta;
    real log10_alpha;

}
transformed parameters {
   real<lower=0> beta_ = 10^log10_beta;
   real<lower=1> alpha = 10^log10_alpha;
}

model {
    // Prior
    log10_beta ~ normal(0, 1.276);
    log10_alpha ~ normal(0.85, 0.434);

    // Likelihood
    y ~ gamma(alpha, beta_);
}

generated quantities {
    // Posterior predictive samples
    array[N] real<lower=0> y_pred;

    for (n in 1:N) {
        y_pred[n] = gamma_rng(alpha, beta_);
    }

    // Log-likelihood
    array[N] real log_lik;
    for (n in 1:N) {
        log_lik[n] = gamma_lpdf(y[n] | alpha, beta_);
    }
}
