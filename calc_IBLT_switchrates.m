function [sr, srvec] = calc_IBLT_switchrates(actions,wins,losses)
%{
for each outcome combination in IBLT
compute the probability of switching afterwards

%input: actions & all outcomes (wins & losses)
    %actions: array of 1 & 2 (ntrials x 1)
    %wins & losses: two arrays of ntrials x 2; col 1 for opt 1
%}
%% create trial logical indices for outcome combinations

% find win-loss coincident trials
wonlost_opt1 = (wins(:,1) == 1 & losses(:,1)==1);%ntrials x 1 logical
wonlost_opt2 = (wins(:,2) == 1 & losses(:,2)==1);

% find neither win or loss trials
neither_opt1 = (wins(:,1) == 0 & losses(:,1)==0);
neither_opt2 = (wins(:,2) == 0 & losses(:,2)==0);
%actually, neither_opt2 == wonlost_opt1 etc... can use to check

% find +1 trials
won_opt1 = (wins(:,1) == 1 & losses(:,1)==0);
won_opt2 = (wins(:,2) == 1 & losses(:,2)==0);

% find -1 trials
lost_opt1 = (wins(:,1) == 0 & losses(:,1)==1);
lost_opt2 = (wins(:,2) == 0 & losses(:,2)==1);

%index trials on which participant received each outcome combo
wonlost = or(and(wonlost_opt1,actions == 1),and(wonlost_opt2,actions ==2));
neither = or(and(neither_opt1,actions == 1),and(neither_opt2,actions ==2));
won = or(and(won_opt1,actions == 1),and(won_opt2,actions ==2));
lost = or(and(lost_opt1,actions == 1),and(lost_opt2,actions ==2));

%find total number of trials in which each happened
    %end-1, since no stay or switch after final trial
n_wonlost = sum(wonlost(1:end-1));
n_won = sum(won(1:end-1));
n_lost = sum(lost(1:end-1));
n_neither = sum(neither(1:end-1));

%n_won - n_lost should sum to total task earning minus last trial
%sum of these four numbers should be trials_resp_made -1
%% check if switch occurred & compute switch rate

% switch: action different
switched = diff(actions)~=0;%1 if the NEXT trial is different

% find if switch occurred after each outcome combination
s_wonlost = (switched & wonlost(1:end-1));
s_won = (switched & won(1:end-1));
s_lost = (switched & lost(1:end-1));
s_neither = (switched & neither(1:end-1));

% convert to rate
sr.won = sum(s_won)/n_won;
sr.neither = sum(s_neither)/n_neither;
sr.wonlost = sum(s_wonlost)/n_wonlost;
sr.lost = sum(s_lost)/n_lost;

% output in a single vector, for barchart plot
srvec = [sr.won;sr.neither;sr.wonlost;sr.lost];
%same order as xticklab = {'win & no loss','no win & no loss','win & loss','no win & loss'};
end