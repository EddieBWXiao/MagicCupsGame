function [task,outcome_opt1] = gen_IBLT_task(condition,randomisation)

%creates struct with task information
%allows different versions (60 trials, 80 trials, fixed or random) 
%& conditions (bothvol, winvol etc.)
%provides input to all _sim functions

if nargin<2
    randomisation = 'fixed';
end

%% main/default: Magic Cups Game, 60 trials per condition
% load the task structure, from file in same directory, or from input
tans = readtable('Magic_Cups_Answers.csv');%the task structure information from Gorilla spreadshet

%% set the probabilistic associations

%first write them in ntrials-contingency
win1_revs = [14;14;16;16];%know the trials
loss1_revs = [18;18;12;12];%know the trials
%split the 24 wins into the buckets of miniblocks
win1_conting = [3/14;11/14;3/16;13/16];
loss1_conting = [14/18;4/18;10/12;2/12];
%both-volatile block contingencies:
win1seq_b1 = [win1_revs,win1_conting];
loss1seq_b1=[loss1_revs,loss1_conting];
%other block contingencies
win1seq_b2 = [15,0.8;15,0.2;15,0.8;15,0.2];
loss1seq_b2 = [16,0.5;14,0.5;14,0.5;16,0.5];%use this sequence, not [60,0.5], so each 15 trial interval has around the same 1 and 0
win1seq_b3 = [16,0.5;14,0.5;14,0.5;16,0.5];
loss1seq_b3 = [15,0.8;15,0.2;15,0.8;15,0.2];

%spell out contingency for all the trials
win1_b1 = [repmat(win1seq_b1(1,2),win1seq_b1(1,1),1);repmat(win1seq_b1(2,2),win1seq_b1(2,1),1);repmat(win1seq_b1(3,2),win1seq_b1(3,1),1);repmat(win1seq_b1(4,2),win1seq_b1(4,1),1)];
win1_b2 = [repmat(0.8,15,1);repmat(0.2,15,1);repmat(0.8,15,1);repmat(0.2,15,1)];
win1_b3 = repmat(0.5,60,1);
%win1 = [win1_b1;win1_b2;win1_b3];
loss1_b1 = [repmat(loss1seq_b1(1,2),loss1seq_b1(1,1),1);repmat(loss1seq_b1(2,2),loss1seq_b1(2,1),1);repmat(loss1seq_b1(3,2),loss1seq_b1(3,1),1);repmat(loss1seq_b1(4,2),loss1seq_b1(4,1),1)];
loss1_b2 = repmat(0.5,60,1);
loss1_b3 = [repmat(0.8,15,1);repmat(0.2,15,1);repmat(0.8,15,1);repmat(0.2,15,1)];%b3 = loss volatile
%loss1 = [loss1_b1;loss1_b2;loss1_b3];


%manually write down Sandy's contingencies:
win1_b1set = [repmat(0.2,12,1);repmat(0.8,13,1);repmat(0.2,17,1);repmat(0.8,18,1)];
loss1_b1set = [repmat(0.8,18,1);repmat(0.2,17,1);repmat(0.8,13,1);repmat(0.2,12,1);];

%% set task condition & generate feedback
if strcmp(randomisation,'fixed') || nargin < 2
    % take the Magic_Cups_Answers file and split into the conditions
    switch condition
        case 'both volatile'
            wins = tans.win_1(11:70);
            losses = tans.loss_1(11:70);
            p_win = win1_b1set;%use the manually-set contingencies
            p_loss = loss1_b1set;
        case 'win volatile'
            wins = tans.win_1(71:130);
            losses = tans.loss_1(71:130);
            p_win = win1_b2;
            p_loss = loss1_b2;
        case 'loss volatile'
            wins = tans.win_1(131:190);
            losses = tans.loss_1(131:190);
            p_win = win1_b3;
            p_loss = loss1_b3;
    end
    %flip the 1 and 0 from option one, creating option two
    %combine to form matrices of n_trial x n_options
    wins = [wins,~wins];
    losses = [losses,~losses];
elseif strcmp(randomisation,'random')
    % produce different task for each simulation
    switch condition
        case 'both volatile'
            winseq = win1seq_b1;
            lossseq = loss1seq_b1;
            p_win = win1_b1;
            p_loss = loss1_b1;
        case 'win volatile'
            winseq = win1seq_b2;
            lossseq = loss1seq_b2;
            p_win = win1_b2;
            p_loss = loss1_b2;
        case 'loss volatile'
            winseq = win1seq_b3;
            lossseq = loss1seq_b3;
            p_win = win1_b3;
            p_loss = loss1_b3;
    end
    
    %designate whether each trial is a win or loss, for option one
    wintask = gen_misce_task(winseq);
    losstask = gen_misce_task(lossseq);
    wins = wintask.outcome;
    losses = losstask.outcome;
end

%% record other task-relevant information
nt = length(wins);%record number of trials
xt = 1:1:nt;%array for 1:1:number of trials
xt = xt';%should be a column vector
points = wins - losses;%table for what participants would receive upon each choice
outcome_opt1 = [wins(:,1),losses(:,1)];%the outcomes for option 1 (Y in Browning code)
%% output 
task = struct('p_win',p_win,'p_loss',p_loss,'wins',wins,'losses',losses,'nt',nt,'xt',xt,'points',points,'outcome_opt1',outcome_opt1);
end