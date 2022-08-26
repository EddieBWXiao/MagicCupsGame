function [out]= gridsearch_ValenceWeightedNoisyWSLS(information,choice, start, alphabins,betabins, resp_made,fig_yes)

%{ 
Input:
% Information contains win & loss for the "left option"
    % n_trial x 2 matrix, contents 0 and 1, column 1 about wins
% choice is the participant choice
    % n_trial x 1, 0 and 1, 1 for "chose left"
% start [rew_start loss_start] => default 0.5
% alphabins: sets grid to estimate noise
% betabins sets grid for valence weight (win over loss)
% resp_made is trials on which a response was made (true/false, n_trials)
% fig_yes: 0 or 1; please set to 0 when looping through 10+ iterations

Output: struct with all relevant info
Model specifications:
% 
%}
% Written by Bowen Xiao, PaL Cambridge

%% default options & prepare space 
if(nargin<7)
    fig_yes=0;
end
if(nargin<6)
    resp_made=true(size(information,1),1);
end
if(nargin<5)
    betabins=30; 
end
if(nargin<4) 
    alphabins=30; 
end

out=struct;

%Creates vectors for the bins on grid
noise_range = 0:(1 - 0)/(alphabins-1):1;
weight_range = 0:(1 - 0)/(betabins-1):1;
%note: consistently use row vectors

%record as lables
noiselabel=noise_range;
weightlabel=weight_range;

%process the standard information + choice input (turn into actions &
%outcomes_all)
all_actions = 2-choice; %1 still 1, 0 becomes 2
wins = information(:,1);%sequence of wins from opt1
losses = information(:,2);%sequence of losses from opt1
all_wins = [wins,~wins];
all_losses = [losses,~losses];
all_outcomes = [all_wins,all_losses];

%% loop through possible values, with other parameters fixed
%a_win
for cycle1 = length(noise_range):-1:1
    for cycle2 = length(weight_range):-1:1
        %parameters should NOT be in native space here
        parameters(1) = noise_range(cycle1);
        parameters(2) = weight_range(cycle2);
        joint(cycle1,cycle2) = get_IBLT_ValenceWeightedNoisyWSLS_lik(parameters,all_actions,all_outcomes);
    end
end

%record which dimension for which parameter
noise_dim = 1;
weight_dim = 2;

%% find mean (of joint LL, not log LL)
joint = exp(joint);%convert back to LL
    %the total sum of this matrix may be < 1
joint = joint./sum(joint(:));% normalise
    % equivalent to out.posterior_prob in Browning_fit_2lr_1betaplus

out.posterior_prob=joint;    
marg_noise = make_column(squeeze(sum(joint,weight_dim)));%should be a normalised distribution
marg_weight = make_column(squeeze(sum(joint,noise_dim))); %marg over beta; is column too
out.marg_noise = marg_noise;
out.marg_weight = marg_weight;
out.mean_noise = dot(marg_noise,noise_range);%column vector before row vect
out.mean_weight = dot(marg_weight,weight_range);
out.var_noise = ((noise_range - out.mean_noise).^2)*out.marg_noise;%again, row before column
out.var_weight = ((weight_range - out.mean_weight).^2)*out.marg_weight;

out.weight_label=weightlabel;
out.noise_label=noiselabel;
out.noise_points=noise_range;
out.weight_points=weight_range;

%% graphics for mean of posterior
if fig_yes==1 
    figure;
    subplot(2,2,1)
    plot(noise_range,marg_noise)
    hold on
    xline(out.mean_noise,'r')
    hold off
    legend('distribution','marg mean')
    xlabel('noise')
    ylabel('probability')

    subplot(2,2,2)
    imagesc(joint);
    title('noise and weight, joint LL distribution')

    subplot(2,2,3)
    plot(weight_range,marg_weight)
    hold on
    xline(out.mean_weight,'r')
    hold off
    legend('distribution','marg mean')
    xlabel('weight')
    ylabel('probability')
end

