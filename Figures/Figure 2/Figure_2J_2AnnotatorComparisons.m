%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Consensus');

%% Load data.
load(fullfile(dataFolder,'annSimilarity.mat'));
nNeurons=numel(annSimilarity);

%% average percentage agreement as %total.
bank = NaN(nNeurons,1);
for iNeuron = 1:nNeurons
    cNeuron = annSimilarity(iNeuron);
    bank(iNeuron) = (cNeuron.base.length/cNeuron.consensus.length)*100;
end
bank(bank>100)=100; % edge cases.
bank(isnan(bank)) = [];
fprintf('\nAverage agreement length (normalized)');
fprintf('\n\t %.1f +- %.1f %% (n=%i)',mean(bank),std(bank),nNeurons);

%% cdf plot.
hFig = figure('Color',[1,1,1]);
hAx = axes;
hP = cdfplot(bank);
box off;
hAx.TickDir = 'out';
hAx.GridLineStyle = 'none';
xlabel('Agreement (% of total length)');
ylabel('Cumulative probability');
hP.Color = [0,0,0];
hP.LineWidth = 1;
title('');
hAx.XLim = [0,100];
hAx.YLim = [0,1];