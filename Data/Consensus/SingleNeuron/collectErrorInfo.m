% generates data stored in 'errorInfo.mat'
% Added for clarity.
%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
types = {'Frag','Man'};

%% Get annotators.
anList = dir(fullfile(mainFolder));
anList = anList([anList.isdir]);
anList = anList(3:end);

%% Go through reconstructions.
nAn = size(anList,1);
errorInfo = struct();
for iType = 1:2
    cType = types{iType};
    fprintf('\nMethod: %s',cType);
    % load gold standard
    goldSwc = importSWCFast(fullfile(mainFolder,...
        sprintf('goldstandard_%s.swc',cType)));
    % Go through annotators.
    for iAn = 1:nAn
        cAn = anList(iAn).name;
        cFolder = fullfile(mainFolder,cAn,cType);
        % store full recon
        cAnFile = dir(fullfile(cFolder,sprintf('%s*.swc',cType)));
        errorInfo(iAn).(cType).swc = importSWCFast(fullfile(cFolder,cAnFile.name));
        % load False Positives (unique annotator recon).
        cFPFile = dir(fullfile(cFolder,'Mistakes',sprintf('%s_*_unique.swc',cType)));
        cFPFile = fullfile(cFPFile.folder,cFPFile.name);
        errorInfo(iAn).(cType).fpBranches = sepSwcBranches(importSWCFast(cFPFile));
        % load False Negatives (unique gold standard recon).
        cFNFile = fullfile(cFolder,'Mistakes',sprintf('goldstandard_%s_unique.swc',cType));
        errorInfo(iAn).(cType).fnBranches = sepSwcBranches( importSWCFast(cFNFile));
        % count.
        errorInfo(iAn).(cType).nFN = numel(errorInfo(iAn).(cType).fnBranches);
        errorInfo(iAn).(cType).nFP = numel(errorInfo(iAn).(cType).fpBranches);
    end
end
fprintf('\n');