%GENVISUALIZATIONSFORAGRINOVUSCHALLENGE Highlight "OATS" on Matt's ATV
%tracks and generate some visualizations for the AgriNovus challenge.
%
% Yaguang Zhang, Purdue, 12/02/2020

% Uncomment this line to force ender the manually label markers mode.
% flagManuallyHighLight = true;

% Used to add more GPS points via interpolation.
numOfDoublingGpsTimes = 4;

% We will compute the minimum distance between a GPS point to the markers,
% and if it is smaller or equal to the value below, we will highlight that
% GPS point.
maxDistInMAllowedForHighlight = 1;

% The region where the markers can be added.
LON_RANGE = [-86.553458942468197 -86.550462195776774];
LAT_RANGE = [40.396945909126693  40.398745910572806];

% For the vidoe clip.
VIDEO_FRAME_RATE = 60;
NUM_OF_NEW_GPS_PTS_PER_FRAME = 2^numOfDoublingGpsTimes; % 1s per frame.

%% Interpolate GPS Points
while numOfDoublingGpsTimes>=1
    for idxFile = 1:length(files)
        files(idxFile).lon = [files(idxFile).lon; ...
            (files(idxFile).lon(2:end)...
            -files(idxFile).lon(1:(end-1)))./2 ...
            + files(idxFile).lon(1:(end-1))]; %#ok<SAGROW>
        files(idxFile).lat = [files(idxFile).lat; ...
            (files(idxFile).lat(2:end)...
            -files(idxFile).lat(1:(end-1)))./2 ...
            + files(idxFile).lat(1:(end-1))]; %#ok<SAGROW>
        files(idxFile).gpsTime = [files(idxFile).gpsTime; ...
            (files(idxFile).gpsTime(2:end)...
            -files(idxFile).gpsTime(1:(end-1)))./2 ...
            + files(idxFile).gpsTime(1:(end-1))]; %#ok<SAGROW>
        files(idxFile).speed = [files(idxFile).speed; ...
            (files(idxFile).speed(2:end)...
            -files(idxFile).speed(1:(end-1)))./2 ...
            + files(idxFile).speed(1:(end-1))]; %#ok<SAGROW>
    end
    numOfDoublingGpsTimes = numOfDoublingGpsTimes-1;
end

%% Interactively Label Markers on a Map

pathToSaveVisualizations = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
absPathToSaveMarkerLocs = ...
    fullfile(pathToSaveVisualizations, 'manuallyHighlightenOatsPts.mat');

if ~exist('flagManuallyHighLight', 'var')
    if exist(absPathToSaveMarkerLocs, 'file')
        flagManuallyHighLight = false;
    else
        flagManuallyHighLight = true;
    end
end

% Fetch all GPS data.
allLons = vertcat(files.lon);
allLats = vertcat(files.lat);

% Overview.
if flagManuallyHighLight
    hFigOverview = figure('CloseRequestFcn',@saveMarkLocs);
else
    hFigOverview = figure;
end
hold on; axis([LON_RANGE, LAT_RANGE]);
hPt = plot(allLons, allLats, '.', 'Color', 'y');
plot_google_map('MapType', 'satellite');
xticks([]);
yticks([]);
xlabel('Longitude')
ylabel('Latitude')
legend(hPt, 'All GPS Pts', 'AutoUpdate','off')

% Add the markers if necessary.
if exist(absPathToSaveMarkerLocs, 'file')
    load(absPathToSaveMarkerLocs);
    numOfMarkers = size(markLocs, 1);
    hMarkerAxes = findall(hFigOverview, 'type', 'axes');
    hMarkLocs = plot3(hMarkerAxes, ...
        markLocs(:, 2), markLocs(:, 1), ones(numOfMarkers,1), ...
        'rx', 'LineWidth', 2);
end

% Add the interactive function if necessary.
if flagManuallyHighLight
    if ~exist(absPathToSaveMarkerLocs, 'file')
        clearvars markLocs;
    end
    
    hInteractiveArea = fill3([LON_RANGE(1), LON_RANGE(1), ...
        LON_RANGE(2), LON_RANGE(2)], ...
        [LAT_RANGE, LAT_RANGE(end:-1:1)], ...
        ones(1,4), 'r', 'LineStyle', 'none', 'FaceColor', 'none');
    
    set(hInteractiveArea,'ButtonDownFcn', @(src,evnt) ...
        updateMarkerState(src, evnt), ...
        'PickableParts','all', 'HitTest','on');
    
    disp('    The interactive tool for manually marking locations is ready!')
    disp('    Please (left) click on the plot to add new markers ...')
    disp(' ')
    disp('    It''s OK to zoom in the figure and move around if necessary. ')
    disp('    It''s also OK to manually modify the marker locations stored in the variable markLocs in the base workspace. ')
    disp('    The variable markLocs will eventually be saved into a .mat file when the figure is closed. ')
    disp(' ')
    
    
    disp('    Press any key to finish adding markers.')
    pause;
