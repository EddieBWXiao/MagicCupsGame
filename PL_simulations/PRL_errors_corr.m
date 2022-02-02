function PRL_errors_corr(beta,theagent)

%assess correlation between parameter vals and persever. or regres. errors
%each data point is one simulated participant, not averaged (no sim_ave)

if nargin<2
    theagent = @RW1lr_plsim;
end
if nargin == 0
    beta = [0.5,2.5,6,30];
    theagent = @RW1lr_plsim;
end

task = gen_misce_task([100,0.8;100,0.2]);

%set sequence of parameter values to try
alphas = unifrnd(0,1,[1000,1]);

%iteratete and calculate metrics for each param value
for i = length(alphas):-1:1
    for j = length(beta):-1:1
        s = theagent(task,[alphas(i),beta(j)],0); %run simulation
        
        %extract metrics
        [loseshift(j,i),~] = wsls_calc(s);
        [persev(j,i), regres(j,i)] = PRL_metric_calc(s);
        
        %row for beta, since plot() maps each row independently
    end
end

%set different beta values and see relation
figure;
subplot(2,2,1)
gen_misce_task_visual(task)
subplot(2,2,2)
metric_plot(alphas,beta,loseshift);
ylabel('lose-shift rate')
ylim([0,1.05])
subplot(2,2,3)
metric_plot(alphas,beta,persev);
ylabel('Perseverative errors')
subplot(2,2,4)
metric_plot(alphas,beta,regres);
ylabel('Regressive errors')

end
function h = metric_plot(alphas,beta,inmet)

%plotting the relations for any metric

%metric = inputname(3);

if size(beta,1)<size(beta,2)
    beta = beta';%transpose to column vec
end
plot(alphas,inmet,'.')
%customise legend
mylegend = [repmat('beta = ',length(beta),1),num2str(beta)];
[~,legh] = legend(mylegend,'Location','Northeast');
set(findobj(legh,'-property','MarkerSize'),'MarkerSize',20)%make legend marker larger
xlabel('learning rate')
h = gcf;

end
