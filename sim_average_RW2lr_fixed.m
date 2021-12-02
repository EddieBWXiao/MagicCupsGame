function sim_average_RW2lr_fixed(simufunc,params,condition)

%takes in function handle for simulations
    % only for models with two independent representations (v_r and v_p),
    % not simpleRW models
%params: parameter values for simulation 
    %MUST BE COLUMN VECTOR, with sequence same as simufunc params
%condition: string, e.g., 'both volatile'

%runs simulations over multiple subjects of similar input parameters
%takes average, produce choice graph

%fixed: use Magic Cups Game feedback scheme

%% transpose params if not vertical
if size(params,2) > size(params,1)
   params = params'; 
end

%% same parameter value, run multiple times to remove stochasticity in choice

t = gen_IBLT_task(condition);%set up task; fixed (all from Magic Cups Game)
refc = 1;%consider option 1
nruns = 100;

for i = nruns:-1:1
    %simulate
    
    s = simufunc(t,params,false);%false: must NOT plot graphs within each simu
    % extract things to plot
    p_win(:,i) = s.task.p_win;
    p_loss(:,i) = s.task.p_loss;
    v_r(:,i) = s.v_r(:,refc);%use option 1 as
    v_p(:,i) = s.v_p(:,refc);
    pchoice(:,i) = s.pchoice(:,refc);
    choicevis(:,i) = 2-s.choices;
end

%produce string for displaying the parameters simulated
paraminfo = string(fieldnames(s.params)) + repmat([' = '],[length(params),1]) + num2str(params);
paraminfo = paraminfo';%allow merge 
tailored_title = cellstr([sprintf('%s, %s, simulation average (n = %i)',func2str(simufunc),condition,nruns),paraminfo]);
xt = s.furtherinfo.xt;

%% average the variables across simulations
p_win = mean(p_win,2);
p_loss = mean(p_loss,2);
v_r = mean(v_r,2);
v_p = mean(v_p,2);
pchoice = mean(pchoice,2);
choicevis = mean(choicevis,2);
%get the temporal trajectories across "identical" virtual participants

%% visualise
figure;
plot(xt,p_win,'b-');
hold on
plot(xt,p_loss,'r-');
plot(xt,v_r(:,refc),'--');
plot(xt,v_p(:,refc),'--');
plot(xt,pchoice(:,refc),'-','LineWidth',3);
plot(xt, choicevis,'*')
hold off
legend('p(win|choose opt 1)','p(loss|choose opt 1)','reward expectation for opt 1','punishment expectation for opt 1','p(choose option 1)')
xlabel('trials')
ylabel('probability')
title(tailored_title, 'Interpreter', 'none')%tailored_title already cell array


end