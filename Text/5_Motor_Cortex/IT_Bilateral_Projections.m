%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','IT');
infoFile = '11-25-NeuronInfo.mat';
areas = {'root'};
halfPoint = 5695;
minEndPoints = 1;
bufferContra = 100;

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

%% Go through layers.
layers = {'L2/3','L5','L6','L'};
for iLayer = 1:4
    % filter according to layers.
    ind = find(contains({neuronInfo.layer},layers{iLayer}));
    countBi = 0;
    % Go through neurons.
    for iNeuron = 1:numel(ind)
        neuron.full = neuronInfo(ind(iNeuron)).morphology.axon;
        % sanity check (is soma on right side).
        if neuron.full(1).x>5695, error('Soma on wrong side!'); end
        % get only nodes in area.
        [~,indNodes] = neuronInfoAllenRegion(neuron.full,structInfo.structure_id_path);
        tempNeuron = neuron.full(indNodes);
        % get nodes on both sides.
        neuron.contra = tempNeuron([tempNeuron.x]>(halfPoint+bufferContra));
        neuron.ipsi = tempNeuron([tempNeuron.x]<=halfPoint);
        % check number of endpoints to determine bilaterality.
        if sum([neuron.contra.structureIdValue]==6)>=minEndPoints && ...
            sum([neuron.ipsi.structureIdValue]==6)>=minEndPoints
            countBi = countBi + 1;
        end
    end
    % Output percentage.
    fprintf('\nBilateral %s %s: \t\t%i\\%i',...
        structInfo.acronym, layers{iLayer},countBi,numel(ind));
end
fprintf('\n');