function vis_simu_RW1lr(actions,traj,task)

%visualise any IBLT task model with one learning rate
%need to sum wins & losses together 

chose1_vis = actions == 1;
refc = 1;
% unpack the task struct
f = fieldnames(task);%get fieldnames of the struct
for index = 1:length(f)
  %turn everything in struct into a global variable
  eval(['' f{index} ' = task.' f{index} ';']);%execute the string as the command
end

expected_value = p_win-p_loss; % (if we use one point per win / loss)

figure;
plot(xt,p_win,'b-');
hold on
plot(xt,p_loss,'r-');
plot(xt, traj.pchoice(:,refc),'-','LineWidth',3);
plot(xt,chose1_vis,'*');
hold off
legend('p(win|choose opt 1)','p(loss|choose opt 1)','p(choose opt 1)','chosen option 1')
xlabel('trials')
ylabel('probability')

figure;
plot(xt,expected_value,'-');
hold on
plot(xt,traj.v(:,refc),'--');
hold off
legend('true EV','expectation from model')
xlabel('trials')
ylabel('expected value')

end