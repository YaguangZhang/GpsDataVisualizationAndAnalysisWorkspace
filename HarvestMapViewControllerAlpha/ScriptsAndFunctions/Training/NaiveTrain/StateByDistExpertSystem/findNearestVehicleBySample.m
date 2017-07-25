function [indexNearestVehFile, minDist, gpsTimeDiff, ...
    indexNearestVehSample, hDebugFig] = ...
    findNearestVehicleBySample(vehFiles, indexCurrentVehFile, ...
    indexCurrentSample, maxTimeDiffAllowed, ...
    FLAG_REUSE_GPS_TIME_RANGES, FLAG_DEBUG, hDebugFig)
%FINDNEARESTVEHICLEBYGPSTIME Find the nearest vehicle.
%
% This function will search the nearest vehicle in vehFiles.
%
% Inputs:
%
%   - vehFiles
%     Relevant vehicles information loaded from the CKT GPS log files. See
%     loadGpsData.mat for more information.
%
%   - indexCurrentVehFile
%     The index of current vehicle in vehFiles.
%
%   - indexCurrentSample
%     Current sample index for this vehicle.
%
%   - maxTimeDiffAllowed
%     The maximum time difference (in second) allowed for the searching.
%
%   - FLAG_REUSE_GPS_TIME_RANGES
%     Optional. Default false. The flag to control whether to save and
%     reuse the variable gpsTimeRanges, the GPS time ranges for all
%     elements in vehFiles.
%
%   - FLAG_DEBUG
%     Optional. Default false. The flag to control whether to generate
%     plots for debugging.
%
%   - hDebugFig
%     Optional. The handle to the debug figure. If not set, will create a
%     new handle.
%
% Outputs:
%
%   - indexNearestVehFile
%     The index for the nearest vehicle found. NaN if no qualified vehicle
%     is found. Only one will be recorded if multiple nearest vehicles are
%     found.
%
%   - minDist
%     The minimum dist if any nearest vehicle is found.
%
%   - gpsTimeDiff
%     The GPS time difference.
%
%   - indexNearestVehSample
%     The sample index for the nearest vehicle. 
%
% Yaguang Zhang, Purdue, 09/14/2015

% Set FLAG_DEBUG if necessary.
if nargin < 5
    FLAG_REUSE_GPS_TIME_RANGES = false;
elseif nargin < 6
    FLAG_DEBUG = false;
elseif nargin < 7
    hDebugFig = nan;
    if FLAG_DEBUG
        hDebugFig =  figure('Name', 'findNearestVehicleBySample_DEBUG', ...
            'NumberTitle', 'off', ...
            'Units','normalized', ...
            'OuterPosition',[0.2 0.2 0.6 0.6]);
    end
end

% Retreive information from vehFiles.
currentVehFile = vehFiles(indexCurrentVehFile);
currentGpsTime = currentVehFile.gpsTime(indexCurrentSample);
currentVehType = currentVehFile.type;
currentVehId = currentVehFile.id;
currentLatLon = [currentVehFile.lat(indexCurrentSample), ...
    currentVehFile.lon(indexCurrentSample)];

% Initialize gpsTimeRanges.
if FLAG_REUSE_GPS_TIME_RANGES ...
        && evalin('base','exist(''gpsTimeRanges'',''var'')')
    % Try to reuse gpsTimeRanges.
    gpsTimeRanges = evalin('base','gpsTimeRanges');
end

if ~exist('gpsTimeRanges','var')
    % Failed in reusing gpsTimeRanges. Need to compute it instead.
    
    gpsTimeRanges = [inf(length(vehFiles),1),  -inf(length(vehFiles),1)];
    % Retrieve time ranges for all the elements in vehFiles.
    for idxVehFile = 1:length(vehFiles)
        % Start time.
        gpsTimeRanges(idxVehFile,1) = vehFiles(idxVehFile).gpsTime(1);
        % End time.
        gpsTimeRanges(idxVehFile,2) = vehFiles(idxVehFile).gpsTime(end);
    end
    
    % Save the result in the base workspace for later reusing.
    putvar(gpsTimeRanges);
end

% Only vehFiles with gpsTimeRange covering currentGpsTime are valid.
indicesValidVehFiles = setdiff(find(gpsTimeRanges(:,1) <= currentGpsTime ...
    & gpsTimeRanges(:,2) >= currentGpsTime),indexCurrentVehFile);

% Find the indices for current samples according to currentGpsTime. Will
% set an element to be NaN if no valid current sample is found for the
% corresponding vehFile.
indicesCurrentSamples = nan(length(vehFiles),1);
% Also record the cooresponding GPS time differences.
gpsTimeDiffCurrentSamples = inf(length(vehFiles),1);

