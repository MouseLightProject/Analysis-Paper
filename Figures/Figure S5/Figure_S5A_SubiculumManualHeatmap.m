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
groupOrder = {'Proximal','Intermediate','Local','Distal'};
property =           {'totalLength'};   % Property used for analysis.
clustMethod =       'average';          % Clustering method

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

%% Sort by in-group similarity
leafOrder = [];
for iGroup = 1:numel(groupOrder)
    ind = find(strcmpi({neuronInfo.group},groupOrder{iGroup}));
    scores = info.values(ind,:);
    % Order by similarity.
    dist = squareform(pdist(scores, 'correlation'));
    dist(isnan(dist)) = 0;
    Z = linkage(scores, 'average', 'correlation');
    leafOrder = [leafOrder,ind(optimalleaforder(Z, dist, 'Criteria', 'adjacent'))];    
end

%% Generate heatmap.
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
