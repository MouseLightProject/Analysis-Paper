function [data] = anatomyInfo(neurons,anatomyInfo,varargin)
%anatomyInfo. Gathers anatomy info from given anatomy info structure.
%anatomyInfo is returned by getAllenAnatomyInfo.
%% Parse input.
p = inputParser;
p.addRequired('neurons',@isstruct);
p.addRequired('anatomyInfo',@(x) isstruct(x) && size(x,2)==1);
p.addParameter('Verbose',false,@islogical);
p.addParameter('Type','axon',@(x) ismember(x,{'axon','dendrite'}));
p.parse(neurons,anatomyInfo, varargin{:});
Inputs = p.Results;

%% Gather requested anatomy info.
structIdPaths = {anatomyInfo.structure_id_path}';
nRegions = size(structIdPaths,1);

%% Prep output variable.
nNeurons = numel(Inputs.neurons);
data = [];
data.bi.nBranches = zeros(nNeurons,nRegions);
data.bi.nEndPoints = zeros(nNeurons,nRegions);
data.bi.length = zeros(nNeurons,nRegions);
data.ipsi = data.bi;
data.contra = data.bi;
data.laterality = cell(nNeurons,nRegions);

%% Go through neurons and regions.
for iNeuron=1:nNeurons
    if Inputs.Verbose
        fprintf('\nNeuron %i\\%i',iNeuron,nNeurons);
    end
    for iRegion = 1:nRegions
       % get anatomy info.
       info = neuronInfoAllenRegion(...
           Inputs.neurons(iNeuron).(Inputs.Type),structIdPaths{iRegion});
       % Store info.
       for iField = {'bi','ipsi','contra'}
          cField = iField{:};
          data.(cField).nBranches(iNeuron,iRegion) = info.(cField).nBranches;
          data.(cField).nEndPoints(iNeuron,iRegion) = info.(cField).nEndPoints;
          data.(cField).length(iNeuron,iRegion) = info.(cField).totalLength;
       end
       data.laterality(iNeuron,iRegion) = {info.laterality};
    end
end
end

