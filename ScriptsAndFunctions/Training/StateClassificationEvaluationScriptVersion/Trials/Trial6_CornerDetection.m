% TRIAL6_CORNERDETECTOR Trial 6 - Plot the results of the corner detector
% for some fields.
%
% Yaguang Zhang, Purdue, 05/22/2017

% Load data and set the current Matlab directory.
cd(fileparts(mfilename('fullpath')));
prepareTrial;
cd(fileparts(mfilename('fullpath')));

% The file to process.
idxFile = 2;
% The number of consecutive samples to inspect in the window.
windowSize = 5;
% For the first combine (file 2) in the data set.
[ cornerLabels ] = detectCorners( files(idxFile),windowSize );

% Save the result.
fileName = ['Trial6_Results_cornerLabels_idxFile_', num2str(idxFile) ,...
    '_windowSize_', num2str(windowSize)];
save([fileName, '.mat'], 'cornerLabels');

% Figures.
file = files(idxFile);
hFigCorners = figure; hold on;
plot3k([file.lon, file.lat, cornerLabels],'ColorBar',false);
hold off; daspect auto; plot_google_map('MapType', 'satellite');
title('Corner Detector');
saveas(hFigCorners, [fileName, '_Corners.png']);
saveas(hFigCorners, [fileName, '_Corners.fig']);

% EOF