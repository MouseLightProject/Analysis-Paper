% generates data stored in 'errorInfo.mat'
% Added for clarity.
%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
types = {'Frag'};

%% Get neurons.
neuronList = dir(fullfile(mainFolder));
neuronList = neuronList([neuronList.isdir]);
neuronList = neuronList(3:end);
neuronList = {neuronList.name};
% remove 'results' folder
neuronList(strcmpi(neuronList,'Results')) = [];
nNeurons = numel(neuronList);

errorInfo = struct();
goldSwcs = struct();
for iNeuron = 1:nNeurons
    %% Get neuron.
    cNeuron = neuronList{iNeuron};
    fprintf('\nNeuron %s [%i\\%i]',cNeuron,iNeuron,nNeurons);    
    neuronFolder = fullfile(mainFolder,cNeuron);
    
    %% Get annotators.
    anList = dir(fullfile(neuronFolder));
    anList = anList([anList.isdir]);
    anList = anList(3:end);

    %% Go through reconstructions.
    nAn = size(anList,1);
    for iType = 1:numel(types)
        cType = types{iType};
        fprintf('\nMethod: %s',cType);
        % load gold standard
        goldSwcs(iNeuron).(cType) = importSWCFast(fullfile(neuronFolder,...
            sprintf('%s_Consensus.swc',cNeuron)));
        % Go through annotators.
        for iAn = 1:nAn
            cAn = anList(iAn).name;
            errorInfo(iAn,iNeuron).(cType).neuron = cNeuron;
            errorInfo(iAn,iNeuron).(cType).annotator = cAn;
            fprintf('\n\tAnnotator %s [%i\\%i]',cAn,iAn,nAn);            
            cFolder = fullfile(neuronFolder,cAn,cType);
            % store full recon
            cAnFile = dir(fullfile(cFolder,sprintf('%s_%s.swc',cNeuron,cAn)));
            errorInfo(iAn,iNeuron).(cType).swc = importSWCFast(fullfile(cFolder,cAnFile.name));
            % load False Positives (unique annotator recon).
            cFPFile = dir(fullfile(cFolder,'Mistakes',...
                sprintf('%s_%s_unique.swc',cNeuron,cAn)));
            cFPFile = fullfile(cFPFile.folder,cFPFile.name);
            errorInfo(iAn,iNeuron).(cType).fpBranches = sepSwcBranches(importSWCFast(cFPFile));
            % load False Negatives (unique gold standard recon).
            cFNFile = dir(fullfile(cFolder,'Mistakes',sprintf('%s_*onsensus_*nique.swc',cNeuron)));
            cFNFile = fullfile(cFNFile.folder,cFNFile.name);
            errorInfo(iAn,iNeuron).(cType).fnBranches = sepSwcBranches( importSWCFast(cFNFile));
            % count.
            errorInfo(iAn,iNeuron).(cType).nFN = numel(errorInfo(iAn,iNeuron).(cType).fnBranches);
            errorInfo(iAn,iNeuron).(cType).nFP = numel(errorInfo(iAn,iNeuron).(cType).fpBranches);
        end
    end
    fprintf('\n');
end

%% Save.
save(fullfile(mainFolder,'errorInfo.mat'),'errorInfo','goldSwcs');