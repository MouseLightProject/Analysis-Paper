%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','IT');
infoFile = '11-25-NeuronInfo.mat';
areas = {'STR'};
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
if numel(areas)~=numel(structInfo), error('Area name not found'); end

%% Get anatomy info.
[info] = anatomyInfo([neuronInfo.morphology],structInfo,'Verbose',true);

%% Output.
%boolean flags.
isAny =      info.bi.nEndPoints>=minEndPoints;
isIpsi =    info.ipsi.nEndPoints>=minEndPoints;
isContra =  info.contra.nEndPoints>=minEndPoints;
% output
fprintf('\nProjections to %s:',structInfo.safe_name);
fprintf('\n\tAny:\t\t\t%i\\%i',              sum(isAny),nNeurons);
fprintf('\n\tBilateral:\t\t%i\\%i',        sum(isIpsi & isContra),nNeurons);
fprintf('\n\tIpsilateral:\t%i\\%i',      sum(isIpsi & ~isContra),nNeurons);
fprintf('\n\tContralateral:\t%i\\%i',    sum(~isIpsi & isContra),nNeurons);