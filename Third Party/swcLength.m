function [totalLength] = swcLength(swc)
%SWCLENGTH calculate total length from supplied matrix in swc format.
%% Sanity checks.
if size(swc,2)~=7, error('Expect swc to be in form of Nx7'); end
if ~isequal(swc(:,1),[1:size(swc,1)]'), error('Sample numbers are not contigious'); end
if swc(1,7)~=-1, error('First node is not root'); end
if sum(swc(:,7)==-1)>1, error('Swc has multiple roots'); end
% get length
totalLength = 0;
for iPnt = 2:size(swc,1)
   pPnt = swc(iPnt,7);
   totalLength = totalLength + sqrt( (swc(iPnt,3) - swc(pPnt,3))^2 + ...
                (swc(iPnt,4) - swc(pPnt,4))^2 +...
                (swc(iPnt,5) - swc(pPnt,5))^2 );
end

end

