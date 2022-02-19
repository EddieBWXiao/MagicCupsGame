function maps = sim_noncomp_IBLTblocks(simufunc,condition,altparams,alpha_div,maxn,whatvis)

% scan through different win-loss learning rate combinations
% for each block of the IBLT (specified in input)
% compute loss-driven choices & earnings etc.
% produce matrices for future heatmap plots

%% function input-related

if nargin < 1
    %to be moved to input
    maxn = 100;%number of repeats for each heatmap cell
    altparams = [10,0];% parameters other than learning rates
    condition = 'both volatile';
    alpha_div = 0.05;
    simufunc = @simu_RW2lr_bias;
    whatvis = 'LD';%the figure to plot
end

task = gen_IBLT_task(condition);%set up task;
    %all using the magic cups game schedule
opt1 = task.outcome_opt1;
wins = task.wins;
losses = task.losses;

%% create the alphas to be searched through
alpha_l = 0.01:alpha_div:0.96;
alpha_w = 0.01:alpha_div:0.96;

%% loop through combinations
for k = length(alpha_w):-1:1
    for i = length(alpha_l):-1:1
        %loop for many simulations
        for iter = maxn:-1:1
            %simulate
            params = [alpha_w(k),alpha_l(i),altparams];
            actions = simufunc(params,opt1);
            
            %calculate
            earning(i,k,iter) = calc_IBLT_earning(actions,wins,losses);
            %[~,switchrates(:,i,k,iter)] = calc_IBLT_switchrates(actions,t.wins,t.losses);%switch rates; four of them
            lossdriven(i,k,iter) = calc_lossdriven(actions,wins,losses);%the proportion of loss driven choices
        end
    end
end

earn_mean = mean(earning,3);%mean across each participant, get n_alphal x n_alphar matrix
LD_mean = mean(lossdriven,3);%mean across each participant, get n_alphal x n_alphar matrix

%% visualise (output its handle)

switch whatvis
    case 'earning'
        %fh_earning = figure('visible','off');%create figure but do not display
        imagesc(earn_mean)
        hc = colorbar;
        ylabel(hc, 'earning in block')
        xticks = linspace(1, size(earn_mean, 2), numel(alpha_w));%size(~,2), because columns
        yticks = linspace(1, size(earn_mean, 1), numel(alpha_l));
        set(gca, 'XTick', xticks, 'XTickLabel', alpha_w)
        set(gca, 'YTick', yticks, 'YTickLabel', alpha_l)
        ylabel('learning rate from losses')%these are rows
        xlabel('learning rate from wins')%these are columns
    case 'LD'
        %fh_LD = figure('visible','off');
        imagesc(LD_mean)
        hc = colorbar;
        ylabel(hc, 'loss-driven behaviour in block')
        xticks = linspace(1, size(LD_mean, 2), numel(alpha_w));%size(~,2), because columns
        yticks = linspace(1, size(LD_mean, 1), numel(alpha_l));
        set(gca, 'XTick', xticks, 'XTickLabel', alpha_w)
        set(gca, 'YTick', yticks, 'YTickLabel', alpha_l)
        ylabel('learning rate from losses')%these are rows
        xlabel('learning rate from wins')%these are columns
end
%% output
maps.earning = earn_mean;
maps.lossdriven = LD_mean;

end