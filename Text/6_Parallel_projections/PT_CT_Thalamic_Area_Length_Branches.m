%% parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data');
infoFile = {fullfile(dataFolder,'CT','10-28-NeuronInfo.mat');...
    fullfile(dataFolder,'PT','10-30-NeuronInfo.mat')};
groupNames = {'CT','PT'};
% analysis.
area = 'TH';
voxelSize = 200;

%% Get area info.
structInfo = getAllenAnatomyInfo(area,'Property','acronym');

%% Collect data per group.
bank = [];
for iGroup = 1:numel(infoFile)
    fprintf('\nLoading %s Data',groupNames{iGroup});
    load( infoFile{iGroup});
    nNeurons = numel(neuronInfo);
    bank.(groupNames{iGroup}) = NaN(nNeurons,3);
    %% Collect info per neuron
    for iNeuron = 1:nNeurons
        fprintf('\nNeuron %i\\%i',iNeuron,nNeurons);
        % upsample.
        neuron = neuronInfo(iNeuron).morphology.axon;
        swc = [ [neuron.sampleNumber]',[neuron.structureIdValue]',...
            [neuron.x]',[neuron.y]',[neuron.z]',...
            ones(numel(neuron),1),[neuron.parentNumber]'];
        [~,partSwc] = upsampleSWC(swc,1); % store added points per node.
        % filter per location
        [info,ind] = neuronInfoAllenRegion(neuron,structInfo.structure_id_path);
        coords = cat(1,[partSwc{ind}]');
        % project to voxel address.
        voxels = ceil(coords./voxelSize);
        nVoxels = size(unique(voxels,'rows'),1);
        
        % Store area.
        bank.(groupNames{iGroup})(iNeuron,1) = ((voxelSize/1000).^3) * nVoxels;
        % Store length.
        bank.(groupNames{iGroup})(iNeuron,2) = info.bi.totalLength/1000;
        % Store branchpoints.
        bank.(groupNames{iGroup})(iNeuron,3) = info.bi.nBranches;
    end
end

%% Output.
properties = { {'Area','mm3'}, {'Length','mm'}, {'Branches','ends'}};
for iProp = 1:3
    cProp = properties{iProp};
    fprintf('\n%s:',cProp{1});
    % go through groups.
    for iGroup=1:numel(infoFile)
        cValues= bank.(groupNames{iGroup})(:,iProp);
        fprintf('\n\t%s %.1f +- %.1f %s',...
            groupNames{iGroup},mean(cValues),std(cValues),cProp{2});
    end
    [h,p] = ttest2(bank.PT(:,iProp),bank.CT(:,iProp));
    fprintf('\n\tp: %.12f\n',p);
end
