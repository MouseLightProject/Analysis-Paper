function info = collectAnaData(neurons,areaList,varargin)
%% Parse input.
p = inputParser;
p.addRequired('neurons');
p.addRequired('areaList');
p.addParameter('Type','axon',@(x) ismember(x,{'axon','dendrite'}));
p.addParameter('Properties',{'totalLength'},@(x) iscell(x));
p.parse(neurons,areaList,varargin{:});
Inputs = p.Results;

%% Prepare output.
nAreas = numel(Inputs.areaList);
nNeurons = numel(Inputs.neurons);
info.graphOrder = NaN(nAreas,1);
info.values = NaN(nNeurons,nAreas);
info.area = cell(nAreas,1);
%% Go through areas.
for iArea = 1:nAreas
    cArea = areaList{iArea}{1};
    cHemi = areaList{iArea}{2};
    cHemi = cHemi{:};
    info.area(iArea) = areaList{iArea}{3};
    fprintf('\nArea: %s [%i\\%i]',info.area{iArea},iArea,nAreas);
    
%     % check for abbreviations.
%     [indA,indB] = ismember(cArea,[AbList{:,1}]');
%     cArea(indA) = [];
%     cArea = [cArea;[AbList{indB(indB~=0),2}]'];

    % get anatomy info.
    structInfo = getAllenAnatomyInfo(cArea,'Property','acronym');
    if numel(structInfo)~=numel(cArea)
        error('Mismatch returned areas. Likely incorrect area string');
    end
    info.graphOrder(iArea) = min([structInfo.graph_order]);
    % collect anatomy data.
    for iNeuron = 1:nNeurons
        ana = neuronInfoAllenRegion(neurons(iNeuron).(Inputs.Type),...
           {structInfo.structure_id_path});
       % go through properties.
        value = 0;
        for iProp = 1:numel(Inputs.Properties)
            value = value + sum(ana.(cHemi).(Inputs.Properties{iProp}),2); % sum over areas.
        end
        info.values(iNeuron,iArea) = value; 
    end
end
end

