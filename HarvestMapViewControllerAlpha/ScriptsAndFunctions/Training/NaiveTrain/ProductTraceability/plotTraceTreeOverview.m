function [ hFig, nodeCoors ] = plotTraceTreeOverview( traceTree, files, ...
    SPACE_NODE_BY_PRODUCT_AMOUNT )
%PLOTTRACETREEOVERVIEW Illustrate the traceability tree with a possibly
%interactive plot.
%
% Set SPACE_NODE_BY_PRODUCT_AMOUNT to be true to space the nodes according
% to how much "product" they have. Here we simply use the total number of
% GPS points covered by the descendant swatch nodes as the amount of
% product gathered inside a node.
%
% Yaguang Zhang, Purdue, 03/08/2018

if SPACE_NODE_BY_PRODUCT_AMOUNT
    % Construct the product amount list for all nodes.
    estimatedProductAmountForTraceTreeNodes = nan(length(traceTree),1);
    for nodeIdx = 1:length(traceTree)
        estimatedProductAmountForTraceTreeNodes(nodeIdx) ...
            = estiNodeProductAmountForTraceTree(traceTree, files, nodeIdx);
    end
end

% Mimic a stack.
indicesNodeToPlot = nan(length(traceTree),1);
% Specify the y location for tree layers.
layerLabels = {'D', 'E', 'T', 'K', 'C', 'S'};
layerYLabels = {0, -1, -2, -3, -4, -5};
ysForLayers = containers.Map(layerLabels, layerYLabels);
% The total x range to occupy.
xRange = [0,1];
% Record for each node where its childen can be plotted. Note the range
% center will be where the node has been plotted.
xRangesForChildren = nan(length(traceTree),2);
% Marker style for different types of node.
markerStyles = containers.Map(layerLabels, ...
    {'ok', '*k', '.k', '.b', '.r', '.g'});

% Start drawing the nodes with nan parent.
indicesNodesWithNanParent = find([arrayfun(@(n) isnan(n.parent(1)), traceTree)])';
indicesNodeToPlot(1:length(indicesNodesWithNanParent)) = indicesNodesWithNanParent;

xStart = xRange(1);
if SPACE_NODE_BY_PRODUCT_AMOUNT
    % Assign the x ranges for their children. We will add one imaginary
    % product to each child node to make sure it will always have some
    % space assigned.
    totalProductFromChildren ...
        = sum(estimatedProductAmountForTraceTreeNodes(indicesNodesWithNanParent)) ...
        + length(indicesNodesWithNanParent);
    xSpacePerProduct = (xRange(2)-xRange(1))/totalProductFromChildren;
else
    % Assign the x ranges for their children. We will add one imaginary
    % child to each node to make sure it will have some space assigned.
    totalNumChildren = sum(arrayfun(@(n) length(n.children)+1, ...
        traceTree(indicesNodesWithNanParent)));
    xSpacePerChild = (xRange(2)-xRange(1))/totalNumChildren;
end

for idxN = indicesNodesWithNanParent'
    if SPACE_NODE_BY_PRODUCT_AMOUNT
        xEnd = xStart+xSpacePerProduct*(estimatedProductAmountForTraceTreeNodes(idxN)+1);
    else
        xEnd = xStart+xSpacePerChild*(length(traceTree(idxN).children)+1);
    end
    
    xRangesForChildren(idxN,:) ...
        = [xStart, xEnd];
    xStart = xEnd;
end

% All the node ids.
idsForAllNodes = arrayfun(@(n) n.nodeId, traceTree, ...
    'UniformOutput', false)';
