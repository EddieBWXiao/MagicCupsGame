function task = gen_simpleRL_task(ntrials,nreversals,contingency,graph)

%creates struct with task information
%allows different versions (60 trials, 80 trials, fixed or random,
%different number of reversals etc.)
%provides input to all _sim functions
%outcome can also be merged to form a Behrens 2007-like task

%% outline the probabilistic associations
altconting = 1-contingency;%the contingency after reversal
probpre = repmat(contingency,ntrials,1);
probs = [repmat(contingency,ntrials,1);repmat(altconting,ntrials,1)];

%% set task condition & generate feedback

if nreversals == 1
    p = probs;
elseif nreversals == 0
    p = probpre;
elseif mod(nreversals,2)~=0
    p = [repmat(probs,(nreversals-1)/2,1);repmat(probpre,1,1)];
else
    p = repmat(probs,nreversals/2,1);%
end
outcome = nan(size(p));

%designate whether each trial is a win or loss, for option one
for t = 1:length(p)
    if rand(1)< p(t)
    outcome(t) = 1;
    else
    outcome(t) = 0;
    end
end

%% record other task-relevant information
nt = length(outcome);%record number of trials
xt = 1:1:nt;%array for 1:1:number of trials
xt = xt';%should be a column vector
%flip the 1 and 0 from option one, creating option two
%combine to form matrices of n_trial x n_options
outcome = [outcome,~outcome];

%% output 
task = struct('p',p,'outcome',outcome,'nt',nt,'xt',xt);

%% visualise
if graph
    figure;
    plot(xt,p,'b-');
    hold on
    plot(xt, outcome(:,1),'*')
    hold off
    legend('p(good outcome|choose opt 1)','outcome')
    xlabel('trials')
    ylabel('probability')
end
end