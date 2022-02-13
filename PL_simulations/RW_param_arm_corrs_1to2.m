function RW_param_arm_corrs_1to2(inseq,alpha_range,beta_range)


task = gen_misce_task(inseq);
nsimus = length(alpha_range);
%the parameters to estimate with "wrong" model
alpha_2arm = nan(nsimus,1);
beta_2arm = nan(nsimus,1);

lb = [0,0];
ub = [1,100];

for i = 1:nsimus
    s = RW1lr_plsim(task,[alpha_range(i),beta_range(i)],0);
    %generate with 1-p assumption
    
    actions = s.choices; % 1 for action=1 and 2 for action=2; assume no missing trials
    outcomes = s.feedback.score; % e.g., 1 for win on trial, 0 for no win

    %fit with 2arms model
    initial = [rand exprnd(1)];
    costfun = @(x) lik_RW1lr_2arms_PL_native(x,actions,outcomes,false);
    params = fmincon(costfun,initial,[],[],[],[],lb, ub,[],optimset('maxfunevals',10000,'maxiter',2000,'Display', 'off'));

    alpha_2arm(i,1) = params(1);
    beta_2arm(i,1) = params(2);
    
    if mod(i,10) == 0
        fprintf('== simulation number %i completed == \n',i)
    end
end

r_a = corr(alpha_range',alpha_2arm);
r_beta = corr(beta_range',beta_2arm);
r_alphabeta = corr(alpha_range',beta_2arm);
r_betaalpha = corr(beta_range',alpha_2arm);

figure;
subplot(2,2,1)
plot(alpha_range,alpha_2arm,'o')
hold on
plot(0:0.05:1,(0:0.05:1)*2,'r-')%show the 1/2 line
hold off
xlabel('ground truth alpha (1-armed)')
ylabel('alpha for 2-armed')
legend('virtual participants','line y=2x','Location','Northwest')
title(sprintf('r = %.3f',r_a))

subplot(2,2,2)
plot(beta_range,beta_2arm,'o')
hold on
plot(0:0.05:max(beta_range),0:0.05:max(beta_range),'r-')
hold off
xlabel('ground truth beta (1-armed)')
ylabel('beta for 2-armed')
title(sprintf('r = %.3f',r_beta))
legend('virtual participants','line y=x','Location','Northwest')

subplot(2,2,3)
plot(beta_range,alpha_2arm,'o')
xlabel('ground truth beta (2-armed)')
ylabel('alpha for 1-armed')
title(sprintf('r = %.3f',r_betaalpha))
legend('virtual participants','Location','Northwest')

subplot(2,2,4)
plot(alpha_range,beta_2arm,'o')
xlabel('ground truth alpha (1-armed)')
ylabel('beta for 2-armed')
title(sprintf('r = %.3f',r_alphabeta))
legend('virtual participants','Location','Northwest')

recoverability = struct('alpha',r_a,'beta',r_beta);

outr = struct('recoverability',recoverability,...
    'alpha_range',alpha_range,'alpha_recovered',alpha_2arm,...
    'beta_range',beta_range,'beta_recovered',beta_2arm,...
    'n_simulated',nsimus,'task',task);

save(sprintf('RW_1v2arms_comparison_from1to2-%s',date),'outr')
end