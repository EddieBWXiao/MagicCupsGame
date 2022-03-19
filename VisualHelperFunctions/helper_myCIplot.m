function helper_myCIplot(xin,yin)
% mean
ymean = mean(yin,2);

upb = 90;
lowb = 10;
% CI edges
yup = prctile(yin,upb,2);
ylow = prctile(yin,lowb,2);

%vis
plot(xin,ymean,'-')
hold on
patch([xin, fliplr(xin)], [ylow' fliplr(yup')],...
    'r', 'EdgeColor','none', 'FaceAlpha',0.2)
hold off

end