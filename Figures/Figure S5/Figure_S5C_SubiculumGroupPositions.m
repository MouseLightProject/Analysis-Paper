%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Subiculum');
neuronFile = '04-24-NeuronInfo.mat';
groups = {{'Proximal'},{'Intermediate'},{'Distal'},{'Local'}};
groupLabels = {'Proximal (Broad)','Intermediate (TH)','Distal (HY)','Local'};

%% Read neuronInfo;
fprintf('\nLoading neuron info..');
load(fullfile(dataFolder,neuronFile));
nNeurons = size(neuronInfo,2);
fprintf('\nDone!\n');

%% Collect data.
nGroups = numel(groups);
hFig = figure('Color',[1,1,1]);
hAx = axes;
hold on;
bank = [];
for iGroup = 1:nGroups
    % find cells in group.
    ind = find(ismember({neuronInfo.group},groups{iGroup}));
    values = [neuronInfo(ind).Distance]';
    bank = [bank; values,repmat(iGroup,numel(values),1)];
    % find bar.
    hS = scatter(values,repmat(iGroup,numel(values),1));
    hS.MarkerEdgeColor = [0.8,0.8,0.8];
    hS.MarkerFaceColor = hS.MarkerEdgeColor;
    hE = errorbar(mean(values),iGroup,  std(values)/sqrt(numel(values)),'horizontal' );
    hold on
    hE.Color = [0,0,0];
    hE.Marker = 'o';
    hE.MarkerEdgeColor = [0,0,0];
    hE.MarkerFaceColor = hE.MarkerEdgeColor;
    hE.MarkerSize = 10;
    hE.LineWidth =1;
end
hAx.YDir = 'reverse';
hAx.YTick = 1:nGroups;
hAx.YTickLabel = groupLabels;
hAx.XLim(1) = 0;
hAx.YLim = [0.5,nGroups+0.5];
hAx.YTickLabelRotation = 0;
hAx.Box = 'off';
hAx.TickDir = 'out';
xlabel('Distance to CA1 (\mum)');
hAx.PlotBoxAspectRatio = [1,0.75,1];
hAx.XLim = [0,1400];

%% Anova.
[p,tbl,stats] = anova1(bank(:,1),bank(:,2));
c = multcompare(stats);