function [ hsOverlaidNodes ] = plotTraceTreeOverlayColoredByVeh( hFig, ...
    nodeCoors, traceTree, files)
%PLOTTRACETREEOVERLAYCOLOREDBYVEH Add an overlay layer of the nodes which
%are colored by their vehicle IDs.
%
% Inputs:
%   - hFig, nodeCoors
%     The outputs of plotTraceTreeOverview.m, which are the handler of the
%     traceability tree figure and the coordinates for its nodes.
%   - traceTree, files
%     The traceability tree structure and the GPS data for it.
% Output:
%   - hsOverlaidNodes
%     Handlers to the newly-added overlay nodes.
%
% Yaguang Zhang, Purdue, 03/08/2018

eleMarker = '*';
vehMarker = '.';

indicesForAllEles = find(arrayfun(@(n) ...
    strcmp(n.nodeId(1), 'E'), traceTree));
indicesForAllVehs = setdiff((2:length(traceTree))', indicesForAllEles);
uniqueVehIds = unique(arrayfun(@(n) ...
    files(n.fileIdx).id, traceTree(indicesForAllVehs), ...
    'UniformOutput', false));

hsOverlaidNodes = nan(length(uniqueVehIds)+length(uniqueVehIds), 1);
numGroupPloted = 0;

% Overlay new elevator nodes.
figure(hFig); hold on;
for nodeIdxEle = indicesForAllEles
    numGroupPloted = numGroupPloted+1;
    hsOverlaidNodes(numGroupPloted) = plot(nodeCoors(nodeIdxEle, 1), ...
        nodeCoors(nodeIdxEle, 2), eleMarker, 'Color', rand(1,3));
end

% Overlay new vehicle nodes.
for idxVeh = 1:length(uniqueVehIds)
    numGroupPloted = numGroupPloted+1;
    curVehId = uniqueVehIds{idxVeh};
    
    curNodeIndices = find(arrayfun(@(n) ...
        (~isnan(n.fileIdx)) && strcmp(files(n.fileIdx).id, curVehId), ...
        traceTree));
    hsOverlaidNodes(numGroupPloted) = plot(nodeCoors(curNodeIndices, 1), ...
        nodeCoors(curNodeIndices, 2), vehMarker, 'Color', rand(1,3));
end

end
% EOF