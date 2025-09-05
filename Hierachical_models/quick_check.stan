data {
  int N;
  int J_1;
  int J_2;
  array[J_2] int index_1;
  array[N] int index_2;
}
parameters {
  // Test with just the main parameter
  real log10_theta;
}
model {
  // Your extreme test
  log10_theta ~ normal(40, 1.02);
}
generated quantities {
  // Just return the parameter value
  real theta = 10^log10_theta;
}