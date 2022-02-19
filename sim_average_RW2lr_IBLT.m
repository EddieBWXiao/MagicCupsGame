function aveb = sim_average_RW2lr_IBLT(simufunc,params,condition,nruns)

%takes in function handle for simulations
    % only for models with two independent representations (v_w and v_l),
    % not simpleRW models
%params: parameter values for simulation 
    %MUST BE COLUMN VECTOR, with sequence same as simufunc params
%condition: string, e.g., 'both volatile'
%runs simulations over multiple subjects of similar input parameters
%takes average, produce choice graph

% each implementation has a different task

%% transpose params if not vertical
if size(params,2) > size(params,1)
   params = params'; 
end

%% same parameter value, run multiple times to remove stochasticity in choice

refc = 1;%consider option 1

if nargin < 4
    %default number of repeats
    nruns = 100;
end

for i = nruns:-1:1
    %simulate
    t = gen_IBLT_task(condition,'random');%set up task;
        %different for each block
    Y = t.outcome_opt1;
    [actions,traj] = simufunc(params,Y);%false: must NOT plot graphs within each simu
    % extract things to plot
        %IMPORTANT: each column a "participant"
    
    % record trajectory    
    p_win(:,i) = t.p_win;
    p_loss(:,i) = t.p_loss;
    v_w(:,i) = traj.v_w;%look at option 1
    v_l(:,i) = traj.v_l;
    pchoice(:,i) = traj.pchoice(:,refc);
    
    % compute metrics for storage
    earning(i) = calc_IBLT_earning(actions,t.wins,t.losses);
    [~,switchrates(:,i)] = calc_IBLT_switchrates(actions,t.wins,t.losses);%switch rates; four of them
    lossdriven(i) = calc_lossdriven(actions,t.wins,t.losses);%the proportion of loss driven choices
    
end

%produce string for displaying the parameters simulated
params_disp = params;
paraminfo = string(fieldnames(traj.params)) + repmat([' = '],[length(params_disp),1]) + num2str(params_disp);
paraminfo = paraminfo';%allow merge 
tailored_title = cellstr([sprintf('%s, %s, simulation average (n = %i)',func2str(simufunc),condition,nruns),paraminfo]);
xt = t.xt;

%% average the variables across simulations

%for the trajectory
p_win = mean(p_win,2);
p_loss = mean(p_loss,2);
v_w = mean(v_w,2);
v_l = mean(v_l,2);
pchoice = mean(pchoice,2);
%choicevis = mean(choicevis,2);

%store
aveb = struct('p_win',p_win,'p_loss',p_loss,'v_w',v_w,'v_l',v_l,'pchoice',pchoice,...
    'params',traj.params,'earning',earning,'switchrates',switchrates,'lossdriven',lossdriven);

%% visualise
%first plot: all trajectories; no CI
figure;
plot(xt,p_win,'b-');
hold on
plot(xt,p_loss,'r-');
plot(xt,v_w(:,refc),'--');
plot(xt,v_l(:,refc),'--');
plot(xt,pchoice(:,refc),'-','LineWidth',3);
%plot(xt, choicevis,'*')
hold off
legend('p(win|choose opt 1)','p(loss|choose opt 1)','win expectation for opt 1','loss expectation for opt 1','p(choose option 1)')
xlabel('trials')
ylabel('probability')
title(tailored_title, 'Interpreter', 'none')%tailored_title already cell array
ylim([-0.1,1.1])

end