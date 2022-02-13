function ParameterRecoveryComparisons1

% compare mean posterior (grid search) versus optimisation algorithm

inseq = [1000,0.8];
nsimus = 1000;%number of parameter values/simulations swept through/done
alpha_range = unifrnd(0,1,[1,nsimus]);
beta_range = exprnd(10,[1,nsimus]);
fith = @lik_RW1lr_PL;
simuh = @RW1lr_plsim;

recovery_fit_PL_RW_2p(inseq,alpha_range,beta_range,fith,simuh);
sgtitle('stable 1000 trials task; mean posterior fit')

fith = @lik_RW1lr_PL_native;
recovery_fmin_RW_2p(inseq,alpha_range,beta_range,fith,simuh,false);
sgtitle('stable 1000 trials task; MLE fit')

fith = @lik_RW1lr_PL_native;
recovery_fmin_RW_2p(inseq,alpha_range,beta_range,fith,simuh,true);
sgtitle('stable 1000 trials task; MAP fit')

end