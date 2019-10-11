%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Consensus','SingleNeuron');
type = 'Frag';

%% Load swc.
swc = importSWCFast(fullfile(dataFolder,sprintf('goldstandard_%s.swc',type)));

%% print stats
%length
lengthSwc = swcLength(swc)/10000;
nBranches = sum(swc(:,2)==5);
fprintf('\nLength: %.1f cm',lengthSwc);
fprintf('\nNumber of branches: %i ',nBranches);