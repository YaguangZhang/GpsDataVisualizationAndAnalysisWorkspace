function [ status ] = interactiveTraceTreeOverviewCallback(src, evnt, ...
    nodeCoors, traceTree, files, elevatorLocPoly)
%INTERACTIVETRACETREEOVERVIEWCALLBACK The onclick call back attached to a
%trace tree overview figure to make it interactive.
%
% Inputs:
%   - src, evnt
%     The source and event which triggers this callback function.
%   - nodeCoors
%     The coordinates, returned by plotTraceTreeOverview, indicating where
%     the nodes of the trace tree have been plotted.
%   - traceTree, files
%     The traceability tree and its cooresponding GPS track data.
%   - elevatorLocPoly
%     A cell matrix with rows {'eleveator id', plolygon} to represent the
%     elevator areas.
%
% Yaguang Zhang, Purdue, 03/09/2018

% Set this flag to true to show relevant truck tracks. We will find the
% truck unloading events, then locate all tracks for the trucks involved,
% and for each truck, only show the tracks between its first loading event
% (end time) to its last unloading event (start time), excluding end time
% points.
FLAG_PLOT_RELEVANT_TRUCK_TRACKS = true;

% Change the background color to indicate the click worked.
interTreeViewAxes = gca;
set(interTreeViewAxes,'color',ones(1,3)*0.9);
xlabel('Click received. Generating new plots...');
drawnow;

disp(' ');
disp('    InterTraceTree: Click received. ');
status = 'Unkown';

% We will use a globel variable to store the information we need for this
% interactive function and block further callback when there is one active.
if evalin('base', 'exist(''interactiveTraceTreeOverviewCallbackMeta'')')
    interactiveTraceTreeOverviewCallbackMeta = evalin('base', ...
        'interactiveTraceTreeOverviewCallbackMeta');
    if interactiveTraceTreeOverviewCallbackMeta.flagBlocked
        status = 'Blocked';
        disp('    InterTraceTree: A previous click is still being processed... Abort. ');
        return
    else
        disp('    InterTraceTree: Updating traceability tree... ');
        
        interactiveTraceTreeOverviewCallbackMeta.flagBlocked = true;
        assignin('base', 'interactiveTraceTreeOverviewCallbackMeta', ...
            interactiveTraceTreeOverviewCallbackMeta);
        % Remove the previously highlighted components.
        deleteHandles(interactiveTraceTreeOverviewCallbackMeta.hAncestors);
        deleteHandles(interactiveTraceTreeOverviewCallbackMeta.hNodeChosen);
        deleteHandles(interactiveTraceTreeOverviewCallbackMeta.hDescendant);
        deleteHandles(interactiveTraceTreeOverviewCallbackMeta.hEdges);
    end
else
    disp('    InterTraceTree: Generating meta data for the initial click... ');
    
    interactiveTraceTreeOverviewCallbackMeta = struct( ...
        'flagBlocked', true, ...
        'hAncestors', nan, 'hNodeChosen', nan, 'hDescendant', nan, ...
        'hEdges', nan);
    assignin('base', 'interactiveTraceTreeOverviewCallbackMeta', ...
        interactiveTraceTreeOverviewCallbackMeta);
end

ptOnClick = evnt.IntersectionPoint(1:2);
[~, idxNodeChosen] = min(...
    arrayfun(@(idx) norm(nodeCoors(idx,:)-ptOnClick), ...
    1:length(traceTree)));
% Display the node.
disp('    InterTraceTree: The node below has been selected. ');
disp(traceTree(idxNodeChosen));
disp('    InterTraceTree: Tracing up and down the tree ... ');
% Find all ancestor nodes.
idsForAllNodes = arrayfun(@(n) n.nodeId, traceTree, ...
    'UniformOutput', false)';
idxCurNode = idxNodeChosen;
indicesAllAncestorNodes = [];
while ~isnan(traceTree(idxCurNode).parent)
    idxCurNode = find(strcmp(idsForAllNodes, ...
        traceTree(idxCurNode).parent));
    indicesAllAncestorNodes(end+1) = idxCurNode;
