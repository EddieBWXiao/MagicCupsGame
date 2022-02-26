function single_ptp_IBLT_RW1lr_test

% try different functions for analysing IBLT
% focus on code for a single virtual participant
% do only one block
% use an RW1lr model

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
alpha = 0.4; %learning rate from wins
beta = 10; % inverse temperature
params = [alpha,beta]; 

fprintf('simulated alpha = %.2f \n',params(1))
fprintf('simulated beta = %.2f \n',params(2))

    
%generate the simulation (another struct variable)
[actions, traj] = simu_RW1lr_beta(params,opt1);

%another function to do a plot of the simulation separately, if needed
vis_simu_RW1lr(actions,traj,task)
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

% using MLE
lb = [1e-4,1e-4];
ub = [0.9999,100];
initial = [rand*0.99, exprnd(1)];
costfun = @(x) lik_RW1lr_beta_IBLT_native(x,actions,opt1);
ests = fmincon(costfun,initial,[],[],[],[],lb, ub,[],optimset('maxfunevals',10000,'maxiter',2000,'Display', 'off'));
disp('MLE: ')
fprintf('estimated alpha = %.2f \n',ests(1))
fprintf('estimated beta = %.2f \n',ests(2))

%% step 5: check quality of fit for individual virtual participant
% (needed for the MLE fit)
fitvis_IBLT_1lr(@lik_RW1lr_beta_IBLT_native, ests, actions, opt1, task)
%visualise the fitted trajectories

end