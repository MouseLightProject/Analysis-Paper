%% Get current location.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Consensus','SingleNeuron');

%% Analysis parameters.
typeMethod = 'Frag';
lengthErrorRate = 10; % in mm. reports as -- errors per X mm;

%% load error info.
load(fullfile(dataFolder,'errorInfo.mat'));

%% Go through errors.
lengthAxon = NaN(size(errorInfo,2),1);
numErrors = NaN(size(errorInfo,2),1);
for iAnn = 1:size(errorInfo,2)
    fprintf('\nAnnotator %i\\%i',iAnn,size(errorInfo,2));
    % get length.
    swc = errorInfo(iAnn).(typeMethod).swc;
    totLength = swcLength(swc);
    lengthAxon(iAnn) = totLength/1000;
    % get mistakes.
    numErrors(iAnn) = errorInfo(iAnn).(typeMethod).nFN +...
        errorInfo(iAnn).(typeMethod).nFP;
end
% calculate error rate.
errorRate = (numErrors./lengthAxon)*lengthErrorRate;

%% output.
fprintf('\nReconstruction Method: %s',typeMethod);
fprintf('\nError Rate %.1f +- %.1f errors per %i mm',...
    mean(errorRate),std(errorRate), lengthErrorRate);
fprintf('\nRange: %.1f - %.1f',min(errorRate),max(errorRate));