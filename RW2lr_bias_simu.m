function simued = RW2lr_bias_simu(condition,graph,params,mytask)
%{

% produce simulated bebehaviour for one participant
% model: Rescola-Wagner, 2lr = independent learning from wins & losses
% contains bias parameter (as bias approaches 1, more prone to choose cup 1, despite negative net value for cup 1; 0 no bias)

input:
% conditions: string; both volatile, win volatile, or loss volatile
% mytask: task structure, in win_1 loss_1 table format;
    -should have 190 rows and at least two columns
    -can be omitted, after which the default .csv file would be used
% params: numeric array of all parameteters (four of them)
% graph: logical; plot or not
    -true to display graphics
    -must set to "false" when running multiple simulations

output:
struct for simulated behaviour

written by Bowen Xiao
22/Nov/2021

references:
Pulcu and Browning (2017)
Overman et al. (2021)
Hanneke RL tutorial
%}


%% set up the task
    %% load the task structure, from file in same directory, or from input
    if nargin < 6
        tans = readtable('Magic_Cups_Answers.csv');%the task structure information from Gorilla spreadshet
    else
        tans = mytask;
    end
    
    %outline the probabilistic associations
    win1_b1 = [repmat(0.2,12,1);repmat(0.8,13,1);repmat(0.2,17,1);repmat(0.8,18,1)];
    win1_b2 = [repmat(0.8,15,1);repmat(0.2,15,1);repmat(0.8,15,1);repmat(0.2,15,1)];
    win1_b3 = repmat(0.5,60,1);
    %win1 = [win1_b1;win1_b2;win1_b3];
    loss1_b1 = [repmat(0.8,18,1);repmat(0.2,17,1);repmat(0.8,13,1);repmat(0.2,12,1);];
    loss1_b2 = repmat(0.5,60,1);
    loss1_b3 = [repmat(0.8,15,1);repmat(0.2,15,1);repmat(0.8,15,1);repmat(0.2,15,1)];%b3 = loss volatile
    %loss1 = [loss1_b1;loss1_b2;loss1_b3];
    
    %% determine task condition
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
    
    %% other task-relevant information
    
    nt = length(wins);%record number of trials
    xt = 1:1:nt;%array for 1:1:number of trials
    xt = xt';%should be a column vector

    %flip the 1 and 0 from option one, creating option two
    %combine to form matrices of n_trial x n_options
    wins = [wins,~wins];
    losses = [losses,~losses];

    points = wins - losses;%table for what participants would receive upon each choice

%% apply model (for belief update)
    %% initialise for trial information to be stored 
    choice = nan(nt,1);%one choice made every trial
    
    %follow format: n_trials x n_choices
    WPE = nan(size(wins));%updates expectation for wins, for each option
    LPE = nan(size(losses));%updates expectation for losses
    v_r = nan(size(wins));%value learnt from wins (rewards)
    v_p =nan(size(losses));%value learnt from losses (punishments)
    pchoice = nan(size(wins));

    %% set initial parameters (fixed, not free)
    %create default options for fewer input
    initial_reward_belief = [0.5,0.5];
    initial_punishment_belief = [0.5,0.5];
    
    %% get parameter values (code different for each model)
    alphas = params(1:2);
    beta = params(3);
    bias = params(4);
    alpha_r = alphas(1);
    alpha_p = alphas(2);
    params = struct('alpha_r',alpha_r,'alpha_p',alpha_p,'beta',beta,'bias',bias);
    model_title = sprintf('rew lr = %.3f , pun lr = %.3f,beta = %d,added-bias = %d',alpha_r,alpha_p, beta,bias);
    
    %% loop through trials
    for t=1:nt
        %% the model is specified below:
         %initial expectations
        if t == 1
            v_r(t,:) = initial_reward_belief;
            v_p(t,:) = initial_punishment_belief;
        end
        
        %% choice/response model: decision based on knowledge from previous trials (instrumental)
        win_EV_opt1 = v_r(t,1);%only consider option 1
        loss_EV_opt1 = v_p(t,1);
        pchoice_opt1 = (1+exp(-beta*(win_EV_opt1-loss_EV_opt1+bias))).^-1;%not comparing between two options; just option one alone
        pchoice_opt2 = 1-pchoice_opt1;%either choose opt1, or opt2
        pchoice(t,:) = [pchoice_opt1,pchoice_opt2];        
        
        %% learning
        %PE: observe both options, update both options
        WPE(t,:) = wins(t,:) - v_r(t,:);%for first trial, note change from baseline
        LPE(t,:) = losses(t,:) - v_p(t,:);

        %update expectation on future trial
    	v_r(t+1,:) = v_r(t,:) + alpha_r*WPE(t,:);
        v_p(t+1,:) = v_p(t,:) + alpha_p*LPE(t,:);
 
        %remove extra trial predictions
        if t == nt
            v_r(t+1,:) = [];
            v_p(t+1,:) = [];
            %though, store them in another place:
            final_v_r = v_r(t,:) + alpha_r*WPE(t,:);
            final_v_p = v_p(t,:) + alpha_p*LPE(t,:);
        end
        
        %% produce choices according to response model output
        %choice behaviour... credits: written by Hanneke den Ouden 2015 <h.denouden@gmail.com>
        % Do a weighted coinflip to make a choice: choose stim 1 if random
        % number is in the [0 p(1)] interval, and 2 otherwise
        if rand(1) < pchoice(t,1) %bigger the pchoice, more likely to choose "1"
            choice(t) = 1;%
        else
            choice(t) = 2;
        end
    end

