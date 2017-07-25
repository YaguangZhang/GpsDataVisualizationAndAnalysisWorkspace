%CONVERTFIGTOPNG
% This file will convert all .fig files in the same filefolder as this
% script it self to .png files with the same file names.
%
% Just copy this file to the filefolder where the .fig files are kept, and
% run it.
%
% Yaguang Zhang, Purdue, 03/07/2015

disp('Start converting.');
disp(' ');
% Change current Matlab directory to this script's filefolder.
cd(fullfile(fileparts(which(mfilename))));

% Scan all existing log files in this filefolder (subdirectories excluded).
figFileList = rdir('*.fig');

for idxFigFile = 1:length(figFileList)
    disp(strcat('Converting', 23, 23, figFileList(idxFigFile).name,'...(', ...
        num2str(idxFigFile),'/',num2str(length(figFileList)),')'));
    
    close all;
    hFigFile = openfig(figFileList(idxFigFile).name);
    frameFigFile = getframe(hFigFile);
    
    imwrite(frameFigFile.cdata, ...
        [figFileList(idxFigFile).name(1:(end-4)), '.png']);
end

close all;

disp(' ');
disp('Done.')
% EOF