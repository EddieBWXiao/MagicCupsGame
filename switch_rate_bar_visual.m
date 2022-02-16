function switch_rate_bar_visual(bothvol, winvol,lossvol)

%visualises switch rate with bar chart
%input: the output vectors from calc_IBLT_switchrates

x = 1:4;
y = [bothvol,winvol,lossvol];%ensure each column being a condition, with all four calcs 
bar(x,y)
err = y/10;

hold on
ngroups = size(y, 1);
nbars = size(y, 2);
% Calculating the width for each bar group
groupwidth = min(0.8, nbars/(nbars + 1.5));%somehow this gets the right width...
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    er = errorbar(x, y(:,i), err(:,i));
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
end

hold off
xticklab = {'win & no loss','no win & no loss','win & loss','no win & loss'};
set(gca,'XTickLabel',xticklab)
ylabel('switch rate')
xlabel('outcome configuration')
legend('both-volatie','win-volatile','loss-volatile')
end