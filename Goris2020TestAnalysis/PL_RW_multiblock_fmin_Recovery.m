function outr = PL_RW_multiblock_fmin_Recovery(priors)
    % parameter recovery check for lik_RW_multiblock
    % task: follow Goris et al. (2020)
    % examine performance for parameter estimation + model itself
    % using fmincon on likelihood function
    
    if nargin < 1
        priors = false;
    end
    
    %% prepare task & trial info
    myseq = [100,0.7;100,0.6;repmat([20,0.1;20,0.9],2,1);[10,0.1]];
    task = gen_misce_task(myseq);
    
    %manually set label for block conditions (complicated to automate...)
    condition = [ones(100,1); 2*ones(100,1);3*ones(length(task.p)-200,1)];
    
    nsimus = 1000;%number of parameter values/simulations swept through/done
    
    alpha1_range = unifrnd(1e-4,1,[nsimus,1]);
    alpha1_recovered = nan(nsimus,1);
    alpha2_range = unifrnd(1e-4,1,[nsimus,1]);
    alpha2_recovered = nan(nsimus,1);
    alpha3_range = unifrnd(1e-4,1,[nsimus,1]);
    alpha3_recovered = nan(nsimus,1);
    beta_range = unifrnd(1e-4,20,[nsimus,1]);
    beta_recovered = nan(nsimus,1);
    
    %boundary: must have same size as params
    lb = [1e-8,1e-8,1e-8,1e-8];
    ub = [1,1,1,30];

    %% loop
    for i = 1:nsimus
        s = RW1lr_multiblock_plsim(task,[alpha1_range(i),alpha2_range(i),alpha3_range(i),beta_range(i)],condition,0);
        
        actions = s.choices; % 1 for action=1 and 2 for action=2; assume no missing trials
        outcomes = s.feedback.score; % e.g., 1 for win on trial, 0 for no win
        
        initial = rand(1,length(lb)).* (ub - lb) + lb;
        costfun = @(x) lik_RW_multiblock(x, actions, outcomes,condition,priors);
        params = fmincon(costfun,initial,[],[],[],[],lb, ub,[],optimset('maxfunevals',10000,'maxiter',2000,'Display', 'off'));
        
        alpha1_recovered(i,1) = params(1);
        alpha2_recovered(i,1) = params(2);
        alpha3_recovered(i,1) = params(3);
        beta_recovered(i,1) = params(4);    
        
        if mod(i,10) == 0
            fprintf('== simulation number %i completed == \n',i)
        end
    end
    
    r_a1 = corr(alpha1_range,alpha1_recovered);
    r_a2 = corr(alpha2_range,alpha2_recovered);
    r_a3 = corr(alpha3_range,alpha3_recovered);
    r_beta = corr(beta_range,beta_recovered);

    figure;
    subplot(2,2,1)
    plot(alpha1_range,alpha1_recovered,'o')
    hold on
    plot(0:0.05:1,0:0.05:1,'r-')
    hold off
    xlabel('simulated alpha, block 1')
    ylabel('recovered alpha, block 1')
    title(sprintf('r = %.3f',r_a1))

    subplot(2,2,4)
    plot(beta_range,beta_recovered,'o')
    hold on
    plot(0:0.05:max(beta_range),0:0.05:max(beta_range),'r-')
    hold off
    xlabel('simulated beta')
    ylabel('recovered beta')
    title(sprintf('r = %.3f',r_beta))
    
    subplot(2,2,2)
    plot(alpha2_range,alpha2_recovered,'o')
    hold on
    plot(0:0.05:1,0:0.05:1,'r-')
    hold off
    xlabel('simulated alpha, block 2')
    ylabel('recovered alpha, block 2')
    title(sprintf('r = %.3f',r_a2))
    
    subplot(2,2,3)
    plot(alpha3_range,alpha3_recovered,'o')
    hold on
    plot(0:0.05:1,0:0.05:1,'r-')
    hold off
    xlabel('simulated alpha, block 3')
    ylabel('recovered alpha, block 3')
    title(sprintf('r = %.3f',r_a3))
    
    
    recoverability = struct('alpha1',r_a1,'alpha2',r_a2,'alpha3',r_a3,'beta',r_beta);
    
    outr = struct('recoverability',recoverability,...
        'alpha1_range',alpha1_range,'alpha1_recovered',alpha1_recovered,...
        'alpha2_range',alpha2_range,'alpha2_recovered',alpha2_recovered,...
        'alpha3_range',alpha3_range,'alpha3_recovered',alpha3_recovered,...
        'beta_range',beta_range,'beta_recovered',beta_recovered,...
        'n_simulated',nsimus);
    
    save(sprintf('multiblock_Goris_RW_recovery-%s',date),'outr')
    
end