if ~isempty(indicesValidVehFiles)
    for idxValidVehFile = indicesValidVehFiles'
        indexTentativeSample = find(...
            vehFiles(idxValidVehFile).gpsTime >= currentGpsTime, ...
            1, 'first');
        gpsTimeDiffTentative = ...
            vehFiles(idxValidVehFile).gpsTime(indexTentativeSample) ...
            - currentGpsTime;
        
        if indexTentativeSample > 1
            % Need to check the adjacent sample, too.
            gpsTimeDiffTentativeNew = currentGpsTime ...
                - vehFiles(idxValidVehFile).gpsTime(indexTentativeSample-1);
            if  gpsTimeDiffTentativeNew < gpsTimeDiffTentative
                indexTentativeSample = indexTentativeSample-1;
                gpsTimeDiffTentative = gpsTimeDiffTentativeNew;
            end
        end
        
        % This is the current sample if the GPS time difference is small
        % enough.
        if gpsTimeDiffTentative <= maxTimeDiffAllowed * 1000
            indicesCurrentSamples(idxValidVehFile) = indexTentativeSample;
            gpsTimeDiffCurrentSamples(idxValidVehFile) = gpsTimeDiffTentative;
        end
    end
end

% Compute all the distances (in meter) from current sample to other valid
% samples at current time.
dists = inf(length(vehFiles),1);
indicesVehFileWithValidSample = find(~isnan(indicesCurrentSamples));
if ~isempty(indicesVehFileWithValidSample)
    for idxVehFileWithValidSample = indicesVehFileWithValidSample'
        if ~(strcmp(vehFiles(idxVehFileWithValidSample).type, currentVehType) ...
                && strcmp(vehFiles(idxVehFileWithValidSample).id, currentVehId))
            % Only compute the distance if it's a sample from a different
            % vehicle.
            indexNearestVehSample = indicesCurrentSamples(idxVehFileWithValidSample);
            latLonDest = [vehFiles(idxVehFileWithValidSample).lat(indexNearestVehSample), ...
                vehFiles(idxVehFileWithValidSample).lon(indexNearestVehSample)];
            dists(idxVehFileWithValidSample) = ...
                lldistkm(currentLatLon, latLonDest)*1000;
        end
    end
end

if any(~isinf(dists))
    % Find the nearest vehicle.
    [minDist, indexNearestVehFile] = min(dists);
    indexNearestVehSample = indicesCurrentSamples(indexNearestVehFile);
    gpsTimeDiff = gpsTimeDiffCurrentSamples(indexNearestVehFile);
else
    minDist = nan;
    indexNearestVehFile = nan;
    gpsTimeDiff = nan;
    indexNearestVehSample = nan;
end

try
% Generate plots for debugging.
if FLAG_DEBUG && ~isnan(minDist) && sum(~isinf(dists))>=3
    figure(hDebugFig);
    hDebugFigEle = cell(5,1);
    
    subplot(1,3,1);
    hold on;
    
    indicesVehToPlot = find(~isinf(dists))
    % Current vehicle location.
    hDebugFigEle{1} = plot(vehFiles(indexCurrentVehFile).lon(indexCurrentSample), ...
        vehFiles(indexCurrentVehFile).lat(indexCurrentSample), 'b+');
    % Other vehicle locations.
    if ~isempty(indicesVehToPlot)
        for idxVehToPlot = indicesVehToPlot'
            hDebugFigEle{2}(end+1) = ...
                plot(vehFiles(idxVehToPlot).lon(indicesCurrentSamples(idxVehToPlot)), ...
                vehFiles(idxVehToPlot).lat(indicesCurrentSamples(idxVehToPlot)), 'r*');
             hDebugFigEle{2}(end+1) = ...
                text(vehFiles(idxVehToPlot).lon(indicesCurrentSamples(idxVehToPlot)), ...
                vehFiles(idxVehToPlot).lat(indicesCurrentSamples(idxVehToPlot)), ...
                num2str(idxVehToPlot));
        end
    end
    % The nearest one.
    if ~isnan(minDist)
        hDebugFigEle{3} = plot([vehFiles(indexCurrentVehFile).lon(indexCurrentSample), ...
            vehFiles(indexNearestVehFile).lon(indicesCurrentSamples(indexNearestVehFile))], ...
            [vehFiles(indexCurrentVehFile).lat(indexCurrentSample), ...
            vehFiles(indexNearestVehFile).lat(indicesCurrentSamples(indexNearestVehFile))], ...
            'b-');
        hDebugFigEle{3}(end+1) = text( ...
            ( vehFiles(indexCurrentVehFile).lon(indexCurrentSample) + ...
            vehFiles(indexNearestVehFile).lon(indicesCurrentSamples(indexNearestVehFile)) )/2, ...
            ( vehFiles(indexCurrentVehFile).lat(indexCurrentSample) + ...
            vehFiles(indexNearestVehFile).lat(indicesCurrentSamples(indexNearestVehFile)) )/2, ...
            num2str(minDist));
    end
    grid on;
    hold off;
    axis equal;
    %plot_google_map;
    title('Map');
    
    subplot(1,3,2);
    hDebugFigEle{4} = plot(dists,'r*');
    title('dists');
    grid on;
    
    subplot(1,3,3);
    hDebugFigEle{5} = plot(gpsTimeDiffCurrentSamples,'b*');
    title('timeDiff');
    grid on;
    
    drawnow;
%     disp('Press any key to continue...');
%     pause;
    deleteHandles(hDebugFigEle);
end
catch errorGenDebugPlot
    disp('Error while generating debug plot...');
end

end
% EOF