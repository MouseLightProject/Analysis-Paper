%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','IT');
infoFile = '11-25-NeuronInfo';
areas = {'Isocortex','STR'};
% scatter sizing.
lengthRange = [50,400]; % in mm. (input range).
radRange = [1.5,4];     % in pnts. (output range).   

%% Memoize functions (for efficiency in recalculations).
if ~exist('sessionFcn'),  sessionFcn= memoize(@(x) load(x)); end

%% Load neuron info.
fprintf('\nLoading neuron Info..');
neuronInfo = sessionFcn(fullfile(dataFolder,infoFile));
neuronInfo = neuronInfo.neuronInfo;
nNeurons = numel(neuronInfo);
fprintf('\nDone!\n');

%% Collect anatomy info.
structInfo = getAllenAnatomyInfo([{'root'},areas],'Property','acronym');
anatomy = anatomyInfo([neuronInfo.morphology],structInfo,'Verbose',true);
anatomy = anatomy.bi.length./1000;

%% Go through layers
layers = {'L2/3','L5','L6'};
for iLayer = 1:numel(layers)
    % select neurons in layer.
    cLayer = layers{iLayer};
    ind = strcmpi({neuronInfo.layer},cLayer);
    bank = anatomy(ind,:);
    layerStr = strrep(cLayer,'/','-');
    
    % Calculate proportion.
    XData = (bank(:,2)./bank(:,1))*100;
    YData = (bank(:,3)./bank(:,1))*100;
    SData = bank(:,1);

    % Calculate marker size based on total length. 
    Length2Rad = @(value,lRange,radRange) radRange(1) + (mat2gray(value,lRange)*(radRange(2)-radRange(1)));
    radData = Length2Rad(SData,lengthRange,radRange);
    
    % prepare figure.
    hFig = figure('Color',[1,1,1],...
        'Units','points');
    hAx = axes('Units','points',...
        'Position',[40,30,90,70],...
        'FontName','Arial','FontSize',8,...
        'XTick',[0:20:100],'YTick',[0:20:100],...
        'TickDir','out',...
        'XLim',[0,100],'YLim',[0,100]);
    hFig.Position(3:4) = [170,120];
    hAx.XLabel.Color = [0,0,0];
    hAx.XLabel.VerticalAlignment = 'top';
    hAx.YLabel.Color = [0,0,0];
    hAx.XAxis.Color = [0,0,0];
    hAx.YAxis.Color = [0,0,0];
    xlabel('Cortex - Axon length (%)');
    ylabel('Striatum - Axon length (%)');
    title(sprintf('IT neurons %s',layerStr));
    
    % plot scatter.
    hold on
    for iNeuron = 1:numel(XData)
        hS = scatter(XData(iNeuron),YData(iNeuron),...
            pi*radData(iNeuron)^2,[0,0,0]);
        hS.MarkerEdgeColor = [0,0,0];
        hS.MarkerEdgeAlpha = 1;
        hS.MarkerFaceColor = [0.2,0.2,0.2];
        hS.MarkerFaceAlpha = 0.4;
    end
    
    % plot 100% line.
    hL = line([0,100],[100,0],...
        'LineWidth',1,'LineStyle','--',...
        'Color',[0,0,0]); 
    
    % scale circles.
    sizeVals = 50:100:350;
    radVals = Length2Rad(sizeVals,lengthRange,radRange);
    yVals = [10:10:numel(radVals)*10];
    for iPnt = 1:numel(radVals)
        hS = scatter( 10,yVals(iPnt),pi*radVals(iPnt)^2,[1,0,0],'filled');
        hT = text(15,yVals(iPnt),num2str(sizeVals(iPnt)),...
            'Fontname','Arial','FontSize',7);
    end
    hFig.Renderer = 'painters';
    hAx.Units = 'normalized'; hFig.Units = 'normalized';
end