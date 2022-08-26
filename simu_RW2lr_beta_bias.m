function [actions, traj] = simu_RW2lr_beta_bias(params,opt1)

% simplified simulation code for IBLT task
% model: Rescorla-Wagner, two learning rates, with one beta and one bias parameter
% input:
    % params: parameters; 4x1 matrix, a_win a_loss, beta, bias
    % opt1: the outcomes from option 1 observed by the participant
% output:
    % actions: array of 1 & 2 --> options chosen
    % traj: struct variable; trajectories for pchoice & v_win/loss

%% unpack free parameters & set fixed parameters
alphas = params(1:2);
beta = params(3);
bias = params(4);
alpha_w = alphas(1);
alpha_l = alphas(2);

initial_win_belief = 0.5;
initial_loss_belief = 0.5;

%% prepare and preallocate variables
wins = opt1(:,1);
losses = opt1(:,2);
nt = length(wins);%record number of trials
actions = nan(nt,1);%one choice made every trial

%follow format: n_trials x n_choices
WPE = nan(size(wins));%updates expectation for wins, for option1
LPE = nan(size(losses));%updates expectation for losses
v_w = nan(size(wins));%value learnt from wins (rewards)
v_l =nan(size(losses));%value learnt from losses (punishments)
pchoice = nan(nt,2);

%% loop through trials
for t=1:nt
    %% initialise  expectations
    if t == 1
        v_w(t) = initial_win_belief;
        v_l(t) = initial_loss_belief;
    end
    %% choice/response model
    pchoice_opt1 = (1+exp(-beta*(v_w(t)-v_l(t)+bias))).^-1;%as per Pulcu & Browning 2017
    pchoice(t,:) = [pchoice_opt1,1-pchoice_opt1]; %record p for both; either choose opt1, or opt2    
    % Do a weighted coinflip to make a choice: choose stim 1 if random
    if rand(1) < pchoice(t,1) %bigger the pchoice, more likely to choose "1"
        actions(t) = 1;
    else
        actions(t) = 2;
    end
    
    %% learning
    WPE(t) = wins(t) - v_w(t);%calculate PE
    LPE(t) = losses(t) - v_l(t);
    v_w(t+1) = v_w(t) + alpha_w*WPE(t);%update value
    v_l(t+1) = v_l(t) + alpha_l*LPE(t);
    %% deal with extra t+1
    if t == nt    
        v_w(t+1) = [];
        v_l(t+1) = [];
        final_v_w = v_w(t) + alpha_w*WPE(t);
        final_v_l = v_l(t) + alpha_l*LPE(t);
    end
end

%% output
params = struct('alpha_w',alpha_w,'alpha_l',alpha_l,'beta',beta,'bias',bias);
traj = struct('v_w',v_w,'v_l',v_l,'pchoice',pchoice,'final_v_w',final_v_w,'final_v_p',final_v_l,'WPE',WPE,'LPE',LPE,'params',params);
end