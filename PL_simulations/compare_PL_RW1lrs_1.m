function compare_PL_RW1lrs_1

% use explore_PL_RW1lr
% run with different task structures and models

%% comparison 1: stable environment, with or without updating both options
s1 = [1000,0.8];
stask = gen_misce_task(s1);
figure;
gen_misce_task_visual(stask);

explore_PL_RW1lr(@RW1lr_plsim,s1,1500,3)
sgtitle('Rescorla-Wagner model updating both options; stable environment')
explore_PL_RW1lr(@RW1lr_2arms_plsim,s1,1500,3)
sgtitle('Standard Rescorla-Wagner model, update only the chosen; stable environment')

%% comparison 2: volatile environment, with or without updating both options
vol1 = repmat([20,0.8;20,0.2],10,1);
vtask = gen_misce_task(vol1);
figure;
gen_misce_task_visual(vtask);

explore_PL_RW1lr(@RW1lr_plsim,vol1,1500,3)
sgtitle('Rescorla-Wagner model updating both options; volatile environment')
explore_PL_RW1lr(@RW1lr_2arms_plsim,vol1,1500,3)
sgtitle('Standard Rescorla-Wagner model, update only the chosen; volatile environment')

%% comparison 3: compare between stable and volatile environments
    %again focusing on inverse temperature

% present differences in the betas
explore_PL_RW1lr(@RW1lr_plsim,s1,1500,2)
sgtitle('stable environment: role of inverse temperature')
explore_PL_RW1lr(@RW1lr_plsim,vol1,1500,2)
sgtitle('volatile environment: role of inverse temperature')

%% comparison 4: examine role of "noise"
s2 = [1000,0.6];
stask2 = gen_misce_task(s2);
figure;
gen_misce_task_visual(stask2);
%here, higher variance (for binomial distribution)

s3 = [1000,0.95];
stask3 = gen_misce_task(s3);
figure;
gen_misce_task_visual(stask3);
%here, very low variance (for binomial distribution)

explore_PL_RW1lr(@RW1lr_plsim,s1,1500,2)
sgtitle('stable low noise: role of inverse temperature')
explore_PL_RW1lr(@RW1lr_plsim,s2,1500,2)
sgtitle('stable high noise: role of inverse temperature')

%% comparison 5: examine role of "noise", but with standard RW
explore_PL_RW1lr(@RW1lr_2arms_plsim,s1,1500,2)
sgtitle('stable low noise: role of inverse temperature in standard RW')
explore_PL_RW1lr(@RW1lr_2arms_plsim,s2,1500,2)
sgtitle('stable high noise: role of inverse temperature in standard RW')

end