function explore_PL_RW1lr(theagent,taskseq,nsim,ngraph,betatry,alphatry)

% for the Rescorla Wagner Model with Softmax selector
% maps out how free parameters relate to model-independent measures

%default settings
if nargin < 1
    theagent = @RW1lr_plsim;%RW with both options updated
    taskseq = repmat([20,0.8],50,1);%stable condition
    nsim = 1000;
    ngraph = 4;%graph the heatmaps
end
if ngraph ~= 3 && nargin < 5
    betatry = [1,3,20];
    alphatry = [0.05,0.3,0.4,0.5,0.6,0.9];
end

task = gen_misce_task(taskseq);
gen_misce_task_visual(task);

if ngraph == 1 || ngraph == 4
    %% change with learning rate, at different betas
    %set sequence of parameter values to try
    alphas = unifrnd(0,1,[nsim,1]);
    %preallocate
    final_earning = nan(length(betatry),length(alphas));
    loseshift = nan(size(final_earning));
    winstay = nan(size(final_earning));
    accu = nan(size(final_earning));
    %iteratete and calculate metrics for each param value
    for i = 1:length(alphas)
        for j = 1:length(betatry)
            s = theagent(task,[alphas(i),betatry(j)],0); %run simulation

            %extract metrics
            earn_traj = cumsum(s.feedback.score');%original output is row; total earning
            final_earning(j,i) = earn_traj(end);
            [loseshift(j,i),winstay(j,i)] = wsls_sim_calc(s);
            accu(j,i) = accuracy_calc(s.choices,s.task.p);
            %row for beta, since plot() maps each row independently
        end
    end

    %set different beta values and see relation
    figure;
    subplot(2,2,1)
    metric_plot_alphax(alphas,betatry,loseshift);
    ylabel('lose-shift rate')
    ylim([0,1.05])
    subplot(2,2,2)
    metric_plot_alphax(alphas,betatry,winstay);
    ylabel('win-stay rate')
    ylim([0,1.05])
    legend('hide')
    subplot(2,2,4)
    metric_plot_alphax(alphas,betatry,final_earning);
    ylabel('final task earning')
    legend('hide')
    subplot(2,2,3)
    metric_plot_alphax(alphas,betatry,accu);
    ylabel('task accuracy')
    legend('hide')
end

if ngraph == 2 || ngraph == 4
    %% change with beta, at different alphas
    %set sequence of parameter values to try
    betas = unifrnd(0.5,20,[nsim,1]);
    %preallocate
    final_earning = nan(length(betatry),length(alphas));
    loseshift = nan(size(final_earning));
    winstay = nan(size(final_earning));
    accu = nan(size(final_earning));
    %iteratete and calculate metrics for each param value
    for i = 1:length(betas)
        for j = 1:length(alphatry)
            s = theagent(task,[alphatry(j),betas(i)],0); %run simulation

            %extract metrics
            earn_traj = cumsum(s.feedback.score');%original output is row; total earning
            final_earning(j,i) = earn_traj(end);
            [loseshift(j,i),winstay(j,i)] = wsls_sim_calc(s);
            accu(j,i) = accuracy_calc(s.choices,s.task.p);
            %row for alpha, since plot() maps each row independently
        end
    end

    %set different beta values and see relation
    figure;
    subplot(2,2,1)
    metric_plot_betax(betas,alphatry,loseshift);
    ylabel('lose-shift rate')
    ylim([0,1.05])
    legend('hide')
    subplot(2,2,2)
    metric_plot_betax(betas,alphatry,winstay);
    ylabel('win-stay rate')
    ylim([0,1.05])
    subplot(2,2,4)
    metric_plot_betax(betas,alphatry,final_earning);
    ylabel('final task earning')
    legend('hide')
    subplot(2,2,3)
    metric_plot_betax(betas,alphatry,accu);
    ylabel('task accuracy')
    legend('hide')
end

if ngraph == 3 || ngraph == 4
    %% heatmap 
    %repeat multiple times to get average picture

    %set sequence of parameter values to try
    alpha_range = 0.05:0.05:1;
    beta_range = 0.5:0.5:10;
    nreps = 60;
    %preallocate
    final_earning = nan(length(beta_range),length(alpha_range),nreps);
    loseshift = nan(size(final_earning));
    winstay = nan(size(final_earning));
    accu = nan(size(final_earning));
    %iteratete and calculate metrics for each param value
    for i = 1:length(beta_range)
        for j = 1:length(alpha_range)
            for k = 1:nreps
                s = theagent(task,[alpha_range(j),beta_range(i)],0); %run simulation

                %extract metrics
                earn_traj = cumsum(s.feedback.score');%original output is row; total earning
                final_earning(i,j,k) = earn_traj(end);
                [loseshift(i,j,k),winstay(i,j,k)] = wsls_sim_calc(s);
                accu(i,j,k) = accuracy_calc(s.choices,s.task.p);
            end
        end
    end

    %mean
    final_earning = mean(final_earning,3);
    loseshift = mean(loseshift,3);
    winstay = mean(winstay,3);
    accu = mean(accu,3);

    %set different beta values and see relation
    figure;
    subplot(2,2,1)
    helper_heatmap(loseshift,beta_range,alpha_range);
    title('lose-shift rate')
    xlabel('learning rate')
    ylabel('inverse temperature')
    subplot(2,2,2)
    helper_heatmap(winstay,beta_range,alpha_range);
    title('win-stay rate')
    xlabel('learning rate')
    ylabel('inverse temperature')
    subplot(2,2,4)
    helper_heatmap(final_earning,beta_range,alpha_range);
    title('final task earning')
    xlabel('learning rate')
    ylabel('inverse temperature')
    subplot(2,2,3)
    helper_heatmap(accu,beta_range,alpha_range);
    title('task accuracy')
    xlabel('learning rate')
    ylabel('inverse temperature')
end

end
function h = metric_plot_alphax(alphas,beta,inmet)

%plotting the relations for any metric
%alpha on x axis

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
function h = metric_plot_betax(betas,alpha,inmet)

%plotting the relations for any metric
%beta on x axis

if size(alpha,1)<size(alpha,2)
    alpha = alpha';%transpose to column vec
end

plot(betas,inmet,'.')
%customise legend
mylegend = [repmat('alpha = ',length(alpha),1),num2str(alpha)];
[~,legh] = legend(mylegend,'Location','Southeast');
set(findobj(legh,'-property','MarkerSize'),'MarkerSize',20)%make legend marker larger
xlabel('inverse temperature')
h = gcf;
end