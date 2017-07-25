% TRIAL4_VEHICLEHEADINGESTIMATION Trial 4 - Plot the estimated vehicle
% heading (note this is not necessarily the direction to which the vehicle
% moves, e.g. when the vechile moves backward) for a few GPS tracks.
%
% Yaguang Zhang, Purdue, 05/17/2017

% Load data and set the current Matlab directory.
cd(fileparts(mfilename('fullpath')));
prepareTrial;
cd(fileparts(mfilename('fullpath')));

% 1: Truck; 2: Combine; 64: Grain Cart.
indicesFilesToPlot = 64;%[1, 2, 64];
MAX_NUM_OF_SAMPLES_TO_SHOW = 5000;
DEBUG = true;
close all;

for idxFileC = indicesFilesToPlot
    % [ vehHeading, isForwarding, x, y, utmZones, refBearing, ...
    %    hFigArrOnTrack, hFigDiffHist, hFigMap ] ... =
    %    estimateVehicleHeading( file, DEBUG )
    if(length(files(idxFileC).lat)>MAX_NUM_OF_SAMPLES_TO_SHOW)
        [ ~, ~, ~, ~, ~, ~, hFigArrOnTrack, hFigDiffHist, hFigMap ] = ...
            estimateVehicleHeading( subFile(files(idxFileC), ...
            1:MAX_NUM_OF_SAMPLES_TO_SHOW), DEBUG);
    else
        [ ~, ~, ~, ~, ~, ~, hFigArrOnTrack, hFigDiffHist, hFigMap ] = ...
            estimateVehicleHeading( files(idxFileC), DEBUG);
    end
    figFileName = ['Trial4_Results_ArrOnTrack_file_', ...
        num2str(idxFileC), '_', files(idxFileC).type];
    saveas(hFigArrOnTrack, [figFileName, '.png']);
    saveas(hFigArrOnTrack, [figFileName, '.fig']);

    figFileName = ['Trial4_Results_DiffHist_file_', ...
        num2str(idxFileC), '_', files(idxFileC).type];
    saveas(hFigDiffHist, [figFileName, '.png']);
    saveas(hFigDiffHist, [figFileName, '.fig']);
    
    figFileName = ['Trial4_Results_TrackOnMap_file_', ...
        num2str(idxFileC), '_', files(idxFileC).type];
    saveas(hFigMap, [figFileName, '.png']);
    saveas(hFigMap, [figFileName, '.fig']);
end

% EOF