
data {
    // Number of events
    int<lower=1> N;

    // interspike intervals
    array[N] real<lower=0> y;
}

parameters {
//    real<lower=0> beta_;
    real log10_sigma;
    real log10_alpha;


}
transformed parameters {
   real<lower=0> sigma = 10^log10_sigma;
   real<lower=0> alpha = 10^log10_alpha;
}

model {
    // Prior
    log10_sigma ~ normal(0.5, 1.276);
    log10_alpha ~ normal(0.35, 0.3316);

    // Likelihood
    y ~ weibull(alpha, sigma);
}

generated quantities {
    // Posterior predictive samples
    array[N] real<lower=0> y_pred;

    for (n in 1:N) {
        y_pred[n] = weibull_rng(alpha, sigma);
    }

    // Log-likelihood
    array[N] real log_lik;
    for (n in 1:N) {
        log_lik[n] = weibull_lpdf(y[n] | alpha, sigma);
    }

}