end

if flagManuallyHighLight
    saveMarkLocs;
end

saveas(hFigOverview, ...
    fullfile(pathToSaveVisualizations, 'GpsOverviewWithMarkers.png'));

%% Find GPS Points to Highlight

numOfGpsPts = length(allLons);
numOfMarkers = size(markLocs, 1);
flagsGpsPtsToHighlight = false(numOfGpsPts, 1);
for idxGpsPt = 1:numOfGpsPts
    curLatLon = [allLats(idxGpsPt), allLons(idxGpsPt)];
    
    for idxMark = 1:numOfMarkers
        curDistInMToMarker = lldistkm(curLatLon, ...
            markLocs(idxMark,:))*1000;
        if curDistInMToMarker<=maxDistInMAllowedForHighlight
            flagsGpsPtsToHighlight(idxGpsPt) = true;
            break;
        end
    end
end

% Order data by GPS time.
allSpeeds = vertcat(files.speed);
allGpsTimes = vertcat(files.gpsTime);
[allGpsTimes, indicesNewOrder] = sort(allGpsTimes);

allLats = allLats(indicesNewOrder);
allLons = allLons(indicesNewOrder);
flagsGpsPtsToHighlight = flagsGpsPtsToHighlight(indicesNewOrder);
allSpeeds = allSpeeds(indicesNewOrder);

allBoolsNonZeroSpeed = allSpeeds>0.1;
allNumsOfNonZeroSpeedPts = arrayfun( ...
    @(idxM) sum(allBoolsNonZeroSpeed(1:idxM)), 1:numOfGpsPts);

%% Visualizations

% 1. Overview with highlighted GPS points.
hFigOverviewWithHL = figure; hold on; axis([LON_RANGE, LAT_RANGE]);
plot(allLons(~flagsGpsPtsToHighlight), ...
    allLats(~flagsGpsPtsToHighlight), '.', 'Color', 'y');
plot(allLons(flagsGpsPtsToHighlight), ...
    allLats(flagsGpsPtsToHighlight), '.', 'Color', 'r');
plot_google_map('MapType', 'satellite');
xticks([]);
yticks([]);
xlabel('Longitude')
ylabel('Latitude')

saveas(hFigOverview, ...
    fullfile(pathToSaveVisualizations, 'GpsOverviewHighlighted.png'));

% 2. Video.
pathToSaveVideo = fullfile(pathToSaveVisualizations, 'demo.mp4');

curVideoWriter = VideoWriter( ...
    pathToSaveVideo, 'MPEG-4');
curVideoWriter.FrameRate = VIDEO_FRAME_RATE;
open(curVideoWriter);

hFigVideo = figure; hold on; axis([LON_RANGE, LAT_RANGE]);
plot_google_map('MapType', 'satellite');
xticks([]);
yticks([]);
xlabel('Longitude')
ylabel('Latitude')
[hPt, hPtHL] = deal([]);
writeVideo(curVideoWriter, getframe(hFigVideo));

numOfFrames = floor(numOfGpsPts/NUM_OF_NEW_GPS_PTS_PER_FRAME);
% We will skip the zero-speed moments.
for idxFrame = 1:numOfFrames
    curNumGpsPtsToShow = idxFrame*NUM_OF_NEW_GPS_PTS_PER_FRAME;
    curMaxIdxGpsPtToShow = ...
        find(allNumsOfNonZeroSpeedPts>=curNumGpsPtsToShow, 1, 'first');
    
    if ~isempty(curMaxIdxGpsPtToShow)
        deleteHandles({hPt, hPtHL});
        
        curLats = allLats(1:curMaxIdxGpsPtToShow);
        curLons = allLons(1:curMaxIdxGpsPtToShow);
        curFlagsGpsPtsToHighlight ...
            = flagsGpsPtsToHighlight(1:curMaxIdxGpsPtToShow);
        
        hPt = plot(curLons(~curFlagsGpsPtsToHighlight), ...
            curLats(~curFlagsGpsPtsToHighlight), '.', 'Color', 'y');
        hPtHL = plot(curLons(curFlagsGpsPtsToHighlight), ...
            curLats(curFlagsGpsPtsToHighlight), '.', 'Color', 'r');
        
        drawnow;
        writeVideo(curVideoWriter, getframe(hFigVideo));
    end
end

close(curVideoWriter);

% Terminate the program to avoid anything beyond this script from running.
return;

% EOF