%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Segments');
sampleName = '2018-07-02';

type = {'frags','full'};
for iType = 1:2
    %% Load info.
    cType = type{iType};
    cFile = fullfile(dataFolder,sprintf('%s-%s.mat', sampleName, cType));
    load(cFile);
    % take out single-points.
    bank = bank(bank>0);
    % take out single garbage outlier.
    bank = bank(bank<1000000);
    %% Output.
    fprintf('\nSegments(%s)\t%.1f +- %.1f\t(n=%i)',...
        cType,mean(bank),std(bank),numel(bank()));   
end