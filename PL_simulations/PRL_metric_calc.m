function [perser,regres] = PRL_metric_calc(s,tr)

%calculate errors made in probabilistic reversal learning task
%perseverative error & regress -- follow D'Cruz 2013 definitions

%s: struct for simulation
%tr: explicit indication of after which trial the reversal happened
%output: two errors

%Bowen Xiao
%01/02/2022

if nargin < 2
    tr = find(diff(s.task.p)~=0);%detect where contingency change occurred
    tr = tr+1;%the NEXT element is the start of the reversal
    if length(tr) ~=1 %just in case task was misspecified
        tr = tr(1);
        disp('Note: multiple reversalss in task structure')
    end
end

%% unpack virtual participant struct, only for trials post reversal
nt = length(s.task.p);%length of task, total    
choices = s.choices(tr:nt);
nchoice = length(choices);
%find the rich (better) option
if s.task.p(tr) > 0.5
    rich = 1;
else
    rich = 2;
end
%detect first choice of the rich option
switched = find(choices == rich);
switched = switched(1);
%mark all previous trials as perseverative
perser = length(choices(1:switched));
%mark all following trials choosing lean as regressive
regressed = choices(switched:nchoice) ~= rich;
regres = sum(regressed);
end