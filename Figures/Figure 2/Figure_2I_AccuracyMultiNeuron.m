%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Consensus','MultiNeuron');
types = {'Frag'};
colors = [0.5,0.5,0.5;0,0,0];
stepSize = 10000;       % number of points to check at a time (for computational efficiency does not effect analysis)
maxDist = 5;            % minimal distance considerd covered (in um).
upsampleSize = 1;       % in um (smaller is more accurate/longer calculation time.).

%% Load error info.
load(fullfile(dataFolder,'errorInfo.mat'),'errorInfo','goldSwcs');
nNeurons = size(errorInfo,2);
nAn = size(errorInfo,1);

%% Go through neurons.
resData = [];
for iNeuron = 1:nNeurons
    cNeuron = errorInfo(1,iNeuron).Frag.neuron;
    fprintf('\nNeuron %s [%i\\%i]',cNeuron,iNeuron,nNeurons);  
    for iType=1:numel(types)
        cType = types{iType};
        fprintf('\n\tReading Consensus: %s',cType);
        % read gold standard and upsample.
        goldSwc = goldSwcs(iNeuron).(cType);
        goldSwc = upsampleSWC(goldSwc,upsampleSize);
        nPntsGold = size(goldSwc,1);
        % Go through annotators.
        dist = NaN(size(goldSwc,1),nAn); % stores distances. 
        for iAn = 1:nAn
            fprintf('\n\tAnnotator %i\\%i',iAn,nAn);
            swc = errorInfo(iAn,iNeuron).(cType).swc;
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
        % Store coverage for 1 annotator.
        resData(iNeuron).(cType) = cell(nAn,1);
        resData(iNeuron).(cType)(1) = {(sum(coverData,1)/nPntsGold*100)'};      
        % Permutate annotator combinations.
        for numAnInPerm = 2:nAn-1
            p = nchoosek((1:nAn),numAnInPerm);
            % Go through permutations.
            temp = NaN(size(p,1),1);
            for iPerm = 1:size(p,1)
                cAn = p(iPerm,:);
                temp(iPerm) = (sum(any(coverData(:,cAn),2))/nPntsGold)*100;
            end  
            resData(iNeuron).(cType)(numAnInPerm) = {temp};
        end 
        resData(iNeuron).(cType)(nAn) = {100};
    end
end

%% Get mean values.
meanRes = [];
for iType = 1:numel(types)
    cType = types{iType};
    fprintf('\nCoverage %s',cType);
    for numAnInPerm = 1:nAn
        for iNeuron = 1:nNeurons
            meanRes.(cType)(numAnInPerm,iNeuron) = mean(resData(iNeuron).(cType){numAnInPerm});
        end
        % print.
        values = meanRes.(cType)(numAnInPerm,:);
        fprintf('\n\tn = %i, %.1f +- %.1f%%',numAnInPerm, mean(values),std(values));
    end
end

%% Plot figure.
hFig = figure('Color',[1,1,1]);
hAx = axes; 
hAx.XLim = [0.5,nAn+0.5];
hAx.XTick = [1:nNeurons];
hold on;
hAx.TickDir = 'out';
for iType = 1:numel(types)
    cType = types{iType};
    values = meanRes.(cType);
    % Plot individual.
    for iNeuron = 1:nNeurons
        hP = plot([1:nAn],values(:,iNeuron));
        hP.Color = [0.8,0.8,0.8];
        hP.LineWidth = 0.25;
        hP.Marker = 'o';
        hP.MarkerSize = 4;
        hP.MarkerEdgeColor = [0.5,0.5,0.5];
        hP.MarkerFaceColor = hP.MarkerEdgeColor;
    end
    %plot average.
    hE = errorbar([1:nAn],mean(values,2),std(values,[],2)/sqrt(nNeurons));
    hE.Marker = 'o';
    hE.MarkerEdgeColor = [0,0,0];
    hE.MarkerFaceColor = hE.MarkerEdgeColor;
    hE.Color = [0,0,0];
    hE.MarkerSize = 8;
    hE.CapSize = 10;
    hE.LineWidth = 1;
end
xlabel(sprintf('Number of\nannotators'));
ylabel(sprintf('Axonal length\n(%% of consensus)'));


