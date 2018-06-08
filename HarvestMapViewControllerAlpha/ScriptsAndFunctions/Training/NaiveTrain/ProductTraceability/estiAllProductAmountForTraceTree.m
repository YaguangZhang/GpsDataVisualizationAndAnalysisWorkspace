function [ estimatedProductAmountForTraceTreeNodes ] ...
    = estiAllProductAmountForTraceTree( traceTree, files )
%ESTIALLPRODUCTAMOUNTFORTRACETREE Estimate the product amount gathered by
%all nodes in a traceability tree.
%
% Yaguang Zhang, Purdue, 03/09/2018
disp(' ');
disp('estimatedProductAmountForTraceTreeNodes: Estimating product amount for the whole traceability tree...')

estimatedProductAmountForTraceTreeNodes = nan(length(traceTree),1);

progresses = [0:0.1:1];
progressIdx = 1;
for nodeIdx = 1:length(traceTree)
    progress =nodeIdx/length(traceTree);
    if (progress>=progresses(progressIdx))
        progressIdx = progressIdx+1;
        disp(['    ', num2str(progress*100, '%.1f'), '%'])
    end
    estimatedProductAmountForTraceTreeNodes(nodeIdx) ...
        = estiNodeProductAmountForTraceTree(traceTree, files, nodeIdx);
end

disp('estimatedProductAmountForTraceTreeNodes: Done! ')
disp(' ');
end

