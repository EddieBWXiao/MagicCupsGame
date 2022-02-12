function acc = accuracy_calc(choices,conting)

%choices: ntrials x 1, vector of 1 & 2 for which option chosen
%conting: ntrials x 1, denote trial-wise probability of producing the good outcome

%ensure input vectors have same size
if length(choices)~= length(conting)
    disp('Warning: missing trials')
end
if size(choices,2) ~= size(conting,2)
    choices = choices';
end

tasklength = length(conting);

rich = conting > 0.5;%"good" options
chose1 = choices == 1;%find those that chose 1
optim = rich==chose1;%logical for if rich was chosen
    %choose 1 when 1 good, no choose 1 when 1 not good
acc = sum(optim,'all')/tasklength;
end