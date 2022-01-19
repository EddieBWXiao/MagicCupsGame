function [ests,joint] = MLEfit_PL_RW1lr(subj, graph)
    % find the full joint likelihood distribution for input data
    % model: simplest RW with inverse temp (no bias, only two parameters)
    % note: PL = probabilistic learning task 
        %(binary outcome, one-armed bandit)
    
    % fit by maximising the full joint/take mean of distribution
    % produce parameter estimate
    % search of parameter space done in logit/log
    
    %note: derived from the debugged "simpleRW_jointLLfit_transformed"
    
    %close all

    %% list possible range of parameter values
    alphabins = 30;
    betabins = 30;
    
    %created in logit space or log etc.
    a_range = logit(0.01):(logit(0.99) - logit(0.01))/(alphabins-1):logit(0.99);
    b_range = log(0.1):(log(100)-log(0.1))/(betabins-1):log(100);
    %note: consistently use row vectors

    %put back to native space
    a_native = logistic(a_range);
    b_native = exp(b_range);
    
    %% loop through possible values, with other parameters fixed
    
    for cycle1 = length(a_range):-1:1
        for cycle2 = length(b_range):-1:1
            %parameters in native space must be transformed for _lik
            parameters(1) = a_range(cycle1);
            parameters(2) = b_range(cycle2);
            joint(cycle1,cycle2) = in_PL_RW1lr_lik(parameters,subj);%function at the end of script
        end
        %fprintf('parameter combination loops: %i to go \n',cycle1-1)
    end
    
    %record which dimension for which parameter
    a_dim = 1;
    beta_dim = 2;
    
    %% find maxima (of log joint LL)
    [~,loc] = max(joint(:));
    [ii,jj] = ind2sub(size(joint),loc);
    ests.aMLE = logistic(a_range(ii));
    ests.betaMLE = exp(b_range(jj));
    
    %% find mean (of joint LL, not log LL)
    joint = exp(joint);%convert back to LL
        %the total sum of this matrix may be < 1
    joint = joint./sum(joint(:));% normalise
        % equivalent to out.posterior_prob in Browning_fit_2lr_1betaplus
    
    marg_a = make_column(squeeze(sum(joint,beta_dim)));%should be a normalised distribution
    marg_beta = make_column(squeeze(sum(joint,a_dim)));
    
    %find mean (expected value) from marginalised distr. of each parameter
    ests.mean_a = logistic(dot(marg_a,a_range));%column vector before row vect
    ests.mean_beta = exp(dot(marg_beta,b_range));

    %% graph
    %clear joint
    if graph   
        figure;
        subplot(2,2,1)
        plot(a_native,marg_a)
        hold on
        
        xline(ests.aMLE,'g')
        xline(ests.mean_a,'r')
        hold off
        legend('distribution','joint MLE','marg mean')
        xlabel('alpha')
        ylabel('probability')

        subplot(2,2,2)
        imagesc(joint);
        title('alpha and beta, joint LL distribution')
        
        subplot(2,2,3)
        plot(b_native,marg_beta)
        hold on
        xline(ests.betaMLE,'g')
        xline(ests.mean_beta,'r')
        hold off
        legend('distribution','joint MLE','marg mean')
        xlabel('beta')
        ylabel('probability')
        hold off       
        
    end
    
    
end
function v = make_column(v)
    if ~iscolumn(v)
        v = v';
    end
end
function [loglik,p1_store,vv,p,negLL] = in_PL_RW1lr_lik(parameters,subj)
    %{
    % likelihood function for given parameters and performance
    % simplest RW, only two free parameters, no independent LRs
    % for task with only one outcome type (PL, probabilistic learning)

    %parameters: vector (1xn parameters), transformed to logit/log space
    %subj: struct, from output of a simulated agent
    %subj.choices: n_trials x 1, for decisions 
    %subj.feedback.outcomes: n_trials x 4, all feedback received (including
    those not entering total score)
    %}

    %% parameters (transform to native space)
    %alpha = learning rate
    nd_alpha  = parameters(1); % normally-distributed alpha
    alpha     = 1/(1+exp(-nd_alpha)); % alpha1 (transformed to be between zero and one) 

    %inverse temperature
    nd_beta  = parameters(2);
    beta    = exp(nd_beta);

    %% unpack data (struct content same as RW2lr_bias_simu)
    actions = subj.choices; % 1 for action=1 and 2 for action=2; assume no missing trials
    outcomes = subj.feedback.outcomes(:,1:2); % e.g., 1 for win on trial, 0 for no win
        %column 1 and 2 corresponds to choices of action 1 and 2

    % number of trials
    T = length(actions);

    % to save probability of choice & values expected
    p = nan(T,1);%one column (p of that choice, on that trial)
        p1_store = nan(T,1);
    v = nan(T,2);%specify expectation for each option

    % expected value for both actions initialized at 0.5
    v_trial = [0.5,0.5];%1x2, just about current trial

    for t=1:T    
        v(t,:) = v_trial;
        %% response model
        % probability of action 1
        p1 = 1./(1+exp(-beta*(v(t,1)-v(t,2))));
        p1_store(t) = p1;
        % probability of action 2
        p2 = 1-p1;
        % store probability of the chosen action
        a = actions(t); % action on this trial (1 or 2)
        if a==1
            p(t) = p1;
        elseif a==2
            p(t) = p2;
        end   
        %% learning
        %update, regardless of outcome
        delta  = outcomes(t,:) - v(t,:);
        v_trial = v_trial + (alpha*delta);

    end
    vv = v;

    % sum of log-probability(data | parameters)
    loglik = sum(log(p+eps));
    negLL = -loglik;
end
