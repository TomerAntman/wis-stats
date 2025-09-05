data {
  // Total number of data points
  int N;
  
  // Number of entries in each level of the hierarchy
  int J_1;
  
  //Index arrays to keep track of hierarchical structure
  array[N] int index_1;
  
  // The measurements
  array[N] real Fy;
  array[N] real Fc;

}
parameters {
  // Log-scale hyperparameters
  real log10_theta;
  
  // non-Log-scale hyperparameters
  real<lower=0> tau;
  real<lower=0> sigma;
  
  // parameters for hierarchical levels
  vector[J_1] theta_1_tilde;
  // vector[J_1] theta_1; // now defined in transformed parameters
  
  // Multiplicative factor
  real<lower=0> r;
}
transformed parameters {
  // Transform to natural scale
  real<lower=0> theta = 10^log10_theta;
  vector[J_1] theta_1 = theta + tau * theta_1_tilde;  

}
model {
  // Priors on log-scale parameters
  log10_theta ~ normal(3.0, 0.6378);
  theta_1_tilde ~ normal(0, 1);
  tau ~ normal(0, 2000);
  sigma ~ normal(0, 1000);
  r ~ gamma(1.5, 1.5);
  
  // Hierarchical structure
  // theta_1 ~ normal(theta, tau); // now defined in transformed parameters
  
  // Likelihood
  Fy ~ normal(theta_1[index_1], sigma);
  Fc ~ normal(r*theta_1[index_1], r*sigma);
  
}

generated quantities {
    // Posterior predictive samples
    array[N] real Fy_pred;
    array[N] real Fc_pred;

    // Generate one predicted observation per each real observation
      for (n in 1:N) {
        real temp_theta_1 = theta_1[index_1[n]];
        Fy_pred[n] = normal_rng(temp_theta_1, sigma);
        Fc_pred[n] = normal_rng(r*temp_theta_1, r*sigma);
    }
    // Log-likelihood
    array[N] real log_lik_Fy;
    array[N] real log_lik_Fc;
    array[N] real log_lik;
    for (n in 1:N) {
      real temp_theta_1 = theta_1[index_1[n]];
      log_lik_Fy[n] = normal_lpdf(Fy[n] | temp_theta_1, sigma);
      log_lik_Fc[n] = normal_lpdf(Fc[n] | r*temp_theta_1, r*sigma);
      log_lik[n] = log_lik_Fy[n] + log_lik_Fc[n];
    }

}