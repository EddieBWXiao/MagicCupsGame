function dfit = fitRW_Goris

%fit RW1lr (2arms) model to Goris

%% load data & prepare
d = load('GorisParticipantsMini.mat');
vnam = fieldnames(d);
d = d.(vnam{1});

nsub = length(d);%num subjects

%preallocate
alpha_sl = nan(nsub,1);%stable, low noise
beta_sl = nan(nsub,1);
alpha_sh = nan(nsub,1);%stable, high noise
beta_sh = nan(nsub,1);
alpha_v = nan(nsub,1);%stable, high noise
beta_v = nan(nsub,1);
subj = cell(nsub,1);

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
    ests = fit_PL_RW_2p(actions,outcomes,@lik_RW1lr_2arms_PL,missing,0);
    alpha_sl(i) = ests.mean_a;
    beta_sl(i) = ests.mean_beta;
    
    %stable block, high noise
    actions = t.actions(t.Condition == 2);
    outcomes = t.outcomes(t.Condition == 2);
    missing = t.missing(t.Condition == 2);
    ests = fit_PL_RW_2p(actions,outcomes,@lik_RW1lr_2arms_PL,missing,0);
    alpha_sh(i) = ests.mean_a;
    beta_sh(i) = ests.mean_beta;
    
    %volatile block
    actions = t.actions(t.Condition == 3);
    outcomes = t.outcomes(t.Condition == 3);
    missing = t.missing(t.Condition == 3);
    ests = fit_PL_RW_2p(actions,outcomes,@lik_RW1lr_2arms_PL,missing,0);
    alpha_v(i) = ests.mean_a;
    beta_v(i) = ests.mean_beta;
end

dfit = table(subj,alpha_sl,beta_sl,alpha_sh,beta_sh,alpha_v,beta_v);

save('Goris_RW1lr_fit_threemods_MP.mat','dfit')
writetable(dfit,'Goris_RW1lr_fit_threemods_MP.csv')

end