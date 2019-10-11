%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','VAL');
infoFile = '11-01-NeuronInfo.mat';
meshFile = fullfile(mainFolder,'..','..','AllenFiles','allenMesh.mat');

%% Analysis Parameters.
cells = {'AA0586', 'AA0485', 'AA0451',...
    'AA0366', 'AA0364', 'AA0350',...
    'AA0349', 'AA0348', 'AA0347',...
    'AA0346', 'AA0345', 'AA0343',...
    'AA0340', 'AA0339', 'AA0338',...
    'AA0337', 'AA0331', 'AA0302'};
areas = {'MO','SS'};
rotation = [90,0,35];
borderLoc = 1800 ;  % in rotated space.
borderDim = 2;      %in rotated space.
somaDim = 1;

%% Memoize functions (for efficiency in recalculations).
if ~exist('sessionFcn'),  sessionFcn= memoize(@(x,y) load(x)); end
if ~exist('centFcn'),  centFcn = memoize(@(x,y,z,h,r) calcCentroid(x,y,z,'Hemi',h,'Rotation',r)); end
centFcn.CacheSize = 200;

%% Load neuron info.
fprintf('\nLoading neuron Info..');
neuronInfo = sessionFcn(fullfile(dataFolder,infoFile));
neuronInfo = neuronInfo.neuronInfo;
% Filter neurons.
neuronInfo = neuronInfo(ismember({neuronInfo.id},cells));
if numel(neuronInfo)~=numel(cells), error('Could not find cell in neuron info file'); end
nNeurons = numel(neuronInfo);
fprintf('\nDone!\n');

%% Load mesh
if ~exist('allenMesh')
    fprintf('\nLoading mesh file..');
    load(meshFile);
end

%% Go through areas.
bank = NaN(nNeurons,3);
for iArea = 1:2
   cArea = areas{iArea};
   indArea = find(strcmpi({allenMesh.acronym},cArea));
   % Go through neurons.
   for iNeuron = 1:nNeurons
       fprintf('\nNeuron [%i\\%i]',iNeuron,nNeurons);
       % get centroid.
       [info,coords] = centFcn(neuronInfo(iNeuron).morphology.axon,...
           allenMesh(indArea),borderDim,...
           'ipsi',rotation);
       % get distance to border.
       bank(iNeuron,1) = neuronInfo(iNeuron).position(somaDim); 
       bank(iNeuron,iArea+1) = pdist2(borderLoc/1000,info.Centroid);
   end
end

%% Calculate values
x = 11.400-(bank(:,1)/1000);
y = mean([bank(:,2),bank(:,3)],2);

%% Plot.
hFig = figure('Color',[1,1,1],'Units','points');
hAx = axes(...
    'Units','points',...
    'FontName','Arial',...
    'FontSize',8);
hAx.Position(3:4) = [75,80];
scatter(x,y,pi*(1.6^2),[0,0,0],'filled');
hold on
% curve fit.
[fitObj,~] = fit(x,y,'poly1');
hL = plot(fitObj);
hL.Color = [0,0,0];
hL.LineStyle = '--';
legend off
% format.
hAx.TickDir = 'out';
hAx.YLim = [0,2.25];
hAx.XLim = [6.4,7.2];
hAx.XTick = [6.4:0.1:7.2];
hAx.XTickLabel(2:2:numel(hAx.XTickLabel)) = {''};
hAx.YTick = [0:0.5:2];
hAx.YTickLabel(2:2:numel(hAx.YTickLabel)) = {''};
hAx.XColor = [0,0,0]; hAx.YColor = [0,0,0];
axisLabels = {'medial-lateral','superior-inferior','anterior-posterior'};
xlabel(sprintf('Soma position\n%s (mm)',axisLabels{somaDim}));
ylabel(sprintf('Centroid distance\nMO\\\\SS border (mm)'));
hAx.XLabel.Color = [0,0,0]; hAx.YLabel.Color = [0,0,0];
hAx.OuterPosition(1:2) = [5,5];
hFig.Position(3:4) = hAx.OuterPosition(3:4);
%stats.
regInfo = regstats(x,y,'linear');
text(0.95,0.95,sprintf('\nr2: %.2f\n\tp: %.6f',regInfo.rsquare,regInfo.tstat.pval(2)),'Units','normalized',...
    'HorizontalAlignment','right','FontSize',8,'Color',[0,0,0])
hAx.Units = 'normalized'; hFig.Units = 'normalized';


