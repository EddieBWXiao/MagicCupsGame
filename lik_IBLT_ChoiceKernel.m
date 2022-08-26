function [loglik,CK,pchoice] = lik_IBLT_ChoiceKernel(parameters, actions)
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