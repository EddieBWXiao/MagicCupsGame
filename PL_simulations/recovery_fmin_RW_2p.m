function outr = recovery_fmin_RW_2p(inseq,alpha_range,beta_range,fith,simuh,priors)
    % examine performance for parameter estimation + model itself
    % using fmincon on likelihood function
    % allow priors
    
    %% prepare and preallocate
    task = gen_misce_task(inseq);
    nsimus = length(alpha_range);%number of parameter values/simulations swept through/done
        %should be the same for both parameters 
    alpha_recovered = nan(nsimus,1);
    beta_recovered = nan(nsimus,1);
    
    %% run with optimisation function, no priors
    lb = [0,0];
    ub = [1,100];
    for i = 1:nsimus
        s = simuh(task,[alpha_range(i),beta_range(i)],0);
        %% fit with MLE
        actions = s.choices; % 1 for action=1 and 2 for action=2; assume no missing trials
        outcomes = s.feedback.outcomes(:,1:2); % e.g., 1 for win on trial, 0 for no win
        %missing = false(size(actions));
        initial = [rand exprnd(1)];
        costfun = @(x) fith(x,actions,outcomes,priors);
        params = fmincon(costfun,initial,[],[],[],[],lb, ub,[],optimset('maxfunevals',10000,'maxiter',2000,'Display', 'off'));
        
        alpha_recovered(i,1) = params(1);
        beta_recovered(i,1) = params(2);    
        
        if mod(i,10) == 0
            fprintf('== simulation number %i completed == \n',i)
        end
    end
    
    r_a = corr(alpha_range',alpha_recovered);
    r_beta = corr(beta_range',beta_recovered);
    
    figure;
    subplot(2,2,1)
    plot(alpha_range,alpha_recovered,'o')
    hold on
    plot(0:0.05:1,0:0.05:1,'r-')
    hold off
    xlabel('simulated alpha')
    ylabel('recovered alpha')
    title(sprintf('r = %.3f',r_a))

    subplot(2,2,2)
    plot(beta_range,beta_recovered,'o')
    hold on
    plot(0:0.05:max(beta_range),0:0.05:max(beta_range),'r-')
    hold off
    xlabel('simulated beta')
    ylabel('recovered beta')
    title(sprintf('r = %.3f',r_beta))
    
    subplot(2,2,3)
    plot(beta_recovered,alpha_recovered,'o')
    ylabel('recovered alpha')
    xlabel('recovered beta')
    title(sprintf('r = %.3f',corr(beta_recovered,alpha_recovered)))
    
    recoverability = struct('alpha',r_a,'beta',r_beta);
    
    outr = struct('recoverability',recoverability,...
        'alpha_range',alpha_range,'alpha_recovered',alpha_recovered,...
        'beta_range',beta_range,'beta_recovered',beta_recovered,...
        'n_simulated',nsimus);
    
end
