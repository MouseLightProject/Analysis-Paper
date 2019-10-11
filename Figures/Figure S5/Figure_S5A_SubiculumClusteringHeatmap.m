%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Subiculum');
infoFile = '04-24-NeuronInfo.mat';
colorLim = [0,20];  
%% Analysis Parameters.
% n*1 cell with each cell of size 3x1. first cell is areas that will be joined,
% second cell is hemspihere and third used name.
areaList = {...
    {{'ACB'},{'bi'},  {'NA'}},...   
    {{'PL','ILA'},{'bi'},  {'PFC'}},...  
    {{'ENTl'},{'bi'},  {'LEC'}},...  
    {{'RSP'},{'bi'},  {'RSC'}},...  
    {{'ENTm'},{'bi'},  {'MEC'}},...  
    {{'VMH'},{'bi'},  {'VHN'}},...  
    {{'LS'},{'bi'},  {'Septum'}},...  
    {{'NDB'},{'bi'},  {'NDB'}},...  
    {{'PAG'},{'bi'},  {'PAG'}},...  
    {{'ECT'},{'bi'},  {'Ecto'}},...  
    {{'SUB','PRE','PAR','POST'},{'bi'},  {'SUB_Pre,Para,Post'}},...  
    {{'TH'},{'bi'},  {'Thal'}},...  
    {{'HY'},{'bi'},  {'Hypothalamus'}},...  
    };
%
property =           {'totalLength'};   % Property used for analysis.
leafOrderCriteria = 'adjacent';         % Adjacent or group.
metric =            'spearman';         % Metric for clustering.
clustMethod =       'average';          % Clustering method

%formatting group order
cutoffValue = 0.6;
groupOrder = [4,3,1,5,6,2];
reverseGroup = 5;

%% Memoize functions (for efficiency in recalculations).
if ~exist('sessionFcn'),  sessionFcn= memoize(@(x) load(x)); end

%% Load neuron info.
fprintf('\nLoading neuron Info..');
neuronInfo = sessionFcn(fullfile(dataFolder,infoFile));
neuronInfo = neuronInfo.neuronInfo;
fprintf('\nDone!\n');

%% Collect anatomy info.
info = collectAnaData([neuronInfo.morphology],areaList,...
    'Properties',property);

%% Hierarchical clustering.
scores = zscore(info.values);
% scores = info.values;
Z = linkage(scores, clustMethod, metric);

%% Order by similarity.
dist = squareform(pdist(scores, metric));
dist(isnan(dist)) = 0;
leafOrder = optimalleaforder(Z, dist, 'Criteria', leafOrderCriteria);

%% Shuffle group results.
if (~isempty(groupOrder))
    T = cluster(Z,'cutoff',cutoffValue,'criterion','distance');
    temp = [];
    for i=1:numel(groupOrder)
        neuronsInGroup = find(T==groupOrder(i));
        [~,ind]= ismember(neuronsInGroup,leafOrder);
        [~,ind] = sort(ind);
        if ismember(groupOrder(i),reverseGroup), ind = flip(ind); end
        temp = [temp;neuronsInGroup(ind)];
    end
    leafOrder = temp;
end


%% Generate heatmap.
% order score.
values = info.values(leafOrder,:)/1000;
% color code.
I = mat2gray(values',colorLim);
I = gray2ind(I,1024);
cMap = parula(1024); 
I = ind2rgb(I,cMap);
for i=1:3
    temp = I(:,:,i);
    temp(values'<=0)=0;
    I(:,:,i)= temp;
end

%% Add group identity color.
[groups,~,groupInd] = unique({neuronInfo.group});
cMapGroup = flipud([237,28,36;27,117,188;57,181,74;236,0,140]./255);
groupColor = cMapGroup(groupInd,:);
groupColor = groupColor(leafOrder,:);
for i=1:size(I,2)
    I(numel(areaList)+1,i,:) = groupColor(i,:);
end

% Plot.
hFig = figure('Color',[1,1,1]);
hAx = axes;
Y = info.area;
imshow(I,'InitialMagnification',1200); hold on
hAx.Visible = 'on';
hAx.XLim =[0.5,size(values,1)+0.5];
hAx.YLim =[0.5,size(values,2)+1.5];
hAx.YDir = 'reverse';
hAx.XAxisLocation = 'top';
hAx.YTick = [1:hAx.YLim(2)];
hAx.XTick = [1:hAx.XLim(2)];
hAx.YTickLabel = [Y;{'Manual'}];
hAx.XAxis.Visible = 'off';
hAx.TickDir = 'out';
ytickangle(45);
hAx.DataAspectRatio = [3,1,1];
hFig.Color = [1,1,1];
hAx.Box = 'off';
hFig.Renderer = 'painter';

% Plot dendrogram.
hFig = figure();
hAx = axes();
hD = dendrogram(Z,0,'Reorder',leafOrder,'ColorThreshold',0.7);
% [hD.Color] = deal([0,0,0]);
hAx.TickDir = 'out';
hAx.XTickLabel = {};
