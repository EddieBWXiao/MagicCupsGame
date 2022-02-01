function response_model_illu

%plots to illustrate inverse temperature and lapse rate

xt = -5:0.05:5;
betas = [0.5,1,4,20]';
lapses = [0,0.1,0.5,1]';

%logistic function:
figure;
hold on 
for i = 1:length(betas)
sf = softmaxf(xt,betas(i));
plot(xt,sf,'-','LineWidth',2.5)
end
hold off
mylegend = [repmat('beta = ',length(betas),1),num2str(betas)];
legend(mylegend,'Location','Southeast','FontSize',12);
xlabel('V_t^A - V_t^B','FontSize',16)
ylabel('Probability of choice','FontSize',16)
title('Role of beta (inverse temperature)','FontSize',16)

figure;
hold on 
for i = 1:length(lapses)
sf = lapsef(xt,lapses(i));
plot(xt,sf,'-','LineWidth',2.5)
end
hold off
mylegend = [repmat('lapse rate = ',length(lapses),1),num2str(lapses)];
legend(mylegend,'Location','Southeast','FontSize',12);
xlabel('V_t^A - V_t^B','FontSize',16)
ylabel('Probability of choice','FontSize',16)
title('Influence of lapse rate; beta = 4','FontSize',16)



end
function y = softmaxf(x,beta)
y = 1./(1+exp(-beta*x));
end
function y = lapsef(x,lapse)
y = (1-lapse)./(1+exp(-4*x))+lapse/2;
end