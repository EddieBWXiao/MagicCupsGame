function PL_metric_corr(beta,inseq)

%assess correlation between parameter values and model-independent metrics
%e.g., learning rate and final earning in different environments
%each data point is one simulated participant, not averaged (no sim_ave)

theagent = @RW1lr_plsim;

if nargin == 0
    beta = [0.5,1,3,4,8,10,20];
    task = gen_misce_task(repmat([20,0.8;20,0.2],2,1));
else
    task = gen_misce_task(inseq);
end
%set sequence of parameter values to try
alphas = unifrnd(0,1,[1000,1]);

%iteratete and calculate metrics for each param value
for i = length(alphas):-1:1
    for j = length(beta):-1:1
        s = theagent(task,[alphas(i),beta(j)],0); %run simulation
        
        %extract metrics
        earn_traj = cumsum(s.feedback.score');%original output is row; total earning
        final_earning(j,i) = earn_traj(end);
        [loseshift(j,i),winstay(j,i)] = wsls_calc(s);
        
        %row for beta, since plot() maps each row independently
    end
end

%set different beta values and see relation
figure;
subplot(2,2,3)
metric_plot(alphas,beta,loseshift);
ylabel('lose-shift rate')
ylim([0,1.05])
subplot(2,2,4)
metric_plot(alphas,beta,winstay);
ylabel('win-stay rate')
ylim([0,1.05])
legend('hide')
subplot(2,2,2)
metric_plot(alphas,beta,final_earning);
ylabel('final task earning')
legend('hide')
subplot(2,2,1)
gen_misce_task_visual(task)

end
function h = metric_plot(alphas,beta,inmet)

%plotting the relations for any metric

if size(beta,1)<size(beta,2)
    beta = beta';%transpose to column vec
end
plot(alphas,inmet,'.')
%customise legend
mylegend = [repmat('beta = ',length(beta),1),num2str(beta)];
[~,legh] = legend(mylegend,'Location','Southeast');
set(findobj(legh,'-property','MarkerSize'),'MarkerSize',20)%make legend marker larger
xlabel('learning rate')
h = gcf;
end
