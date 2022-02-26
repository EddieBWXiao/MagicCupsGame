function fitvis_IBLT_1lr(modelh, parameters,actions,outcome_in,task)

%visualise IBLT model fits (single block)
%tailored for working with single learning rate (no independent value updates)
%modelh: handle for model
%paramaeters: vector for parameters (input to modelh; remember to use right
%space, e.g., logit or log for some functions)
%actions: from data, or from simulation
%outcome_in: depends on the modelh --> the other input to modelh
%task: the struct from gen_IBLT etc.

% get the estimated belief trajectories out
[negLL,vv,pchoice] = modelh(parameters, actions, outcome_in);
xt = 1:1:length(vv);

%diagnostic graph for pchoice 
figure;
plot(xt,task.p_win,'-');
hold on
plot(xt,task.p_loss,'-');
plot(xt,pchoice(:,1),'b-','LineWidth',2);
plot(xt,2-actions,'ro');
plot(xt,task.outcome_opt1,'bx');
hold off
legend('p(win | choose opt 1)','p(loss | choose opt 1)','p(choose opt 1)','chosen option 1','outcomes of opt 1')
xlabel('trials')
ylabel('probability')
title(sprintf('Probability of choice and choices made, LogLikelihood = %d',-negLL))

%plot expectations
figure;
plot(xt,task.p_win-task.p_loss,'-');
hold on
plot(xt,vv(:,1),'--');
hold off
legend('true EV','inferred value expectations')
xlabel('trials')
ylabel('expected value')

end