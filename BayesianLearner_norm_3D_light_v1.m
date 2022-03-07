function out = BayesianLearner_norm_3D_light_v1(task,graph)

% reproduction of Behrens 2007's Bayesian learner
% in this version: use Gaussian distribution throughout!
    %hence, do r in logit space
    %benefit: same distributions as the Pulcu 2022 code 
    %check if failure due to log scales etc.
%ALSO: not using 5D grid
    % instead, loop to...
    % first involve p(v | v & k), update v & k for same r
    % then get p(r | r & v), update r & v (not caring k)

if nargin<1
    Behrens = [[60,0.75];[60,0.75];repmat([30,0.2;30,0.8],[3,1])];
    %Behrens = [repmat([30,0.2;30,0.8],[2,1]);[60,0.75];[60,0.75];[60,0.75]];
    task = gen_misce_task(Behrens);
    graph = 1;
end

y = task.outcome(:,1);%outcome of option 1, to be observed
    %ntrials x 1 of 1 & 0
nt = length(y);

%% prepare the parameter space

% the number of parameter values to "try"
rbins = 40;
vbins = 40;
kbins = 40;

logitf = @(x) log(x./(1-x));
logisticf = @(x) 1./(1+exp(-x));

rRange = (logitf(0.01):(logitf(0.99)-logitf(0.01))/(rbins-1):logitf(0.99))'; % possible values of r
vRange= (log(0.01):(log(20)-log(0.01))/(vbins-1):log(20))';%possible values of v
    % log scale
    % native space -- may need to log it to get more reasonable numbers for
    % reparameterised beta distribution (lower the v, more precise)
kRange = (log(5e-5):(log(100)-log(5e-5))/(kbins-1):log(100))';
    %when in normal distribution, output as sd between 1 and 2.69

%% preallocate
L = nan(rbins,nt);  %likelihood p(y_i | r_i)  
est_r = nan(nt,1); % mean for marginal distribution over r
    marg_r = nan(nt,rbins); % store marginal distribution over r
est_v = nan(nt,1); % mean for marginal distribution over v
    marg_v = nan(nt,vbins); % store marginal distribution over v
est_k = nan(nt,1); % mean for marginal distribution over k
pv_given_vk = nan(vbins,vbins,kbins); % probability for change in v
pr_given_rv = nan(rbins,rbins,kbins); % probability for change in r
    % also, smaller matrices are created (easier to normalise over)
    pv_given_v_eachk = nan(vbins,vbins);
    pr_given_r_eachv = nan(rbins,rbins);

%% set up transition functions (TFs; e.g., from v_i to v_i+1)
% they do not need trial-wise information
% for volatility
for kind = 1:kbins %loop for all possible k's
    for v1ind = 1:vbins %loop for different v_i
        for v2ind = 1:vbins %loop for different v_i+1
            % look at different combinations of v_i+1, v_i, and k
            xv = vRange(v2ind);
            muv = vRange(v1ind);
            sigv = exp(kRange(kind));% k should be in log space
            % use built in normpdf to find probability
            pv_given_v_eachk(v2ind,v1ind) = normpdf(xv,muv,sigv);
        end
        %normalise: for each v_i, different v_i+1 should sum to 1
        pv_given_v_eachk(:,v1ind) = pv_given_v_eachk(:,v1ind)/sum(pv_given_v_eachk(:,v1ind));
    end
    % add to overall grid
    pv_given_vk(:,:,kind) = pv_given_v_eachk;
end

% for r
for vind = 1:vbins
    for r1ind = 1:rbins
        for r2ind = 1:rbins
            % look at different combinations of r_i+1, r_i, and v
            xr = rRange(r2ind);
            mur = rRange(r1ind);
            sigr = exp(vRange(vind));
            % use normal distribution to find probability (already in logit
            % space, r is, so can use normal)
            pr_given_r_eachv(r2ind,r1ind) = normpdf(xr,mur,sigr);
        end
        pr_given_r_eachv(:,r1ind) = pr_given_r_eachv(:,r1ind)/sum(pr_given_r_eachv(:,r1ind));
    end
    pr_given_rv(:,:,vind) = pr_given_r_eachv;
end

%% create prior: for the first cycle; other preallocations
prior_rvk = ones(rbins,vbins,kbins)/sum(ones(rbins,vbins,kbins),'all'); %3D grid; updated on each trial
joint_hold = nan(size(prior_rvk)); %for temporary storage

