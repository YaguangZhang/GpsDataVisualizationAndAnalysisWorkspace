%UPDATEWMVEHICLEMARKERS
% Update overlayed vehicle markers on the web map display. If
% RENDER_VEHICLES_ON_WEB_MAP is set to be false, this script will only
% update the current samples to show.
%
% Yaguang Zhang, Purdue, 02/13/2015

% First, make sure no vehicle markers are shown.
if RENDER_VEHICLES_ON_WEB_MAP
    if exist('hVehiclesToShow', 'var')
        if ~isempty(hVehiclesToShow{1})
            overlayerMarkers = repmat(hVehiclesToShow{1},length(hVehiclesToShow),1);
            for wmRemoveIndex = 1:1:length(hVehiclesToShow)
                overlayerMarkers(wmRemoveIndex) = hVehiclesToShow{wmRemoveIndex};
            end
            wmremove(overlayerMarkers);
            hVehiclesToShow = [];
        end
    end
end

% Update the current sample to show according to currentGpsTime.
updateCurrentSampleInd;

if RENDER_VEHICLES_ON_WEB_MAP
    % Show current samples in the web map display.
    for indexVehicle = 1:1:length(filesToShow)
        currentFile = filesToShow(indexVehicle);
        sampleTime = currentFile.time(currentSampleInd(indexVehicle));
        markerLat = currentFile.lat(currentSampleInd(indexVehicle));
        markerLon = currentFile.lon(currentSampleInd(indexVehicle));
        
        hVehiclesToShow{indexVehicle} = wmmarker(hWebMap, ...
            markerLat, markerLon, 'FeatureName', 'Vehicle', ...
            'Color', color{indexVehicle}, 'Autofit', false, ...
            'Description', ...
            strcat(currentFile.type, ':', {' '}, currentFile.id, {' '}, sampleTime), ...
            'OverlayName', ...
            strcat('Vehicle', {' '}, currentFile.type, ':', {' '}, currentFile.id));
    end
    
end
% EOF