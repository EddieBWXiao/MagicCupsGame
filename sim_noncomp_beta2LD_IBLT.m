function sim_noncomp_beta2LD_IBLT

% visualise how beta affects LR ~ loss-driven relations


maxn = 60;%number of repeats for each heatmap cell
condition = 'both volatile';
alpha_div = 0.1;
simufunc = @simu_RW2lr_bias;
    
%% try different betas

figure
altparams = [0.4,0];% here, beta and bias
subplot(3,2,1);
sim_noncomp_IBLTblocks(simufunc,condition,altparams,alpha_div,maxn,'LD');
axis square
title({'loss-driven behaviour',sprintf('beta = %i, bias = %i',altparams(1),altparams(2))})
altparams = [0.8,0];% here, beta and bias
subplot(3,2,2);
sim_noncomp_IBLTblocks(simufunc,condition,altparams,alpha_div,maxn,'LD');
axis square
title({'loss-driven behaviour',sprintf('beta = %i, bias = %i',altparams(1),altparams(2))})
altparams = [1,0];% here, beta and bias
subplot(3,2,3);
sim_noncomp_IBLTblocks(simufunc,condition,altparams,alpha_div,maxn,'LD');
axis square
title({'loss-driven behaviour',sprintf('beta = %i, bias = %i',altparams(1),altparams(2))})
altparams = [2,0];% here, beta and bias
subplot(3,2,4);
sim_noncomp_IBLTblocks(simufunc,condition,altparams,alpha_div,maxn,'LD');
axis square
title({'loss-driven behaviour',sprintf('beta = %i, bias = %i',altparams(1),altparams(2))})
altparams = [3,0];% here, beta and bias
subplot(3,2,5);
sim_noncomp_IBLTblocks(simufunc,condition,altparams,alpha_div,maxn,'LD');
axis square
title({'loss-driven behaviour',sprintf('beta = %i, bias = %i',altparams(1),altparams(2))})
altparams = [10,0];% here, beta and bias
subplot(3,2,6);
sim_noncomp_IBLTblocks(simufunc,condition,altparams,alpha_div,maxn,'LD');
axis square
title({'loss-driven behaviour',sprintf('beta = %i, bias = %i',altparams(1),altparams(2))})


end