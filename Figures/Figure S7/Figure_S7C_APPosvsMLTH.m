%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','CT');
infoFile = '10-28-NeuronInfo';
meshFile = fullfile(mainFolder,'..','..','AllenFiles','allenMesh.mat');

%% AP soma vs SI axon RT.
area = 'TH';            % Anatomy area.
somaAxis = 3;           % Axis for soma location (X axis).
projAxis = 1;           % Axis for axon centroid (Y axis).
hemi = 'ipsi';          % Hemisphere to analyse projections in (ipsi,bi contra);
endPointThreshold = 0;  % Minimal number of endpoints in region.

%% Memoize functions (for efficiency in recalculations).
if ~exist('sessionFcn'),  sessionFcn= memoize(@(x) load(x)); end
if ~exist('centFcn'),     centFcn = memoize(@(x,y,z,h) calcCentroid(x,y,z,'Hemi',h)); end
if ~exist('anatomyFcn'),  anatomyFcn = memoize(@(x,y) anatomyInfo(x,y)); end
anatomyFcn.CacheSize = 400;
centFcn.CacheSize = 100;

%% Load neuron info.
fprintf('\nLoading neuron Info..');
neuronInfo = sessionFcn(fullfile(dataFolder,infoFile));
neuronInfo = neuronInfo.neuronInfo;
nNeurons = numel(neuronInfo);
fprintf('\nDone!\n');

%% Load mesh
if ~exist('allenMesh')
    fprintf('\nLoading mesh file..');
    load(meshFile);
end

%% get area Info
structInfo = getAllenAnatomyInfo(area,'Property','acronym');
indStruct = find(strcmpi({allenMesh.acronym}, area));

%% Go through individual neurons. 
bank = [];
for iNeuron = 1:nNeurons
    fprintf('\nNeuron [%i\\%i]',iNeuron,nNeurons);
    neuron = neuronInfo(iNeuron).morphology;
    % get anatomy info.
    ana =  anatomyFcn(neuron,structInfo);
    % check thresholds.
    if ana.(hemi).nEndPoints>=endPointThreshold
        % get centroid.
        info = centFcn(neuron.axon,allenMesh(indStruct),projAxis,hemi);
        % get soma position.
        somaPos = neuronInfo(iNeuron).position(somaAxis)/1000;
        % Convert to allen axis.
        if somaAxis == 1, somaPos = 11.400 - somaPos; end
        if projAxis == 1, info.Centroid = 11.400 - info.Centroid; end
        % Store.
        bank = [bank;somaPos, info.Centroid];
    end
end

%% Plot
hFig = figure('Color',[1,1,1],'Units','points');
hAx = axes(...
    'Units','points',...
    'FontName','Arial',...
    'FontSize',8);
hAx.Position(3:4) = [70,75];
scatter(bank(:,1),bank(:,2),pi*(1.25^2),[0,0,0],'filled');
hold on
% curve fit.
[fitObj,~] = fit(bank(:,1),bank(:,2),'poly1');
hL = plot(fitObj);
hL.Color = [0,0,0];
hL.LineStyle = '--';
legend off
% format.
hAx.TickDir = 'out';
axisLabels = {'medial-lateral','superior-inferior','anterior-posterior'};
xlabel(sprintf('Soma position\n%s (mm)',axisLabels{somaAxis}));
ylabel(sprintf('Axon centroid\n%s (mm)',axisLabels{projAxis}));
% x axis.
xticks = [2.5:0.5:5];
hAx.XLim = [xticks(1),xticks(end)];
hAx.XTick = xticks;
hAx.XTickLabel(2:2:numel(hAx.XTickLabel)) = {''};
% y axis.
yticks = [6:0.2:7.2];
hAx.YLim = [yticks(1),yticks(end)];
hAx.YTick = yticks;
hAx.YTickLabel(2:2:numel(hAx.YTickLabel)) = {''};
%
hAx.XColor = [0,0,0]; hAx.YColor = [0,0,0];
hAx.XLabel.Color = [0,0,0]; hAx.YLabel.Color = [0,0,0];
hAx.OuterPosition(1:2) = [5,5];
hFig.Position(3:4) = hAx.OuterPosition(3:4);
%stats.
regInfo = regstats(bank(:,1),bank(:,2),'linear');
text(0.95,0.95,sprintf('\nr2: %.2f\n\tp: %.6f',regInfo.rsquare,regInfo.tstat.pval(2)),'Units','normalized',...
    'HorizontalAlignment','right','FontSize',8,'Color',[0,0,0])
hAx.Units = 'normalized'; hFig.Units = 'normalized';