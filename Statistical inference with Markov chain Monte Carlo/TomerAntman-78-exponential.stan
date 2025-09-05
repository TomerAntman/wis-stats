
data {
    // Number of events
    int<lower=1> N;

    // interspike intervals
    array[N] real<lower=0> y;
}

parameters {
//    real<lower=0> beta_;
    real log10_beta;


}
transformed parameters {
   real<lower=0> beta_ = 10^log10_beta;
}

model {
    // Prior
    log10_beta ~ normal(-0.5, 1.276);

    // Likelihood
    y ~ exponential(beta_);
}

generated quantities {
    // Posterior predictive samples
    array[N] real<lower=0> y_pred;

    for (n in 1:N) {
        y_pred[n] = exponential_rng(beta_);
    }

    // Log-likelihood
    array[N] real log_lik;
    for (n in 1:N) {
        log_lik[n] = exponential_lpdf(y[n] | beta_);
    }
}
