function vis_simu_RW2lr(actions,traj,task)

%visualise any IBLT task model with two learning rates

chose1_vis = actions == 1;
refc = 1;
% unpack the task struct
f = fieldnames(task);%get fieldnames of the struct
for index = 1:length(f)
  %turn everything in struct into a global variable
  eval(['' f{index} ' = task.' f{index} ';']);%execute the string as the command
end

figure;
plot(xt,p_win,'b-');
hold on
plot(xt,p_loss,'r-');
plot(xt,traj.v_w(:,refc),'--');
plot(xt,traj.v_l(:,refc),'--');
plot(xt, traj.pchoice(:,refc),'-','LineWidth',3);
plot(xt,chose1_vis,'*');
hold off
legend('p(win|choose opt 1)','p(loss|choose opt 1)','win expectation for opt 1','loss expectation for opt 1','p(choose opt 1)','chosen option 1')
xlabel('trials')
ylabel('probability')

end