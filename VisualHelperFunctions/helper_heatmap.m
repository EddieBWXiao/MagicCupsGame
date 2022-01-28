function outfig = helper_heatmap(grid,rowv,colv,yspace,xspace,specs)

%produce customised heatmap
%good for visualising search across parameter space
%can only work with linear, natural log or logit scales

%grid: a matrix (e.g., learning rate at different parameter combos)
%rowv: vector, parameter values used for each row (i); y axis
%colv: vector, param vals for each column (j)
%specs: other issues, e.g., number of ticks
%x or yspace: linear or log or logit


%% preparations for input

if nargin<4
    %default
    nxticks = 11;
    nyticks = 11;
    xspace = 'linear';
    yspace = 'linear';
elseif nargin <6
    nxticks = 11;
    nyticks = 11;
else
    nxticks = specs(1);
    nyticks = specs(2);
    colormin = specs(3);
    colormax = specs(4);
end

%create heatmap content & scale
imagesc(grid);
colorbar

%% change x and y axis
%placement of tick markers
xticks = linspace(1, size(grid, 2), nxticks);%size(~,2), because columns
yticks = linspace(1, size(grid, 1), nyticks);
%compute content of tick markers (the scale displayed)
myxlab = makeaxesscale(colv,nxticks,xspace);
myylab = makeaxesscale(rowv,nyticks,yspace);
set(gca, 'XTick', xticks, 'XTickLabel', myxlab)
set(gca, 'YTick', yticks, 'YTickLabel', myylab)

%% control the colour scale
%caxis: set to same range for all comparable simulations
if nargin >5
    caxis([colormin,colormax])
end

outfig = gcf;

end
function axlab = makeaxesscale(vec,nticks,space)
%creates axis scale
%vec: the vector of parameter values on axes
%nticks: number of ticks
%space: the space, lin, logit etc.

nsigfig = 2;%rounding also applied
logitf = @(x) log(x./(1-x));

%quick check
if min(vec)~= vec(1) || max(vec) ~= vec(end)
    disp('error: input vec not in order')
end

if strcmp(space,'linear')
   axlab = round(linspace(min(vec),max(vec),nticks),nsigfig,'significant');%linear scale
elseif strcmp(space,'log') || strcmp(space,'ln') || strcmp(space,'naturallog')
   axlab = round(logspace(log(min(vec))/log(10),log(max(vec))/log(10),nticks),nsigfig,'significant');
   %conversion: log(x)/log(base) = log_base(x); logspace = 10^, converts back to x
elseif strcmp(space,'logit')
   begin = vec(1);
   fin = vec(end);
   logitspace = logitf(begin):(logitf(fin) - logitf(begin))/(nticks-1):logitf(fin);%eq interval in logit space
   axisinlogitspace = 1./1+exp(-logitspace);%go back to native space
   axlab = round(axisinlogitspace,nsigfig,'significant');
end
end
