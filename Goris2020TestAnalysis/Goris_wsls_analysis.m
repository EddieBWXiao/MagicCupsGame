function Goris_wsls_analysis

%calculate win-stay and lose-shift rates per block

    %% load data & prepare
    d = load('GorisParticipantsMini.mat');
    vnam = fieldnames(d);
    d = d.(vnam{1});

    nsub = length(d);%num subjects
    
    %preallocate
    subj = cell(nsub,1);
    loseshift_sl = nan(nsub,1);
    loseshift_sh = nan(nsub,1);
    loseshift_v = nan(nsub,1);
    winstay_sl = nan(nsub,1);
    winstay_sh = nan(nsub,1);
    winstay_v = nan(nsub,1);

    %% the loop
    for i = 1:nsub
        %get participant label
        subj{i} = d{i,1};
        %table for all responses
        t = d{i,2};

        %% fit through all block at once
        actions = t.actions;
        outcomes = t.outcomes;
        condition = t.Condition;
        
        [loseshift_sl(i),winstay_sl(i)] = wsls_calc(actions(condition==1),outcomes(condition==1));
        [loseshift_sh(i),winstay_sh(i)] = wsls_calc(actions(condition==2),outcomes(condition==2));
        [loseshift_v(i),winstay_v(i)] = wsls_calc(actions(condition==3),outcomes(condition==3));

    end
    %% output
    calculated = table(subj,loseshift_sl,loseshift_sh,loseshift_v,winstay_sl,winstay_sh,winstay_v);
    writetable(calculated,'Goris_wsls.csv')
    
end