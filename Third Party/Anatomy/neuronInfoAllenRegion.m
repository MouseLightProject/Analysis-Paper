function [info,varargout] = neuronInfoAllenRegion(neuron,cStructIdPath)
%% neuronInfoAllenRegion. Takes structure 'neuron' from getNeuronfromIdString
% and a Allen structure path and return axonal info of that neuron for that
% structure.
halfPoint = 5695;
xSoma = neuron(1).x;

%% ananonymous check ipsilateral function
isIpsi = @(x) (x<halfPoint)==(xSoma<halfPoint);

%% Prep output variable.
info = [];
info.laterality = '';
info.bi.nBranches = 0;
info.bi.nEndPoints = 0;
info.bi.totalLength = 0;
info.ipsi = info.bi;
info.contra = info.bi;

%% Check for empty anatomy info.
[neuron(cellfun(@isempty,{neuron.structureIdPath})).structureIdPath] = deal('/997/'); % sets empty indices to root.

%% Find nodes in area (with sanity check).
indNodes = contains({neuron.structureIdPath},cStructIdPath);
if numel(indNodes)~=numel(neuron), error('Expected node sizes do not match!'); end
indNodes = find(indNodes);
% Optional outputs
varargout{1} = indNodes;
% return empty if no nodes are found.
if isempty(indNodes), return; end

%% count branches/endpoints.
structIdValues = [neuron(indNodes).structureIdValue];
info.bi.nBranches = sum(structIdValues==5);
info.bi.nEndPoints = sum(structIdValues==6);

%% Check sample numbers are contigious (assumption for speed).
if ~isequal([neuron.sampleNumber],1:numel(neuron))
    error('sampleNumbers in tree graph need to be contigious');
end

%% Go through nodes.
for iNode = 1:size(indNodes,2)
   cNode = neuron(indNodes(iNode));
   if cNode.parentNumber>0
       % laterality info current node.
       if isIpsi(cNode.x)
           laterality = 'ipsi';
       else
           laterality = 'contra';
       end
       % count branches or end points.
       if cNode.structureIdValue == 5
           info.(laterality).nBranches = info.(laterality).nBranches + 1;
       elseif cNode.structureIdValue == 6
           info.(laterality).nEndPoints = info.(laterality).nEndPoints + 1;
       end
       % add length current node.
       pNode = neuron(cNode.parentNumber);
       dist = sqrt((cNode.x - pNode.x)^2 + (cNode.y - pNode.y)^2 + (cNode.z - pNode.z)^2); 
       info.bi.totalLength = info.bi.totalLength + dist;
       info.(laterality).totalLength = info.(laterality).totalLength + dist;
   end
end

%% get laterality entire neuron. 
xCoords = [neuron(indNodes).x];
if all(isIpsi(xCoords))
   info.laterality = 'I';
elseif all(isIpsi(xCoords)==0)
   info.laterality = 'C';
else
   info.laterality = 'B';
end

end