%% loop (5D grid involved)
for i = 1:nt %loop for all trials
    
    %%%%%%%% Extract Bayesian estimates %%%%%%%%
    marg_r(i,:) = sum(sum(prior_rvk,2),3)./sum(sum(sum(prior_rvk,2),3),1);
    est_r(i) = logisticf(sum(sum(sum(prior_rvk,2),3).*rRange,'all'));
    marg_v(i,:) = squeeze(sum(sum(prior_rvk,1),3)./sum(sum(sum(prior_rvk,1),3),2));
    est_v(i) = sum(dot(marg_v(i,:),vRange));
        % note that the ests are still in "log space"
    marg_k = squeeze(sum(sum(prior_rvk,1),2));
    est_k(i) = sum(dot(marg_k,kRange));
    
    %%%%%%%% Update %%%%%%%%
    % compute likelihood function p (y_i| r_i)
        % this step done first, since we are at i
        % after i, multiple TFs, to get i+1 info
        % for trial i-1, this step is the "p (y_i+1| r_i+1)" bit in Behrens 2007 eq(B)
    if y(i) == 1
        L(:,i) = logisticf(rRange); %Bernoulli; P(y_i = 1) = p
    elseif y(i) ==0
        L(:,i) = 1-logisticf(rRange); % P(y_i = 0) = p
    end
    bigL = repmat(L(:,i),[1,vbins,kbins]); %to 3D
    % note that p (y_i = 0 | r_i = 0.5, v, k) same for all v & k
    % thus, we have:
    p_rvk_y = bigL.*prior_rvk; % joint probability, with y added
    p_rvk_y = p_rvk_y./sum(p_rvk_y,'all');%normalsie
    
    % multiply with p(v_i+1 | vi, k) and integrate over v_i
    for vi1 = 1:vbins %for different possible v_i+1
        tempvk = pv_given_vk(vi1,:,:);
        for ri = 1:rbins
            joint_hold(ri,vi1,:) = sum(tempvk.*p_rvk_y(ri,:,:),2); %do the multiplication & sum over dim 2
                % find probability for this v_i+1, at different k
        end
    end
    
    % multiply with p(r_i+1 | ri, vi+1), and integrate over r_i
    for kth = 1:kbins % extract different kth, since we care about each r_i+1 & v_i+1
        temprv = joint_hold(:,:,kth); % for a specific k, different r & v combinations
        temprv = permute(temprv,[3,1,2]);% turn into 1 x nri x nvi
        for ri = 1:rbins %for different r_i+1
            prior_rvk(ri,:,kth) = squeeze(sum(temprv.*pr_given_rv(ri,:,:),2)); %do the multiplication & sum over dim 2
                % find probability for this r_i+1, given different vi+1
                % what was multiplied: at this r_i+1, the r_i & vi+1 combos, with the r_i & vi+1 combo we have
                % outcome is the probability for that vi+1 (related to ri+1
                % and kth, one controlling how v changed to this point, and the other providing evidence for having this v_i+1)
        end
    end
    
end

if graph == 1
    % visualise: Behrens 2007 Fig d, plus plot of marginal distributions
    figure;
    subplot(3,1,1)
    plot(1:nt,task.p,'-')
    hold on
    plot(1:nt,est_r,'--')
    plot(1:nt,y,'o')
    hold off
    legend('contingency','r estimate','outcomes observed')
    xlabel('trials')
    ylabel('probability')
    subplot(3,1,2)
    plot(1:nt,est_v,'--')
    ylabel('volatility')
    xlabel('trials')
    subplot(3,1,3)
    plot(1:nt,est_k,'--')
    ylabel('k')
    xlabel('trials')

    figure;
    subplot(2,1,1)
    hold on
    imagesc(1:nt,logisticf(rRange),marg_r');
    hold off
    xlabel('trials')
    ylabel('reward prob. estimated')
    hcb = colorbar;
    hcb.Label.String = 'probability density (from marginal distribution)';
    xlim([0 nt]) %I don't know why extra blank bits pop up, so had to add this
    ylim([0 1]) 
    subplot(2,1,2)
    imagesc(1:nt,(vRange),marg_v');
    set(gca,'YDir','normal')%display high volatility on top (imagesc default is 'reverse')
    ylabel('volatility')
    xlabel('trials')
    hcb = colorbar;
    hcb.Label.String = 'probability density (from marginal distribution)';
end

out = struct('est_r',est_r,'marg_r',marg_r,'est_v',est_v,'marg_v',marg_v,'est_k',est_k,...
    'rRange',rRange,'vRange',vRange,'kRange',kRange);

end