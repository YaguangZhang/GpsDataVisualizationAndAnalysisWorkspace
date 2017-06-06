%INITIALIZEANIMATION
% Generate the first frame for the animation.
%
% Tasks include rendering map, adding routes and marker vehicles' current
% locations. 
%
% Yaguang Zhang, Purdue, 01/28/2015

% This link can be found at
%       http://viewer.nationalmap.gov/example/services/serviceList.html
try
    info = wmsinfo('http://raster.nationalmap.gov/arcgis/services/Orthoimagery/USGS_EROS_Ortho_SCALE/ImageServer/WMSServer?request=GetCapabilities&service=WMS');
    layer = info.Layer(1);
    
    
    [A, R] = wmsread(layer, 'Latlim', currentWmLimits(1:2), 'Lonlim', currentWmLimits(3:4), ...
        'ImageHeight', IMAGE_HEIGHT, 'ImageWidth', IMAGE_WIDTH);
    
    % For really large map view area, low resolution image may not be
    % available. In this case, keep increasing the resolution and trying
    % downloading the map image.
    if all(A(1:end)==0)
        imageHeightTemp = IMAGE_HEIGHT;
        imageWidthTemp = IMAGE_WIDTH;
        while all(A(1:end)==0) || all(A(1:end)==255)
            imageHeightTemp = imageHeightTemp*1.5;
            imageWidthTemp = imageWidthTemp*1.5;
            [A, R] = wmsread(layer, 'Latlim', ...
                currentWmLimits(1:2), 'Lonlim', currentWmLimits(3:4), ...
                'ImageHeight', floor(imageHeightTemp), ...
                'ImageWidth', floor(imageWidthTemp));
        end
    end
    
catch err
    disp('           Default web map server error!');
    disp('           Error info:');
    disp(' ');
    disp(err.message);
    disp(' ');
    disp('           Searching for avalaible servers...');
    
    % Search and refine the search.
    layers = wmsfind('satellite');
    layers = layers.refine('global');
    layer = layers(1);
    
    info = wmsinfo(layer.ServerURL);
    
    layer = info.Layer(1);
    
    [A, R] = wmsread(layer, 'Latlim', currentWmLimits(1:2), 'Lonlim', currentWmLimits(3:4), ...
        'ImageHeight', IMAGE_HEIGHT, 'ImageWidth', IMAGE_WIDTH);
    
    disp('           Done.');
end

% Make sure the map will be added in the right figure and area.
if gca ~= hAnimationMapArea
    set(0,'CurrentFigure', hAnimationFig);
    set(hAnimationFig, 'currentaxes', hAnimationMapArea);
end

hold on;
hMap = usamap(A,R);
geoshow(hMap,A,R);

% Show the active routes.
hMapRoutes = cell(length(filesToShow),1);
colorAsDone = zeros(1,length(filesToShow));

for indexMapRoute = 1:1:length(filesToShow)
    tempSampleInd = find(filesToShow(indexMapRoute).gpsTime > currentGpsTime,1,'first');
    
    if isempty(tempSampleInd)
        tempSampleInd = length(filesToShow(indexMapRoute).gpsTime);
        colorAsDone(indexMapRoute) = 1;
    end
    
    hMapRoutes{indexMapRoute} = geoshow(...
        filesToShow(indexMapRoute).lat, filesToShow(indexMapRoute).lon, ...
        'Color', color{indexMapRoute}, ...
        'DisplayType', 'line', 'LineWidth', 1, 'LineStyle', ':');
end

axis tight;

title1 = strcat('Current Time: ', num2str(currentTime));
title2 = strcat('(date and time)');
title({title1,  title2},'Interpreter','None','FontSize',12);

% The time to add the next new route from routes which haven't started yet.
newRouteToBeAddedIndex = filesNotStartedRecInd(numNewAddedFileToShow + 1);
newRouteToBeAdded = ...
    files(newRouteToBeAddedIndex);
newRouteToBeAddedTime = newRouteToBeAdded.gpsTime(1);

timeToUpdateAnimation = newRouteToBeAddedTime - originGpsTime;

% First frame.
% Update the current sample to show according to currentGpsTime.

dotsToPlotLat = zeros(length(filesToShow), 1);
dotsToPlotLon = dotsToPlotLat;
dotsToPlotSta = dotsToPlotLat;

for fileIndex = 1:1:length(filesToShow)
    dotsToPlotLat(fileIndex) = filesToShow(fileIndex).lat(currentSampleInd(fileIndex));
    dotsToPlotLon(fileIndex) = filesToShow(fileIndex).lon(currentSampleInd(fileIndex));
    dotsToPlotSta(fileIndex) = states{filesToShowIndices(fileIndex)}(tempSampleInd);
end

if colorAsDone(end) == 1
    dateAndTime = 'Date and time unavailable';
else
    dateAndTime = filesToShow(end).time{currentSampleInd(end)};
end

% Plot current vehicle locations.
updateVehicleMarkers;
updateVehicleStateTimelines;

title1 = strcat('Current Time: ', num2str(currentTime));
title2 = strcat('(', dateAndTime, ')');
title({title1,  title2},'Interpreter','None','FontSize',12);

% Set the width of the state area the same as that of the map area in the
% animation figure.
set(hAnimationStatesArea, 'Unit', 'Normalized');
stateAreaPositonNormalized = get(hAnimationStatesArea, 'Position');
set(hAnimationStatesArea, 'Position', ...
    [LEFT_EDGE_STATES_AREA_NORMALIZED stateAreaPositonNormalized(2) ...
    1-LEFT_EDGE_STATES_AREA_NORMALIZED*2 stateAreaPositonNormalized(4)]);

% Make sure the plots are effectively shown.
pause(0.0000000001);

% Get rid of extra space.
tightfig(hAnimationFig);

% Set the position of the state area the same as that of the map area in the
% animation figure.
set(hAnimationStatesArea, 'Unit', 'Pixels');
stateAreaPositonPixels = get(hAnimationStatesArea, 'Position');
set(hAnimationStatesArea, 'Position', ...
    [LEFT_EDGE_STATES_AREA_PIXELS stateAreaPositonPixels(2:4)]);

if GENERATE_MOV
    if ~exist('animationFigPosition', 'var')
        animationFigPosition = get(hAnimationFig, 'Position');
    end
    set(hAnimationFig, 'Position', animationFigPosition);
    frameNum = frameNum + 1;
    F(frameNum) = getframe(hAnimationFig);
end

% EOF