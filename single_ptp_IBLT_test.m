function single_ptp_IBLT_test

% try different functions for analysing IBLT
% focus on code for a single virtual participant
% do only one block

close all
%% step 1: generate the task (from Magic Cups Game)

% specify task block
block = 'win volatile';
task = gen_IBLT_task(block);
opt1 = task.outcome_opt1;
wins = task.wins;
losses = task.losses;

%visualise task to check if structure is as predicted
gen_IBLT_task_visual(task);
title(block)

%% step 2: create a simulated agent (virtual participant) that performs the task

%set free parameters
    %second free parameter -- beta 
alpha_w = 0.4; %learning rate from wins
alpha_l = 0.2; %learning rate from losses
beta = 6; % inverse temperature
bias = 0.1; %
params = [alpha_w,alpha_l,beta,bias]; 

fprintf('simulated alpha_w = %.2f \n',params(1))
fprintf('simulated alpha_l = %.2f \n',params(2))
fprintf('simulated beta = %.2f \n',params(3))
fprintf('simulated bias = %.2f \n',params(4))
    
%generate the simulation (another struct variable)
[actions, traj] = simu_RW2lr_bias(params,opt1);

%another function to do a plot of the simulation separately, if needed
vis_simu_RW2lr(actions,traj,task)
title(sprintf('block: %s; parameters = %s', block, num2str(params)),'Interpreter', 'none')

%% step 3: model-independent measures for the virtual participant

earning = calc_IBLT_earning(actions,wins,losses); %task earning
switchrates = calc_IBLT_switchrates(actions,wins,losses);%switch rates; four of them
lossdriven = calc_lossdriven(actions,wins,losses);%the proportion of loss driven choices

fprintf('\n')
disp('switch rates')
disp(switchrates)
fprintf('task earning = %i \n', earning)
fprintf('loss-driven choices = %.2f \n',lossdriven)

%% step 4: model fitting

fprintf('\n')
disp('==== Model fitting ====')
disp('Grid search:')
% using Browning fit code
start = [0.5 0.5];
alphabins = 30; 
betabins = 30;
fig_yes = 1; %visualise; plot the two diagnostic graphs
resp_made = true(size(opt1,1),1); %no missing trials
choice = actions == 1;
Browningfit = Browning_fit_2lr_1betaplus(opt1,choice, start,alphabins,betabins, resp_made,fig_yes);
fprintf(' win lr = %.3f , loss lr = %.3f, \n beta = %.1f, added-bias = %.3f \n',...
       Browningfit.mean_alpha_rew,Browningfit.mean_alpha_loss, Browningfit.mean_beta,Browningfit.mean_addm);
set(gcf,'NumberTitle','off') 
set(gcf,'Name','Both Volatile')


% using MLE
lb = [1e-4,1e-4,1e-4,-1];
ub = [0.9999,0.9999,100,1];
initial = [rand*0.99 rand*0.99 exprnd(1) rand*0.99];
costfun = @(x) lik_RW2lr_beta_bias_IBLT_native(x,actions,opt1);
ests = fmincon(costfun,initial,[],[],[],[],lb, ub,[],optimset('maxfunevals',10000,'maxiter',2000,'Display', 'off'));
disp('MLE: ')
fprintf('estimated alpha_w = %.2f \n',ests(1))
fprintf('estimated alpha_l = %.2f \n',ests(2))
fprintf('estimated beta = %.2f \n',ests(3))
fprintf('estimated bias = %.2f \n',ests(4))

%% step 5: check quality of fit for individual virtual participant
% (needed for the MLE fit)
fitvis_IBLT_2lr(@lik_RW2lr_beta_bias_IBLT_native, ests, actions, opt1, task)
%visualise the fitted trajectories

end