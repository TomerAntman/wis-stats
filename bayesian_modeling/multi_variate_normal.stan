data {
    int<lower=1> N;  
    // hyperpriors for means
    real mean_length_mu;
    real mean_length_sigma;
    real mean_mass_mu;
    real mean_mass_sigma;

    // hyperpriors for stds
    real std_length_mu;
    real std_length_sigma;
    real std_mass_mu;
    real std_mass_sigma;
}

parameters{
    vector<lower=0>[2] mu;             // means
    vector<lower=0>[2] tau;            // std devs
    corr_matrix[2] R;         // correlation

}

transformed parameters {
    cov_matrix[2] CovMat;
    CovMat = quad_form_diag(R, tau);
}

model {
    mu[1] ~ lognormal(mean_length_mu, mean_length_sigma);
    mu[2] ~ lognormal(mean_mass_mu, mean_mass_sigma);

    tau[1] ~ lognormal(std_length_mu, std_length_sigma);
    tau[2] ~ lognormal(std_mass_mu, std_mass_sigma);

    R ~ lkj_corr(2);   // sample correlation
}

generated quantities {
    // Likelihood
    matrix[N, 2] new_obs;             // N beetles
    vector[N] length;                  // N length observations (positive)
    vector[N] mass;                    // N mass observations (positive)
    // Derived parameters for interpretation
    real correlation;
    correlation = R[1, 2];

    //   vector<lower=0>[2] new_obs;        // one simulated beetle
    // Generate N observations from the likelihood
    for (n in 1:N) {
        new_obs[n] = multi_normal_rng(mu, CovMat)';
        length[n] = new_obs[n,1];
        mass[n] = new_obs[n,2];
    }
}
