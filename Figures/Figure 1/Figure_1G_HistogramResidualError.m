%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Stitching');
infoFile = 'mse_results_iterated';

% C_num: number of descs
% C_mse: residual magnitude
% C_mse<x,y,z>: residual magniture on <x,y,z> axis for C_mse
% C<X,Y,Z>_mse are similar to C_mse, but just the subset of descriptors with
% <x,y.z> adjacent tiles

%% Analysis parameters.
minPnts = 0;
cDim = {3,[1,2]};
titleStr = {'Axial Axis','Lateral Axis'};
alphaValues = [0.6,0.6];
color = [0,0,0;0,0,0];
interiorOnly = true;

%% load data.
load(fullfile(dataFolder,infoFile));
numPnts = C_num';
resError = [C_msex',C_msey',C_msez'];
if interiorOnly
    numPnts = numPnts(finterior,:);
    resError = resError(finterior,:);
end

%% Collect data.
data = cell(numel(cDim),1);
for iDim = 1:numel(cDim)
    ind = find(numPnts>=minPnts);
    temp = resError(ind,cDim{iDim});
    if size(temp,2)==2
        data(iDim) = {sqrt(temp(:,1).^2 + temp(:,2).^2)};
    else
        data(iDim) = {temp};
    end
end

%% Plot histogram.
for iDim = 1:numel(cDim)
    hFig = figure;
    hAx = axes;
    hB = histogram(data{iDim},[0:0.05:2],'Normalization','probability'); hold on
    hB.FaceColor = color(iDim,:);
    hB.FaceAlpha = alphaValues(iDim);
    hAx.Box = 'off';
    hAx.TickDir = 'out';
    hAx.XLim = [0,2];
    hAx.XTick = [0:0.25:2];
    xlabel('Residual Error (\mum)');
    ylabel('Frequency (%)');
    title(titleStr{iDim});
    hFig.Renderer = 'painter';
    hAx.YLim = [0,0.2];
end