%% export likelihood for final model
%plug parameter estimate back into model
[mlogL,ptendencies,pchoice]=get_IBLT_ValenceWeightedNoisyWSLS_lik([out.mean_noise out.mean_weight],all_actions,all_outcomes);%logL + value expectation trajectory
prob_ch_left = pchoice(:,1); %pchoice of ref option

%calculate model evidence
out.neg_log_like= -mlogL;
out.BIC=(2.*out.neg_log_like)+2*(log(sum(resp_made))); % BIC given 2 free parameters

%% further plots to demonstrate participant data & fit
nt = length(ptendencies);
xt = 1:1:nt;
xt = xt';
if fig_yes==1
    % a single summary graph
    figure;
    hold on
    plot(xt,prob_ch_left,'-','LineWidth',3);
    plot(xt,choice,'*');
    
    %include outcomes for debugging
    plot(xt,information(:,1)*0.9+0.05,'go')
    plot(xt,information(:,2)*0.95+0.025,'rx')
    plot(xt,ptendencies(:,1),'--')
    plot(xt,ptendencies(:,2),'--')
    hold off
    legend('p(choose option 1)','chosen option 1','opt1 wins','opt1 losses','winstaytendency','losestaytendency')
    xlabel('trials')
    ylabel('probability')
    title(sprintf('noise = %.3f , weight = %.3f',...
        out.mean_noise,out.mean_weight))
end

%end of the main function
%should produce all metrics & graphs
end
function v = make_column(v)
    if ~iscolumn(v)
        v = v';
    end
end
function [loglik,ptendencies,pchoice] = get_IBLT_ValenceWeightedNoisyWSLS_lik(parameters, actions,all_outcomes)

%unpack input
noise  = parameters(1); 
winlossweight  = parameters(2);
all_wins = all_outcomes(:,1:2);%all_outcomes MUST be win-c1&c2, then loss
all_losses = all_outcomes(:,3:4);
T = length(actions);

%tendency to repeat (regarding outcome in win or in loss)
ptendency_win = nan(T,1);
ptendency_loss = nan(T,1);
    %these two will be merged to be ptendencies
pchoice = nan(T,2); % for both options
p = nan(T,1); % for the chosen option (to calculate L)
    %one column (p of that choice, on that trial)

for t=1:T
    
    %compute p of choice on that trial
    if t == 1
        ptrial = [0.5,0.5];%the start, initial
    else
        choice_logic_ind = actions(t-1) == [1 2];%logical index for which was chosen
        
        %implement noisy WSLS, for both outcome types
        if all_wins(t-1,actions(t-1)) == 1 %if win received, ON PREVIOUS TRIAL
            ptendency_win(t) = 1-noise; %when epsilon 0, always win-stay
        elseif all_wins(t-1,actions(t-1)) ==0 %if no win received
            ptendency_win(t) = noise;%avoid the choice that led to 0
        end
        if all_losses(t-1,actions(t-1)) == 1 %if loss received, ON PREVIOUS TRIAL
                    %IMPORTANT: loss coded as 0 and 1
            ptendency_loss(t) = noise; %when epsilon 0, always shift
        elseif all_losses(t-1,actions(t-1)) == 0 %if no loss received
            ptendency_loss(t) = 1-noise;%stick to the choice that avoided loss
        end    
                
        %combine by the weight (to get probability of repeating same choice
        p_repeat = winlossweight*ptendency_win(t)+(1-winlossweight)*ptendency_loss(t);
        
        %get choice probability of BOTH options (sum should be 1)
        ptrial(choice_logic_ind) = p_repeat;
        ptrial(~choice_logic_ind) = 1 - p_repeat;
    end
    
    %HERE BE THE LIKELIHOOD
    if actions(t) == 1
        p(t) = ptrial(1,1);%p of choosing option 1
    elseif actions(t) == 2
        p(t) = ptrial(1,2);%p of choosing option 1
    end
    
    % store the pchoice
    pchoice(t,:) = ptrial(:); %record the p for each choice
        %NOTE: different from simulation function
        %here, rows for trials, not columns

end

ptendencies = [ptendency_win,ptendency_loss]; %chop off the extra row
loglik = sum(log(p+eps)); %key output

end