% SORT_TREE   sorts index of nodes in tree to be BCT conform.
% (trees package)
% 
% [tree, order] = sort_tree (intree, options)
% -------------------------------------------
%
% puts the indices in the so-called BCT order, an order in which elements
% are arranged according to their hierarchy keeping the subtree-structure
% intact. Many isomorphic BCT order structures exist, this one is created by
% switching the location of each element one at a time to the neighboring
% position of their parent element. For a unique sorting use '-LO' or
% '_LEX' options. '-LO' orders the indices using path length and level
% order. This results in a relatively unique equivalence relation. '-LEX'
% orders the BCT elements lexicographically. This makes less sense but
% results in a purely unique equivalence relation. "sort_tree" changes
% index in all vectors of form Nx1 accordingly.
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - options::string: {DEFAULT: ''}
%     '-s'   : show
%     '-LO'  : sort according to level order (see "LO_tree")
%     '-LEX' : lexicograph order: B before C before T at branch points
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree:: structured output tree
% - order::vector: vector of new indices
%
% Example
% -------
% sort_tree (sample_tree, '-s')
% sort_tree (sample_tree, '-s -LO')
%
% See also redirect_tree LO_tree BCT_tree isBCT_tree dendrogram_tree
% Uses idpar_tree ver_tree dA
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function varargout = sort_tree (intree, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intree),
    intree = length(trees); % {DEFAULT tree: last tree in trees cell array}
end;

ver_tree (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct(intree),
    tree = trees{intree};
else
    tree = intree;
end
    
if (nargin < 2)||isempty(options),
    options = ''; % {DEFAULT: no option}
end

N = size(tree.dA,1); % number of nodes in tree

if strfind(options,'-LO'),
    PL = PL_tree (intree); % path length away from node
    LO = LO_tree (intree); % level order for each node (see "LO_tree")
    % order indices first according to path length then to level order
    [i1 iipre] = sortrows ([PL LO]);
    % change the adjacency matrix according to the new order:
    tree.dA = tree.dA(iipre,iipre); % new directed adjacency matrix of tree
    % update all vectors of form Nx1
    S = fieldnames(tree);
    for ward = 1:length(S),
        if ~strcmp(S{ward},'dA'),
            vec = tree.(S{ward});
            if isvector(vec) && (numel(vec) == size (tree.dA, 1)),
                tree.(S{ward}) = tree.(S{ward})(iipre);
            end
        end
    end
elseif strfind(options,'-LEX'),
    % order indices first according to number of daughters:
    % this means that T comes first then C then B
    typeN = full(sum(tree.dA)');
    [i1 iipre] = sort(typeN(2:end)); iipre = [1;iipre];
    % change the adjacency matrix according to the new order:
    tree.dA = tree.dA(iipre,iipre); % new directed adjacency matrix of tree
    % update all vectors of form Nx1
    S = fieldnames(tree);
    for ward = 1:length(S),
        if ~strcmp(S{ward},'dA'),
            vec = tree.(S{ward});
            if isvector(vec) && (numel(vec) == size (tree.dA, 1)),
                tree.(S{ward}) = tree.(S{ward})(iipre);
            end
        end
    end
else
    iipre = (1:N)'; 
end


idpar = idpar_tree(tree); % vector containing index to direct parent
dA = tree.dA; % directed adjacency matrix of tree

% simple hierarchical sorting
ii = 1:N;
r2 = 1:N;
for ward = 2:N,
    elem = r2(ward); % sorting ii is not faster...
    par = r2(idpar(ward)); % parent node
    % just sort that the parent always comes directly before the daughter:
    if par>elem,
        r = [1:elem-1 elem+1:par elem par+1:N];
    else
        r = [1:par elem par+1:elem-1 elem+1:N];
    end
    ii = ii(r);
    [x r2] = sort(ii);
end
order = iipre(ii);

% change the trees-structure according to the new order:
tree.dA = dA(ii,ii);
% in all vectors of form Nx1
S = fieldnames(tree);
for ward = 1:length(S),
    if ~strcmp(S{ward},'dA'),
        vec = tree.(S{ward});
        if isvector(vec) && (numel(vec) == size (tree.dA, 1)),
            tree.(S{ward}) = tree.(S{ward})(ii);
        end
    end
end

if strfind(options,'-s'), % show option
    clf; hold on; shine; HP = plot_tree(intree); set(HP,'facealpha',.5);
    T = vtext_tree (intree, [], [0 1 0], [-2 3 5]); set (T, 'fontsize',14);
    T = vtext_tree (tree, [], [], [0 0 5]); set (T, 'fontsize',14);
    title ('sort nodes BCT conform');
    HP(1) = plot(1, 1, 'g-'); HP(2) = plot(1, 1, 'r-');
    legend (HP, {'before', 'after'}); set (HP, 'visible', 'off');
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view(2); grid on; axis image;
end

if (nargout >0)||(isstruct(intree)),
    varargout{1} = tree; % if output is defined then it becomes the tree
else
    trees{intree} = tree; % otherwise add to end of trees cell array
end

if (nargout >1),
    varargout{2} = order;
end
