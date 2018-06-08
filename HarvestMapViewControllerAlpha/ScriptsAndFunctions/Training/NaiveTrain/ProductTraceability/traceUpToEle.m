function [ ancestorEleIdx ] = traceUpToEle(traceTree, childNodeIdx)
%TRACEUPTOELE Trace from a node all the way up and return the ancestor
%elevator if there is any.
%
% Inputs:
%   - traceTree
%     The traceability tree structure array.
%   - childNodeIdx
%     The index for the node of interest.
%
% Outputs:
%   - ancestorEleIdx
%     The index for the elevator found. When there is no ancestor elevator
%     found, NaN will be returned.
%
% Yaguang Zhang, Purdue, 06/01/2018

ancestorEleIdx = nan;

if childNodeIdx ~= 1
    % The top two nodes that we need to locate.
    topNodeIdx = childNodeIdx;
    topSecNodeIdx = nan;
    
    % Keep climbing up if there is still something up.
    while ~isnan(traceTree(topNodeIdx).parent)
        topSecNodeIdx = topNodeIdx;
        
        curParentId = traceTree(topNodeIdx).parent;
        topNodeIdx = find(arrayfun(@(n) ...
            strcmp(n.nodeId, curParentId), traceTree));
    end
    
    if topNodeIdx==1
        % The top node is "Done", which means the second top node is a
        % valid elevator.
        ancestorEleIdx = topSecNodeIdx;
        assert(strcmp(traceTree(ancestorEleIdx).nodeId(1), 'E'), ...
            'The id of the ancestor elevator node should start with E!');
        
        % Otherwise: No valid elevator found; Do nothing.
    end
end

% EOF