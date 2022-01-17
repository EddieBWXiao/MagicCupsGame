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

nr = 0;%no reversals occur within each miniblock
    %the transition between miniblocks ARE the reversals
graph = 0;%if not... will plot all miniblocks

%% preallocate
nt = sum(seq(:,1));%record number of trials
p = nan(nt,1);%yes, column vector
outcome = nan(size(p,1),2);

%know the trials on which the reversals occur
trialm = cumsum(seq(:,1));

%% iterate across miniblocks
for i = 1:size(seq,1)
    m = gen_simpleRL_task(seq(i,1),nr,seq(i,2),graph);%generate a miniblock
    
    if i == 1
        p(1:trialm(i,1),1) = m.p;
        outcome(1:trialm(i,1),:) = m.outcome;
    else
        blockini = trialm(i-1,1)+1;%starting trial of this miniblock
        p(blockini:trialm(i,1),1) = m.p;
        outcome(blockini:trialm(i,1),:) = m.outcome;
    end
    
end

%% record other task-relevant information
xt = 1:1:nt;%array for 1:1:number of trials
xt = xt';%should be a column vector

%% output 
task = struct('p',p,'outcome',outcome,'nt',nt,'xt',xt);
%% visualise
figure;
plot(xt,p,'b-');
hold on
plot(xt, outcome(:,1),'*')
hold off
legend('p(good outcome|choose opt 1)','outcome')
xlabel('trials')
ylabel('probability')

end