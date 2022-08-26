function fitvis_IBLT_2lr(modelh, parameters, actions)

%visualise IBLT model fits for all three blocks
%modelh: handle for model
    %e.g. @lik_IBLT_RW2lr_beta_bias_native
%paramaeters: vector for parameters (input to modelh; remember to use right
%space, e.g., logit or log for some functions)
    %each column would be one block!
    %expect nparams x 3 array

%actions: from data, or from simulation; the choice made by participants

%% unpack for the three blocks

% get the task blocks from gen_IBLT_task
    % contains all the Magic Cups Game outcomes
taskbothvol = gen_IBLT_task('both volatile');
taskwinvol = gen_IBLT_task('win volatile');
tasklossvol = gen_IBLT_task('loss volatile');

%parameters:
parameters_bothvol = parameters(:,1);
parameters_winvol = parameters(:,2);
parameters_lossvol = parameters(:,3);

% segment choices into three blocks
actions_bothvol = actions(1:60);
actions_winvol = actions(61:120);
actions_lossvol = actions(121:180);

%% getting the trajectory found in the fitting function back
% put parameter estimate into the likelihood function
[negLL_bothvol,vv_bothvol,pchoice_bothvol] = modelh(parameters_bothvol, actions_bothvol, taskbothvol.outcomes_all);
[negLL_winvol,vv_winvol,pchoice_winvol] = modelh(parameters_winvol, actions_winvol, taskwinvol.outcomes_all);
[negLL_lossvol,vv_lossvol,pchoice_lossvol] = modelh(parameters_lossvol, actions_lossvol, tasklossvol.outcomes_all);

xt = 1:1:60;


%% plotting (2x3 graph, horizontal all blocks, also see pchoice versus value learnt)

%diagnostic graph for pchoice 
subplot(2,3,1)
sgtitle('filler')
plot(xt,pchoice_bothvol(:,1),'b-','LineWidth',2);
hold on
plot(xt,2-actions_bothvol,'k*');
plot(xt,taskbothvol.p_win,'g-');
plot(xt,taskbothvol.p_loss,'r-');
hold off
ylabel('probability')
title(sprintf('Both-Volatile Block \n LogLikelihood = %.3g',-negLL_bothvol))
subplot(2,3,2)
plot(xt,pchoice_winvol(:,1),'b-','LineWidth',2);
hold on
plot(xt,2-actions_winvol,'k*');
plot(xt,taskwinvol.p_win,'g-');
plot(xt,taskwinvol.p_loss,'r-');
hold off
title(sprintf('Win-Volatile Block \n LogLikelihood = %.3g',-negLL_winvol))
subplot(2,3,3)
plot(xt,pchoice_lossvol(:,1),'b-','LineWidth',2);
hold on
plot(xt,2-actions_lossvol,'k*');
plot(xt,tasklossvol.p_win,'g-');
plot(xt,tasklossvol.p_loss,'r-');
hold off
lh1 = legend('p(choose opt 1)','chosen option 1','p(win|choose opt 1)','p(loss|choose opt 1)');
set(lh1,'position',[0.91    0.75    0.08    0.12]) %IMPORTANT: shove the legend out of the plot
title(sprintf('Loss-Volatile Block \n LogLikelihood = %.3g',-negLL_lossvol))

%plot win & loss expectations
subplot(2,3,4)
plot(xt,taskbothvol.p_win,'g-');
hold on
plot(xt,taskbothvol.p_loss,'r-');
plot(xt,taskbothvol.outcome_opt1(:,1)*1.1-0.05,'go'); %note: shift the dots a bit
plot(xt,taskbothvol.outcome_opt1(:,2)*1.05-0.025,'rx'); 
plot(xt,vv_bothvol(:,1),'b--');
plot(xt,vv_bothvol(:,2),'r--');
plot(xt,2-actions_bothvol,'k*');
hold off
xlabel('trials')
ylabel('probability')
title(['params: ', sprintf('  %.2g',parameters_bothvol')])
subplot(2,3,5)
plot(xt,taskwinvol.p_win,'g-');
hold on
plot(xt,taskwinvol.p_loss,'r-');
plot(xt,taskwinvol.outcome_opt1(:,1)*1.1-0.05,'go'); %note: shift the dots a bit
plot(xt,taskwinvol.outcome_opt1(:,2)*1.05-0.025,'rx'); 
plot(xt,vv_winvol(:,1),'b--');
plot(xt,vv_winvol(:,2),'r--');
plot(xt,2-actions_winvol,'k*');
hold off
xlabel('trials')
title(['params: ', sprintf('  %.2g',parameters_winvol')])
subplot(2,3,6)
plot(xt,tasklossvol.p_win,'g-');
hold on
plot(xt,tasklossvol.p_loss,'r-');
plot(xt,tasklossvol.outcome_opt1(:,1)*1.1-0.05,'go'); %note: shift the dots a bit
plot(xt,taskbothvol.outcome_opt1(:,2)*1.05-0.025,'rx'); 
plot(xt,vv_lossvol(:,1),'b--');
plot(xt,vv_lossvol(:,2),'r--');
plot(xt,2-actions_lossvol,'k*');
hold off
xlabel('trials')
title(['params: ', sprintf('  %.2g',parameters_lossvol')])
lh2 = legend('p(win|choose opt 1)','p(loss|choose opt 1)','win outcome','loss outcome','win expectation (opt 1)','loss expectation (opt 1)','chosen option 1');
set(lh2,'position',[0.91    0.24    0.10    0.20])%IMPORTANT: shove the legend out of the plot


%set the size of overall plot
ff = gcf;
ff.Position=[1 360 1440 440];




end