%% single_ptp_demo

% illustrate role of functions in the folder PL_simulations
% focus on code for a single virtual participant

%% step 1: create a one-armed bandit task with two options and binary outcomes

%first, specify task (number of trials per miniblock, e.g., 20, 
%and contingency, e.g., 0.8 or 0.2)
task_sequence = [20,0.8;20,0.2;20,0.8;20,0.2];

%generate task (output is a struct variable with task information)
task1 = gen_misce_task(task_sequence);

%visualise task to check if structure is as predicted
gen_misce_task_visual(task1);

%% step 2: create a simulated agent (virtual participant) that performs the task

graph = 1; %plot the behaviour of the simulated agent

%set free parameters
    %first free parameter -- alpha (learning rate)
    %second free parameter -- beta (inverse temperature)
alpha = 0.4;
beta = 6;
params = [alpha,beta]; 

fprintf('simulated alpha = %.2f \n',params(1))
fprintf('simulated beta = %.2f \n',params(2))
    
%generate the simulation (another struct variable)
simu = RW1lr_plsim(task1,params,graph);
    %use Rescorla-Wagner model, with single learning rate
    %the agent updates expectations of both options

%another function to do a plot of the simulation separately, if needed
simvis_RW(simu,task1);
    
%% step 3: compute model-independent measures for the virtual participant

%find win-stay and lose-shift rates in this particular run
[lsrate,wsrate] = wsls_sim_calc(simu);

%% step 4: visualise average behaviour of virtual participant

%same free parameters, same overall task structure
%multiple runs (outcomes on each individual trial differs across runs)
%help visualise general behavioural pattern 
%(e.g., slow or quick update to contingency changes)

graph = 1;
nruns = 100;%larger, less noisy

sim_average_PL(@RW1lr_plsim,params,task_sequence,nruns,graph);

%% step 5: fit behaviour in "simu" with grid search

%extract relevant information 
actions = simu.choices;%extract participant choices (to fit)
outcomes = simu.feedback.outcomes;%get outcomes (for both options)
missing = false(size(actions));%missing trials -- none for simulated agents

graph = true;%visualise the likelihood function and marginal distributions

%estimate the free parameters
ests = fit_PL_RW_2p(actions,outcomes,@lik_RW1lr_PL,missing,graph);
fprintf('estimated alpha = %.2f \n',ests.mean_a)
fprintf('estimated beta = %.2f \n',ests.mean_beta)

%% step 6: check quality of fit for individual virtual participant

fitvis_RW(@lik_RW1lr_PL, [logit(alpha),log(beta)],simu.choices,simu.feedback.outcomes,task1)
%visualise the fitted trajectories


