%UPDATEANIMATIONFRAME
% Create one frame for the animation, including updating the active routes
% and corresponding vehicle markers, states and distances.
%
% Yaguang Zhang, Purdue, 02/13/2015

% Remove vehicle markers if necessary.
for indexMapVehicle = 1:1:length(filesToShow)
    if hMapVehicles(indexMapVehicle) > 0
        delete(hMapVehicles(indexMapVehicle));
    end
    if hMapVehiclesAcurateLoc(indexMapVehicle) > 0
        delete(hMapVehiclesAcurateLoc(indexMapVehicle));
    end
    if hMapVehiclesStates(indexMapVehicle) > 0
        % States. "L", "U" or "-".
        delete(hMapVehiclesStates(indexMapVehicle));
    end
end

if hMapVehiclesVelocity(1,1) ~= -1
    % The velocity marker.
    delete(hMapVehiclesVelocity);
end

% We also need to erase the old hMapRoutesAlreadyRun plots
% because the user may press go back # frames button.
if exist('hMapRoutesAlreadyRun', 'var')
    for indexMapVehicle = 1:1:length(hMapRoutesAlreadyRun)
        if ishghandle(hMapRoutesAlreadyRun{indexMapVehicle})
            delete(hMapRoutesAlreadyRun{indexMapVehicle});
        end
    end
end

% Update the current sample to show according to currentGpsTime.
currentSampleInd = zeros(length(filesToShow), 1);
% Get the latitude, longitude and state for the shown vehicles.
dotsToPlotLat = currentSampleInd;
dotsToPlotLon = currentSampleInd;
% Lat and lon from the next sample. Note that they are not necessarily the
% lat and lon to show for the next frame.
dotsToPlotLatNext = currentSampleInd;
dotsToPlotLonNext = currentSampleInd;
% States.
dotsToPlotSta = currentSampleInd;

% Distinguish the routes where the vechicles have run on.
% So far this segment of codes are only used in this file.
hMapRoutesAlreadyRun = cell(length(filesToShow),1);
colorAsDone = zeros(1,length(filesToShow));
for fileIndex = 1:1:length(filesToShow)
    tempSampleInd = find(filesToShow(fileIndex).gpsTime > currentGpsTime,1,'first');
    
    if isempty(tempSampleInd)
        tempSampleInd = length(filesToShow(fileIndex).gpsTime);
        colorAsDone(fileIndex) = 1;
    end
    
    currentSampleInd(fileIndex) = tempSampleInd;
    dotsToPlotLat(fileIndex) = filesToShow(fileIndex).lat(tempSampleInd);
    dotsToPlotLon(fileIndex) = filesToShow(fileIndex).lon(tempSampleInd);
    dotsToPlotSta(fileIndex) = states{filesToShowIndices(fileIndex)}(tempSampleInd);
    
    % Make sure there exists a "next sample".
    if tempSampleInd < length(filesToShow(fileIndex).lat)
        dotsToPlotLatNext(fileIndex) = filesToShow(fileIndex).lat(tempSampleInd+1);
        dotsToPlotLonNext(fileIndex) = filesToShow(fileIndex).lon(tempSampleInd+1);
    else
        dotsToPlotLatNext(fileIndex) = NaN;
        dotsToPlotLonNext(fileIndex) = NaN;
    end
    
    % Specify hMap as one of the input arguments to avoid updating
    % timeline figure when the user changes window focus.
    hMapRoutesAlreadyRun{fileIndex} = geoshow(hMap, ...
        filesToShow(fileIndex).lat(1:tempSampleInd), ...
        filesToShow(fileIndex).lon(1:tempSampleInd), ...
        'Color', color{fileIndex}, ...
        'DisplayType', 'line', 'LineWidth', 1, 'LineStyle', '-');
end

if colorAsDone(end) == 1
    dateAndTime = 'Date and time unavailable';
else
    dateAndTime = filesToShow(end).time{currentSampleInd(end)};
end

% Plot current vehicle locations.
updateVehicleMarkers;

% Compute and show the distances between vehicles shown.
clearVehicleDistancesAndStates
showVehicleDistancesAndStates;

title1 = strcat('Current Time: ', num2str(currentTimeForThisFrame));
title2 = strcat('(', dateAndTime, ')');
set(0,'CurrentFigure',hAnimationFig);
title({title1,  title2},'Interpreter','None','FontSize',12);

% Plot vehicle states.
set(hAnimationFig, 'currentaxes', hAnimationStatesArea);
% Clear the subplot first. "cla(hAnimationStatesArea,'reset');" is too
% slow.
if exist('hStateLinePlots', 'var')
    delete(hStateLinePlots(hStateLinePlots~=0));
    clear hStateLinePlots;
end
hold on;

% Convert GPS time to the time we use in the figure.
if ~exist('fileToShowTimePoints','var')
    fileToShowTimePoints = cell(length(filesToShow),1);
    for stateLineIndex = 1:1:length(filesToShow)
        fileToShowTimePoints{stateLineIndex} = filesToShow(stateLineIndex).gpsTime ...
            - originGpsTime;
    end
end
% If new routes are activated.
if length(fileToShowTimePoints)<length(filesToShow)
    for stateLineIndex = (length(filesToShow)-length(fileToShowTimePoints)):1:length(filesToShow)
        fileToShowTimePoints{stateLineIndex} = filesToShow(stateLineIndex).gpsTime ...
            - originGpsTime;
    end
end

