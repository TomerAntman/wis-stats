data {
    // Number of ISIs
    int N;

    // interspike intervals
    array[N] real y;
}
   
parameters {
   real<lower=0> beta_; /*beta is a saved name in stan. So avoid clash */

}

model {
    // Prior
    beta_ ~ normal(0, 10);

    // Likelihood
    y ~ exponential(beta_);
    
    /* This is equivalent to:
    for (i in 1:N){ # Stan is "1 based" and the loop includes N
        y[i] ~ exponential(beta_);
    }
    */
}