%% Get current location.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','SNR');
endId = [179,135,284,303]; % example ends in order (from session file).

%% load error info.
load(fullfile(dataFolder,'snrInfo.mat'));
load(fullfile(dataFolder,'endLoc.mat'));

%% Plot
hFig = figure;
hAx = axes;
hB = histogram(info,[0:2:100]);
box off
hAx.TickDir = 'out';
xlabel('SNR');
ylabel('Count');
xlim([0,100]);
hAx.PlotBoxAspectRatio = [0.85,1,1];
hB.FaceColor = [0,0,0];
hFig.Renderer = 'painter';
hAx.XTick = [0:10:100];

%% go through pnts.
for iPoint = 1:numel(endId)
    cPnt = endLoc(endId(iPoint),:);
    [indPnt] = find(ismember(swc(:,3:5),cPnt,'rows'));
    fprintf('\nPoint: %i snr: %.0f distance to soma: %.1f',...
        endId(iPoint), info(endId(iPoint)),dists(indPnt)/1e3);
end