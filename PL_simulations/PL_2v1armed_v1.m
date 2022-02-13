function PL_2v1armed_v1(inseq)

%assess effect of fitting 1armed on 2armed agents

task = gen_misce_task(inseq);

nsimus = 1000;%number of parameter values/simulations swept through/done

alpha_range = unifrnd(0,1,[1,nsimus]);%"ground truth"
beta_range = unifrnd(0.1,6,[1,nsimus]);

%the parameters to recover
alpha_1arm = nan(nsimus,1);
beta_1arm = nan(nsimus,1);

for i = 1:nsimus
    s = RW1lr_2arms_plsim(task,[alpha_range(i),beta_range(i)],0);
    
    actions = s.choices; % 1 for action=1 and 2 for action=2; assume no missing trials
    outcomes = s.feedback.outcomes(:,1:2); % e.g., 1 for win on trial, 0 for no win

    fitted = MLEfit_PL_RW1lr(actions,outcomes,0);

    alpha_1arm(i,1) = fitted.mean_a;
    beta_1arm(i,1) = fitted.mean_beta;
    
    if mod(i,10) == 0
        fprintf('== simulation number %i completed == \n',i)
    end
end

r_a = corr(alpha_range',alpha_1arm);
r_beta = corr(beta_range',beta_1arm);
r_alphabeta = corr(alpha_range',beta_1arm);
r_betaalpha = corr(beta_range',alpha_1arm);

figure;
subplot(2,2,1)
plot(alpha_range,alpha_1arm,'o')
hold on
plot(0:0.05:1,(0:0.05:1)/2,'r-')%show the 1/2 line
hold off
xlabel('ground truth alpha (2-armed)')
ylabel('alpha for 1-armed')
legend('virtual participants','line y=0.5x','Location','Northwest')
title(sprintf('r = %.3f',r_a))

subplot(2,2,2)
plot(beta_range,beta_1arm,'o')
hold on
plot(0:0.05:max(beta_range),0:0.05:max(beta_range),'r-')
hold off
xlabel('ground truth beta (2-armed)')
ylabel('beta for 1-armed')
title(sprintf('r = %.3f',r_beta))
legend('virtual participants','line y=x','Location','Northwest')

subplot(2,2,3)
plot(beta_range,alpha_1arm,'o')
xlabel('ground truth beta (2-armed)')
ylabel('alpha for 1-armed')
title(sprintf('r = %.3f',r_betaalpha))
legend('virtual participants','Location','Northwest')

subplot(2,2,4)
plot(alpha_range,beta_1arm,'o')
xlabel('ground truth alpha (2-armed)')
ylabel('beta for 1-armed')
title(sprintf('r = %.3f',r_alphabeta))
legend('virtual participants','Location','Northwest')

recoverability = struct('alpha',r_a,'beta',r_beta);

outr = struct('recoverability',recoverability,...
    'alpha_range',alpha_range,'alpha_recovered',alpha_1arm,...
    'beta_range',beta_range,'beta_recovered',beta_1arm,...
    'n_simulated',nsimus,'task',task);

save(sprintf('RW_1v2arms_comparison-%s',date),'outr')

end