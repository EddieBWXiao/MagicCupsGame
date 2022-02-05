function outr = PL_RW1lr_Joint_Recovery
    % examine performance for parameter estimation + model itself
    % for fit_RL_RW_2p

    
    myseq = [20,0.8;20,0.2;20,0.8;20,0.2;20,0.8];
    task = gen_misce_task(myseq);
    
    nsimus = 500;%number of parameter values/simulations swept through/done
    nmethods = 1;
    
    alpha_range = unifrnd(0,1,[1,nsimus]);
    alpha_recovered = nan(nsimus,nmethods);
    beta_range = unifrnd(0.1,6,[1,nsimus]);
    beta_recovered = nan(nsimus,nmethods);
    
    for i = 1:nsimus
        s = RW1lr_plsim(task,[alpha_range(i),beta_range(i)],0);
        
        %% fit from Browning's mean posterior
        
        actions = s.choices; % 1 for action=1 and 2 for action=2; assume no missing trials
        outcomes = s.feedback.outcomes(:,1:2); % e.g., 1 for win on trial, 0 for no win
        
        missing = false(size(actions));
        
        fitted = fit_PL_RW_2p(actions,outcomes,@lik_RW1lr_PL,missing,0);
        
        alpha_recovered(i,1) = fitted.mean_a;
        beta_recovered(i,1) = fitted.mean_beta;    
        
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
    
    
    recoverability = struct('alpha',r_a,'beta',r_beta);
    
    outr = struct('recoverability',recoverability,...
        'alpha_range',alpha_range,'alpha_recovered',alpha_recovered,...
        'beta_range',beta_range,'beta_recovered',beta_recovered,...
        'n_simulated',nsimus);
    
    save(sprintf('simpleRW_recovery-%s',date),'outr')
    
end
