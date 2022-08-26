function [out]= gridsearch_RW1lr_1beta1bias(information,choice, start, alphabins,betabins, resp_made,fig_yes)

%modified from osf, https://osf.io/k36h4/
%{
% provides model fit,can plot extra figures

Input:
% Information contains win & loss for the "left option"
    % n_trial x 2 matrix, contents 0 and 1, column 1 about wins
    % "left" is "shape1" in Gorilla -- here used for convenience
% choice is the participant choice
    % n_trial x 1, 0 and 1, 1 for "chose left"
% alphabins: sets number of points to estimate lr, betabins same for beta
    % i.e., grid search 
% resp_made is trials on which a response was made (true/false, n_trials)
% fig_yes: 0 or 1; please set to 0 when looping through 10+ iterations

Output: struct with all relevant info
    %DO NOT modify struct fields

Model specifications:
% runs a modified Rescorla-Wagner model, but: no separate est for win & loss
% has a bias term (tendency for one option)

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
b_label = log(0.1):(log(100)-log(0.1))/(betabins-1):log(100);
% Creates vector in linear space for added bias
add_label = -2:4/(betabins-1):2; %same length as betabins
%Note: "label" means the "original values" (on each bin of grid)

%% run learning model
% for different alpha values...
% creates grid with all alpha_win and alpha_loss combinations
for k= length(alphas):-1:1 % loop faster with preallocating in first iteration
    learn_left=rescorla_wagner_only1lr(information(:,1:2),logistic(alphas(k))); % calculates separate value for wins and losses 
    val_l(k,:)=learn_left(:,1); 
end
%val_l: nbins x ntrials
%value expectation for each and every trial, under each alpha value

%% set up for different response model parameter values
% expand (repeat) the grid for beta value s 
mmdl_v=repmat(val_l,[1,1,length(b_label),length(add_label)]);%nbins x ntrials x nbins x nbins
clear val_l

% matrix of beta with same dimensions as value matrix
    % *** unique added bias on dim 4 ***
    % *** unique beta on dim 3 *** 
betatot=repmat(permute(exp(b_label),[1 3 2 4]),... %move dim 2 to dim 3
    [length(alphas) length(information) 1, length(add_label)]);
addam=repmat(permute(add_label,[1 3 4 2]),...%move dim 2 to dim 4
    [length(alphas) length(information) length(b_label) 1]);

%% run response model 
probleft=1./(1+exp(-(betatot.*(mmdl_v+addam))));
% result: 4D value matrix with all parameter combinations on all trials
clear betatot addam

%% compute likelihood for choice data
% create a 4D matrix of the same dimensions as before with the choices
% arranged along the second dimension
ch=repmat(permute(choice,[2 1 3 4]),[length(alphas) 1 length(b_label) length(add_label)]);
% 1 at position three since choice is column vector, not row vector

% calculate the likelihood of the choices made given the model parameters
% L(choice_per_trial | params)
probch=((ch.*probleft)+((1-ch).*(1-probleft)));
clear probleft

%remove data from trials in which the participant made no response
probch=probch(:,resp_made,:,:);
% hence, not multiplied into the final likelihood

% find posterior:
% calculate the overall liklihood of the parameters
out.posterior_prob(:,:,:)=squeeze(prod(probch,2))*10^(size(probch,2)/4); % product of probability across all individual trials 
out.posterior_prob=out.posterior_prob./(sum(sum(sum(out.posterior_prob))));% normalise (divide by sum over entire 4D grid space)
    %gets p(entire_choice_data | params), entire grid sums to one
    %dim1 LR, dim2 beta, dim3 addm

clear probch

% return parameter from logit or log space to regular space
alphalabel=logistic(alphas);
betalabel=exp(b_label);

%% find parameter estimates & error
%summary: get distribution, find EV

out.marg_alpha=squeeze(sum(sum(out.posterior_prob,3),2));
out.mean_alpha = logistic(alphas*out.marg_alpha);
out.var_alpha = logistic(((alphas - logit(out.mean_alpha)).^2)*out.marg_alpha);

%the second dim ~ inverse temperature
out.marg_beta = squeeze(sum(sum(out.posterior_prob,1),3))';
out.mean_beta = exp(b_label*out.marg_beta);
out.var_beta = exp(((b_label - log(out.mean_beta)).^2)*out.marg_beta);

%the addm
out.marg_addm=squeeze(sum(sum(out.posterior_prob,1),2));
out.mean_addm=add_label*out.marg_addm;
out.var_addm=((add_label-out.mean_addm).^2)*out.marg_addm;

out.beta_label=betalabel;
out.lr_label=alphalabel;
out.lr_points=alphas;
out.beta_points=b_label;
out.addm_points=add_label;

%% graphics for mean of posterior

if fig_yes==1 
   figure;
   subplot(2,2,1);
   plot(alphalabel,out.marg_alpha);
   hold on
   xline(out.mean_alpha)
   hold off
   legend('distribution','est alpha')
   title('Learning Rate (only one)');
 
   subplot(2,2,3);
   plot(betalabel,out.marg_beta);
   hold on
   xline(out.mean_beta)
   hold off
   legend('distribution','est beta')
   title('Beta');
   subplot(2,2,4);
   plot(add_label,out.marg_addm);
  hold on
   xline(out.mean_addm)
   hold off
   legend('distribution','est addm')
   title('Addm (bias, aka tendency parameter)');

end

%% export likelihood for final model
%plug parameter estimate back into model
v=rescorla_wagner_only1lr(information(:,1:2),out.mean_alpha);%value expectation trajectory
prob_ch_left=1./(1+exp(-(out.mean_beta.*(v(:,1)+out.mean_addm))));

%calculate model evidence
likelihood=prob_ch_left;
likelihood(choice==0)=1-likelihood(choice==0);
out.neg_log_like=-sum(log(likelihood(resp_made)+eps));%add eps to each term, not 1e-16
out.BIC=(2.*out.neg_log_like)+3*(log(sum(resp_made))); % BIC given 3 free parameters;
    %no 2pi, just standard BIC (assume number of data points >> 3); no AIC

%% further plots to demonstrate participant data & fit
nt = length(v);
xt = 1:1:nt;
xt = xt';
    if fig_yes==1
        % a single summary graph
        figure;
        plot(xt,v(:,1),'--');
        hold on
        plot(xt,prob_ch_left,'-','LineWidth',3);
        plot(xt,choice,'*');
        hold off
        legend('expectation for opt 1','p(choose option 1)','chosen option 1')
        xlabel('trials')
        ylabel('probability')
        title(sprintf('lr = %.3f , beta = %.1f, added-bias = %.3f',...
            out.mean_alpha, out.mean_beta,out.mean_addm))
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

function [r]=rescorla_wagner_only1lr(Y,alpha,start)
%[r]=rescorla_wagner(Y,alpha,start)
% Y is column of wins and losses
%[r]=rescorla_wagner(Y,alpha)  (start is assumed to be 0.5
% Output is probability estimate
% Author: Dr Michael Browning, University of Oxford
% Modified by bowen xiao

if(nargin<3) 
    start = 0.5; %I will be using this throughout -- prevent [0.5 0.5] error
end
r=zeros(length(Y));
r(1,:)=start;
for i=2:size(r,1)
  r(i,1)=r(i-1,1)+alpha*(Y(i-1,1)-Y(i-1,2)-r(i-1,1));
  %important: column 1 win - column 2 loss, get the "net outcome"
end
   
end