function [out]= gridsearch_RandomActions(information,choice, start, alphabins,betabins, resp_made,fig_yes)

%{ 
Input:
% Information contains win & loss for the "left option"
    % n_trial x 2 matrix, contents 0 and 1, column 1 about wins
% choice is the participant choice
    % n_trial x 1, 0 and 1, 1 for "chose left"
% start [rew_start loss_start] => default 0.5
% alphabins: sets number of points to estimate the CKLR, betabins same for beta
% resp_made is trials on which a response was made (true/false, n_trials)
% fig_yes: 0 or 1; please set to 0 when looping through 10+ iterations

Output: struct with all relevant info
Model specifications:
% random: p(actionA) = 1-p(actionB), only one parameter for bias
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
    betabins=30; %keeping this input variable for consistency across gridsearch functions
end
if(nargin<4) 
    alphabins=100; 
end

out=struct;

%Creates a vector of length alphabins in logit space (0-1 transform to -inf to +inf)
%b_range = logit(1e-5):(logit(0.99999) - logit(1e-5))/(alphabins-1):logit(0.99999); %this is the bias -- probability of choosing one side
%note: consistently use row vectors
b_range = logit(0.01):(logit(0.99) - logit(0.01))/(alphabins-1):logit(0.99);

%put back to native space
b_native = logistic(b_range);
biaslabel = b_native;

all_actions = 2-choice; %1 still 1, 0 becomes 2

%% loop through possible values, with other parameters fixed
for cycle = length(b_range):-1:1
    %parameters should NOT be in native space here
    parameters(1) = b_range(cycle);
    LL(cycle,1) = get_IBLT_random_lik(parameters,all_actions);%IMPORTANT: LL should be a column vector
end

%% find mean (of joint LL, not log LL)
LL = exp(LL);%convert back to LL
    %the total sum of this matrix may be < 1
LL = LL./sum(LL(:));% normalise

out.posterior_prob=LL;   
out.marg_bias = LL;
out.mean_bias = logistic(b_range*out.marg_bias);
out.var_alpha = logistic(((b_range - logit(out.mean_bias)).^2)*out.marg_bias);%again, row before column

out.bias_label=biaslabel;
out.bias_points=b_range;

%% graphics for mean of posterior
if fig_yes==1 
    figure;
    plot(b_native,out.marg_bias)
    hold on
    xline(out.mean_bias,'r')
    hold off
    legend('distribution','marg mean')
    xlabel('bias')
    ylabel('probability')    
end

%% export likelihood for final model
%plug parameter estimate back into model
[mlogL,~,pchoice]=get_IBLT_random_lik(logit(out.mean_bias),all_actions);%logL + value expectation trajectory
prob_ch_left = pchoice(:,1); %pchoice of ref option

%calculate model evidence
out.neg_log_like= -mlogL;
out.BIC=(2.*out.neg_log_like)+1*(log(sum(resp_made))); % BIC given 1 free parameter

%% further plots to demonstrate participant data & fit
nt = length(pchoice);
xt = 1:1:nt;
xt = xt';
if fig_yes==1
    % a single summary graph
    figure;
    hold on
    plot(xt,prob_ch_left,'-','LineWidth',3);
    plot(xt,choice,'*');
    hold off
    legend('p(choose option 1)','chosen option 1')
    xlabel('trials')
    ylabel('probability')
    title(sprintf('bias = %.3f ',...
        out.mean_bias))
end

%end of the main function
%should produce all metrics & graphs
end
function [ out ] = logit(innum)
%applies logistic func (inf to 0 and 1)
% Author: Dr Michael Browning, University of Oxford
% Date: 27/01/2021
    if innum < 0 || innum > 1
        error('inverse of logit only defined for numbers between 0 and 1');
    end
    out=-log((1./innum)-1);
end
function [ out ] = logistic(innum)
%retuns thelogit of input (0 and 1 to inf)
%logit
% Author: Dr Michael Browning, University of Oxford
% Date: 27/01/2021
    out=1./(1+exp(-innum));
end
function [loglik,p,pchoice] = get_IBLT_random_lik(parameters, actions)
%IMPORTANT: input should NOT be in native space
%adapted from the random actions in Wilson & Collins 2019
bias  = 1/(1+exp(-parameters(1))); 

T = length(actions);

pchoice = nan(T,2); % for both options
p = nan(T,1); % for the chosen option (to calculate L)
    %one column (p of that choice, on that trial)

for t=1:T
    p1 = bias; % probability of action 1
    p2 = 1-bias; % probability of action 2
    pchoice(t,:) = [p1,p2]; %record both
    
    if actions(t) == 1
        p(t) = p1;
    elseif actions(t) ==2
        p(t) = p2;
    end
end

loglik = sum(log(p+eps)); %key output

end