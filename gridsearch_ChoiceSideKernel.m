function [out]= gridsearch_ChoiceSideKernel(information,choice_left, start, alphabins,betabins, resp_made,fig_yes)

%{ 
Input:
% Information contains win & loss for the "left option"
    % n_trial x 2 matrix, contents 0 and 1, column 1 about wins
% choice_left is the SIDE that the participant choice (NOT the option)
    % n_trial x 1, 0 and 1, 1 for "chose left"
% start [rew_start loss_start] => default 0.5
% alphabins: sets number of points to estimate the CKLR, betabins same for beta
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

%Creates a vector of length alphabins in logit space (0-1 transform to -inf to +inf)
a_range = logit(0.01):(logit(0.99) - logit(0.01))/(alphabins-1):logit(0.99);
b_range = log(0.1):(log(100)-log(0.1))/(betabins-1):log(100);
%note: consistently use row vectors

%put back to native space
a_native = logistic(a_range);
b_native = exp(b_range);
alphalabel=a_native;
betalabel=b_native;

%process the standard information + choice input (turn into actions &
%outcomes_all)
all_actions = 2-choice_left; %1 still 1, 0 becomes 2
    %here, 1 stands for left, and 2 stands for right
all_outcomes = [information,1-information];

%% loop through possible values, with other parameters fixed
%a_win
for cycle1 = length(a_range):-1:1
    for cycle2 = length(b_range):-1:1
        %parameters should NOT be in native space here
        parameters(1) = a_range(cycle1);
        parameters(2) = b_range(cycle2);
        joint(cycle1,cycle2) = get_IBLT_ChoiceKernel_lik(parameters,all_actions);
    end
end

%record which dimension for which parameter
a_dim = 1;
beta_dim = 2;

%% find mean (of joint LL, not log LL)
joint = exp(joint);%convert back to LL
    %the total sum of this matrix may be < 1
joint = joint./sum(joint(:));% normalise
    % equivalent to out.posterior_prob in Browning_fit_2lr_1betaplus

out.posterior_prob=joint;    
marg_alpha = make_column(squeeze(sum(joint,beta_dim)));%should be a normalised distribution
marg_beta = make_column(squeeze(sum(joint,a_dim))); %marg over beta; is column too
out.marg_alpha = marg_alpha;
out.marg_beta = marg_beta;
out.mean_alpha = logistic(dot(marg_alpha,a_range));%column vector before row vect
out.mean_beta= exp(dot(marg_beta,b_range));
out.var_alpha = logistic(((a_range - logit(out.mean_alpha)).^2)*out.marg_alpha);%again, row before column
out.var_beta=exp(((b_range-log(out.mean_beta)).^2)*out.marg_beta);

out.beta_label=betalabel;
out.lr_label=alphalabel;
out.lr_points=a_range;
out.beta_points=b_range;

%% graphics for mean of posterior
if fig_yes==1 
    figure;
    subplot(2,2,1)
    plot(a_native,marg_alpha)
    hold on
    xline(out.mean_alpha,'r')
    hold off
    legend('distribution','marg mean')
    xlabel('alpha')
    ylabel('probability')

    subplot(2,2,2)
    imagesc(joint);
    title('alpha and beta, joint LL distribution')

    subplot(2,2,3)
    plot(b_native,marg_beta)
    hold on
    xline(out.mean_beta,'r')
    hold off
    legend('distribution','marg mean')
    xlabel('beta')
    ylabel('probability')
    
end

%% export likelihood for final model
%plug parameter estimate back into model
[mlogL,CK,pchoice]=get_IBLT_ChoiceKernel_lik([logit(out.mean_alpha) log(out.mean_beta)],all_actions);%logL + value expectation trajectory
prob_ch_left = pchoice(:,1); %pchoice of ref option

%calculate model evidence
out.neg_log_like= -mlogL;
out.BIC=(2.*out.neg_log_like)+2*(log(sum(resp_made))); % BIC given 2 free parameters

%% further plots to demonstrate participant data & fit
nt = length(CK);
xt = 1:1:nt;
xt = xt';
if fig_yes==1
    % a single summary graph
    figure;
    hold on
    plot(xt,prob_ch_left,'-','LineWidth',3);
    plot(xt,choice_left,'*');
    hold off
    legend('p(choose option 1)','chosen option 1')
    xlabel('trials')
    ylabel('probability')
    title(sprintf('ck_alpha = %.3f , beta = %.1f',...
        out.mean_alpha,out.mean_beta))
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
function v = make_column(v)
    if ~iscolumn(v)
        v = v';
    end
end
function [loglik,CK,pchoice] = get_IBLT_ChoiceKernel_lik(parameters, actions)
%IMPORTANT: input should NOT be in native space
%adapted from the choice kernel in Wilson & Collins 2019
alpha  = 1/(1+exp(-parameters(1))); 
beta  = exp(parameters(2));

T = length(actions);

CK = nan(T,2);
pchoice = nan(T,2); % for both options
p = nan(T,1); % for the chosen option (to calculate L)
    %one column (p of that choice, on that trial)

for t=1:T
    if t == 1
        CK(t,:) = [0,0];
    end
    
    %p1 = 1./(1+exp(-beta*CK(t,1))); % probability of action 1
    p1 = exp(beta*CK(t,1))/(exp(beta*CK(t,1))+exp(beta*CK(t,2)));
    p2 = 1-p1; % probability of action 2
    pchoice(t,:) = [p1,p2]; %record both
    if actions(t) == 1
        p(t) = p1;
        a = [1,0];
    elseif actions(t) ==2
        p(t) = p2;
        a = [0,1];
    end
    
    % update choice kernel based on choice produced
    CK(t+1,:) = CK(t,:) + alpha.*(a-CK(t,:));

end

CK = CK(1:end-1,:); %chop off the extra row
loglik = sum(log(p+eps)); %key output

end