%% further documentation of behaviour    

%note outcomes experienced by participant (i.e., if trial won and/or lost)
opt1_ind = choice == 1;%logical indices for trials where option 1 was chosen
opt2_ind = choice == 2;%logical indices for trials where option 2 was chosen
won(opt1_ind) = wins(opt1_ind,1);%chose opt 1, won in opt 1
won(opt2_ind) = wins(opt2_ind,2);%chose opt 2, won in opt 2
lost(opt1_ind) = losses(opt1_ind,1);
lost(opt2_ind) = losses(opt2_ind,2);

%note whether participants chose option 1 or not
chose1 = double(opt1_ind);
chose1(~opt1_ind) = NaN;

%net received points on each trial (no *15, just ±1) 
score = won - lost;%(three possibilities: 1, 0, -1)
total_value = v_r - v_p;

%matrix for outcomes from both outcome types
winloss = [won;lost];% n_trials x 2 (won or loss, colour-free)
%↑column 1 - column 2 would get feedback.score

combos = [wins,losses]; %4 x n_trials, for all combo; basically the learnt task "answers"
feedback.outcomes = combos;%stores all feedback received (should be identical to mytask)
feedback.scores = score;%stores value they received on each trial (no *15)
feedback.winloss = winloss;%stores how much won & lost, 

%% output (store the "participant data")

%record task structure & parameters & else
opt1 = [wins(:,1),losses(:,1)];%equivalent to Overman script Information; outcome from opt 1
%check: opt1(:,1)-opt1(:,2) == points(:,refc);
chose1_vis = (2-choice); %choice coded in 1 and 2; become 1 and 0
task = struct('p_win',p_win,'p_loss',p_loss,'wins',wins,'losses',losses,'opt1',opt1);

PE.WPE = WPE;
PE.LPE = LPE;
%experience: flips between choices, not learning about particular one
%this is important for learning from rew/pun (option-free)
PE.WPEexperienced(opt1_ind) = WPE(opt1_ind,1);
PE.WPEexperienced(opt2_ind) = WPE(opt2_ind,2);
PE.LPEexperienced(opt1_ind) = LPE(opt1_ind,1);
PE.LPEexperienced(opt2_ind) = LPE(opt2_ind,2);
furtherinfo = struct('final_v_r',final_v_r,'final_v_p',final_v_p,'xt',xt);

%output
simued = struct('params',params,'v_r',v_r,'v_p',v_p,'pchoice',pchoice,'choices',choice,'chose1',chose1,'feedback',feedback,'task',task,...
    'PE',PE,'furtherinfo',furtherinfo);

%% plot simulation results

refc = 1;%use option 1 to plot

if graph
    close all
    % visualise task structure
    subplot(2,2,1)
    plot(xt,p_win);
    hold on
    plot(xt,p_loss);
    plot(xt,wins(:,refc),'gx');
    plot(xt,losses(:,refc),'ro');
    hold off
    legend('p(win|choose opt 1)','p(loss|choose opt 1)','wins-if-chosen','losses-if-chosen')
    xlabel('trial number')
    ylabel('probability')
    title('Visualisation of task structure')

    subplot(2,2,2)
    plot(xt,p_win,'b-');
    hold on
    plot(xt,p_loss,'r-');
    plot(xt,v_r(:,refc),'--');
    plot(xt,v_p(:,refc),'--');
    plot(xt, pchoice(:,refc),'-','LineWidth',3);
    
    plot(xt,chose1_vis,'.');

    hold off
    legend('p(win|choose opt 1)','p(loss|choose opt 1)','reward expectation for opt 1','punishment expectation for opt 1','p(choose opt 1)','chosen option 1')
    xlabel('trials')
    ylabel('probability')
    title('Value expectations and Choices')
    
    subplot(2,2,3)
    plot(xt,points(:,refc),'.');%points received if constantly choosing option 1
    hold on
    plot(xt,score,'.');
    plot(xt,p_win-p_loss,'-')%top probability of receiving reward
    plot(xt,total_value(:,refc),'-.')%total reward expectations
    hold off
    legend('points from opt 1','net score received','p(net gain | opt 1)','expected total value')
    xlabel('trials')
    ylabel('probability or value')
    title('Possible gains from opt 1')
    
    subplot(2,2,4)
    plot(xt,cumsum(score));
    xlabel('trials')
    ylabel('score')
    title('Net gain')
    
    sgtitle(model_title)


    % a single summary graph
    figure;
    plot(xt,p_win,'b-');
    hold on
    plot(xt,p_loss,'r-');
    plot(xt,v_r(:,refc),'--');
    plot(xt,v_p(:,refc),'--');
    plot(xt,pchoice(:,refc),'-','LineWidth',3);
    plot(xt,chose1_vis,'*');
    hold off
    legend('p(win|choose opt 1)','p(loss|choose opt 1)','reward expectation for opt 1','punishment expectation for opt 1','p(choose option 1)','chosen option 1')
    xlabel('trials')
    ylabel('probability')
    title({'summarising plot',model_title})    
end


end