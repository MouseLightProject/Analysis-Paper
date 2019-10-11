%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','PT');
infoFile = '10-30-NeuronInfo.mat';

%% Analysis Parameters.
% n*1 cell with each cell of size 3x1. first cell is areas that will be joined,
% second cell is hemspihere and third used name.
areaList = {...
    {{'PF'},{'bi'},  {'PF'}},...    
    {{'MD'},{'bi'},  {'MD'}},...    
    {{'VM'},{'bi'},  {'VM'}},...  
    {{'PCN'},{'bi'},  {'PCN'}},...      
    {{'VAL'},{'bi'},  {'VAL'}},...      
    {{'PO'},{'bi'},  {'PO'}},...   
    };
property =           {'nEndPoints','nBranches'};    % Property used for analysis.
colorLim =          [0,45];                         % Color scaling of heatmap.
leafOrderCriteria = 'adjacent';                     % Adjacent or group.
metric =            'spearman';                     % Metric for clustering.
clustMethod =       'average';                      % Clustering method
groupOrder = [3,1,4,2];

%% Memoize functions (for efficiency in recalculations).
if ~exist('sessionFcn'),  sessionFcn= memoize(@(x) load(x)); end
if ~exist('anatomyFcn'),  anatomyFcn = memoize(@(x,y) neuronInfoAllenRegion(x,y)); end
anatomyFcn.CacheSize = 1000;

%% Load neuron info.
fprintf('\nLoading neuron Info..');
neuronInfo = sessionFcn(fullfile(dataFolder,infoFile));
neuronInfo = neuronInfo.neuronInfo;
nNeurons = numel(neuronInfo);
fprintf('\nDone!\n');

%% Collect anatomy info.
info = collectAnaData([neuronInfo.morphology],areaList,...
    'Properties',property);

%% Hierarchical clustering.
scores = info.values;
Z = linkage(zscore(scores), clustMethod, metric);

%% Order by similarity.
dist = squareform(pdist(scores, metric));
leafOrder = optimalleaforder(Z, dist, 'Criteria', leafOrderCriteria);
T = cluster(Z,'cutoff',1,'criterion','distance');
temp = [];
for i=1:numel(groupOrder)
    neuronsInGroup = find(T==groupOrder(i));
    [~,ind]= ismember(neuronsInGroup,leafOrder);
    [~,ind] = sort(ind);
    temp = [temp;neuronsInGroup(ind)];
    for j=1:numel(neuronsInGroup)
        neuronInfo(neuronsInGroup(j)).group = i;
    end
end
leafOrder = temp;

%% Plot clustering result.
hFig = figure('Units','points');
hAx = axes('Units','points');
[hD] = dendrogram(Z,size(Z,1)+1,...
        'Orientation','top',...
        'Reorder',leafOrder);
[hD.Color] = deal([0,0,0]);
hAx.XAxis.Visible = 'off';
hAx.YAxis.Visible = 'off';
hFig.Color = [1,1,1];
ylim([0,1.5]);
% size.
hAx.Position(3:4) = [192.02,13.615];
hAx.OuterPosition(1:2) = [2,3];
hFig.Position(3:4) = hAx.OuterPosition(3:4);
hFig.Renderer = 'painter';
hAx.Units = 'normalized'; hFig.Units = 'normalized';

%% Plot heatmap.
% generate heatmap image.
values = scores(leafOrder,:);
values(values<0)=0;
I = mat2gray(values',colorLim);
I = gray2ind(I,1024);
cMap = parula(1024); 
I = ind2rgb(I,cMap);
for i=1:3
    temp = I(:,:,i);
    temp(values'==0)=0;
    I(:,:,i)= temp;
end
% plot.
hFig = figure('Units','points','Color',[1,1,1]);
hAx = axes(...
    'Units','points');
hFig.Color = [1,1,1];
Y = info.area;
imshow(I);
hold on
hAx.DataAspectRatio = [200,85,1];
hAx.Position(3:4) = [200,85];
hAx.YLim = [0.5,numel(Y)+0.5];
hAx.YTick = [1:numel(Y)];
hAx.YAxis.Visible = 'on';
hAx.YColor = [0,0,0];
hAx.YAxis.FontName = 'Arial';
hAx.YAxis.FontSize = 8;
hAx.YTickLabel = Y;
hAx.OuterPosition(1:2) = [1,5];
hFig.Position(3:4) = hAx.OuterPosition(3:4);
hAx.Units = 'normalized'; hFig.Units = 'normalized';