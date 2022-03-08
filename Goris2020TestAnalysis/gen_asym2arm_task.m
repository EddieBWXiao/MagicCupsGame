function task = gen_asym2arm_task(seq,settings)

%{
%creates two-armed bandit tasks
    %asymmetric: where success in one option does NOT preclude success from the other
    %however, for this version ~ the change in probability for the two
    options happen together (i.e., same volatility)

    %additional option: 'auto_sym'
        %sets any 1-p in specified contingency as symmetric bandits
%depending on the number of blocks and the contents of (mini)block within
%not the quickest way to generate stable-volatile block tasks
%but good for more continuous changes with miniblocks of varying lengths

%input:
    seq is an nblock x 3 matrix
    -each row: a miniblock
    -first column: the number of trials
    -second column: the contingency of bandit 1
    -third column: the contingency of bandit 2
    -example: [12,0.5,0.8;20,0.8,0.1]
%}

if nargin < 2
    settings = 'auto_sym';
end

%% preallocate

nt = sum(seq(:,1));%record number of trials
p = nan(nt,2);%the p for both options
outcome = nan(size(p)); %the outcomes from both options  

%know the trials after which the reversal would occur
trialm = cumsum(seq(:,1));

%% iterate across miniblocks

for i = 1:size(seq,1)
    
    % generate the options, considering whether they can be sym or not
    if seq(i,2) == 1-seq(i,3) && strcmp(settings,'auto_sym') %only do this if set to auto_sym
        % generate one option, then 1-p for the other
        opt1 = gen_miniblock(seq(i,1),seq(i,2));%generate option1
        opt2 = gen_miniblock(seq(i,1),seq(i,3));%create the struct ~ but modifies it
        opt2.outcome = 1-opt1.outcome; %if opt1 win, opt2 is no win
    else
        % generate the two options separately
        opt1 = gen_miniblock(seq(i,1),seq(i,2));%generate option1
        opt2 = gen_miniblock(seq(i,1),seq(i,3));%generate option2
    end
    % merge the miniblocks together
    if i == 1
        p(1:trialm(i,1),1) = opt1.p;%%concatonate probability of outcome
        outcome(1:trialm(i,1),1) = opt1.outcome;%concatonate outcome sequence
        
        %repeat for opt2
        p(1:trialm(i,1),2) = opt2.p;
        outcome(1:trialm(i,1),2) = opt2.outcome;
    else
        blockini = trialm(i-1,1)+1;%note down starting trial of this miniblock
            %has +1, because e.g., 20 in trialm = reversal at 21
        p(blockini:trialm(i,1),1) = opt1.p; %concatonate p 
        outcome(blockini:trialm(i,1),1) = opt1.outcome;%concatonate outcome
        
        %repeat for opt2
        p(blockini:trialm(i,1),2) = opt2.p;
        outcome(blockini:trialm(i,1),2) = opt2.outcome;
    end 
end

%% record other task-relevant information
xt = 1:1:nt;%array for 1:1:number of trials
xt = xt';%should be a column vector

%% output 
task = struct('p',p,'outcome',outcome,'nt',nt,'xt',xt);

end
function bandit = gen_miniblock(ntrials,contingency)
% produce trial outcomes based on contingency specified
% for ONE bandit
% needs to be concatonated with other mini-blocks
% AND joined with the other bandit (2arms)

%% outline the probabilistic associations & proportion of successes

p = repmat(contingency,ntrials,1);%probability of outcome
n1s =contingency*ntrials;%number of success available from the option

%% designate whether each trial is a win or loss, for option one

%create a string of binary outcomes with the specified proportion
rawtrials = [zeros(round(ntrials-n1s),1);ones(round(n1s),1)];
%permute the sequence of 0 and 1
outcome = rawtrials(randperm(length(rawtrials)));

%% record other task-relevant information
nt = length(outcome);%record number of trials
xt = 1:1:nt;%array for 1:1:number of trials
xt = xt';%should be a column vector

%% output 
bandit = struct('p',p,'outcome',outcome,'nt',nt,'xt',xt);
end
