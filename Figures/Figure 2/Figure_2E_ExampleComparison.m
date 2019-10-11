%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Comparison');
%
anaGroup = 1; %1-4
typeAna = 'Frag'; %Frag or Man.

%% load data.
load(fullfile(dataFolder,'comparison_data'));

%% Grab allen data.
allenFile = fullfile(tempdir,'allen.nrrd');
if isempty(dir(allenFile))
    fprintf('\nGrabbing Allen average volume');
    websave(allenFile,'http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/average_template/average_template_50.nrrd');
end
stack = nrrdread(allenFile);
stack = permute(stack,[1,3,2]);

%% Space settings.
extDim = [10,10,10,;11400,8000,13200];

%% Plot Coronal Base unique's
dimSel = [1,2];
hFig = figure;
hAx = axes;
hAx.YDir = 'reverse';
hAx.DataAspectRatio = [1,1,1]; hAx.TickDir = 'out';
hold on
hAx.XLim = extDim(:,1)';
hAx.YLim = extDim(:,2)';

%% Show allen image.
I = max(stack(:,:,(2000/50):(4000/50)),[],3);
RA = imref2d(size(I),50,50);
imshow(I,RA,[30,100]); hold on

%base.
hBase = plotSwcFast2D(swcInfo(anaGroup).(typeAna).base,dimSel);
hBase.Color = [0,0,0];
%an1
hAn1 = plotSwcFast2D(swcInfo(anaGroup).(typeAna).uni1,dimSel);
[hAn1.Color] = deal([1,0,1]);
[hAn1.LineWidth] = deal(2);
%an2.
hAn2 = plotSwcFast2D(swcInfo(anaGroup).(typeAna).uni2,dimSel);
[hAn2.Color] = deal([57, 181, 74]/255);
[hAn2.LineWidth] = deal(2);
%dendrite.
hDend = plotSwcFast2D(dendSwc,dimSel);
hDend.Color = [124,124,124]/255;
hDend.LineWidth = 3;
hFig.Renderer = 'painter';