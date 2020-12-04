function [ topNodeIdx, topSecNodeIdx ] ...
    = traceUpToTop(traceTree, childNodeIdx)
%TRACEUPTOTOP Trace from a node all the way up and return the top node
%reachable.
%
% Note: this method is slow because we need to locate parent nodes by their
% string IDs.
%
% Inputs:
%   - traceTree
%     The traceability tree structure array.
%   - childNodeIdx
%     The index for the node of interest.
%
% Outputs:
%   - topNodeIdx
%     The index for the top node found.
%   - topSecNodeIdx
%     The index for the second top node. This value can be NaN if there is
%     no second top node found.
%
% Yaguang Zhang, Purdue, 09/20/2018

% The top two nodes that we need to locate.
topNodeIdx = childNodeIdx;
topSecNodeIdx = nan;

% Keep climbing up if there is still something up.
while ~isnan(traceTree(topNodeIdx).parentNodeIdx)
    topSecNodeIdx = topNodeIdx;
    
    %         curParentId = traceTree(topNodeIdx).parent;
    %
    %         topNodeIdx = find(arrayfun(@(n) ...
    %             strcmp(n.nodeId, curParentId), traceTree));
    topNodeIdx = traceTree(topNodeIdx).parentNodeIdx;
end

% EOF