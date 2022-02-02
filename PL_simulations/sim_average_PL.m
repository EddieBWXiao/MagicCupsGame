function ave = sim_average_PL(simufunc,params,taskseq,nruns,graph)

%takes in function handle for simulations
    % for simple PL models (binary outcome)
%task changes for every simulation
%good for illustrating what agent with such feature would on average do
%complemented by version with distribution of params & fixed task
    
%params: parameter values for simulation 
    %MUST: sequence same as simufunc params
%taskseq: col 1 trial number, col 2 contingency
%graph: logical; plot or not
%specs: other things to specify

%runs simulations over multiple subjects with same parameter value
%takes average, produce choice graph
%output struct that can be unpacked easily into each variable

%example: sim_average_PL(@RW1lr_plsim,[0.4,10],[100,0.8;100,0.2],300,1)

%% transpose params if not vertical
if size(params,2) > size(params,1)
   params = params'; 
end

%% same parameter value, run on multiple 
if nargin < 4
    graph = 0;
end

refc = 1;%consider option 1

for i = nruns:-1:1
    %create task (random outcome gen for each participant)
    t = gen_misce_task(taskseq);
    
    %create simulated participant
    s = simufunc(t,params,false);%false: must NOT plot graphs within each simu
    
    % extract trajectories to plot
        %IMPORTANT: each column is a "participant"
    p(:,i) = s.task.p;
    v(:,i) = s.v(:,refc);%look at option 1
    pchoice(:,i) = s.pchoice(:,refc);
    
    %compute other metrics for each participant
    earning(:,i) = cumsum(s.feedback.score');%original output is row; total earning
    choicecorr(i) = corr(s.chose1,s.feedback.outcomes(:,1));%correlation between choice and "answer"
    [loseshift(i),winstay(i)] = wsls_calc(s);
end

%produce string for displaying the parameters simulated
paraminfo = string(fieldnames(s.params)) + repmat([' = '],[length(params),1]) + num2str(params);
	%string() produces string array (2x1)
tailored_title = cellstr([sprintf('%s, simulation average (n = %i)',func2str(simufunc),nruns),paraminfo']);
xt = s.furtherinfo.xt;

%% average the variables across simulations
%these are the temporal trajectories
p = mean(p,2);
v = mean(v,2);
pchoice = mean(pchoice,2);
earning_traj = mean(earning,2);%trajectory across trials, mean simus
earning_final = earning(end,:);%final earning for each participant

%% visualise
if graph == 1
    figure;
    plot(xt,p,'g-','LineWidth',2);
    hold on
    plot(xt,v(:,refc),'--','LineWidth',2);
    plot(xt,pchoice(:,refc),'-','LineWidth',2);
    hold off
    legend('p(outcome|choose opt 1)','value expectation for opt 1','p(choose option 1)')
    xlabel('trials')
    ylabel('probability')
    title(tailored_title, 'Interpreter', 'none')%tailored_title already cell array
    ylim([-0.1,1.1])
end

%% store output
ave = struct('p',p,'v',v,'pchoice',pchoice,'earning_final',earning_final,'earning_traj',earning_traj,...
    'choicecorr',choicecorr,'winstay',winstay,'loseshift',loseshift,'params',params,'simufunc',simufunc);
end