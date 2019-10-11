% generates data stored in 'errorInfo.mat'
% Added for clarity.
%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
types = {'Frag','Man'};

%% Read dendrite.
dendSwc = importSWCFast(fullfile(mainFolder,'dendrite.swc'));

%% Get annotators.
anList = dir(fullfile(mainFolder));
anList = anList([anList.isdir]);
anList = anList(3:end);

%% Go through reconstructions.
nAn = size(anList,1);
errorInfo = struct();
swcInfo = [];
for iType = 1:2
    cType = types{iType};
    fprintf('\nMethod: %s',cType);
    % Go through annotator pairs.
    for iAn = 1:nAn
        cFolder = fullfile(anList(iAn).folder,anList(iAn).name,cType);
        % find base.
        baseFile = dir(fullfile(cFolder,'*base.swc'));
        if isempty(baseFile)
            fprintf('\nCould not find base file for %s - %s',anList(iAn).name,cType);
            return;
        end  
        % find uniques.
        uniFile = dir(fullfile(cFolder,'*unique.swc'));
        if length(uniFile)~=2
            fprintf('\nCould not find two unique files for %s - %s',anList(iAn).name,cType);
            return;            
        end
        
        % store.
        swcInfo(iAn).(cType).name = anList(iAn).name;
        swcInfo(iAn).(cType).base =...
            importSWCFast(fullfile(baseFile.folder,baseFile.name));
        swcInfo(iAn).(cType).uni1 =...
            sepSwcBranches(importSWCFast(...
            fullfile(uniFile(1).folder,uniFile(1).name)));   
        swcInfo(iAn).(cType).uni2 =...
            sepSwcBranches(importSWCFast(...
            fullfile(uniFile(2).folder,uniFile(2).name)));             
    end
end
% save(fullfile(mainFolder,'comparison_data.mat'),'swcInfo','dendSwc');
