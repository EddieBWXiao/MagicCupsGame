function quickrun_simu_RW2lr(simuh,block,params)

% function to run simulations for IBLT
% visualise a single block, with input function & parameters
% test if simulation code working

% loop through all the blocks
close all
blocks = {block};

for i = 1:length(blocks)
%% set up task
    task = gen_IBLT_task(blocks{i});
    opt1 = task.outcome_opt1;

    %% perform model simulation
    [actions, traj] = simuh(params,opt1);

    %% visualise the simulation
    % visualise task structure
    gen_IBLT_task_visual(task);
    title(blocks{i})
    % plot simulation
    vis_simu_RW2lr(actions,traj,task)
    title(sprintf('block: %s; parameters = %s', blocks{i}, num2str(params)),'Interpreter', 'none')
end

end