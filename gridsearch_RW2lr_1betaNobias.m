function [out]= gridsearch_RW2lr_1betaNobias(information,choice, start, alphabins,betabins, resp_made,fig_yes)

%modified from osf, https://osf.io/k36h4/
%{
% provides model fit,can plot extra figures

Input:
% Information contains win & loss for the "left option"
    % n_trial x 2 matrix, contents 0 and 1, column 1 about wins
    % "left" is "shape1" in Gorilla -- here used for convenience
% choice is the participant choice
    % n_trial x 1, 0 and 1, 1 for "chose left"
% start [rew_start loss_start] => default 0.5
% alphabins: sets number of points to estimate lr, betabins same for beta
    % i.e., grid search 
% resp_made is trials on which a response was made (true/false, n_trials)
% fig_yes: 0 or 1; please set to 0 when looping through 10+ iterations

Output: struct with all relevant info
    %DO NOT modify struct fields

Model specifications:
% runs a modified Rescorla-Wagner model which uses separate learning rates for wins and losses.
%for 2 option vol training task in which outcomes are linked.
% (i.e. if one option wins, the other doesn't) => 1-p
%bias term removed

%}
% Author: Dr Michael Browning, University of Oxford
% adapted by Dr Margot Overman 
% then by Bowen Xiao, PaL Cambridge

%% default options & prepare space 

if(nargin<7) fig_yes=0; end
if(nargin<6) resp_made=true(size(information,1),1); end
if(nargin<5) betabins=30; end
if(nargin<4) alphabins=30; end

out=struct;

%Creates a vector of length alphabins in logit space (0-1 transform to -inf to +inf)
alphas = logit(0.01):(logit(0.99) - logit(0.01))/(alphabins-1):logit(0.99);
% Creates a vector of length betabins the value of which changes
% linearly from log(1)=0 to log(100)=4.6 (i.e., beta in log space)
b_label=log(0.1):(log(100)-log(0.1))/(betabins-1):log(100);
%Note: "label" means the "original values" (on each bin of grid)

%% run learning model
% for different alpha values...
% creates grid with all alpha_win and alpha_loss combinations
for k= length(alphas):-1:1 % loop faster with preallocating in first iteration
    for j= length(alphas):-1:1
        learn_left=rescorla_wagner_2lr(information(:,1:2),[logistic(alphas(k)) logistic(alphas(j))],start); % calculates separate value for wins and losses 
        val_l_win(k,j,:)=learn_left(:,1); 
        val_l_loss(k,j,:)=learn_left(:,2);
    end
end
%val_l_win/loss: nbins x nbins x ntrials
%value expectation for each and every trial, under each alpha value

%% set up for different response model parameter values
% expand (repeat) the grid for beta value s 
mmdl_win=repmat(val_l_win,[1,1,1,length(b_label)]);%nbins x nbins x ntrials x nbins
mmdl_loss=repmat(val_l_loss,[1,1,1,length(b_label)]);
clear val_l_win val_l_loss
% same as old val matrix on dim 4 and 5, ready for different beta 

% matrix of beta with same dimensions as value matrix
    % *** unique beta on dim 4 *** 
betatot=repmat(permute(exp(b_label),[1 3 4 2]),[length(alphas) length(alphas) length(information) 1]);

%% run response model 
probleft=1./(1+exp(-(betatot.*(mmdl_win-mmdl_loss))));
% result: 4D value matrix with all parameter combinations on all trials
% p(left_per_trial|alpha_w,alpha_l,beta), 
    %sum to one with p(right_per_trial...)
clear betatot

%% compute likelihood for choice data
% create a 5D matrix of the same dimensions as before with the choices
% arranged along the THIRD dimension
ch=repmat(permute(choice,[2 3 1 4]),[length(alphas) length(alphas)  1 length(b_label)]);
% 1 at position three since choice is column vector, not row vector

% calculate the likelihood of the choices made given the model parameters
% L(choice_per_trial | params)
probch=((ch.*probleft)+((1-ch).*(1-probleft)));
clear probleft

%remove data from trials in which the participant made no response
probch=probch(:,:,resp_made,:);
% hence, not multiplied into the final likelihood

% find posterior:
% calculate the overall liklihood of the parameters by taking the
% product of probability across all individual trials (squeeze prod 3)
% scales up the numbers => reduce rounding error
% creates three dimensional matrix (one dimension per free parameter)
out.posterior_prob(:,:,:)=squeeze(prod(probch,3))*10^(size(probch,3)/4);  
% normalise (divide by sum over entire 4D grid space)
out.posterior_prob=out.posterior_prob./(sum(sum(sum(out.posterior_prob))));
    %gets p(entire_choice_data | params), entire grid sums to one
    % dim 1: win lr
    % dim 2: loss lr
    %dim 3: beta

clear probch

% return parameter from logit or log space to regular space
alphalabel=logistic(alphas);
betalabel=exp(b_label);

%% find parameter estimates & error
%summary: get distribution, find EV

% find marginal distribution of the learning rates
out.marg_alpha_win=squeeze(sum(sum(out.posterior_prob,3),2));

% This generates the expected value of the learning rate using a weighted
% sum-- marginal probabilities multiplied by learning rate values. Note
% for both the learning rate and temperature mean and variance are
% caculated in log space
out.mean_alpha_win = logistic(alphas*out.marg_alpha_win);

% calculate the variance of the distribution of learning rates
out.var_alpha_win= logistic(((alphas - logit(out.mean_alpha_win)).^2)*out.marg_alpha_win);

% repeat for alpha_loss
out.marg_alpha_loss = squeeze(sum(sum(out.posterior_prob,1),3))';
out.mean_alpha_loss = logistic(alphas*out.marg_alpha_loss);
out.var_alpha_loss = logistic(((alphas - logit(out.mean_alpha_loss)).^2)*out.marg_alpha_loss);

%the inverse temperature
    out.marg_beta=squeeze(sum(sum(out.posterior_prob,1),2));
    out.mean_beta=exp(b_label*out.marg_beta);
    out.var_beta=exp(((b_label-log(out.mean_beta)).^2)*out.marg_beta);

out.beta_label=betalabel;
out.lr_label=alphalabel;
out.lr_points=alphas;
out.beta_points=b_label;

%% graphics for mean of posterior

if fig_yes==1 
   figure;
   subplot(2,2,1);
   plot(alphalabel,out.marg_alpha_win);
   hold on
   xline(out.mean_alpha_win)
   hold off
   legend('distribution','est alpha-win')
   title('Learning Rate Reward');
   subplot(2,2,2);
   plot(alphalabel,out.marg_alpha_loss);
   hold on
   xline(out.mean_alpha_loss)
   hold off
   legend('distribution','est alpha-loss')
   title('Learning Rate Loss');
   subplot(2,2,3);
   plot(betalabel,out.marg_beta);
   hold on
   xline(out.mean_beta)
   hold off
   legend('distribution','est beta')
   title('Beta');

end

%% export likelihood for final model
%plug parameter estimate back into model
v=rescorla_wagner_2lr(information(:,1:2),[out.mean_alpha_win out.mean_alpha_loss],start);%value expectation trajectory
out.v_corr=corr(v(:,1),v(:,2));%hmmm what is this correlation doing here????
prob_ch_left=1./(1+exp(-(out.mean_beta.*(v(:,1)-v(:,2)))));

%calculate model evidence
likelihood=prob_ch_left;
likelihood(choice==0)=1-likelihood(choice==0);
out.neg_log_like=-sum(log(likelihood(resp_made)+eps));%add eps to each term, not 1e-16
out.BIC=(2.*out.neg_log_like)+3*(log(sum(resp_made))); % BIC given 3 free parameters;
    %no 2pi, just standard BIC (assume number of data points >> 4); no AIC

%% further plots to demonstrate participant data & fit
nt = length(v);
xt = 1:1:nt;
xt = xt';
    if fig_yes==1
        % a single summary graph
        figure;
        plot(xt,v(:,1),'--');
        hold on
        plot(xt,v(:,2),'--');
        plot(xt,prob_ch_left,'-','LineWidth',3);
        plot(xt,choice,'*');
        hold off
        legend('win expectation for opt 1','loss expectation for opt 1','p(choose option 1)','chosen option 1')
        xlabel('trials')
        ylabel('probability')
        title(sprintf('win lr = %.3f , loss lr = %.3f, beta = %.1f',...
            out.mean_alpha_win,out.mean_alpha_loss, out.mean_beta))

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

function [r]=rescorla_wagner_2lr(Y,alpha,start)
%[r]=rescorla_wagner(Y,alpha,start)
% Y is column of wins and losses
% alpha is [reward_lr loss_lr], start is [start_reward start_loss]
%[r]=rescorla_wagner(Y,alpha)  (start is assumed to be 0.5
% Output is probability estimate
% Author: Dr Michael Browning, University of Oxford
% Date: 27/01/2021

if(nargin<3) 
    start = [0.5 0.5];
end
r=zeros(size(Y));
r(1,:)=start;
for i=2:size(r,1)
  r(i,1)=r(i-1,1)+alpha(1)*(Y(i-1,1)-r(i-1,1));
  r(i,2)=r(i-1,2)+alpha(2)*(Y(i-1,2)-r(i-1,2));
end
   
end