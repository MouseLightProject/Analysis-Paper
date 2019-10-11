function [upDATA,varargout] = upsampleSWC(swcData,spacing)
spacing = spacing*1000;
swcData(:,3:5) = swcData(:,3:5)*1000;
%%
upDATA = [];
% upsample points that are consequtive
upthese = find(swcData(:,7)>0);
updata_ = [];
for jj=upthese(:)'
    st = swcData(jj,3:5);
    en = swcData(swcData(jj,7),3:5);
    sl = en-st;
    pd = norm(sl);
    sp = [[1:spacing:pd-1 pd]/pd];
    updata_{jj} = [sl(:)*sp+st(:)*ones(1,length(sp))];
end
upDATA = cat(1,upDATA,[updata_{:}]');
upDATA = upDATA/1000;
% set optional output.
varargout{1} = cellfun(@(x) x/1000,updata_,'UniformOutput',false);