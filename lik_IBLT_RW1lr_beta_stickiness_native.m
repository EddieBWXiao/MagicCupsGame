function [negLL,vv,pchoice] = lik_IBLT_RW1lr_beta_stickiness_native(parameters, actions, outcomes_all)

% likelihood function for given parameters and performance
% native space
% fit over only one block (e.g., 60 trials)
% use only one learning rate

% actions: 1 for chosen opt 1 and 2 for chosen opt 2; assume no missing trials
% outcomes_all: ALL the outcomes (for both options, both outcome types)
    %first column: opt1 wins
    %second column: opt1 losses
    %third column: opt2 wins
    %fourth column: opt2 losses
% has two inverse temperatures, one for win & one for loss

%% unpack parameters 
alpha  = parameters(1); 
beta  = parameters(2);
stickiness = parameters(3);

%fixed params
initial_val_belief = 0.5;

%% unpack data & preallocate
opt1 = [outcomes_all(:,1),outcomes_all(:,2)];
    %win opt1 and loss opt1
wins = opt1(:,1); % 1 for win on trial, 0 for no win
losses = opt1(:,2); % 1 for loss on trial
    % note: this is different from the wins & losses used for calc_

% number of trials
T = length(wins);

% preallocate traj for opt1
PE = nan(size(wins));%updates expectation for opt1
v = nan(size(wins));%value learnt from wins (rewards)

pchoice = nan(T,2); % for both options
p = nan(T,1); % for the chosen option (to calculate L)
    %one column (p of that choice, on that trial)
    
for t=1:T    
    %% initialise  expectations
    if t == 1
        v(t) = initial_val_belief;
        stickCode = 0;
    end
    %% response model
    p1 = 1./(1+exp(-(beta*v(t)+stickiness*stickCode))); % probability of action 1
    p2 = 1-p1; % probability of action 2
    pchoice(t,:) = [p1,p2]; %record both
    
    % get probability of the chosen action
    if actions(t) == 1
        p(t) = p1;
        stickCode = 1;
    elseif actions(t) ==2
        p(t) = p2;
        stickCode = -1;
    end   
    %% learning (only about option 1)
    PE(t) = (wins(t)-losses(t)) - v(t);%calculate PE
    v(t+1) = v(t) + alpha*PE(t); %update value  
end

vv = v(1:end-1); %chop off the extra row

% sum of log-probability(data | parameters)
loglik = sum(log(p+eps));
negLL = -loglik;
end