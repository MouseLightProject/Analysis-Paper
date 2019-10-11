%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','VAL');
infoFile = '11-01-NeuronInfo.mat';
areas = {'RT','CP'};
minEndPoints = 1;

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

%% Get anatomy info.
[info] = anatomyInfo([neuronInfo.morphology],structInfo,'Verbose',true);

%% Output.
fprintf('\nInnervation (min. %i ends)',minEndPoints);
for iArea = 1:numel(areas)
    fprintf('\n\t%s, n = %i\\%i', structInfo(iArea).acronym, ...
        sum(info.bi.nEndPoints(:,iArea)>=minEndPoints),nNeurons);
end
fprintf('\n');