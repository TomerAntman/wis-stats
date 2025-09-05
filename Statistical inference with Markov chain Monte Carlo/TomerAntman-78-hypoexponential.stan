
functions {
  // Log probability density function for two-stage hypoexponential distribution
  real hypoexponential_2stage_lpdf(real t, real beta1, real beta2) {
    // Probability density is zero for negative times (time cannot be negative)
    if (t < 0) {
      return negative_infinity();
    }

    // Main PDF formula: f(t) = (beta1 * beta2)/(beta2 - beta1) * (exp(-beta1*t) - exp(-beta2*t))
    // Compute this in log space for numerical stability
    real log_coeff = log(beta1) + log(beta2) - log(abs(beta2 - beta1));

    return log_coeff + log(abs(exp(-beta1 * t) - exp(-beta2 * t)));
  }

  // Random number generator for two-stage hypoexponential distribution
  real hypoexponential_2stage_rng(real beta1, real beta2) {
    // Generates a sample by summing two independent exponential random variables
    // to directly models the biological process: total time = time for process 1 + time for process 2
    return exponential_rng(beta1) + exponential_rng(beta2);
  }

}

data {
    int<lower=1> N;

    // Each y_i value represents the time for two sequential biochemical processes
    array[N] real<lower=0> y;
}

parameters {
    real log10_beta1;  // log10 of rate parameter for first biochemical process  
    real log10_beta2;  // log10 of rate parameter for second biochemical process
}

transformed parameters {
    real<lower=0> beta1 = 10^log10_beta1;  // Rate parameter for first process
    real<lower=0> beta2 = 10^log10_beta2;  // Rate parameter for second process
}

model {
    // Prior
    log10_beta1 ~ normal(-0.5, 1.276);  // Prior for log10(beta1)
    log10_beta2 ~ normal(-0.5, 1.276);  // Prior for log10(beta2)

    // Likelihood (total time for both processes)
    for (n in 1:N) {
      // When beta1 ≈ beta2, the formula breaks because of log(0).
      // In this case, the story fits a Gamma distribution with alpha=2, beta=beta1
      if (abs(beta1 - beta2) < 1e-10) {
        y[n] ~ gamma(2, beta1);
      } else {
        // This automatically calls hypoexponential_2stage_lpdf(y[n] | beta1, beta2):
        y[n] ~ hypoexponential_2stage(beta1, beta2);
      }
    }
}

generated quantities {
    // Posterior predictive samples
    array[N] real<lower=0> y_pred;

    // Generate one predicted observation per each real observation
    for (n in 1:N) {
        y_pred[n] = hypoexponential_2stage_rng(beta1, beta2);
    }

    // Log-likelihood 
    array[N] real log_lik;
    for (n in 1:N) {
        log_lik[n] = hypoexponential_2stage_lpdf(y[n] | beta1, beta2);
    }
}
