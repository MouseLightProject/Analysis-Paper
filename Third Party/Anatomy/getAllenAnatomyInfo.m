function [info] = getAllenAnatomyInfo(selectionValue,varargin)
%% Parse input.
p = inputParser;
p.addRequired('selectionValue');
p.addParameter('Property','id',@(x) any(ismember(x,...
    {'id','atlas_id','acronym','name','safe_name'})));
p.addParameter('Ontology',1,@isnumeric);
p.addParameter('Url','http://api.brain-map.org/api/v2/data/',@(x) ischar(x));
p.parse(selectionValue,varargin{:});
Inputs = p.Results;

if ischar(Inputs.selectionValue)
    Inputs.selectionValue = {Inputs.selectionValue};
end
%% Make search query.
info = [];
for iAna = 1:numel(Inputs.selectionValue)
    cAna = Inputs.selectionValue(iAna);
    if isnumeric(cAna)
        cAna = num2str(cAna);
    end
    if iscell(cAna)
        cAna=cAna{:};
    end
    searchStr = sprintf('%squery.json?criteria=model::Structure,rma::criteria',Inputs.Url);
    searchStr = sprintf('%s,[%s$eq''%s''],ontology[id$eq%i]',searchStr,Inputs.Property,cAna,Inputs.Ontology);
    searchStr = sprintf('%s,rma::options[only$eq''structures.id,structures.safe_name,graph_order,color_hex_triplet,structure_id_path,name,acronym'']',searchStr);
    data = webread(searchStr);
    if isempty(data.msg)
        error('Could not find area with %s as %s',...
            cAna,Inputs.Property);
    end
    info = [info;data.msg];
end
end