end
% Find all descendant nodes.
indicesCurNodes = [idxNodeChosen];
indicesAllDescendantNodes = [];
while ~isempty(indicesCurNodes)
    idxCurNode = indicesCurNodes(1);
    indicesCurNodes(1) = [];
    
    curNode = traceTree(idxCurNode);
    idsCurChildren = curNode.children;
    for idxChild = 1:length(idsCurChildren)
        idxNewChild = find(strcmp(idsForAllNodes, ...
            idsCurChildren(idxChild)));
        indicesAllDescendantNodes(end+1) = idxNewChild;
        indicesCurNodes(end+1) = idxNewChild;
    end
end
% We will find all the edges using the ancestor and descendant nodes.
xsEdge = [];
ysEdge = [];
indicesAllNodesCovered = [indicesAllAncestorNodes, idxNodeChosen, ...
    indicesAllDescendantNodes];
for idxNodeCovered = indicesAllNodesCovered
    curNode = traceTree(idxNodeCovered);
    if ~isnan(curNode.parent)
        curNodeX = nodeCoors(idxNodeCovered,1);
        curNodeY = nodeCoors(idxNodeCovered,2);
        idxParentNode = find(strcmp(idsForAllNodes, ...
            curNode.parent));
        parentNodeX = nodeCoors(idxParentNode,1);
        parentNodeY = nodeCoors(idxParentNode,2);
        xsEdge = [xsEdge [curNodeX; parentNodeX]];
        ysEdge = [ysEdge [curNodeY; parentNodeY]];
    end
end

% Switch to the traceability tree overview figure first.
%     axes(src); hold on;

% Highlight the edges.
interactiveTraceTreeOverviewCallbackMeta.hEdges ...
    = plot(interTreeViewAxes, xsEdge, ...
    ysEdge, '-', 'Color', [0.3010, 0.7450, 0.9330]);
uistack(interactiveTraceTreeOverviewCallbackMeta.hEdges, 'bottom');
circleMarkerSize = 30;
% Highlight the ancestor nodes.
interactiveTraceTreeOverviewCallbackMeta.hAncestors ...
    = scatter(interTreeViewAxes, nodeCoors(indicesAllAncestorNodes,1), ...
    nodeCoors(indicesAllAncestorNodes,2), circleMarkerSize, 'om');
uistack(interactiveTraceTreeOverviewCallbackMeta.hAncestors, 'bottom');
% Highlight the currently chosen nodes.
interactiveTraceTreeOverviewCallbackMeta.hNodeChosen ...
    = scatter(interTreeViewAxes, nodeCoors(idxNodeChosen,1), ...
    nodeCoors(idxNodeChosen,2), 'r*');
% Highlight the descendant nodes.
interactiveTraceTreeOverviewCallbackMeta.hDescendant ...
    = scatter(interTreeViewAxes, nodeCoors(indicesAllDescendantNodes,1), ...
    nodeCoors(indicesAllDescendantNodes,2), circleMarkerSize, 'ob');
uistack(interactiveTraceTreeOverviewCallbackMeta.hDescendant, 'bottom');

% Generate the map view.
disp('    InterTraceTree: Generating map view... ');
disp('                    Fetching GPS tracks... ');
% For plotting the swaths.
nodeIndicesSwaths = indicesAllNodesCovered(...
    arrayfun(@(n) strcmp(n.nodeId(1), 'S'), ...
    traceTree(indicesAllNodesCovered)));
gpsSampsHarvested = fetchGpsTrackSegsForNodes(traceTree, files, ...
    nodeIndicesSwaths);
% Concatenate the swath tracks with nan paddings to make sure they will be
% plotted separately.
for idxSwathNode = nodeIndicesSwaths
    gpsSampsHarvested{idxSwathNode}(end+1,:) = [nan nan];
end
latLonSwaths = vertcat(gpsSampsHarvested{nodeIndicesSwaths});
% For plotting the unloading events of the vehicles.
vehLabels = {'C', 'K', 'T'};
[nodeIndicesVehs, gpsSampsVehs] = deal(cell(length(vehLabels), 1));
for idxLabel = 1:length(vehLabels)
    nodeIndicesVehs{idxLabel} = indicesAllNodesCovered(...
        arrayfun(@(n) strcmp(n.nodeId(1), vehLabels{idxLabel}), ...
        traceTree(indicesAllNodesCovered)));
    if isempty(nodeIndicesVehs{idxLabel})
        gpsSampsVehs{idxLabel} = [];
    else
        gpsSampsVehs{idxLabel} = fetchGpsTrackSegsForNodes(traceTree, files, ...
            nodeIndicesVehs{idxLabel});
        gpsSampsVehs{idxLabel} = gpsSampsVehs{idxLabel}(nodeIndicesVehs{idxLabel});
    end
