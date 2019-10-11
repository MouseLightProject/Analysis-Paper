%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','CT');
infoFile = '10-28-NeuronInfo';
area = 'Thalamus';
halfPoint = 5695;

%% Memoize functions (for efficiency in recalculations).
if ~exist('sessionFcn'),  sessionFcn= memoize(@(x) load(x)); end

%% Load neuron info.
fprintf('\nLoading neuron Info..');
neuronInfo = sessionFcn(fullfile(dataFolder,infoFile));
neuronInfo = neuronInfo.neuronInfo;
nNeurons = numel(neuronInfo);
fprintf('\nDone!\n');

%% Get allen area info.
structInfo = getAllenAnatomyInfo(area,'Property','name');

%% Get anatomy info.
[info] = anatomyInfo([neuronInfo.morphology],structInfo,'Verbose',true);

%% Store.
posInfo = cat(1,neuronInfo.position)/1e3;
bank(:,1) = posInfo(:,3);
bank(:,2) = info.contra.length/1e3;

%% Plot
hFig = figure('Color',[1,1,1],'Units','points');
hAx = axes(...
    'Units','points',...
    'FontName','Arial',...
    'FontSize',8);
hAx.Position(3:4) = [85,80];
scatter(bank(:,1),bank(:,2),pi*(1.5^2),[0,0,0],'filled');
hold on
% curve fit.
[fitObj,~] = fit(bank(:,1),bank(:,2),'poly1');
hL = plot(fitObj);
hL.Color = [0,0,0];
hL.LineStyle = '--';
legend off
% format.
hAx.TickDir = 'out';
xlabel(sprintf('Soma position\nanterior-posterior (mm)'));
ylabel(sprintf('Contralateral\naxon length (mm)'));
hAx.YLim = [0,40];
hAx.XLim = [2.5,5];
hAx.XTick = [2.5:0.5:5];
hAx.XTickLabel(2:2:numel(hAx.XTickLabel)) = {''};
hAx.YTick = [0:5:40];
hAx.YTickLabel(2:2:numel(hAx.YTickLabel)) = {''};
hAx.XColor = [0,0,0]; hAx.YColor = [0,0,0];
hAx.XLabel.Color = [0,0,0]; hAx.YLabel.Color = [0,0,0];
hAx.OuterPosition(1:2) = [5,5];
hFig.Position(3:4) = hAx.OuterPosition(3:4);
%stats.
regInfo = regstats(bank(:,1),bank(:,2),'linear');
text(0.95,0.95,sprintf('\nr2: %.2f\n\tp: %.6f',regInfo.rsquare,regInfo.tstat.pval(2)),'Units','normalized',...
    'HorizontalAlignment','right','FontSize',8,'Color',[0,0,0])
hAx.Units = 'normalized'; hFig.Units = 'normalized';