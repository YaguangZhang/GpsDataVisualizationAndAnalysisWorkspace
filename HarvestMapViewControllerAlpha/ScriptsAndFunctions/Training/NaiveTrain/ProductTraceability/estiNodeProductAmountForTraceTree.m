function [ productAmount ] = estiNodeProductAmountForTraceTree( traceTree, files, nodeIdx )
%ESTINODEPRODUCTAMOUNTFORTRACETREE Estimate the product amount gathered by
%one node in a traceability tree.
%
% Currently, we simply use the total number of GPS points covered by the
% descendant swatch nodes as the amount of product gathered for a node.
%
% Yaguang Zhang, Purdue, 03/09/2018

% disp(['    estiNodeProductAmountForTraceTree: Node #', num2str(nodeIdx),
% ...
%     ' start...']);

% We use a global variable to keep track of the results (memoization).
if evalin('base', 'exist(''estimatedProductAmountForTraceTreeNodes'')')
    estimatedProductAmountForTraceTreeNodes = evalin('base', ...
        'estimatedProductAmountForTraceTreeNodes');
else
    estimatedProductAmountForTraceTreeNodes = nan(length(traceTree), 1);
    assignin('base', 'estimatedProductAmountForTraceTreeNodes', ...
        estimatedProductAmountForTraceTreeNodes);
end

if ~isnan(estimatedProductAmountForTraceTreeNodes(nodeIdx))
    % The memoization result is available.
    productAmount = estimatedProductAmountForTraceTreeNodes(nodeIdx);
else
    if strcmp(traceTree(nodeIdx).nodeId(1), 'S')
        % This node is a swath node. Get its product amount.
        curFileIdx = traceTree(nodeIdx).fileIdx;
        curEstiGpsTimeStartH = traceTree(nodeIdx).estiGpsTimeStartUnloading;
        curEstiGpsTimeEndH = traceTree(nodeIdx).estiGpsTimeEndUnloading;
        
        productAmount = sum(files(curFileIdx).gpsTime>=curEstiGpsTimeStartH ...
            & files(curFileIdx).gpsTime<=curEstiGpsTimeEndH);
        
        disp(['    estiNodeProductAmountForTraceTree: Node #', num2str(nodeIdx), ...
            ' done (a swath node) with product amount ', num2str(productAmount), '!']);
    elseif isempty(traceTree(nodeIdx).children)
        productAmount = 0;
        
        disp(['    estiNodeProductAmountForTraceTree: Node #', num2str(nodeIdx), ...
            ' done (no children) with product amount ', num2str(productAmount), '!']);
    else
        % Find all its children.
        idsForAllNodes = arrayfun(@(n) n.nodeId, traceTree, ...
            'UniformOutput', false)';
        childrenNodeIndices = cellfun(@(c) find(strcmp(idsForAllNodes, c)), ...
            traceTree(nodeIdx).children)';
        % Sum up the product amount of all children nodes.
        productAmount = sum(arrayfun( ...
            @(idx) estiNodeProductAmountForTraceTree(traceTree, files, idx), ...
            childrenNodeIndices));
        
        disp(['    estiNodeProductAmountForTraceTree: Node #', num2str(nodeIdx), ...
            ' done (summing up children products) with product amount ', num2str(productAmount), '!']);
    end
    
    % Update the memoization result.
    estimatedProductAmountForTraceTreeNodes = evalin('base', ...
        'estimatedProductAmountForTraceTreeNodes');
    estimatedProductAmountForTraceTreeNodes(nodeIdx) = productAmount;
    assignin('base', 'estimatedProductAmountForTraceTreeNodes', ...
        estimatedProductAmountForTraceTreeNodes);
end

end
% EOF