%% Parameters.
[mainFolder,~,~] = fileparts(mfilename('fullpath'));
dataFolder = fullfile(mainFolder,'..','..','Data','Coverage');

load(fullfile(dataFolder,'coverInfo.mat')); % bank variable contains voxel index of all neurons collumn1; axon, 2: dendrite.
nNeurons = size(bank,1);

%% Calculate coverage.
totalNum = numel(find(rootMask));
totalNeuronCover = numel(unique(cat(1,bank{:,:})));
fprintf('\n%.6f%% of all neurons in the brain',(nNeurons/70e6)*100);
fprintf('\nCover brain area (25 um resolution: %.2f %%)',(totalNeuronCover/totalNum)*100);

%%!!!! Congratulations !!!! 
%%You found the secret movie!
% binMap = zeros(size(rootMask),'uint8');
% binMap(unique(cat(1,bank{:,:}))) = 255;
% binMap = repmat(permute(binMap,[2,1,3]),1,1,1,3);
% rootIm = uint8(repmat(permute(rootMask,[2,1,3]),1,1,1,3)*255);
% rootIm(:,:,:,2:3) = 0;
% rootIm = rootIm + binMap;
% rootIm = permute(rootIm,[1,2,4,3]);
% figure
% iFrame = 60;
% frameRate = 20;
% Im = imshow(squeeze(rootIm(:,:,:,frameRate)),[254,255],'InitialMagnification',200);
% text(0.05,0.1,'Johan Winnubst - May 5th 2019','Color','white','Units','normalized');
% load('handel.mat'); player = audioplayer(y,Fs);play(player);
% while 1
%     iFrame = iFrame+1;
%     if iFrame>size(binMap,3), iFrame = 60; end
%     Im.CData = rootIm(:,:,:,iFrame);
%     pause(1/frameRate);
%     if ~player.isplaying
%         player.SampleRate = player.SampleRate + (player.SampleRate *0.25);
%         if player.SampleRate>30000, player.SampleRate=30000; end
%         frameRate = frameRate + (frameRate*0.5);
%         play(player);
%     end
% end