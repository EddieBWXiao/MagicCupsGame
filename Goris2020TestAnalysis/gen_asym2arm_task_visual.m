function gen_asym2arm_task_visual(task)

%visualise simple probabilistic learning task structure
%for two-armed asymmetric ~ plots both

%% decompose the struct
f = fieldnames(task);
for index = 1:length(f)
  eval([f{index} ' = task.' f{index} ';']);%execute the string as the command
end

%% visualise
subplot(3,1,1) %first, just option 1
plot(xt,p(:,1),'b-');
hold on
plot(xt, outcome(:,1),'*')
hold off
legend('p(good outcome|choose opt 1)','outcome')
xlabel('trials')
ylabel('probability')

subplot(3,1,2) %also option 2
plot(xt,p(:,2),'r-');
hold on
plot(xt, outcome(:,2),'*')
hold off
legend('p(good outcome|choose opt 2)','outcome')
xlabel('trials')
ylabel('probability')

subplot(3,1,3) %do all three
plot(xt,p(:,1),'b-');
hold on
plot(xt,p(:,2),'r-');
plot(xt, outcome(:,1),'*')
plot(xt, outcome(:,2),'o')
hold off
legend('p(good outcome|choose opt 1)','p(good outcome|choose opt 2)','outcome opt1','outcome opt2')
xlabel('trials')
ylabel('probability')
end