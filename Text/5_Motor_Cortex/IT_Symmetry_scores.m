%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','IT');
infoFile = '11-25-NeuronInfo.mat';
area = {'root'};
voxelSize = 1000;

%% Memoize functions (for efficiency in recalculations).
if ~exist('sessionFcn'),  sessionFcn= memoize(@(x) load(x)); end

%% Load neuron info.
fprintf('\nLoading neuron Info..');
neuronInfo = sessionFcn(fullfile(dataFolder,infoFile));
neuronInfo = neuronInfo.neuronInfo;
nNeurons = numel(neuronInfo);
fprintf('\nDone!\n');

%% filter by area.
structInfo = getAllenAnatomyInfo(area,'Property','acronym');

%% Go through neurons.
distScore = NaN(nNeurons,1);
for iNeuron = 1:nNeurons
    cNeuron = neuronInfo(iNeuron).id;
    fprintf('\nNeuron %s [%i\\%i]',cNeuron,iNeuron,nNeurons);
    neuron = neuronInfo(iNeuron).morphology.axon;
    locs = [[neuron.x]',[neuron.y]',[neuron.z]'];
    % Check for ndoes with missing anatomy info
    [neuron(cellfun(@isempty,{neuron.structureIdPath})).structureIdPath] = deal('/997/'); % sets empty indices to root.
    % filter by location.
    [~,indSelect] = neuronInfoAllenRegion(neuron,structInfo.structure_id_path);
    locs = locs(indSelect,:);
    % Generate binarized voxel volume.
    binMat = zeros(ceil(11400/voxelSize),ceil(8000/voxelSize),ceil(13200/voxelSize),'logical');
    pixs = ceil(locs./voxelSize);
    ind = sub2ind(size(binMat),pixs(:,1),pixs(:,2),pixs(:,3));
    binMat(ind) = true;
    % split.
    pixLocMid = floor((11400/voxelSize(1))/2);
    ipsiMat = binMat(1:pixLocMid,:,:);
    contraMat = binMat(size(binMat,1)-pixLocMid+1:end,:,:);
    % mirror
    contraMat = flipud(contraMat);
    % sanity check.
    if pixLocMid*2 >= size(binMat,1) || ~isequal(size(ipsiMat),size(contraMat))
        error('Incorrect symmetry plane!'); 
    end
    % Check if bilateral 
    if sum(sum(sum(contraMat)))>0
        % calculate jaccard distance.
        distScore(iNeuron) = sum(sum(sum(ipsiMat & contraMat))) / sum(sum(sum(ipsiMat | contraMat)));
    end
end

%% Results.
layers = {'L2/3','L5','L6'};
fprintf('\nSymmetry Voxel size %i um',voxelSize(1));
bank = [];
for iLayer = 1:numel(layers)
   cLayer = layers{iLayer};
   ind = find(strcmpi({neuronInfo.layer},cLayer) & ~isnan(distScore)');
   values = distScore(ind);
   fprintf('\n\t%s: %.2f +- %.2f jaccard simmilarity',cLayer, nanmean(values),nanstd(values))   
   % store values for anova.
   bank = [bank;distScore(ind),repmat(iLayer,numel(ind),1)];
end
[p,tbl,stats] = anova1(bank(:,1),bank(:,2));
fprintf('\nAnova: p: %.6f',p);
multcompare(stats);
