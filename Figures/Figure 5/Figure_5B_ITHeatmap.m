%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','IT');
infoFile = '11-25-NeuronInfo.mat';

%% Analysis Parameters.
% n*1 cell with each cell of size 3x1. first cell is areas that will be joined,
% second cell is hemspihere and third used name.
areaList = {...
    {{'root'},{'bi'},  {'Total'}},...
    {{'Isocortex'},{'bi'},  {'Cortex'}},...
    {{'Isocortex'},{'ipsi'},  {'Cortex_{ipsi}'}},...    
    {{'Isocortex'},{'contra'},  {'Cortex_{contra}'}},...      
    {{'MO'},{'bi'},  {'Motor Cortex'}},...       
    {{'FRP','SS','GU','VISC','AUD','VIS',...
    'ACA','PL','ILA','ORB','AI','RSP',...
    'PTLp','TEa','PERI','ECT'},{'bi'},  {'Other Cortex'}},...         
    {{'STR'},{'bi'},  {'Striatum'}},...   
    {{'STR'},{'ipsi'},  {'Striatum_{ipsi}'}},...     
    {{'STR'},{'contra'},  {'Striatum_{contra}'}},...       
    };
%
property =           {'totalLength'};   % Property used for analysis.
colorLim =           [4,8];             % Color logscaling of heatmap.
leafOrderCriteria = 'adjacent';         % Adjacent or group.
metric =            'euclidean';        % Metric for clustering.
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
layers = {'L2/3','L5','L6'};

%% Go through layers.
for iLayer = 1:3
    %% Select layer.
    cLayer = layers{iLayer};
    ind = strcmpi({neuronInfo.layer},cLayer);
    nNeurons = sum(ind);
    
    %% Hierarchical clustering.
    scores = info.values(ind,:);
    Z = linkage(scores, clustMethod, metric);

    %% Order by similarity.
    dist = squareform(pdist(scores, metric));
    leafOrder = optimalleaforder(Z, dist, 'Criteria', leafOrderCriteria);

    %% Generate heatmap.
    % log score.
    values = log2(scores(leafOrder,:)./1000);
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

    %% Plot.
    hFig = figure('Color',[1,1,1]);
    hAx = axes;
    Y = info.area;
    imshow(I); hold on
    hAx.Visible = 'on';
    hAx.XLim =[0.5,size(values,1)+0.5];
    hAx.YLim =[0.5,size(values,2)+0.5];
    hAx.YDir = 'reverse';
    hAx.XAxisLocation = 'top';
    hAx.YTick = [1:hAx.YLim(2)];
    hAx.XTick = [1:hAx.XLim(2)];
    hAx.YTickLabel = Y;
    hAx.XAxis.Visible = 'off';
    hAx.TickDir = 'out';
    hAx.DataAspectRatioMode = 'auto';
    hAx.PlotBoxAspectRatio = [1.75,1,1];
    hFig.Color = [1,1,1];
    xtickangle(45);
    hAx.Units = 'pixels';
    hAx.PlotBoxAspectRatioMode = 'auto';
    hAx.OuterPosition(1) = 100;
    hFig.Renderer = 'painter';
    hFig.Position=[680,540,1080,580];
    hAx.OuterPosition(3:4) = [7*nNeurons,400];
    hAx.Units = 'normalized';
    title(sprintf('Layer %s',cLayer));
    
    %% Plot dendrogram.
    hFig = figure();
    hAx = axes();
    hD = dendrogram(Z,0,'Reorder',leafOrder);
    [hD.Color] = deal([0,0,0]);
    hAx.TickDir = 'out';
    hAx.XTickLabel = {};
    hAx.Title.String = cLayer;
    
end