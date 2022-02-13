function [ests,joint,LRdirect,BIC] = fit_PL_RW_2p(actions,outcomes,modelh,missing,graph)

%general purpose function for fitting models with two parameters
%e.g., RW1lr, 1 or 2 arms

% fit by maximising the full joint/take mean of distribution
% produce parameter estimate
% search of parameter space done in logit/log

%can account for missing trials
%computes BIC


%input:
%actions: a sequence of 1 and 2's => chosen option on each trial
%outcomes: the sequence of outcomes (for both options)
%modelh:
%missing: logical index for trials not considered

%example: fit_PL_RW_2p(actions,outcomes,@lik_RW1lr_PL,missing,1)

%% list possible range of parameter values
alphabins = 30;
betabins = 30;

%created in logit space or log etc.
a_range = logit(0.01):(logit(0.99) - logit(0.01))/(alphabins-1):logit(0.99);
b_range = log(0.1):(log(40)-log(0.1))/(betabins-1):log(40);
%note: consistently use row vectors

%put back to native space
a_native = logistic(a_range);
b_native = exp(b_range);

%% remove missing trials 
actions(missing,:) = [];
outcomes(missing,:)=[];

%% loop through possible values, with other parameters fixed
for cycle1 = length(a_range):-1:1
    for cycle2 = length(b_range):-1:1
        %parameters in native space must be transformed for _lik
        parameters(1) = a_range(cycle1);
        parameters(2) = b_range(cycle2);
        
        %obtain neg log likelihood from costfunc
        negLL = modelh(parameters,actions,outcomes);
        joint(cycle1,cycle2) = -negLL;%get back to positive LL
    end
    %fprintf('parameter combination loops: %i to go \n',cycle1-1)
end
%record which dimension for which parameter
a_dim = 1;
beta_dim = 2;

%% find mean (of joint LL, not log LL)
joint = exp(joint);%convert back to L
    %the total sum of this matrix may be < 1
joint = joint./sum(joint(:));% normalise
    % equivalent to out.posterior_prob in Browning_fit_2lr_1betaplus

marg_a = make_column(squeeze(sum(joint,beta_dim)));%should be a normalised distribution
marg_beta = make_column(squeeze(sum(joint,a_dim)));

%find mean (expected value) from marginalised distr. of each parameter
ests.mean_a = logistic(dot(marg_a,a_range));%column vector before row vect
ests.mean_beta = exp(dot(marg_beta,b_range));

LRdirect = ests.mean_a; %provide quick record of learning rate

%% obtain BIC from LL
mnegLL = modelh([ests.mean_a,ests.mean_beta],actions,outcomes);
BIC=(2.*mnegLL)+length(parameters)*log(length(actions));
%% graph
%clear joint
if graph   
    figure;
    subplot(2,2,1)
    plot(a_native,marg_a)
    hold on

    xline(ests.mean_a,'r')
    hold off
    legend('distribution','marg mean')
    xlabel('alpha')
    ylabel('probability')

    subplot(2,2,2)
    imagesc(joint);
    xlabel('inverse temperature')
    ylabel('learning rate')
    xticks = 1:betabins;%size(~,2), because columns
    yticks = 1:alphabins;
    %compute content of tick markers (the scale displayed)
    set(gca, 'XTick', xticks, 'XTickLabel', round(exp(b_range)))
    set(gca, 'YTick', yticks, 'YTickLabel', round(logistic(a_range),2))
    title('alpha and beta, joint LL distribution')

    subplot(2,2,3)
    plot(b_native,marg_beta)
    hold on
    xline(ests.mean_beta,'r')
    hold off
    legend('distribution','marg mean')
    xlabel('beta')
    ylabel('probability')
    hold off       
end

end
function v = make_column(v)
    if ~iscolumn(v)
        v = v';
    end
end