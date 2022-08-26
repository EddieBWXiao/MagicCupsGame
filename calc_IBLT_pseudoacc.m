function [net,alles] = calc_IBLT_pseudoacc(actions,block)

% using the contingency
% check if the choice follows the "more lucrative" side

%IMPORTANT: actions must only have 60 elements; can deal with NaN
% actions: 1 or 2

%output: 
%net: proportion of "accurate" choices
%alles: 1x8 vector for tally on if the "better" option was chosen

%segment into seg1~4
seg1 = actions(1:15);
seg2 = actions(15:30);
seg3 = actions(31:45);
seg4 = actions(46:60);

switch block
    case 'win-volatile'
        alles(1) = sum(seg1==1);
        alles(2) = sum(seg2==2);
        alles(3) = sum(seg3==1);
        alles(4) = sum(seg4==2);
        net = sum(alles)/60;
    case 'loss-volatile'
        alles(1) = sum(seg1==2);
        alles(2) = sum(seg2==1);
        alles(3) = sum(seg3==2);
        alles(4) = sum(seg4==1);
        net = sum(alles)/60;
    case 'both-volatile'
        %this is the tricky bit, since...
        %win1_revs = [14;14;16;16];
        %loss1_revs = [18;18;12;12];
        %hence... unambiguously, should have:
            %seg1 = 1~14
            %seg2 = 18~28
            %seg3 = 36~44
            %seg4 = 52~60
        seg1s = actions(1:14);
        seg2s = actions(18:28);
        seg3s = actions(36:44);
        seg4s = actions(52:60);
        alles(1) = sum(seg1s == 2);
        alles(2) = sum(seg2s == 1);
        alles(3) = sum(seg3s == 2);
        alles(4) = sum(seg4s == 1);
        net = sum(alles)/(length([1:14 18:28 36:44 52:60]));
end

end