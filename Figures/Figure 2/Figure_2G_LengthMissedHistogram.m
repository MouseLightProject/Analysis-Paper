%% Get current location.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Consensus','SingleNeuron');

%% load error info.
load(fullfile(dataFolder,'errorInfo.mat'));

%% Collect branches.
fragInfo = [errorInfo.Frag];
manInfo = [errorInfo.Man];
branches.Frag = cat(1,fragInfo.fnBranches); % false negatives only (missed branches).
branches.Man =  cat(1,manInfo.fnBranches);

%% Get length.
branchLength = [];
types = {'Frag','Man'};
for iType = 1:2
    cType = types{iType};
    nBranches = numel(branches.(cType));
    branchLength.(cType) = NaN(nBranches,1);
    for iBranch=1:nBranches
        totLength = swcLength(branches.(cType){iBranch});
        branchLength.(cType)(iBranch) = totLength/1000; % mm.
    end
end

%% Plot.
histBins = [0:0.5:10];
hFig = figure;
hAx = axes;
hHMan = histogram(branchLength.Man,histBins);
hHMan.Normalization = 'probability';
hHMan.FaceColor = [0,0,0];
hold on;
hHFrag = histogram(branchLength.Frag,histBins);
hHFrag.Normalization = 'probability';hold on
hHFrag.FaceColor = [0.4,0.4,0.4];
box off
hAx.TickDir = 'out';
hHMan.FaceAlpha = 1;
hAx.XLim(1) = histBins(1);
hAx.XLim(2) = histBins(end);
xlabel('Length of Missed Branch (mm)');
ylabel('Occurence (norm.)');
hAx.PlotBoxAspectRatio = [0.87,1,1];
hFig.Renderer = 'painter';