end
% For plotting the elevators.
[numEles, ~] = size(elevatorLocPoly);
[lonsElevators, latsElevators] = deal([]);
nodeIndicesElevators = indicesAllNodesCovered(...
    arrayfun(@(n) strcmp(n.nodeId(1), 'E'), ...
    traceTree(indicesAllNodesCovered)));
for idxEle = nodeIndicesElevators
    curEleNode = traceTree(idxEle);
    idxEleInEleLocPoly ...
        = find(strcmp(curEleNode.nodeId, elevatorLocPoly(:,1)));
    lonsElevators = [lonsElevators; nan; ...
        elevatorLocPoly{idxEleInEleLocPoly, 2}(:,2)];
    latsElevators = [latsElevators; nan; ...
        elevatorLocPoly{idxEleInEleLocPoly, 2}(:,1)];
end

% For plotting relative truck tracks for debugging.
if FLAG_PLOT_RELEVANT_TRUCK_TRACKS
    disp('    InterTraceTree: Fetching data for truck tracks ... ');
    % A column vector for all the covered truck node indices.
    indicesAllRelTruckNodes = indicesAllNodesCovered(...
        arrayfun(@(n) strcmp(n.nodeId(1), 'T'), ...
        traceTree(indicesAllNodesCovered)))';
    allRelTruckNodes = traceTree(indicesAllRelTruckNodes);
    
    % Get all distinct vehicle ids for these trucks.
    allRelTruckVehIds = unique(arrayfun(@(n) ...
        files(n.fileIdx).id, allRelTruckNodes,'UniformOutput',false));
    numAllRelTruckVehIds = length(allRelTruckVehIds);
    
    % Identity the time ranges to show each truck specified by its id.
    timeRangesToShowTrucks = cell(numAllRelTruckVehIds,1);
    % Also, get a mega file object containing all the GPS info for this
    % truck (specified by its vehicle id).
    megaFilesToShowTrucks = cell(numAllRelTruckVehIds,1);
    for idxRelTNode = 1:numAllRelTruckVehIds
        curTruckVehId = allRelTruckVehIds{idxRelTNode};
        curAllRelTruckNodes = allRelTruckNodes(arrayfun(@(n) ...
            strcmp(files(n.fileIdx).id, curTruckVehId), allRelTruckNodes));
        
        % A column vector for all stop times.
        curAllRelTruckEndTimes ...
            = [curAllRelTruckNodes.estiGpsTimeStartUnloading]';
        
        curAllRelTruckChildren ...
            = horzcat(arrayfun(@(n) n.children, ...
            curAllRelTruckNodes,'UniformOutput',false));
        curAllRelTruckChildren = [curAllRelTruckChildren{:}];
        
        numCurAllRelTruckChildren = length(curAllRelTruckChildren);
        % A column vector.
        curAllRelTruckStartTimes = nan(numCurAllRelTruckChildren,1);
        for idxRelTC = 1:numCurAllRelTruckChildren
            curRelTCNodeId = curAllRelTruckChildren{idxRelTC};
            curRelTCNode = traceTree([arrayfun(@(n) ...
                strcmp(n.nodeId, curRelTCNodeId), traceTree)]);
            curAllRelTruckStartTimes(idxRelTC) ...
                = curRelTCNode.estiGpsTimeEndUnloading;
        end
        
        % Get rid of nans.
        curAllRelTruckEndTimes(isnan(curAllRelTruckEndTimes)) = [];
        curAllRelTruckStartTimes(isnan(curAllRelTruckStartTimes)) = [];
        
        % Sort the time.
        curAllRelTruckEndTimes = sort(curAllRelTruckEndTimes);
        curAllRelTruckStartTimes = sort(curAllRelTruckStartTimes);
        
        % Construct the time segments for showing truck location on the
        % map.
        numCurAllRelTruckEndTimes = length(curAllRelTruckEndTimes);
        curTimeRangesToShowTruck = nan(numCurAllRelTruckEndTimes,2);
        for idxRelTEndTime = 1:numCurAllRelTruckEndTimes
            if isempty(curAllRelTruckStartTimes)
                break;
            end
            
            curEndTime = curAllRelTruckEndTimes(idxRelTEndTime);
            curStartTime = curAllRelTruckStartTimes(1);
            if curStartTime<curEndTime
                curAllRelTruckStartTimes...
                    (curAllRelTruckStartTimes<curEndTime) = [];
                curTimeRangesToShowTruck(idxRelTEndTime,:) ...
                    = [curStartTime, curEndTime];
            end
        end
        
        % Make sure all the time ranges are valid.
        curTimeRangesToShowTruck...
            (isnan(curTimeRangesToShowTruck(:,1)),:) = [];
        timeRangesToShowTrucks{idxRelTNode} = curTimeRangesToShowTruck;
        
        % To construct the mega file object, first find all file elements
        % with this vehicle id.
        curVehIdFiles ...
            = files(arrayfun(@(f) strcmp(f.id, curTruckVehId), files));
        curVehMegaFile = curVehIdFiles(1);
        for idxCurVehIdFile = 2:length(curVehIdFiles)
            paddingFile = struct('type', curVehMegaFile.type, ...
                'id', curVehMegaFile.id, ...
                'time', curVehMegaFile.time(end), ...
                'gpsTime', curVehMegaFile.gpsTime(end)+1, ...
                'lat', nan, 'lon', nan, 'altitude', nan,...
                'speed', nan, 'bearing', nan, 'accuracy', nan);
            [curVehMegaFile, ~] = concatenateFiles( ...
                curVehMegaFile, paddingFile);
            [curVehMegaFile, ~] = concatenateFiles( ...
                curVehMegaFile, curVehIdFiles(idxCurVehIdFile));
        end
        
        megaFilesToShowTrucks{idxRelTNode} = curVehMegaFile;
    end
    
