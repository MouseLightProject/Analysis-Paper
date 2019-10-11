% JITTER_TREE   Jitters coordinates of a tree.
% (trees package)
%
% tree = jitter_tree (intree, stde, lambda, options)
% --------------------------------------------------
%
% Adds noise to the coordinates of the nodes of a tree. 
%
% Input
% -----
% - intree::integer:index of tree in trees or structured tree
% - stde::value:standard deviation in um {DEFAULT: 1}
% - lambda::integer:length constant of treeed low pass filter applied on the
%     noise {DEFAULT: 10}
% - options::string: {DEFAULT: '-w'}
%     '-s' : show
%     '-w' : waitbar
%
% Output
% ------
% if no output is declared the tree is changed in trees
% - tree:: structured output tree
%
% Example
% -------
% jitter_tree (sample_tree, [], [], '-s');
%
% See also smooth_tree MST_tree
% Uses ipar_tree
%
% the TREES toolbox: edit, visualize and analyze neuronal trees
% Copyright (C) 2009  Hermann Cuntz

function  varargout = jitter_tree (intree, stde, lambda, options)

% trees : contains the tree structures in the trees package
global trees

if (nargin < 1)||isempty(intree),
    intree = length (trees);
end;

ver_tree (intree);

if ~isstruct(intree),
    tree = trees {intree};
else
    tree = intree;
end

if (nargin <2)||isempty(stde),
   stde = 1;
end

if (nargin <3)||isempty(lambda),
    lambda = 10;
end

if (nargin <4)||isempty(options),
    options = '-w';
end

N  = size (tree.X, 1);
% all paths:
A  = tree.dA + tree.dA';
As = cell (1, 1);

if strfind (options, '-w'), % waitbar option: initialization
    HW = waitbar (0, 'calculating paths...');
    set (HW, 'Name', '..PLEASE..WAIT..YEAH..');
end
for ward = 1 : lambda,
    if strfind (options, '-w'), % waitbar option: update
        if mod (ward, 5) == 0,
            waitbar (ward / lambda, HW);
        end
    end
    As {ward} = A^ward;
end
R  = randn (N, 3) * stde * lambda;
R1 = zeros (N, 3);
if strfind (options, '-w'), % waitbar option: reinitialization
    waitbar (0, HW, 'jittering...');
end
for ward = 1 : N,
    if strfind (options, '-w'), % waitbar option: update
        if mod (ward, 50) == 0,
            waitbar (ward / N, HW);
        end
    end
    Z = zeros (N, 1); Z (ward) = 1;
    S = zeros (N, 1); S1 = zeros (N, 1);
    for te = 1 : lambda,
        zA = As {te} * Z > 0;
        iA = setdiff (find (zA), find (S1));
        S1 (iA) =  1;
        S  (iA) = te;
    end
    S (S == 0) = 100000;
    S = gauss (S, 1, lambda / 5);
    R1 (ward, :) = sum (R .* [S S S]);
end
if strfind (options, '-w'), % waitbar option: close
    close (HW);
end
tree.X = tree.X + R1 (:, 1) - R1 (1, 1);
tree.Y = tree.Y + R1 (:, 2) - R1 (1, 2);
tree.Z = tree.Z + R1 (:, 3) - R1 (1, 3);

if strfind (options, '-s'),
    clf; hold on; shine; plot_tree (intree); plot_tree (tree, [1 0 0]);
    HP (1) = plot (1, 1, 'k-'); HP (2) = plot (1, 1, 'r-');
    legend (HP, {'before', 'after'});
    set (HP, 'visible', 'off');
    title  ('jitter tree');
    xlabel ('x [\mum]'); ylabel ('y [\mum]'); zlabel ('z [\mum]');
    view (2); grid on; axis image;
end

if (nargout == 1)||(isstruct(intree)),
    varargout {1} = tree;
else
    trees {intree} = tree;
end