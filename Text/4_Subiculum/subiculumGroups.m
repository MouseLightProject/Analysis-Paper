%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Subiculum');
infoFile = '04-24-NeuronInfo.mat';
areas = {'RSP','HY'};
minLength = 100;

%% Memoize functions (for efficiency in recalculations).
if ~exist('sessionFcn'),  sessionFcn= memoize(@(x) load(x)); end

%% Load neuron info.
fprintf('\nLoading neuron Info..');
neuronInfo = sessionFcn(fullfile(dataFolder,infoFile));
neuronInfo = neuronInfo.neuronInfo;
nNeurons = numel(neuronInfo);
fprintf('\nDone!\n');
fprintf('\n\nTotal number of neurons: %i',nNeurons);

%% anatomy info.
anaInfo = getAllenAnatomyInfo(areas,'Property','acronym');

%% Go through groups.
groups = unique({neuronInfo.group});
for iGroup = 1:numel(groups)
    cGroup = groups{iGroup};
    ind = find(strcmpi({neuronInfo.group},cGroup));
    fprintf('\n\t%s: %i neurons',cGroup,numel(ind));
    if strcmpi(cGroup,'Distal')
        info = anatomyInfo([neuronInfo(ind).morphology],anaInfo);
        inArea = info.bi.length>=100;
        fprintf('\n\t\t%s only: %i neurons',areas{1},sum(inArea(:,1)&~(inArea(:,2))));
        fprintf('\n\t\t%s only: %i neurons',areas{2},sum(inArea(:,2)&~(inArea(:,1))));        
        fprintf('\n\t\tRSP and HY: %i neurons',sum(all(inArea,2)));     
    end
end
