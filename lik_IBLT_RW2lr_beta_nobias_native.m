function [negLL,vv,pchoice] = lik_IBLT_RW2lr_beta_nobias_native(parameters, actions, outcomes_all)

% likelihood function for given parameters and performance
% native space
% fit over only one block (e.g., 60 trials)

% actions: 1 for chosen opt 1 and 2 for chosen opt 2; assume no missing trials
% outcomes_all: ALL the outcomes (for both options, both outcome types)
    %first column: opt1 wins
    %second column: opt1 losses
    %third column: opt2 wins
    %fourth column: opt2 losses

%% unpack parameters 
%alpha1 is alpha-win
alpha_w  = parameters(1); 
alpha_l  = parameters(2);
beta  = parameters(3);

%fixed params
initial_win_belief = 0.5;
initial_loss_belief = 0.5;

%% unpack data & preallocate
opt1 = [outcomes_all(:,1),outcomes_all(:,2)];
    %win opt1 and loss opt1
wins = opt1(:,1); % 1 for win on trial, 0 for no win
losses = opt1(:,2); % 1 for loss on trial
    % note: this is different from the wins & losses used for calc_
    
% number of trials
T = length(wins);

% preallocate traj for opt1
WPE = nan(size(wins));%updates expectation for wins, for option1
LPE = nan(size(losses));%updates expectation for losses
v_w = nan(size(wins));%value learnt from wins (rewards)
v_l =nan(size(losses));%value learnt from losses (punishments)

pchoice = nan(T,2); % for both options
p = nan(T,1); % for the chosen option (to calculate L)
    %one column (p of that choice, on that trial)
    
for t=1:T    
    %% initialise  expectations
    if t == 1
        v_w(t) = initial_win_belief;
        v_l(t) = initial_loss_belief;
    end
    %% response model
    p1 = 1./(1+exp(-beta*(v_w(t)-v_l(t)))); % probability of action 1
    p2 = 1-p1; % probability of action 2
    pchoice(t,:) = [p1,p2]; %record both
    
    % get probability of the chosen action
    if actions(t) == 1
        p(t) = p1;
    elseif actions(t) ==2
        p(t) = p2;
    end   
    
    %% learning (only about option 1)
    WPE(t) = wins(t) - v_w(t);%calculate PE
    LPE(t) = losses(t) - v_l(t);
    v_w(t+1) = v_w(t) + alpha_w*WPE(t); %update value
    v_l(t+1) = v_l(t) + alpha_l*LPE(t); 
    
end

vv = [v_w(1:end-1),v_l(1:end-1)]; %output for the two value trajectories
    %chop off the extra row

% sum of log-probability(data | parameters)
loglik = sum(log(p+eps));
negLL = -loglik;

end