%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
types = {'Frag'};
axisOrganization = [2,2]; % how subplots are shown.
dimSel = [1,2];
fnColor = [1,0,0];
fpColor = [0,0,1];

%% Output dir.
outputDir = fullfile(mainFolder,'Results');
if (isempty(outputDir)), mkdir(outputDir); end

%% Load error info.
load(fullfile(mainFolder,'errorInfo.mat'),'errorInfo');
nNeurons = size(errorInfo,2);
nAn = size(errorInfo,1);

%% Go through neurons.
for iNeuron = 1:nNeurons
    cNeuron = errorInfo(1,iNeuron).Frag.neuron;
    fprintf('\nNeuron %s [%i\\%i]',cNeuron,iNeuron,nNeurons);  
    for iType = 1:numel(types)
        cType = types{iType};
        fprintf('\nMethod: %s',cType);
        % Make figure.
        hFig = figure('Position',[225,140,2000,1150],'Color',[1,1,1]);
        sgtitle(sprintf('Neuron: %s',cNeuron),'Interpreter','none');
        for iAn = 1:nAn
            cAn = errorInfo(iAn,nNeurons).(cType).annotator;
            hAx = subplot(axisOrganization(1),axisOrganization(2),iAn);
            title(sprintf('Annotator: %s',cAn),'Interpreter','none');
            hAx.YDir = 'reverse';
            hAx.TickDir = 'out';
            hAx.DataAspectRatio = [1,1,1];
            hold on;
            % base.
            hBase = plotSwcFast2D(errorInfo(iAn,iNeuron).(cType).swc,dimSel);
            hBase.Color = [0,0,0];
            hBase.LineWidth = 0.25;
            % False Negative.
            hFN = plotSwcFast2D(errorInfo(iAn,iNeuron).(cType).fnBranches,dimSel);
            [hFN.Color] = deal(fnColor);
            [hFN.LineWidth] = deal(1);
            % False Negative.
            hFP = plotSwcFast2D(errorInfo(iAn,iNeuron).(cType).fpBranches,dimSel);
            [hFP.Color] = deal(fpColor);
            [hFP.LineWidth] = deal(1);
            % legend.
            text(0.05,0.95,'False Negative','Units','normalized','Color',fnColor,'FontSize',12);
            text(0.05,0.90,'False Positive','Units','normalized','Color',fpColor,'FontSize',12);
        end
        saveas(hFig,fullfile(outputDir,sprintf('%s_%s.png',cNeuron,cAn)));
    end
end