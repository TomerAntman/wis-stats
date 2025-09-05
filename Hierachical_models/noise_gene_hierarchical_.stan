data {
  // Total number of data points
  int N;
  
  // Number of entries in each level of the hierarchy
  int J_1;
  int J_2;
  
  //Index arrays to keep track of hierarchical structure
  array[J_2] int index_1;
  array[N] int index_2;
  
  // The measurements
  array[N] real y;
}
parameters {
  // Log-scale hyperparameters
  real log10_theta;
  real log10_tau;
  real log10_sigma;
  
  // Log-scale parameters for hierarchical levels
  vector[J_1] log10_theta_1;
  vector[J_2] log10_theta_2;
  
  // Multiplicative factor
  real<lower=0> mult_factor;
}
transformed parameters {
  // Transform to natural scale
  real<lower=0> theta = 10^log10_theta;
  real<lower=0> tau = 10^log10_tau;
  real<lower=0> sigma = 10^log10_sigma;
  vector<lower=0>[J_1] theta_1 = 10^log10_theta_1;
  vector<lower=0>[J_2] theta_2 = 10^log10_theta_2;
}
model {
  // Priors on log-scale parameters
  log10_theta ~ normal(3, 0.5102);
  log10_tau ~ normal(2, 0.5102);
  log10_sigma ~ normal(1, 0.5102);
  mult_factor ~ gamma(2, 2);
  
  // Hierarchical structure
  log10_theta_1 ~ normal(log10_theta, tau);
  log10_theta_2 ~ normal(log10_theta_1[index_1], tau); 
  
  // Likelihood
  for (i in 1:N) {
    y[i] ~ lognormal(log(theta_2[index_2[i]] * (mult_factor ^ (index_2[i] % 2))), sigma);
  }
}