function [info,varargout] = calcCentroid(neuron,allenMesh,projAxis,varargin)
%% Parse input.
p = inputParser;
p.addRequired('neuron');
p.addRequired('allenMesh');
p.addRequired('projAxis');
p.addParameter('Hemi','bi',@(x) any(ismember(x,...
    {'ipsi','contra','bi'})));
p.addParameter('CropAxis',[],@(x) isnumeric(x) & numel(x)==1);
p.addParameter('CropLims',[],@(x) isnumeric(x) & numel(x)==2);
p.addParameter('Rotation',[],@(x) isnumeric(x) & numel(x)==3);
p.parse(neuron,allenMesh,projAxis,varargin{:});
Inputs = p.Results;
% get upsampled points in area.
coords = pntsInArea(Inputs.neuron,...
    Inputs.allenMesh.v,Inputs.allenMesh.f);
% check hemisphere.
switch Inputs.Hemi
    case 'ipsi'
        coords = coords(coords(:,1)<5695,:);
    case 'contra' 
        coords = coords(coords(:,1)>5695,:);
    case 'bi'
    otherwise
        error('did not recognize hemisphere variable');
end
% Filter based on Crop.
if ~isempty(Inputs.CropAxis)
    coords = coords(coords(:,Inputs.CropAxis)>=Inputs.CropLims(1) &...
        coords(:,Inputs.CropAxis)<=Inputs.CropLims(2),:);
end
% Rotate.
if ~isempty(Inputs.Rotation)
    coords = rotateCoordinates(coords,...
        Inputs.Rotation(1),Inputs.Rotation(2),Inputs.Rotation(3));
end
% get centroid location.
info.Centroid= mean(coords(:,Inputs.projAxis))/1000;
% length in regions.
info.Length = size(coords,1);
varargout{1} = coords;
end

