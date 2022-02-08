function dfit = fitRW_Goris_threemod_MLE

%fit RW1lr (2arms) model to Goris

%% load data & prepare
d = load('GorisParticipantsMini.mat');
vnam = fieldnames(d);
d = d.(vnam{1});

nsub = length(d);%num subjects

priors = false;%no priors

%preallocate
alpha_sl = nan(nsub,1);%stable, low noise
beta_sl = nan(nsub,1);
alpha_sh = nan(nsub,1);%stable, high noise
beta_sh = nan(nsub,1);
alpha_v = nan(nsub,1);%stable, high noise
beta_v = nan(nsub,1);
subj = cell(nsub,1);

%settings for fitting
lb = [1e-8,1e-8];
ub = [1,30];

%% fit with separate blocks (not single inverse temp)
for i=1:nsub
    %get participant label
    subj{i} = d{i,1};
    %table for all responses
    t = d{i,2};

    %stable block, low noise
    actions = t.actions(t.Condition == 1);
    outcomes = t.outcomes(t.Condition == 1);
    missing = t.missing(t.Condition == 1);
    actions(missing)=[];
    outcomes(missing)=[];
    initial = rand(1,length(lb)).* (ub - lb) + lb;
    costfun = @(x) one_LR_lik(x,actions,outcomes,priors);
    params = fmincon(costfun,initial,[],[],[],[],lb, ub,[],optimset('maxfunevals',10000,'maxiter',2000,'Display', 'off'));
    alpha_sl(i) = params(1);
    beta_sl(i) = params(2);
    
    %stable block, high noise
    actions = t.actions(t.Condition == 2);
    outcomes = t.outcomes(t.Condition == 2);
    missing = t.missing(t.Condition == 2);
    actions(missing)=[];
    outcomes(missing)=[];
    initial = rand(1,length(lb)).* (ub - lb) + lb;
    costfun = @(x) one_LR_lik(x,actions,outcomes,priors);
    params = fmincon(costfun,initial,[],[],[],[],lb, ub,[],optimset('maxfunevals',10000,'maxiter',2000,'Display', 'off'));
    alpha_sh(i) = params(1);
    beta_sh(i) = params(2);

    %volatile block
    actions = t.actions(t.Condition == 3);
    outcomes = t.outcomes(t.Condition == 3);
    missing = t.missing(t.Condition == 3);
    actions(missing)=[];
    outcomes(missing)=[];
    initial = rand(1,length(lb)).* (ub - lb) + lb;
    costfun = @(x) one_LR_lik(x,actions,outcomes,priors);
    params = fmincon(costfun,initial,[],[],[],[],lb, ub,[],optimset('maxfunevals',10000,'maxiter',2000,'Display', 'off'));
    alpha_v(i) = params(1);
    beta_v(i) = params(2);
end

dfit = table(subj,alpha_sl,beta_sl,alpha_sh,beta_sh,alpha_v,beta_v);

save('Goris_RW1lr_fit_threemods_MLE.mat','dfit')
writetable(dfit,'Goris_RW1lr_fit_threemods_MLE.csv')

end