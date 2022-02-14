function task = gen_misce_task(seq)

%{
%code capable of generating a miscellaneous set of tasks
%depending on the number of blocks and the contents of (mini)block within
%not the quickest way to generate stable-volatile block tasks
%but good for more continuous changes with miniblocks of varying lengths

%input:
    seq is an nblock x 2 matrix
    -each row: a miniblock
    -first column: the number of trials
    -second column: the contingency
    -example: [12,0.5;20,0.8]
%}
%% preallocate
nt = sum(seq(:,1));%record number of trials
p = nan(nt,1);%yes, column vector
outcome = nan(size(p,1),2);

%know the trials on which the reversals occur
trialm = cumsum(seq(:,1));

%% iterate across miniblocks
for i = 1:size(seq,1)
    m = gen_miniblock(seq(i,1),seq(i,2));%generate a miniblock
    %merge the miniblocks together
    if i == 1
        p(1:trialm(i,1),1) = m.p;%add probability of outcome
        outcome(1:trialm(i,1),:) = m.outcome;%add outcome sequence
    else
        blockini = trialm(i-1,1)+1;%note down starting trial of this miniblock
        p(blockini:trialm(i,1),1) = m.p;%add p
        outcome(blockini:trialm(i,1),:) = m.outcome;%add outcome
    end 
end

%% record other task-relevant information
xt = 1:1:nt;%array for 1:1:number of trials
xt = xt';%should be a column vector

%% output 
task = struct('p',p,'outcome',outcome,'nt',nt,'xt',xt);
end
function task = gen_miniblock(ntrials,contingency)
% produce trial outcomes based on contingency specified
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
%flip the 1 and 0 from option one, creating option two
%combine to form matrices of n_trial x n_options
outcome = [outcome,~outcome];
%% output 
task = struct('p',p,'outcome',outcome,'nt',nt,'xt',xt);
end
