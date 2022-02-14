function gen_IBLT_task_visual(task)

%plot product of gen_IBLT_task

% unpack input
f = fieldnames(task);%get fieldnames of the struct
for index = 1:length(f)
  %turn everything in struct into a global variable
  eval(['' f{index} ' = task.' f{index} ';']);%execute the string as the command
end

figure;
plot(xt,round(p_win,1));
hold on
plot(xt,round(p_loss,1));
plot(xt,wins(:,1),'gx');
plot(xt,losses(:,1),'ro');
hold off
legend('p(win|choose opt 1)','p(loss|choose opt 1)','wins-if-chosen','losses-if-chosen')
xlabel('trial number')
ylabel('probability')
title('Visualisation of IBLT task structure')

end