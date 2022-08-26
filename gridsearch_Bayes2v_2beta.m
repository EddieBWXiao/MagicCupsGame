function [out]= gridsearch_Bayes2v_2beta(information,choice, v_in, alphabins,betabins, resp_made,fig_yes)

%provides model fit with extra figures
% model fit for 2 option vol training task in which outcomes are linked.
% (i.e. if one option wins, the other doesn't) => 1-p
% fixed parameters of v_win & v_loss on each trial

%{ 
Input:
% Information contains win & loss for the "left option"
    % n_trial x 2 matrix, contents 0 and 1, column 1 about wins
% choice is the participant choice
    % n_trial x 1, 0 and 1, 1 for "chose left"
% "start" replaced by fixed v_in
    %v_in: the output from Bayesian learner
    %value estimated upon observing the outcome sequences
%}

%% default options & prepare space 

if(nargin<7) fig_yes=0; end
if(nargin<6) resp_made=true(size(information,1),1); end
if(nargin<5) betabins=30; end
if(nargin<4) alphabins=30; end

out=struct;

%parameter values to try
alphas = logit(0.01):(logit(0.99) - logit(0.01))/(alphabins-1):logit(0.99);
b_label=log(0.1):(log(100)-log(0.1))/(betabins-1):log(100); %MUST be row

%% convert v_in (from Bayesian learner) to current format

val_l_win = repmat(v_in(:,1),[1,betabins,betabins]); %create 3D matrix, each row same v_win
val_l_loss = repmat(v_in(:,2),[1,betabins,betabins]); %repeat for v_loss

betawintot=repmat(permute(exp(b_label),[1 2 3]),[length(information) 1 length(b_label)]); %different betawin on dim 2
betalosstot=repmat(permute(exp(b_label),[1 3 2]),[length(information) length(b_label) 1]);%different betawloss on dim 3

%% run response model 
probleft=1./(1+exp(-(betawintot.*val_l_win-betalosstot.*val_l_loss)));
% result: p(left_per_trial|parameters); 3D matrix, ntrials x nbeta x nbeta
clear betawintot betalosstot 

%% compute likelihood for choice data
ch=repmat(permute(choice,[1 2 3]),[1 length(b_label) length(b_label)]);
    % prepare to find likelihood
    % each row (dim1) -- different responses on different trials
probch = ((ch.*probleft)+((1-ch).*(1-probleft)));%the likelihood
clear probleft

%remove data from trials in which the participant made no response
probch=probch(resp_made,:,:);

% find posterior by summing over the first dim (the dim of trials)
out.posterior_prob(:,:)=squeeze(prod(probch,1))*10^(size(probch,1)/5); 
% normalise
out.posterior_prob=out.posterior_prob./(sum(sum(out.posterior_prob)));
%note: now, dim1 is betawin, dim2 is betaloss

clear probch

% return parameter from logit or log space to regular space
betalabel=exp(b_label);

%% find parameter estimates & error
out.marg_beta_win = squeeze(sum(out.posterior_prob,2));
out.mean_beta_win = exp(dot(b_label,out.marg_beta_win));
out.var_beta_win = exp(((b_label-log(out.mean_beta_win)).^2)*out.marg_beta_win);

out.marg_beta_loss =squeeze(sum(out.posterior_prob,1));
out.mean_beta_loss = exp(dot(b_label,out.marg_beta_loss));
out.var_beta_loss = exp(dot(((b_label-log(out.mean_beta_loss)).^2),out.marg_beta_loss));

out.beta_label=betalabel;
out.beta_points=b_label;

%% graphics for mean of posterior

if fig_yes==1 
   figure;
   subplot(2,2,1)
   plot(betalabel,out.marg_beta_win);
   hold on
   xline(out.mean_beta_win)
   hold off
   legend('distribution','est beta win')
   title('Beta-win')
   subplot(2,2,2)
   plot(betalabel,out.marg_beta_loss);
  hold on
   xline(out.mean_beta_loss)
   hold off
   legend('distribution','est beta loss')
   title('Beta-loss')
    subplot(2,2,3)
   imagesc(out.beta_points,out.beta_points,out.posterior_prob);
 
end

%% export likelihood for final model
%plug parameter estimate back into model
prob_ch_left=1./(1+exp(-(out.mean_beta_win.*v_in(:,1)-out.mean_beta_loss.*v_in(:,2))));

%calculate model evidence
likelihood=prob_ch_left;
likelihood(choice==0)=1-likelihood(choice==0);
out.neg_log_like=-sum(log(likelihood(resp_made)+eps));
out.BIC=(2.*out.neg_log_like)+2*(log(sum(resp_made))); % BIC given 2 free parameters

%% further plots to demonstrate participant data & fit
nt = length(v_in);
xt = 1:1:nt;
xt = xt';
    if fig_yes==1
        % a single summary graph
        figure;
        plot(xt,v_in(:,1),'--');
        hold on
        plot(xt,v_in(:,2),'--');
        plot(xt,prob_ch_left,'-','LineWidth',3);
        plot(xt,choice,'*');
        hold off
        legend('win expectation for opt 1','loss expectation for opt 1','p(choose option 1)','chosen option 1')
        xlabel('trials')
        ylabel('probability')
        title(sprintf('beta_win = %.1f, beta_loss = %.1f',...
            out.mean_beta_win,out.mean_beta_loss),'Interpreter','none')
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