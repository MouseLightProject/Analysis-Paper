function [tree] = quickLoadTreeSwc(swc)
% swc = importSWCFast(cFile);
tree = [];
tree.X = swc(:,3);
tree.Y = swc(:,4);
tree.Z = swc(:,5);
tree.D = ones(size(swc,1),1);
tree.R = ones(size(swc,1),1);
tree.rnames = {'swc'};
% [~,name,~]=fileparts(cFile);
tree.name = 'swc';
tree.dA = sparse(zeros(size(swc,1),size(swc,1)));
for i = 1:size(swc,1)
   if swc(i,7)>0
       tree.dA(i,swc(i,7))=true;
   end
end

end

