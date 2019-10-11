%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','PT');
infoFile = '10-31-Cluster1.mat';

%% Analysis Parameters.
areas =             {'GPe','NPC'};
property =          {'length'}; % Property used for analysis.
cHemi =             'bi';                       % Hemisphere (ipsi/bi/contra).
compGroup =         {1,[2,3]};                  % Groups to compare.
groupColors =       [237,28,36;27,117,188]./255;
groupLabels =       {'PF','Other'};

%% Memoize functions (for efficiency in recalculations).
if ~exist('sessionFcn'),  sessionFcn= memoize(@(x) load(x)); end
if ~exist('anatomyFcn'),  anatomyFcn = memoize(@(x,y) anatomyInfo(x,y)); end
anatomyFcn.CacheSize = 400;

%% Load neuron info.
fprintf('\nLoading neuron Info..');
neuronInfo = sessionFcn(fullfile(dataFolder,infoFile));
neuronInfo = neuronInfo.neuronInfo;
nNeurons = numel(neuronInfo);
fprintf('\nDone!\n');

%% get selected anatomyInfo.
structInfo = getAllenAnatomyInfo(areas,'Property','acronym');

%% Collect info per neuron
anatomy = anatomyFcn([neuronInfo.morphology],structInfo);
data = zeros(nNeurons,numel(areas));
for iProp = 1:numel(property)
    data = data + anatomy.(cHemi).(property{iProp});
end
if strcmpi(property{iProp},'length'), data = data/1000; end

%% Calculate descriptives.
nComp = numel(compGroup);
nAreas = numel(areas);
descStats = [];
for iComp = 1:nComp
    ind = ismember([neuronInfo.group],[compGroup{iComp}]);
    for iArea = 1:nAreas
        values = data(ind,iArea);
        descStats(iComp).values(iArea) =    {values};
        descStats(iComp).m(iArea) =         mean(values);
        descStats(iComp).std(iArea) =       std(values);
        descStats(iComp).n(iArea) =         sum(ind);
        descStats(iComp).sem(iArea) =       std(values)/sqrt(numel(values));
    end
end

%% Plot.
hFig = figure;
hAx = axes;
hAx.TickDir = 'out';
hold on
count = 0;
tickLoc = [];
tickLabels = {};
rng(1);
for iArea = 1:nAreas
    for iComp = 1:nComp
        count = count + 1;
        % plot bar.
        hB = bar(count,descStats(iComp).m(iArea));
        hB.FaceColor = groupColors(iComp,:);
        % plot errorbar.
        hE = errorbar(count,descStats(iComp).m(iArea),[],descStats(iComp).sem(iArea));
        hE.CapSize=12;
        hE.Color = [0,0,0];
        hE.LineWidth = 1;
        % individual values.
        values = descStats(iComp).values{iArea};
        binOffset = (0.005*(numel(values)*3));
        xOffset = rand(numel(values),1)*(binOffset*2)-binOffset;
        xOffset = xOffset - mean(xOffset);
        hS = scatter(repmat(count,numel(values),1)+xOffset ,...
            values,'filled');
        hS.MarkerFaceColor = [0,0,0];
        hS.MarkerEdgeColor = hS.MarkerFaceColor;
        hS.SizeData = 16;
        % store tick info.
        tickLoc = [tickLoc;count];
        tickLabels = [tickLabels;{sprintf('%s - %s',areas{iArea},groupLabels{iComp})}];
    end
    % ttest.
    [h,p] = ttest2([descStats(1).values{iArea}],[descStats(2).values{iArea}]);
    fprintf('\nArea: %s, p<%.10f',areas{iArea}, p);
    count = count+1;
end
% set text.
hAx.XTick = tickLoc;
hAx.XTickLabel = tickLabels;
hAx.XTickLabelRotation = 90;