end

disp('                    Plotting... ');

% First, a map showing all the related unloading events.
hMapView = figure;
mapViewAxes = gca;
hold on;
flagMapViewEmpty = true;
% Plot the swaths.
if ~isempty(nodeIndicesSwaths)
    plot(mapViewAxes, latLonSwaths(:,2), latLonSwaths(:,1), 'g.');
    flagMapViewEmpty = false;
end
% Plot the truck tracks if necessary.
if FLAG_PLOT_RELEVANT_TRUCK_TRACKS
    numMegaFilesToShowTrucks = length(megaFilesToShowTrucks);
    for idxVehMegaFile = 1:numMegaFilesToShowTrucks
        curTimeRanges = timeRangesToShowTrucks{idxVehMegaFile};
        curMegaFile = megaFilesToShowTrucks{idxVehMegaFile};
        
        [numCurTimeRanges, ~] = size(curTimeRanges);
        for idxTimeRange = 1:numCurTimeRanges
            
            curTimeRange = curTimeRanges(idxTimeRange, :);
            curBoolsGpsSampsToShow ...
                = curMegaFile.gpsTime>curTimeRange(1) ...
                & curMegaFile.gpsTime<curTimeRange(2);
            
            plot(mapViewAxes, curMegaFile.lon(curBoolsGpsSampsToShow), ...
                curMegaFile.lat(curBoolsGpsSampsToShow), '-.', ...
                'Color', ones(1,3).*0.9, 'LineWidth', 1.5);
        end
    end
end
% Plot the vehicle unloading GPS segments.
vehMarkers = {'y.', 'b.', 'k.-'};
for idxLabel = 1:length(vehLabels)
    % All the tracks within are stored in one cell. We need to plot them
    % seperately.
    for idxTrackSeg = 1:length(gpsSampsVehs{idxLabel})
        curTrackSeg = gpsSampsVehs{idxLabel}{idxTrackSeg};
        if ~isempty(curTrackSeg)
            plot(mapViewAxes, curTrackSeg(:,2), ...
                curTrackSeg(:,1), vehMarkers{idxLabel});
            flagMapViewEmpty = false;
        end
    end
end
% Plot the elevators.
if ~isempty(lonsElevators)
    plot(mapViewAxes, lonsElevators, latsElevators, 'r-', 'LineWidth',1);
    flagMapViewEmpty = false;
end

if flagMapViewEmpty
    disp('    InterTraceTree: Nothing to show on the map. Closing figure... ');
    close(hMapView);
