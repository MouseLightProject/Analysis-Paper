function [coords] = pntsInArea(neuron,v,f)
% upsample distances.
swcData = [[neuron.sampleNumber]',[neuron.structureIdValue]',...
    [neuron.x]',[neuron.y]',[neuron.z]',...
    ones(size([neuron.y]',1),1), [neuron.parentNumber]'];
[coords] = upsampleSWC(swcData,1);
% Filter based on anatomy.
ind = intriangulation(v,f,coords);
coords = coords(ind,:);
end

