function [loglik,p,pchoice] = lik_IBLT_RandomActions(parameters, actions)
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