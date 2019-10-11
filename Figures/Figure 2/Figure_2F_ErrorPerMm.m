%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Consensus','SingleNeuron');
types = {'Frag','Man'};

%% Get calculated results.
load(fullfile(dataFolder,'errorInfo.mat'));

%% Collect data.
resData = struct();
for iType = 1:2
    cType = types{iType};
    %% Get length of consensus.
    cGoldFile = fullfile(dataFolder,sprintf('goldstandard_%s.swc',cType));
    goldSwc = importSWCFast(cGoldFile);
    totalLength = swcLength(goldSwc);
    totalLength = totalLength/1000; % length to mm
    
    %% Collect error info.
    nAn = size(errorInfo,2);
    resData.(cType).fp = NaN(nAn,1);
    resData.(cType).fn = NaN(nAn,1);
    for iAn = 1:nAn
        resData.(cType).fn(iAn) = (errorInfo(iAn).(cType).nFN/totalLength); %number of error/total length axon(mm) = mistakes per mm,
        resData.(cType).fp(iAn) = (errorInfo(iAn).(cType).nFP/totalLength);
    end
end

%% get bar data.
dataOrder = [resData.Man.fn,resData.Frag.fn,resData.Man.fp,resData.Frag.fp];
m = mean(dataOrder,1);
semRes = [std(dataOrder,[],1)/sqrt(size(dataOrder,1))];

%% Plot.
barWidth = 0.14;
hFig = figure;
hAx = axes;
hB = bar([m(1:2);m(3:4)],1); hold on
hB(1).FaceColor = [0,0,0];
hB(2).FaceColor = [150,150,150]/255;
hE = errorbar([1-barWidth,1+barWidth,2-barWidth,2+barWidth],m,semRes);
barWidth = 0.145;
hE.YNegativeDelta = [NaN,NaN,NaN,NaN];
hE.Color = [0,0,0];
hE.LineWidth = 1;
hE.CapSize = 12;
hE.LineStyle ='none';
box off
hAx.TickDir = 'out';
ylabel('Errors per mm');
% xlabel('Error Type')
hAx.XTickLabel = {'False Negative', 'False Positive'};
legend({'Manual','Semi-Automated'});
ylim([0,0.2]);
hAx.YTick = [0:.05:0.2];

%% Difference Manual/Fragments signficance test.
[~,pFn] = ttest2(resData.Man.fn,resData.Frag.fn);
[~,pFp] = ttest2(resData.Man.fp,resData.Frag.fp);
fprintf('\nDifference Manual/Semi-Automated');
fprintf('\n\tFalse-negatives:\tp: %.4f',pFn);
fprintf('\n\tFalse-positives:\tp: %.4f',pFp);
fprintf('\n');

%% Difference False positives/False Negatives.
[~,pMan] = ttest(resData.Man.fp,resData.Man.fn);
[~,pFrag] = ttest(resData.Frag.fp,resData.Frag.fn);
[~,pJoined] = ttest([resData.Frag.fp;resData.Man.fp],...
    [resData.Frag.fn;resData.Man.fn]);
fprintf('\nDifference False-positives/False-negatives');
fprintf('\n\tManual:\t\tp: %.4f',pMan);
fprintf('\n\tSemi-auto:\tp: %.4f',pFrag);
fprintf('\n\tJoined:\tp: %.6f',pJoined);
fprintf('\n');
