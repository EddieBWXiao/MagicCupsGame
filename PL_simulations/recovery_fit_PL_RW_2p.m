function outr = recovery_fit_PL_RW_2p(inseq,alpha_range,beta_range,fith,simuh)
    % flexible parameter recovery analysis script
    % for fit_PL_RW_2p (grid search strategy)
    % allow different tasks, different parameter values sampled,
    % and different functions compatabile with fit_PL_RW_2p

    %input: 
    % inseq: nminiblock x 2 array for task structure
        % example: inseq = [1000,0.8;1000,0.2];
    % alpha_range & beta_range: parameter values (as realistic as possible)
    % fith: function handle for the likelihood f, e.g., @lik_RW1lr_PL
    % simuh: function handle for simulations
    
    %% prepare and preallocate
    task = gen_misce_task(inseq);
    nsimus = length(alpha_range);%number of parameter values/simulations swept through/done
        %should be the same for both parameters 
    alpha_recovered = nan(nsimus,1);
    beta_recovered = nan(nsimus,1);
    
    for i = 1:nsimus
        s = simuh(task,[alpha_range(i),beta_range(i)],0);%simulate participant
        %% fit from mean posterior
        actions = s.choices; % 1 for action=1 and 2 for action=2; assume no missing trials
        outcomes = s.feedback.outcomes(:,1:2); % e.g., 1 for win on trial, 0 for no win
        missing = false(size(actions));%no missing trials
        
        fitted = fit_PL_RW_2p(actions,outcomes,fith,missing,0);
        
        alpha_recovered(i,1) = fitted.mean_a;
        beta_recovered(i,1) = fitted.mean_beta;    
        
        if mod(i,10) == 0
            fprintf('== simulation number %i completed == \n',i)
        end
    end
    
    %% calculate recoverability
    r_a = corr(alpha_range',alpha_recovered);
    r_beta = corr(beta_range',beta_recovered);

    %% visualise
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
    
    %save(sprintf('simpleRW_recovery-%s',date),'outr')
    
end