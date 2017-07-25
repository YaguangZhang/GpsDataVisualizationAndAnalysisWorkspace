%FINDNEARESTVEHICLEs Find nearest vehicles for all samples in files and
%save the results.
%  
% The results are arranged in the cell array nearestVehicles. Each element
% of it is a matrix with 3 colomns: indexNearestVehFile, minDist and
% gpsTimeDiff. Each row is the nearest vehicle info for the cooresponding
% sample.
%
% Yaguang Zhang, Purdue, 09/14/2015

% Set this to be true to turn on the debugging function.
FLAG_DEBUG = false;

close all;
[~, ~, ~, ~, hDebugFig] = ...
    findNearestVehicleBySample(files, 1, ...
    1, 2, ...
    1, FLAG_DEBUG);

nearestVehicles = cell(length(files),1);

for idxFile = 1:length(files)
    disp(strcat(...
        num2str(idxFile),'/',num2str(length(files))...
        ));
    nearestVehicles{idxFile} = nan(length(files(idxFile).gpsTime),1);
    for idxSample = 1:length(files(idxFile).gpsTime)
        [nearestVehicles{idxFile}(idxSample,1), ... indexNearestVehFile
            nearestVehicles{idxFile}(idxSample,2), ... minDist
            nearestVehicles{idxFile}(idxSample,3), ... gpsTimeDiff
            nearestVehicles{idxFile}(idxSample,4)] = ... indicesCurrentSamples
            findNearestVehicleBySample(files, idxFile, ...
            idxSample, ...
            2, ... maxTimeDiffAllowed (in second)
            1, ... FLAG_REUSE_GPS_TIME_RANGES
            FLAG_DEBUG, hDebugFig); % FLAG_DEBUG
    end
end

% EOF