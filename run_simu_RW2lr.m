function run_simu_RW2lr


% function to run simulations for IBLT
% visualise all three blocks

simuh = @simu_RW2lr_bias;

% loop through all the blocks
close all
blocks = {'both volatile','win volatile','loss volatile'};
params = {[0.9,0.9,10,0],[0.5,0.02,10,0],[0.02,0.5,10,0]};

for i = 1:length(blocks)

%% set up task
    task = gen_IBLT_task(blocks{i});
    opt1 = task.outcome_opt1;

    %% perform model simulation
    [actions, traj] = simuh(params{i},opt1);

    %% visualise the simulation
    % visualise task structure
    gen_IBLT_task_visual(task);
    title(blocks{i})
    % plot simulation
    vis_simu_RW2lr(actions,traj,task)
    title(sprintf('block: %s; parameters = %s', blocks{i}, num2str(params{i})),'Interpreter', 'none')
end

end