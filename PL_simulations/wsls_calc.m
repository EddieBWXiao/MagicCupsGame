function [lsrate,wsrate] = wsls_calc(s)

%calculates win-stay and lose-shift rates of simulated participant
%for simple probabilistic learning task (2AFC, binary outcomes)

%input s: struct (output from _plsim
%output: lose-shift rate and win-stay rate

%Bowen Xiao
%28/01/2022

%% unpack virtual participant struct
nt = length(s.task.p);%length of task
winloss = s.feedback.score;%1 is succss, 0 is failure
choices = s.choices;
%% calculate WSLS
%only consider trial 2 to end
%win-stay: did not change option after trial success
%lose-shift: switch option after no success
wintrials = winloss == 1;
losstrials = winloss == 0;
nwin = sum(wintrials);
nloss = sum(losstrials);
isws = nan(1,nt);%whether a trial is WS or not
isls = nan(1,nt);%tab LS trials

%iterate, checking what happens on the next trial post win or loss
for i = 1:length(wintrials)-1
    if wintrials(i) == 1
        if choices(i+1) == choices(i)%stayed
            isws(i+1) = 1;
        end       
    end
    if losstrials(i) == 1
        if choices(i+1) ~= choices(i)%shifted
            isls(i+1) = 1;
        end       
    end
end

%calculate rate, divide by total; need omitnan!
wsrate = sum(isws,'omitnan')/nwin;
lsrate = sum(isls,'omitnan')/nloss;

end