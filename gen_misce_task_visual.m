function gen_misce_task_visual(task)

%visualise simple probabilistic learning task structure

%% decompose the struct
f = fieldnames(task);
for index = 1:length(f)
  eval([f{index} ' = task.' f{index} ';']);%execute the string as the command
end

%% visualise
plot(xt,p,'b-');
hold on
plot(xt, outcome(:,1),'*')
hold off
legend('p(good outcome|choose opt 1)','outcome')
xlabel('trials')
ylabel('probability')

end