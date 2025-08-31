data {
    int<lower=1> N;
    int<lower=0> n;
}

parameters {
    // probability of sucess
    real<lower=0, upper=1> theta;
}

model {
    // Priors
    theta ~ beta(2, 2);

    // Likelihood
    n ~ binomial(N, theta);
}