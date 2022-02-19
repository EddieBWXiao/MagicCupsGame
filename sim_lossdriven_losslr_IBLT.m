function sim_lossdriven_losslr_IBLT

% simulate participants with different learning rates & betas
% only examine loss LR at x axis
% check if monotonic relationship exists
    % i.e., if high loss LR indicates more loss driven
    % regardless of how other parameters were set

% the different conditions / betas to check through for robustness
condition = {'both volatile','win volatile','loss volatile'};
betamean = [1,2,4,8,10,20];

for j = 1:length(betamean)
    for k = 1:length(condition)
        % parameter combinations
        nsims = 1000;
        alpha_w = unifrnd(1e-4,(1-(1e-4)),[nsims,1]);
        alpha_l = unifrnd(1e-4,(1-(1e-4)),[nsims,1]);
        beta = exprnd(betamean(j),[nsims,1]);%need to check if generalisable to different distriubitons
        simufunc = @simu_RW2lr_bias;

        % task: all using IBLT
        t = gen_IBLT_task(condition{k});%set up task;
            %all using the magic cups game schedule
        opt1 = t.outcome_opt1;
        wins = t.wins;
        losses = t.losses;

        for i = nsims:-1:1
            params = [alpha_w(i),alpha_l(i),beta(i),0];
            actions = simufunc(params,opt1);

            %calculate lossdriven rate & switch rates
            sr = calc_IBLT_switchrates(actions,t.wins,t.losses);%switch rates; four of them
            lossdriven(i) = calc_lossdriven(actions,wins,losses);%the proportion of loss driven choices
            loseshift(i) = sr.lost;
            winloseshift(i) = sr.wonlost;
            neithershift(i) = sr.neither;

        end

        figure;
        subplot(2,2,1)
        mysubplot(alpha_l,lossdriven)
        subplot(2,2,2)
        mysubplot(alpha_l,loseshift)
        subplot(2,2,3)
        mysubplot(alpha_l,winloseshift)
        subplot(2,2,4)
        mysubplot(alpha_l,neithershift)
        sgtitle(sprintf('block: %s; beta ~ exprnd(%i)',condition{k},betamean(j)))
    end
end

end
function mysubplot(xax,metric)

%the ever-repeating subplots to do...

nxax = inputname(1);
ylab = inputname(2);

plot(xax,metric,'.')
xlabel(nxax,'Interpreter','None')
ylabel(ylab,'Interpreter','None')

mycorr = corr(xax,metric');

title(sprintf('r = %.2f',mycorr));
end