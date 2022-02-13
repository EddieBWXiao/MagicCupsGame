function RW_param_arm_BIC(inseq,alpha_range,beta_range)

% check if model comparison can reveal which fit is better
% create confusion matrix
% credit: adapted from Wilson & Collins 2019

%prepare
task = gen_misce_task(inseq);
nsimus = length(alpha_range);

%confusion matrix set-up
CM = zeros(2); %2x2 in this case
    %row being the simu, column being the fit

for i = 1:nsimus
    %generate virtual participants, 1armed or 2armed
    s1 = RW1lr_plsim(task,[alpha_range(i),beta_range(i)],0);
    s2 = RW1lr_2arms_plsim(task,[alpha_range(i),beta_range(i)],0);
    
    best = fitboth_bic(s1);
    CM(1,:) = CM(1,:)+best;%add info about best model
    
    best = fitboth_bic(s2);
    CM(2,:) = CM(2,:)+best;
    
    if mod(i,10) == 0
        fprintf('== simulation number %i completed == \n',i)
    end
end

%visual
FM = round(100*CM/sum(CM(1,:)))/100;
    %normalise => divide by total number of simulations
t = imageTextMatrix(FM);
set(t(FM'<0.3), 'color', 'w')
hold on;
set(t, 'fontsize', 22)
set(gca, 'xtick', [1:2], 'ytick', [1:2], ...
    'XTickLabel',{'update both','update chosen'},...
    'YTickLabel',{'update both','update chosen'},...
    'fontsize', 20, ...
    'xaxislocation', 'top', 'tickdir', 'out')
xlabel('fitted model')
ylabel('simulated model')
title('confusion matrix: p(fitted model | simulated model)')

figure;
%visualise the inverse (posterior, with uniform prior)
for i = 1:size(CM,2)
    iCM(:,i) = CM(:,i) / sum(CM(:,i));
end
FM = round(100*iCM/sum(iCM(1,:)))/100;
t = imageTextMatrix(FM);
set(t(FM'<0.3), 'color', 'w')
hold on;
set(t, 'fontsize', 22)
set(gca, 'xtick', [1:2], 'ytick', [1:2], ...
    'XTickLabel',{'update both','update chosen'},...
    'YTickLabel',{'update both','update chosen'},...
    'fontsize', 20, ...
    'xaxislocation', 'top', 'tickdir', 'out')
xlabel('fitted model')
ylabel('simulated model')
title('confusion matrix: p(simulated model | fitted model)')



end
function best = fitboth_bic(s)

% acknowledgement: Wilson & Collins 2019 code
% output best: vector indicating which model has higher BIC
    %important: output row vector add onto confusion matrix rows

lb = [0,0];
ub = [1,100];

%fit the 1armed model
actions = s.choices; % 1 for action=1 and 2 for action=2; assume no missing trials
outcomes = s.feedback.outcomes(:,1:2); % e.g., 1 for win on trial, 0 for no win
initial = [rand exprnd(1)];
costfun = @(x) lik_RW1lr_PL_native(x,actions,outcomes,false);
params = fmincon(costfun,initial,[],[],[],[],lb, ub,[],optimset('maxfunevals',10000,'maxiter',2000,'Display', 'off'));
mnegLL = lik_RW1lr_PL_native(params,actions,outcomes);
BIC(1) = (2.*mnegLL)+length(params)*log(length(actions));


%fit the 2armed model
actions = s.choices; % 1 for action=1 and 2 for action=2; assume no missing trials
outcomes = s.feedback.score; % e.g., 1 for win on trial, 0 for no win
initial = [rand exprnd(1)];
costfun = @(x) lik_RW1lr_2arms_PL_native(x,actions,outcomes,false);
params = fmincon(costfun,initial,[],[],[],[],lb, ub,[],optimset('maxfunevals',10000,'maxiter',2000,'Display', 'off'));
mnegLL = lik_RW1lr_2arms_PL_native(params,actions,outcomes);
BIC(2) = (2.*mnegLL)+length(params)*log(length(actions));

%determine who is the best
MinBIC = min(BIC);
BEST = BIC == MinBIC;%logical for who is best; allow for ties
best = BEST / sum(BEST);
end