% QUADDIAMETER_TREE   Map quadratic diameter tapering to tree.
% (trees package)
% 
% tree = quaddiameter_tree (intree, scale, offset, options, P, ldend)
% -------------------------------------------------------------------
%
% applies a quadratically decaying diameter on a given tree structure. P
% and ldend are derived precisely in (Cuntz, Borst and Segev 2007, Theor
% Biol Med Model, 4:21). P is an nx3 matrix containing the parameters to
% put in the quadratic equation y = P(1)x^2 + P(2)x + P(3). Each single
% triplet corresponds to the best fit to a segment of length ldend (nx1)
% vector. When the quadratic diameter is added the path from each terminal
% to the root is compared to its closest in ldend. Then the quadratic
% equation is chosen according to the index in ldend. This is done for all
% paths from root to terminal point and for each node the diameter is an
% average of all local diamaters of all paths leading through that node.
% Choosing parameters (P and ldend) by hand here is tempting but very hard.
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - scale::value: scale of diameter of root {DEFAULT: 0.5}
% - offset::value: added base diameter {DEFAULT: 0.5}
% - options::string: {DEFAULT ''}
%    '-s' : show
%    '-w' : waitbar
% - P::matrix of three columns: parameters for the quadratic equation in
%    dependence of the root to tip length given in:
% - ldend::vertical vector, same length as P: typical lengths at which P are 
%    given
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree:: structured output tree
%
% Example
% -------
% quaddiameter_tree (sample_tree, [], [], '-s')
%
% See also
% Uses Pvec_tree ipar_tree T_tree ver_tree dA D
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function  varargout = quaddiameter_tree (intree, scale, offset, options, P, ldend)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intree),
    intree = length (trees); % {DEFAULT tree: last tree in trees cell array}
end;

ver_tree (intree); % verify that input is a tree structure

% use full tree for this function
if ~isstruct (intree),
    tree = trees {intree};
else
    tree = intree;
end

if (nargin < 2)||isempty(scale),
    scale = 0.5; % {DEFAULT: half of what you would choose if the branch was on its own}
end

if (nargin < 3)||isempty(offset),
    offset = 0.5; % {DEFAULT: + .5um of what you would choose if the branch was on its own}
end

if (nargin <4)||isempty(options),
    options = ''; % {DEFAULT: no option}
end

if (nargin <5)||isempty(P),
    load P % {DEFAULT: parameters calculated for optimal current transfer for
           % branches on their own}
end

if (nargin <6)||isempty(ldend),
    load ldend % {DEFAULT: length values of branches for which P is given
               % quaddiameter_tree uses the P whos ldend is closest to the
               % path length for each path to termination point}
end

N = size (tree.dA, 1); % number of nodes in tree
tree.D = ones (N, 1) .* 0.5; % first set diameter to 0.5 um
Plen = Pvec_tree (tree)'; % path length from the root [um]
% NOTE! I'm not sure about the following line:
ipari  = [(1 : N)' ipar_tree(tree)]; % parent index structure incl. node itself twice
ipariT = ipari (T_tree (tree), :);   % parent index paths but only for termination nodes

if strfind (options, '-w'), % waitbar option: initialization
    HW = waitbar (0, 'calculating quad diameter...');
    set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end

Ds = zeros (size (ipariT));
for ward = 1 : size (ipariT, 1);
    if strfind (options, '-w'), % waitbar option: update
        if mod (ward, 500) == 0,
            waitbar (ward / size (ipariT, 1), HW);
        end
    end
    iipariT   = ipariT (ward, ipariT (ward, :) ~= 0);
    iipariT   = fliplr (iipariT);
    pathh     = Plen (iipariT);
    [i1 i2]   = min ((pathh (end) - ldend).^2); % find which ldend is closest to path length
    quadpathh = polyval (P (i2, :), pathh) .* scale;
    Ds (ward, 1 : length (quadpathh)) = fliplr (quadpathh); % apply the diameters
end

if strfind (options, '-w'), % waitbar option: close
    close (HW);
end

% average the diameters for overloaded nodes (there might be a better way
% to do this than averaging):
for ward = 1 : N,
    iR = find (ipariT == ward);
    tree.D (ward) = mean (Ds (iR));
end

tree.D = tree.D + offset; % add offset diameter

if strfind (options, '-s'), % show option
    clf; hold on; plot_tree (tree, [0 0 0]);
    title  ('quadratic diameter tapering');
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view (3); grid on; axis equal;
end

if (nargout == 1)||(isstruct(intree)),
    varargout {1}  = tree; % if output is defined then it becomes the tree
else
    trees {intree} = tree; % otherwise the orginal tree in trees is replaced
end
