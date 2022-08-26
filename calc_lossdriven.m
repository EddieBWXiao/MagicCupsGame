function lossdriven = calc_lossdriven(actions,wins,losses)
%compute proportion of loss-driven choices (for IBLT)

%input: actions & all outcomes (wins & losses)
    %actions: array of 1 & 2 (ntrials x 1)
    %wins & losses: two arrays of ntrials x 2; col 1 for opt 1

%output: a number ~ the proportion of loss-driven choices

% credit: modified from code by Dr Margot Overman https://osf.io/av9pf/

nr_trials=length(wins);%find task length
both_trials=((losses(:,1) == 1 & wins(:,1) ==1) | (losses(:,2) == 1 & wins(:,2) ==1));%any trial where both happened
trial_both_shape1=(losses(:,1) == 1 & wins(:,1) == 1); %only when the win & loss outcome appeared together; other opt would be 0 & 0
trial_both_shape2=(losses(:,2) == 1 & wins(:,2) == 1);

% Count the number of loss-driven choices in subsequent trial
    % def: on next trial, chose the option where no loss appeared
count_lossdriven=0;
for i = 1:(nr_trials-1) % do not run for final trial of each block, as there will be no i+1 response
    if ((trial_both_shape1(i)==1 && actions(i+1)==2) || (trial_both_shape2(i)==1 && actions(i+1)==1))
        %important: does not care button_pressed at i
        %just whether participants were away from the loss side
        count_lossdriven=count_lossdriven+1;
    end
end

nboth = sum(both_trials(1:end-1));
lossdriven = count_lossdriven/nboth;
end