%UPDATEMAPLIMITSREM
% We use a flag to indicate the update of map limits and carry out the
% update (i.e. this script) outside of the callback function.
%
% Yaguang Zhang, Purdue, 01/28/2015

% Make the animation figure invisible.
set(hAnimationFig, 'Visible', 'off');

% Update overlayed vehicle markers on the web map display.
updateWmVehicleMarkers;

% Bring the web map to user.
webmap(hWebMap)
pause;

disp('           Saving setting results...');

[currentWmLimits(1:2),currentWmLimits(3:4)] = wmlimits(hWebMap);
currentZoomLevel = wmzoom(hWebMap);

save(FULLPATH_SETTINGS_HISTORY, ...
    'currentWmLimits', 'currentZoomLevel', '-append');

% Animation
disp('           Recovering the animations...');

% Update total gps time range for active routes.
gpsTimeRangeActive = getGpsTimeRangeActive(gpsTimeLineRange, filesToShow);

% Clear the animation figure.
set(0,'CurrentFigure',hAnimationFig);
set(hAnimationFig, 'Visible', 'off');

cla(hAnimationMapArea,'reset');

% Set parameters for the map without plotting the velocity direction.
clear dotsToPlotLatNext;
initializeAnimation;

% Update flag.
UPDATE_MAP_LIMITS = false;

% EOF