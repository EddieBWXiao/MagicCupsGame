function fitvis_RW(modelh, parameters,actions,outcomes,task)

%visualise Rescorla-Wagner model
%modelh: handle for model
%paramaeters: vector for parameters (input to modelh; remember to use right
%space, e.g., logit or log for some functions)
%outcomes: 
%

%note if we can plot task
if nargin > 4
    taskp = true;
else
    taskp = false;
end

% get the estimated belief trajectories out
[negLL,v,p] = modelh(parameters, actions, outcomes);
xt = 1:1:length(v);
%convert p to pchoice according to action
pchoice = [p,p];%duplicate for both choices
pchoice(actions==2,1) = 1-p(actions==2);%modify those who had the opposite action
pchoice(actions==1,2) = 1-p(actions==1);

%plot main diagnostic graph (should be same as simulation plot with same parameters)
figure;
plot(xt,pchoice(:,1),'b-','LineWidth',2);
hold on
plot(xt,2-actions,'ro');
if size(outcomes,2) == 2
    plot(xt,outcomes(:,1),'bx');
    thecrosses = 'outcome of option 1';
else
    plot(xt,outcomes,'bx');
    thecrosses = 'feedback (scores)';
end
hold off
legend('p(choose opt 1)','chosen option 1',thecrosses)
xlabel('trials')
ylabel('probability')
title(sprintf('Probability of choice and choices made, LogLikelihood = %d',-negLL))

if taskp
    figure;
    subplot(2,2,1)
    plot(xt,task.p,'g-');
    hold on
    plot(xt,task.outcome(:,1),'rx');
    hold off
    legend('p(outcome|choose opt 1)','outcome')
    xlabel('trial number')
    ylabel('probability')
    title('Visualisation of task structure')

    subplot(2,2,2)
    plot(xt,v(:,1),'--')
    hold on
    plot(xt,pchoice(:,1),'-');
    plot(xt,task.p,'g-');
    plot(xt,task.outcome(:,1),'rx')
    hold off
    legend('expected value (option 1)','p(choose option 1)','contingency of option 1','outcome')
    xlabel('trial number')
    ylabel('probability')
    title('value learnt versus contingencies')

    subplot(2,2,3)
    plot(xt,v(:,1),'--')
    hold on
    plot(xt,v(:,2),'--')
    plot(xt,task.p,'g-');
    plot(xt,task.outcome(:,1),'rx')
    hold off
    legend('expected value (option 1)','expected value (option 2)','contingency of option 1','outcome (option 1)')
    xlabel('trial number')
    ylabel('probability')
    title('value update about both options')
    
    subplot(2,2,4)
    plot(xt,v(:,1)-v(:,2),'--')
    hold on
    plot(xt,3-2*actions,'o')
    hold off
    legend('expected value difference','chosen option (1 for 1, -1 for 2)')
    xlabel('trial number')
    ylabel('value difference')
    title('value difference and choices')

else
    %just plot the value difference plot if there is no task information
    figure;
    plot(xt,v(:,1)-v(:,2),'--')
    hold on
    plot(xt,3-2*actions,'o')
    hold off
    legend('expected value difference','chosen option (1 for 1, -1 for 2)')
    xlabel('trial number')
    ylabel('value difference')
    title('value difference and choices')    
   
end

end