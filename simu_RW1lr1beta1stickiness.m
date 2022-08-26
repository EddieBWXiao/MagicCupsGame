function [actions, traj] = simu_RW1lr1beta1stickiness(params,opt1)

% simplified simulation code for IBLT task
% model: Rescorla-Wagner, one learning rate, with one beta, and stickiness
% input:
    % params: parameters; 3x1 matrix, alpha, beta, stickiness
    % opt1: the outcomes from option 1 observed by the participant
% output:
    % actions: array of 1 & 2 --> options chosen
    % traj: struct variable; trajectories for pchoice & v (one only)

%% unpack free parameters & set fixed parameters
alpha = params(1);
beta = params(2);
stickiness = params(3);

initial_belief = 0.5;

%% prepare and preallocate variables
wins = opt1(:,1);
losses = opt1(:,2);
nt = length(wins);%record number of trials
actions = nan(nt,1);%one choice made every trial

%follow format: n_trials x n_choices
PE = nan(size(wins));%updates expectation for wins, for option1
vv = nan(size(wins));%value learnt from wins (rewards)
pchoice = nan(nt,2);

%% loop through trials
for t=1:nt
    %% initialise  expectations
    if t == 1
        vv(t) = initial_belief;
        stickCode = 0;
    end
    %% choice/response model
    pchoice_opt1 = (1+exp(-(beta*vv(t)+stickiness*stickCode))).^-1;
    pchoice(t,:) = [pchoice_opt1,1-pchoice_opt1]; %record p for both; either choose opt1, or opt2    
    % Do a weighted coinflip to make a choice: choose stim 1 if random
    if rand(1) < pchoice(t,1) %bigger the pchoice, more likely to choose "1"
        actions(t) = 1;
    else
        actions(t) = 2;
    end
    
    %% learning
    PE(t) = wins(t)- losses(t) - vv(t);%calculate PE, net outcome
    vv(t+1) = vv(t) + alpha*PE(t);%update value
    
    %% keeping tab of past choice
    if actions(t) == 1
        stickCode = 1;
    elseif actions(t) == 2
        stickCode = -1;
    end
    
    %% deal with extra t+1
    if t == nt    
        vv(t+1) = [];
        final_v = vv(t) + alpha*PE(t);
    end
end

%% output
params = struct('alpha',alpha,'beta',beta,'stickiness',stickiness);
traj = struct('vv',vv,'pchoice',pchoice,'final_v',final_v,'PE',PE,'params',params);

end