% Plot nodes recursively. To speed the plotting and viewing processes, we
% will first record the parameters for plotting and then plot groups of
% markers each time (instead of plotting markers one by one).
[nodeLocsPerLayer{1:length(layerLabels)}] = deal([]);
xsEdge = [];
ysEdge = [];
% For the interactive callback to trace back the nodes.
nodeCoors = nan(length(traceTree), 2);
while ~all(isnan(indicesNodeToPlot))
    idxNextNodeToPlot = find(~isnan(indicesNodeToPlot),1);
    
    % Node idx in the trace tree node list.
    curNodeIdx = indicesNodeToPlot(idxNextNodeToPlot);
    curNode = traceTree(curNodeIdx);
    
    % Plot the current node.
    nodeTypeLabel = curNode.nodeId(1);
    curNodeX = mean(xRangesForChildren(curNodeIdx,:));
    curNodeY = ysForLayers(nodeTypeLabel);
    idxCurType = find(strcmp(layerLabels, nodeTypeLabel));
    nodeLocsPerLayer{idxCurType} = [nodeLocsPerLayer{idxCurType}; ...
        curNodeX, curNodeY];
    nodeCoors(curNodeIdx, :) = [curNodeX, curNodeY];
    % Plot the edge between it and its parent if the parent is not nan.
    if ~isnan(curNode.parent)
        parentNodeIdx = find(strcmp(idsForAllNodes, curNode.parent));
        assert(length(parentNodeIdx)==1, ...
            'Exact one parent node should be found!');
        parentNodeX = mean(xRangesForChildren(parentNodeIdx,:));
        parentNodeY = ysForLayers(traceTree(parentNodeIdx).nodeId(1));
        xsEdge = [xsEdge [curNodeX; parentNodeX]];
        ysEdge = [ysEdge [curNodeY; parentNodeY]];
    end
    
    % Find all its children.
    childrenNodeIndices = cellfun(@(c) find(strcmp(idsForAllNodes, c)), ...
        curNode.children)';
    % Add the children found to indicesNodeToPlot.
    idxLastNodeToPlot = find(~isnan(indicesNodeToPlot), 1, 'last');
    if isnan(idxLastNodeToPlot)
        idxLastNodeToPlot = 0;
    end
    indicesNodeToPlot((idxLastNodeToPlot+1): ...
        (idxLastNodeToPlot+length(childrenNodeIndices))) ...
        = childrenNodeIndices;
    
    xStart = xRangesForChildren(curNodeIdx,1);
    if SPACE_NODE_BY_PRODUCT_AMOUNT
        % Assign x spaces for its children according to their product amounts.
        totalProductFromGrandChildren ...
            = sum(estimatedProductAmountForTraceTreeNodes(childrenNodeIndices)) ...
            + length(childrenNodeIndices);
        xSpacePerProduct = (xRangesForChildren(curNodeIdx,2) ...
            -xRangesForChildren(curNodeIdx,1))/totalProductFromGrandChildren;
    else
        % Assign x spaces for its children according to its grandchildren
        % number.
        totalNumGrandChildren = sum(arrayfun(@(n) length(n.children)+1, ...
            traceTree(childrenNodeIndices)));
        xSpacePerGrandChild = (xRangesForChildren(curNodeIdx,2) ...
            -xRangesForChildren(curNodeIdx,1))/totalNumGrandChildren;
    end
    for idxChild = 1:length(childrenNodeIndices)
        curChildIdxInTree = childrenNodeIndices(idxChild);
        if SPACE_NODE_BY_PRODUCT_AMOUNT
            xEnd = xStart+xSpacePerProduct*(...
                estimatedProductAmountForTraceTreeNodes(curChildIdxInTree)+1);
        else
            xEnd = xStart+xSpacePerGrandChild*(length( ...
                traceTree(curChildIdxInTree).children)+1);
        end
        xRangesForChildren(curChildIdxInTree,:) ...
            = [xStart, xEnd];
        xStart = xEnd;
    end
    
    % Done plotting this node.
    indicesNodeToPlot(idxNextNodeToPlot) = nan;
end

% Actual plotting.
hFig = figure; hold on;
% Edges.
hEdges = plot(xsEdge, ysEdge, ...
    '--', 'Color', ones(3,1)*0.8);
set(hEdges, 'HitTest','off');
% Node points.
hNodeLayers = cell(length(layerLabels), 1);
for idxType = 1:length(layerLabels)
    nodeTypeLabel = layerLabels{idxType};
    hNodeLayers{idxType} ...
        = plot(nodeLocsPerLayer{idxType}(:,1), ...
        nodeLocsPerLayer{idxType}(:,2), ...
        markerStyles(nodeTypeLabel));
    set(hNodeLayers{idxType}, 'HitTest','off');
end
titleSuffixes = {'Children Number', 'Estimated Product Gathered'};
title({'Traceability Tree Overview'; ...
    ['Node Spaced According to ', ...
    titleSuffixes{SPACE_NODE_BY_PRODUCT_AMOUNT+1}]});
set(gca, 'YTick', fliplr(cell2mat(layerYLabels)));
set(gca, 'YTickLabel', fliplr(layerLabels));
set(gca, 'XTick', []); grid minor;

end
% EOF