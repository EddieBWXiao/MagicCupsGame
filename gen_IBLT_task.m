function task = gen_IBLT_task(condition,randomisation)

%creates struct with task information
%allows different versions (60 trials, 80 trials, fixed or random) 
%& conditions (bothvol, winvol etc.)
%provides input to all _sim functions

if nargin<2
    randomisation = 'fixed';
end


%% main/default: Magic Cups Game, 60 trials per condition

%% load the task structure, from file in same directory, or from input
tans = readtable('Magic_Cups_Answers.csv');%the task structure information from Gorilla spreadshet

%% outline the probabilistic associations
win1_b1 = [repmat(0.2,12,1);repmat(0.8,13,1);repmat(0.2,17,1);repmat(0.8,18,1)];
win1_b2 = [repmat(0.8,15,1);repmat(0.2,15,1);repmat(0.8,15,1);repmat(0.2,15,1)];
win1_b3 = repmat(0.5,60,1);
%win1 = [win1_b1;win1_b2;win1_b3];
loss1_b1 = [repmat(0.8,18,1);repmat(0.2,17,1);repmat(0.8,13,1);repmat(0.2,12,1);];
loss1_b2 = repmat(0.5,60,1);
loss1_b3 = [repmat(0.8,15,1);repmat(0.2,15,1);repmat(0.8,15,1);repmat(0.2,15,1)];%b3 = loss volatile
%loss1 = [loss1_b1;loss1_b2;loss1_b3];

%% set task condition & generate feedback
if strcmp(randomisation,'fixed') || nargin < 2
    switch condition
        case 'both volatile'
            wins = tans.win_1(11:70);
            losses = tans.loss_1(11:70);
            p_win = win1_b1;
            p_loss = loss1_b1;
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
elseif strcmp(randomisation,'random')
    % produce different task for each simulation
    switch condition
        case 'both volatile'
            p_win = win1_b1;
            p_loss = loss1_b1;
        case 'win volatile'
            p_win = win1_b2;
            p_loss = loss1_b2;
        case 'loss volatile'
            p_win = win1_b3;
            p_loss = loss1_b3;
    end
    wins = nan(size(p_win));
    losses = nan(size(p_loss));
    %designate whether each trial is a win or loss, for option one
    for t = 1:length(p_win)
        if rand(1)< p_win(t)
        wins(t) = 1;
        else
        wins(t) = 0;
        end
    end
    for t = 1:length(p_loss)
        if rand(1)< p_loss(t)
            losses(t) = 1;
        else
            losses(t) = 0;
        end
    end
end

%% record other task-relevant information
nt = length(wins);%record number of trials
xt = 1:1:nt;%array for 1:1:number of trials
xt = xt';%should be a column vector
%flip the 1 and 0 from option one, creating option two
%combine to form matrices of n_trial x n_options
wins = [wins,~wins];
losses = [losses,~losses];
points = wins - losses;%table for what participants would receive upon each choice

%% output 
task = struct('p_win',p_win,'p_loss',p_loss,'wins',wins,'losses',losses,'nt',nt,'xt',xt,'points',points);

end