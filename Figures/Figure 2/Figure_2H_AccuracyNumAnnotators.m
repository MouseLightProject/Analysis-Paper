%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Consensus','SingleNeuron');
types = {'Frag','Man'};
colors = [0.5,0.5,0.5;0,0,0];
stepSize = 10000;       % number of points to check at a time (for computational efficiency does not effect analysis)
maxDist = 5;            % minimal distance considerd covered (in um).
upsampleSize = 1;       % in um (smaller is more accurate/longer calculation time.).

%% Get annotator folders..
anList = dir(fullfile(dataFolder));
anList = anList([anList.isdir]);
anList = {anList(3:end).name};

%% Get coverage info.
resData = [];
for iType=1:2
    cType = types{iType};
    fprintf('\n%s',cType);
    % read gold standard and upsample.
    goldSwc = importSWCFast(fullfile(dataFolder,sprintf('goldstandard_%s.swc',cType)));
    goldSwc = upsampleSWC(goldSwc,upsampleSize);
    nPntsGold = size(goldSwc,1);
    % Go through annotators.
    dist = NaN(size(goldSwc,1),8); % stores distances.
    for iAn = 1:numel(anList)
        fprintf('\nAnnotator %i\\%i',iAn,8);
        % load annotator file an upsample.
        cFile = dir(fullfile(dataFolder,anList{iAn},cType,...
            sprintf('%s*.swc',cType)));
        if isempty(cFile), error('Could not find %s',cFile.name); end
        swc = importSWCFast(fullfile(cFile.folder,cFile.name));
        swc = upsampleSWC(swc,upsampleSize);
        % get min. distance for nodes in gold standard to nodes in annotator neuron.
        for i = 1:stepSize:size(goldSwc,1)
            iEnd = i+stepSize-1;% set stepsize.
            if iEnd>size(goldSwc,1), iEnd=size(goldSwc,1); end
            dist(i:iEnd,iAn) = pdist2(swc,goldSwc(i:iEnd,:),'Euclidean','Smallest',1)';
        end
    end
    % Flag nodes that fall in radius (Coverage).
    coverData = dist<=maxDist;
    % Store coverage.
    resData.(cType) = cell(8,1);
    resData.(cType)(1) = {(sum(coverData,1)/nPntsGold*100)'};
    % Permutate annotator combinations.
    for nAn = 2:8
        p = nchoosek([1:8],nAn);
        % Go through permutations.
        temp = NaN(size(p,1),1);
        for iPerm = 1:size(p,1)
            cAn = p(iPerm,:);
            temp(iPerm) = (sum(any(coverData(:,cAn),2))/nPntsGold)*100;
        end  
        resData.(cType)(nAn) = {temp};
    end
    fprintf('\n')
end

%% Print.
for iType = 1:2
    cType = types{iType};
    fprintf('\nCoverage %s',cType);
    for nAn = 1:8
        values = resData.(cType){nAn};
        fprintf('\n\tn = %i, %.1f +-%.1f\t(combinations:%i)',...
            nAn,mean(values),std(values),numel(values));
    end
end

%% Figure.
hFig = figure('Color',[1,1,1],'Units','points');
hAx = axes('Units','points');
hAx.TickDir = 'out';
hAx.LineWidth = 1;
hAx.Position(3:4) = [64,75];
hAx.XColor = [0,0,0];hAx.YColor = [0,0,0];
xlabel(sprintf('Number of\nAnnotators'));
ylabel(sprintf('Axon Length\n(%% of consensus)'));
xlim([0.5,8.5]);
ylim([75,100]);
hAx.XTick = [1:8];
hAx.YTick = [75:2.5:100];
hAx.YTickLabel(2:2:numel(hAx.YTickLabel)) = {''};
hAx.OuterPosition(1:2) = [5,5];
hFig.Position(3:4) = hAx.OuterPosition(3:4);
hold on;
% plot Errorbars.
for iType = 1:2
    cType = types{iType};
    hE = errorbar(1:8,cellfun(@mean,[resData.(cType)]),...
        cellfun(@(x) std(x)/sqrt(numel(x)),[resData.(cType)]));
%         cellfun(@(x) std(x),[resData.(cType)]));            
    hE.Color = colors(iType,:);
    hE.LineWidth = 0.5;
    hE.Marker = 'o';
    hE.MarkerFaceColor = hE.MarkerEdgeColor;
    hE.CapSize = 5;
    hE.MarkerSize = 2.5;
end

