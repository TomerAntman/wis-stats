data {
  // Total number of data points
  int N;
  
  // Number of entries in each level of the hierarchy
  int J_1;
  int J_2;
  
  //Index arrays to keep track of hierarchical structure
  array[J_2] int index_1;
  array[N] int index_2;
}
parameters {
  // Log-scale hyperparameters
  real log10_theta;
  real log10_tau;
  real log10_sigma;
  
  // parameters for hierarchical levels
  vector[J_1] theta_1;
  vector[J_2] theta_2;
  
  // Multiplicative factor
  real<lower=0> mult_factor;
}
transformed parameters {
  // Transform to natural scale
  real<lower=0> theta = 10^log10_theta;
  real<lower=0> tau = 10^log10_tau;
  real<lower=0> sigma = 10^log10_sigma;
  // vector<lower=0>[J_1] theta_1 = 10^log10_theta_1;
  // vector<lower=0>[J_2] theta_2 = 10^log10_theta_2;
}
model {
  // Priors on log-scale parameters
  log10_theta ~ normal(40, 1.02);
  log10_tau ~ normal(1.5, 0.7653);
  log10_sigma ~ normal(1, 0.6378);
  mult_factor ~ gamma(2, 2);
  
  // Hierarchical structure
  theta_1 ~ normal(theta, tau);
  theta_2 ~ normal(theta_1[index_1], tau); 
  
  // No likelihood needed for prior predictive checks
}
generated quantities {
  // Generate predictions from the prior
  array[N] real<lower=0> y_pred;
  for (i in 1:N) {
    y_pred[i] = normal_rng(theta_2[index_2[i]], sigma);
    // y_pred[i] = normal_rng(theta_2[index_2[i]] * (mult_factor * (1 - index_2[i] % 2)), sigma);
    // if (index_2[i] % 2 == 0) {
    //   y_pred[i] = normal_rng(theta_2[index_2[i]], sigma);  
    // } else {
    //   y_pred[i] = normal_rng(theta_2[index_2[i]] * mult_factor, sigma);
    // }
  }
}