% Every vehicle will have 2 horizontal lines. One for states and the other
% for flagStatesManuallySet. We change yStateLineGroup to separate lines for
% different vehicles.
yStateLineGroup = 1;
hStateLinePlots = zeros(length(filesToShow)*5+1,1);
counterPlots = 1;
% Only consider active routes.
for stateLineIndex = find(colorAsDone == 0)
    % Time range for the state lines. We used -11 to 11 times of the time
    % per frame with current time as the original point.
    timePointsMax = 11*MILLISEC_PER_FRAME;
    timePoints = -timePointsMax:1:timePointsMax;
    
    % Find sample indices to show.
    timePointsToShowIndicesUpperBounded = find(fileToShowTimePoints{stateLineIndex} ...
        < currentTimeForThisFrame + timePointsMax);
    timePointsToShowIndicesLowerBounded = find(fileToShowTimePoints{stateLineIndex} ...
        > currentTimeForThisFrame - timePointsMax);
    
    timePointsToShowIndices = intersect(...
        timePointsToShowIndicesUpperBounded, ...
        timePointsToShowIndicesLowerBounded);
    timePointsToShow = fileToShowTimePoints{stateLineIndex}(timePointsToShowIndices);
    
    % Furthermore, find indices for different states. Note that states may
    % change because of the user, so we need to "reload" data from it every
    % time.
    statesToShow = states{filesToShowIndices(stateLineIndex)}(timePointsToShowIndices);
    indicesStatesToShowUnloading = find(statesToShow == -1);
    indicesStatesToShowOthers = find(statesToShow == 0);
    indicesStatesToShowLoading = find(statesToShow == 1);
    
    % Plot state lines with: Unloading black "o", Others blue dot, Loading
    % red "+".
    hStateLinePlotTemp = plot(hAnimationStatesArea, ...
        timePointsToShow(indicesStatesToShowUnloading), ...
        (yStateLineGroup + 0.1)*ones(length(indicesStatesToShowUnloading),1), ...
        'ko');
    if ~isempty(hStateLinePlotTemp)
        hStateLinePlots(counterPlots) = hStateLinePlotTemp;
        counterPlots = counterPlots + 1;
    end
    
    hStateLinePlotTemp = plot(hAnimationStatesArea, ...
        timePointsToShow(indicesStatesToShowOthers), ...
        (yStateLineGroup + 0.1)*ones(length(indicesStatesToShowOthers),1), ...
        'b.');
    if ~isempty(hStateLinePlotTemp)
        hStateLinePlots(counterPlots) = hStateLinePlotTemp;
        counterPlots = counterPlots + 1;
    end
    
    hStateLinePlotTemp = plot(hAnimationStatesArea, ...
        timePointsToShow(indicesStatesToShowLoading), ...
        (yStateLineGroup + 0.1)*ones(length(indicesStatesToShowLoading),1), ...
        'r+');
    if ~isempty(hStateLinePlotTemp)
        hStateLinePlots(counterPlots) = hStateLinePlotTemp;
        counterPlots = counterPlots + 1;
    end
    
    % Find the indices for manually set states.
    indicesFlagStatesToShow = ...
        flagStatesManuallySet{filesToShowIndices(stateLineIndex)}(timePointsToShowIndices);
    indicesStatesManuallySetToShow = ...
        find(indicesFlagStatesToShow == 1);
    indicesStatesNotManuallySetToShow = ...
        find(indicesFlagStatesToShow == 0);
    
    % Plot flagStatesManuallySet lines with: Manually set states blue "*"
    % and not manually set states red dots.
    hStateLinePlotTemp = plot(hAnimationStatesArea, ...
        timePointsToShow(indicesStatesManuallySetToShow), ...
        (yStateLineGroup - 0.1)*ones(length(indicesStatesManuallySetToShow),1), ...
        'b*', 'MarkerSize', 1);
    if ~isempty(hStateLinePlotTemp)
        hStateLinePlots(counterPlots) = hStateLinePlotTemp;
        counterPlots = counterPlots + 1;
    end
    
    hStateLinePlotTemp = plot(hAnimationStatesArea, ...
        timePointsToShow(indicesStatesNotManuallySetToShow), ...
        (yStateLineGroup - 0.1)*ones(length(indicesStatesNotManuallySetToShow),1), ...
        'r.', 'MarkerSize', 1);
    if ~isempty(hStateLinePlotTemp)
        hStateLinePlots(counterPlots) = hStateLinePlotTemp;
        counterPlots = counterPlots + 1;
    end
    
    % For the next vehicle.
    yStateLineGroup = yStateLineGroup+1;
end

% Plot current time line.
hStateLinePlots(counterPlots) = plot(hAnimationStatesArea, ...
    [currentTimeForThisFrame currentTimeForThisFrame], ...
    [0 yStateLineGroup], 'k-');

% Adjust the appearance of the plot.
set(hAnimationStatesArea,'xtick', ...
    currentTimeForThisFrame-timePointsMax+MILLISEC_PER_FRAME...
    :2*MILLISEC_PER_FRAME ...
    :currentTimeForThisFrame+timePointsMax-MILLISEC_PER_FRAME);
grid on;
% "axis tight;" is too slow. Change to command set.
axis([currentTimeForThisFrame-timePointsMax ...
    currentTimeForThisFrame+timePointsMax ...
    0.8 yStateLineGroup-0.8])

% To make sure callbacks in the map area will work.
set(hAnimationFig, 'currentaxes', hAnimationMapArea);
% Make sure the plots are effectively shown.
drawnow;

% EOF