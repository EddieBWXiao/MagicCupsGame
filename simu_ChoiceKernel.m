function [actions, traj] = simu_ChoiceKernel(params,opt1)

% simplified simulation code for IBLT task
% model: choice kernel
% input:
    % params: parameters; 2x1 matrix, alpha, beta
    % opt1: the outcomes from option 1 observed by the participant
% output:
    % actions: array of 1 & 2 --> options chosen
    % traj: struct variable; trajectories for pchoice & v (one only)

%% unpack free parameters & set fixed parameters
alpha = params(1);
beta = params(2);

initial_belief = [0,0];

%% prepare and preallocate variables
wins = opt1(:,1);
%losses = opt1(:,2);
nt = length(wins);%record number of trials
actions = nan(nt,1);%one choice made every trial

%follow format: n_trials x n_choices
vv = nan(nt,2);
pchoice = nan(nt,2);

%% loop through trials
for t=1:nt
    %% initialise  expectations
    if t == 1
        vv(t,:) = initial_belief;
    end
    %% choice/response model
    pchoice_opt1 = exp(beta*vv(t,1))/(exp(beta*vv(t,1))+exp(beta*vv(t,2)));
    pchoice(t,:) = [pchoice_opt1,1-pchoice_opt1]; %record p for both; either choose opt1, or opt2    
    % Do a weighted coinflip to make a choice: choose stim 1 if random
    if rand(1) < pchoice(t,1) %bigger the pchoice, more likely to choose "1"
        actions(t) = 1;
        a = [1,0]; %log the action
    else
        actions(t) = 2;
        a = [0,1];
    end
    
    %% pudate choice kernel
    vv(t+1,:) = vv(t,:) + alpha.*(a-vv(t,:));
    
    %% deal with extra t+1
    if t == nt    
        vv(t+1) = [];
    end
end

%% output
params = struct('alpha',alpha,'beta',beta);
traj = struct('vv',vv,'pchoice',pchoice,'params',params);

end