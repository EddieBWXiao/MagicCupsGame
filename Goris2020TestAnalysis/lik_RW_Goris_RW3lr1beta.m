function [negLL,vv,p]=lik_RW_Goris_RW3lr1beta(parameters, actions, outcomes,condition,priors)

%{
%fit three different blocks, with same inverse temperature
% done in native space
% note: value from previous block continues to the next

    %parameters: vector (1xn parameters), transformed to logit/log space
    %subj: struct, from output of a simulated agent
    %subj.choices: n_trials x 1, for decisions 
    %subj.feedback.outcomes: n_trials x 1, ONLY the chosen
    output negative LL for fmin
    %condition: which block the particular trial is in
%}

if nargin < 5
    priors = false;
end

%% unpack input & prepare
%alpha = learning rate
alpha1  = parameters(1); %condition 1, e.g., stable low noise
alpha2  = parameters(2); %condition 2
alpha3  = parameters(3); %condition 3
%inverse temperature, same for all blocks
beta  = parameters(4);

% number of trials
T = length(actions);

% to save probability of choice & values expected
p = nan(T,1);%one column (p of that choice, on that trial)
p1_store = nan(T,1);
v = nan(T,2);%specify expectation for each option
PE = nan(T,2);
% expected value for both actions initialized at 0.5
v_initial = [0.5,0.5];
v_trial = v_initial;%1x2, just about current trial

%% loop through trials
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
    %PE: update only the chosen option
    PE(t,a) = outcomes(t) - v(t,a);%for first trial, note change from baseline
    PE(t,3-a) = 0;%the other option (if 1, 2; if 2, 1)
    
    %update expectation on future trial; alpha depends on trial
    if condition(t) == 1
        v_trial = v_trial + (alpha1.*PE(t,:));
    elseif condition(t) == 2
        v_trial = v_trial + (alpha2.*PE(t,:));
    elseif condition(t) == 3
        v_trial = v_trial + (alpha3.*PE(t,:));
    end
    
end

vv = v;
% sum of log-probability(data | parameters)
loglik = sum(log(p+eps));%eps necessary to prevent negative infinity

if priors
    loglik= loglik+log(pdf('beta', alpha1, 1.1,1.1));
    loglik= loglik+log(pdf('beta', alpha2, 1.1,1.1));
    loglik= loglik+log(pdf('beta', alpha3, 1.1,1.1));
    loglik= loglik+log(pdf('gam', beta, 1.2, 5)); 
end

negLL = -loglik;
end