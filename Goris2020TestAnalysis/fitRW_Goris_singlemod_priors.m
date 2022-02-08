function dfit = fitRW_Goris_singlemod_priors

%fit Goris with single inverse temperature for all blocks
%include priors

%% load data & prepare
d = load('GorisParticipantsMini.mat');
vnam = fieldnames(d);
d = d.(vnam{1});

nsub = length(d);%num subjects

%preallocate
alpha_sl = nan(nsub,1);%stable, low noise
alpha_sh = nan(nsub,1);%stable, high noise
alpha_v = nan(nsub,1);%stable, high noise
beta = nan(nsub,1);
subj = cell(nsub,1);

%settings for fitting
lb = [1e-8,1e-8,1e-8,1e-8];
ub = [1,1,1,30];

%% fit with separate blocks (not single inverse temp)
for i=1:nsub
    %get participant label
    subj{i} = d{i,1};
    %table for all responses
    t = d{i,2};

    %% fit through all block at once
    actions = t.actions;
    outcomes = t.outcomes;
    missing = t.missing;
    condition = t.Condition;
    actions(missing)=[];
    outcomes(missing)=[];
    
    initial = rand(1,length(lb)).* (ub - lb) + lb;
    costfun = @(x) lik_RW_multiblock(x, actions, outcomes,condition,true);
    params = fmincon(costfun,initial,[],[],[],[],lb, ub,[],optimset('maxfunevals',10000,'maxiter',2000,'Display', 'off'));
    
    %% retrieve alpha by the right sequence
    %repind = [true,diff(condition)~=0];%logical indices for removing repeated elements
    %conseq = condition(repind);%array specifying how the conditions were ordered
    
    alpha_sl(i) = params(1);
    alpha_sh(i) = params(2);
    alpha_v(i) = params(3);
    beta(i) = params(4);
    %parameters were coded so that they correspond to the three conditions,
    %not to the order that trials were entered
    
end

dfit = table(subj,alpha_sl,alpha_sh,alpha_v,beta);

save('Goris_RW1lr_fit_singlemod_priors.mat','dfit')
writetable(dfit,'Goris_RW1lr_fit_singlemod_priors.csv')

end