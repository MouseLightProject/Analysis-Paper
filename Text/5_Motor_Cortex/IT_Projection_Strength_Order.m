%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','IT');
infoFile = '11-25-NeuronInfo.mat';
areas = {'MO','SS','AI','ECT','PIR','BLA','VIS','CLA'};

%% Memoize functions (for efficiency in recalculations).
if ~exist('sessionFcn'),  sessionFcn= memoize(@(x) load(x)); end

%% Load neuron info.
fprintf('\nLoading neuron Info..');
neuronInfo = sessionFcn(fullfile(dataFolder,infoFile));
neuronInfo = neuronInfo.neuronInfo;
nNeurons = numel(neuronInfo);
fprintf('\nDone!\n');

%% Get area info.
structInfo = getAllenAnatomyInfo(areas,'Property','acronym');
if numel(areas)~=numel(structInfo), error('Area name not found'); end

%% Get anatomy info.
[info] = anatomyInfo([neuronInfo.morphology],structInfo,'Verbose',true);

%% Order by length.
score = mean(info.bi.length,1);
[score,orderInd] = sort(score,'descend');

%% Output
fprintf('\nIT innervation (strongest to weakest)');
for iArea = 1:numel(areas)
    fprintf('\n\t %s (mean: %.2f mm)',structInfo(orderInd(iArea)).safe_name,score(iArea)./1000);
end
