%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Registration','manualAnnotation');
samples = {'2018-07-02','2018-10-01','2018-04-13'};
colors = [1,0,0;0,1,0;0,0,1];
areas = {'AD','fr','STN'};
    
%% Go through areas..
bank = NaN(numel(samples),numel(areas));
for iArea = 1:numel(areas)
    fprintf('\nArea: %s',areas{iArea});
    allen = load(fullfile(dataFolder,sprintf('%s-Allen.mat',areas{iArea})),'BW','voxelSize');   
    for iSample = 1:numel(samples)
        fprintf('\n\tSample: %i of %i',iSample,numel(samples));        
        sample = load(fullfile(dataFolder,sprintf('%s-%s.mat',areas{iArea},samples{iSample})),'BW','voxelSize');
        % go through frames.
        displace = NaN(size(sample.BW,3),1);
        for iFrame = 1:size(sample.BW,3)
            % gather centroids.
            stats = [];                
            stats.sample = regionprops(sample.BW(:,:,iFrame),'Centroid','Area');
            stats.allen = regionprops(allen.BW(:,:,iFrame),'Centroid','Area'); 
            % check that there are not more then 2 areas and that second
            % area is smaller then 5 pixels.
            if (size(stats.allen,1)>2 || size(stats.sample,1)>2) || ...
                (size(stats.allen,1)>2 && min([stats.allen.Area])>5) ||...
                (size(stats.sample,1)>2 && min([stats.sample.Area])>5)                
                error('Unexpected outline for %s',areas{iArea});
            end
            % only pass largest area.
            [~,ind] = max([stats.allen.Area]);
            stats.allen = stats.allen(ind); 
            [~,ind] = max([stats.sample.Area]);
            stats.sample = stats.sample(ind);                    
            % to um.
            stats.allen.Centroid(1) = stats.allen.Centroid(1) * allen.voxelSize(1);
            stats.allen.Centroid(2) = stats.allen.Centroid(2) * allen.voxelSize(2);
            stats.sample.Centroid(1) = stats.sample.Centroid(1) * sample.voxelSize(1);                
            stats.sample.Centroid(2) = stats.sample.Centroid(2) * sample.voxelSize(2);    
            % store distance.
            displace(iFrame) = pdist2(stats.allen.Centroid,stats.sample.Centroid);
        end
        % store result.
        bank(iSample,iArea) = mean(displace);
    end
end

%% plot.
hFig = figure;
hAx = axes;
% format bar.
hB = bar(1:numel(areas),mean(bank,1)); hold on
hB.FaceColor = [0.5,0.5,0.5];
% format errorbars.
hE = errorbar(1:numel(areas),mean(bank,1), std(bank,[],1)/sqrt(numel(samples)));
hE.LineStyle = 'none';
hE.YNegativeDelta =[];
hE.Color = [0,0,0];
hE.LineWidth = 1;
hE.CapSize = 12;
% individual samples;
for iSample = 1:numel(samples)
    hS = scatter(1:3,bank(iSample,:));
    hS.MarkerEdgeColor = [0,0,0];
    hS.MarkerFaceColor = colors(iSample,:);
    hS.SizeData = 52;
end
% format axis.
hAx.Box = 'off';
hAx.TickDir = 'out';
hAx.XLim = [0.5, numel(areas)+0.5];
hAx.YLim(1) = 0;
hAx.XTick = [1:numel(areas)];
hAx.XTickLabel = areas;
hAx.YLabel.String = 'Offset Centroid (\mum)';