else
    hMapViewAxes = findall(hMapView, 'type', 'axes');
    assert(length(hMapViewAxes) == 1, ...
        'One and only one set of axes should be available in hMapView!');
    plot_google_map('Axis', hMapViewAxes, 'MapType', 'satellite');
    % Hide lat and lon labels.
    set(hMapViewAxes, 'XTick', [], 'YTick', []);
end

% Second, a map with product colored by elevators.
hMapViewTraceUp = figure;
mapViewTraceUpAxes = gca;
hold on;
flagMapViewTraceUpEmpty = true;
% Plot the swaths according to their ancestor elevators.
colorsEle = [1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 0 1; 1 1 0];
[numColorsEle, ~] = size(colorsEle);
if ~isempty(nodeIndicesSwaths)
    ancestorEleIndices = arrayfun(@(nIdx) ...
        traceUpToEle(traceTree, nIdx), nodeIndicesSwaths);
    
    uniqeSncestorEleIndices = unique(ancestorEleIndices);
    [hMapViewTraceUpSwaths, nodeIdsMapViewTraceUpEle] ...
        = deal(cell(length(uniqeSncestorEleIndices),1));
    for idxUniqAncEle = 1:length(uniqeSncestorEleIndices)
        curIdxAncEle = uniqeSncestorEleIndices(idxUniqAncEle);
        curNodeIndicesSwaths ...
            = nodeIndicesSwaths(ancestorEleIndices==curIdxAncEle);
        curLatLonSwaths = vertcat(gpsSampsHarvested{curNodeIndicesSwaths});
        
        hMapViewTraceUpSwaths{idxUniqAncEle} = plot(mapViewTraceUpAxes, ...
            curLatLonSwaths(:,2), curLatLonSwaths(:,1), ...
            '.', 'Color', colorsEle(mod(idxUniqAncEle, numColorsEle),:));
        flagMapViewTraceUpEmpty = false;
    end
    
    % Plot the truck tracks if necessary.
    if FLAG_PLOT_RELEVANT_TRUCK_TRACKS
        for idxVehMegaFile = 1:numMegaFilesToShowTrucks
            curTimeRanges = timeRangesToShowTrucks{idxVehMegaFile};
            curMegaFile = megaFilesToShowTrucks{idxVehMegaFile};
            
            [numCurTimeRanges, ~] = size(curTimeRanges);
            for idxTimeRange = 1:numCurTimeRanges
                
                curTimeRange = curTimeRanges(idxTimeRange, :);
                curBoolsGpsSampsToShow ...
                    = curMegaFile.gpsTime>curTimeRange(1) ...
                    & curMegaFile.gpsTime<curTimeRange(2);
                
                plot(mapViewTraceUpAxes, ...
                    curMegaFile.lon(curBoolsGpsSampsToShow), ...
                    curMegaFile.lat(curBoolsGpsSampsToShow), '-.', ...
                    'Color', ones(1,3).*0.9, 'LineWidth', 1.5);
            end
        end
    end
end

% Plot the elevators.
if ~isempty(lonsElevators)
    plot(mapViewTraceUpAxes, lonsElevators, latsElevators, ...
        'r-', 'LineWidth',1);
    flagMapViewTraceUpEmpty = false;
end

if flagMapViewTraceUpEmpty
    disp('    InterTraceTree: Nothing to show on the map (Trace up). Closing figure... ');
    close(hMapViewTraceUp);
else
    hMapViewTraceUpAxes = findall(hMapViewTraceUp, 'type', 'axes');
    assert(length(hMapViewTraceUpAxes) == 1, ...
        'One and only one set of axes should be available in hMapViewTraceUp!');
    plot_google_map('Axis', hMapViewTraceUpAxes, 'MapType', 'satellite');
    % Hide lat and lon labels.
    set(hMapViewTraceUpAxes, 'XTick', [], 'YTick', []);
    legend(hMapViewTraceUpSwaths, nodeIdsMapViewTraceUpEle);
end

% Change the background color to indicate the click worked.
set(interTreeViewAxes,'color','w');
xlabel(interTreeViewAxes, ' ');
drawnow;

status = 'Updated';

interactiveTraceTreeOverviewCallbackMeta.flagBlocked = false;
assignin('base', 'interactiveTraceTreeOverviewCallbackMeta', ...
    interactiveTraceTreeOverviewCallbackMeta);
disp('    InterTraceTree: Done! ');

end
% EOF