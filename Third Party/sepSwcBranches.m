function [branches] = sepSwcBranches(swc)
      indSoma = find(swc(:,7)==-1);
      nBranches = size(indSoma,1);
      branches = cell(nBranches,1);
      for iBranch = 1:nBranches
          % collect nodes.
          nextNode = find(swc(:,7)==indSoma(iBranch));
          cSwc = [swc(indSoma(iBranch),:)];
          while ~isempty(nextNode)
              cNode = swc(nextNode(1),:);
              nextNode(1) = [];
              cSwc = [cSwc;cNode];
              nextNode = find(swc(:,7)==cNode(1,1));
              % next branch.
              if isempty(nextNode)
                  % nodes that connect to current node list
                  ind = ismember(swc(:,7),cSwc(:,1));
                  % but are not alreayd used
                  ind = ind & (~ismember(swc(:,1),cSwc(:,1)));
                  % and are not root.
                  nextNode = find(ind & (swc(:,7)~=-1),1);
              end
          end
          [oldId,newId]=unique(cSwc(:,1));
          for i=1:size(cSwc,1)
              ind = find(cSwc(i,1) == oldId);
              cSwc(i,1) = newId(ind);
              ind = find(cSwc(i,7) == oldId);
              if ~isempty(ind)
                  cSwc(i,7) = newId(ind);
              end
          end
          branches(iBranch) = {cSwc};
      end
      %% Sanity checks.
      if sum(cellfun(@(x) size(x,1),branches)) ~= size(swc,1)
          error('Collective branch length does not match input swc');
      end
      if any(cellfun(@(x) ~isequal(x(:,1)',1:size(x,1)),branches))
          error('Node numbering was unexpected for one branch');
      end
      if any(cellfun(@(x) any(~ismember(x(2:end,7),x(:,1))),branches))
          error('One branch has reference to node that isnt in its list');
      end
end

