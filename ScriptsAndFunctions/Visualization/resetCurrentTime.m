%SETCURRENTTIME
% Callback function for the "Set current time" button in the animation
% figure. Basically a duplicate of some code in the main file.
%
% Yaguang Zhang, Purdue, 02/12/2015

disp('           Reset current time...');

set(hAnimationFig, 'Visible', 'off');

% updateActiveRoutesInfo.m
[currentGpsTime, ...
    filesToShowIndices, filesToShow, filesToShowTimeRange, ...
    filesNotStartedRecInd, filesNotStartedRecTimeRange, ...
    filesFinishedRecInd, filesFinishedRecTimeRange]...
    = updateActiveRoutesInfo(files, currentTime, originGpsTime, ...
    fileIndicesSortedByStartRecordingGpsTime, fileIndicesSortedByEndRecordingGpsTime);

% Clear timeline figure. See resetFigWithHandleNameAndFigName.m for more information.
hTimelineFig = resetFigWithHandleNameAndFigName('hTimelineFig', 'Timeline');

hold on;
plotTimeLineRoutes;

% Set currentTime using the timeline figure and save the settings.
SKIP_CURRENT_TIME_SETTING = false;
RESET_CURRENT_TIME = true;
setCurrentTime;

% Show the active routes in the web map display.

disp('           Update web map display...')

% Reduce the amount of data used for web map display by sampling.
[latSampled,lonSampled] = sampleCoordinates(filesToShow, SAMPLE_RATE_FOR_WEB_MAP);

% Update overlayed routes on the web map display.
% Remove old routes.
overlayerLines = repmat(hRoutesToShow{1},length(hRoutesToShow),1);
for wmRemoveIndex = 1:1:length(hRoutesToShow)
    overlayerLines(wmRemoveIndex) = hRoutesToShow{wmRemoveIndex};
end
wmremove(overlayerLines);

if RENDER_VEHICLES_ON_WEB_MAP
    % Remove vehicle markers. This will be done again at last by
    % updateMapLimits. It's OK to remove it twice and it makes more sense for
    % resetCurrentTime to remove the vehicle markers here.
    overlayerMarkers = repmat(hVehiclesToShow{1},length(hVehiclesToShow),1);
    for wmRemoveIndex = 1:1:length(hVehiclesToShow)
        overlayerMarkers(wmRemoveIndex) = hVehiclesToShow{wmRemoveIndex};
    end
    wmremove(overlayerMarkers);
end

% Add new routes.
color = cell(length(filesToShow),1);
for indexRoute = 1:1:length(filesToShow)
    routeType = filesToShow(indexRoute).type;
    routeId = filesToShow(indexRoute).id;
    timeStart = filesToShow(indexRoute).time(1);
    timeEnd = filesToShow(indexRoute).time(end);
    
    switch routeType
        case 'Combine'
            color{indexRoute} = COLOR.COMBINE;
        case 'Truck'
            color{indexRoute} = COLOR.TRUCK;
        case 'Grain Kart'
            color{indexRoute} = COLOR.GRAIN_KART;
        otherwise
            error('Error in Adding Routes: unknow vehicle type!')
    end

    hRoutesToShow{indexRoute} = wmline(hWebMap, ...
        latSampled{indexRoute},lonSampled{indexRoute}, ...
        'Color',color{indexRoute}, 'Width', 1, 'FeatureName', 'Route', ...
        'Description', ...
        strcat(routeType,':',{' '},routeId,{' '},timeStart,' to',{' '},timeEnd),...
        'OverlayName', ...
        strcat('Route', {' '}, routeType, ':', {' '}, routeId));
end

% Remaining work is done by calling updateMapLimits.
updateMapLimits;