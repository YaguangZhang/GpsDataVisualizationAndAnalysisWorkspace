function [ traceabilityTree ] ...
    = convertVehEventsToTraceTree(files, vehicleEvents)
%CONVERTVEHEVENTSTOTRACETREE Convert vehicle harvesting events to a
%traceability tree.
%
% Note the restuls are activity ("unloading"/"harvesting") based, in the
% sense that each node represents an unloading/harvesting event to its
% parent. In other words, nodes for the same vehicle are not combined.
%
% Inputs:
%   - files
%     GPS tracks generated by the script loadGpsData.m.
%   - vehicleEvents
%     The corresponding events extracted by the function
%     convertStatesToVehEvents.m.
% Output:
%   - traceabilityTree
%     A struct array presenting the traceability tree with fields:
%         - nodeId
%           A string label for the node with type (one capital letter) + a
%           unique string, e.g. "C1-3" (Combine #1 unloading #3).
%             - Labels for different layers/types
%               D: Done; E: Elevator layer; T: Truck layer; K: Grain cart
%               layer; C: Combine layer; S: Swath/field segment layer.
%             - Unique strings
%               For vehicles: an interger label of that node within its
%               type; For root: [D]one; For elevators: [E]*, where * can be
%               any string that is unique within the elevator nodes.
%         - parent
%           The id of this node's parent.
%         - children
%           A column cell with ids of this node's children.
%         - fileIdx, estiGpsTimeStartUnloading, estiGpsTimeEndUnloading
%           The ID, estimated GPS time for starting unloading, and the
%           estimated GPS time for stopping unloading. The variable fileIdx
%           will be the same as the vehFileIdx for the vehicle
%           corresponding to the node of interest, except for field segment
%           nodes, for which fildIdx is the vehFileIdx for the combine
%           which harvested that field segment. In other words, these
%           viariables defines when the unloading (or harvesting for field
%           segment nodes) activity, which corresponds to the edge between
%           the node of interest and its parent, happened.
%
% Yaguang Zhang, Purdue, 03/07/2018

DEBUG = false;

% Combine all the events into a single event sorted by GPS time start.
allEvents = sortEventsByGpsTimeStart(combineEvents([vehicleEvents{:,2}]'));

% Find all harvesting and unloading events.
allHs = fetchEventsByIndices(allEvents, find(strcmp(allEvents.event, 'h')));
allUs = fetchEventsByIndices(allEvents, find(strcmp( ...
    cellfun(@(e) {e(1)}, allEvents.event), 'u')));

% NOTE: We will treat each unloading event as: everything harvested /
% loaded before the end of the unloading event (including the end moment
% unless it refers to the start of a harvesting event), but hasn't been
% unloaded, will be unloaded.

% The D (Done) root node.
traceabilityTree(1).nodeId = 'Done';
traceabilityTree(1).parent = nan;
traceabilityTree(1).children = {};
traceabilityTree(1).fileIdx = nan;
traceabilityTree(1).estiGpsTimeStartUnloading = nan;
traceabilityTree(1).estiGpsTimeEndUnloading = nan;

% Find all u2e (unloading to elevator) events.
allU2Es = fetchEventsByIndices(allEvents, find(strcmp(allEvents.event, 'u2e')));
% The E (Elevator) nodes.
allEleIds = unique(allU2Es.idTo);
for idxE = 1:length(allEleIds)
    curEleNodeId = allEleIds{idxE};
    assert(strcmp(curEleNodeId(1), 'E'), 'Elevator names should start with "E"!');
    
    % Point it to the root.
    traceabilityTree(idxE+1).parent = 'Done';
    traceabilityTree(1).children{end+1} = curEleNodeId;
    
    traceabilityTree(idxE+1).nodeId = curEleNodeId;
    traceabilityTree(idxE+1).children = {};
    traceabilityTree(idxE+1).fileIdx = nan;
    traceabilityTree(idxE+1).estiGpsTimeStartUnloading = nan;
    traceabilityTree(idxE+1).estiGpsTimeEndUnloading = nan;
end

% Construct CKT (combine/grain cart/truck) vehicle unloading nodes. We will
% keep track of the vehicle we see (identified by their vehIds) for each
% type and find all the estiGpsTimesEndUnloading for each vehicle if we
% haven't done so.
findAllUsForAType = @(type) fetchEventsByIndices(allUs, find(strcmp(allUs.type, type)));
vehTypes = {'Truck', 'Grain Kart', 'Combine'};
vehTypeLabels = {'T', 'K', 'C'};
% The estiGpsTimesEndUnloading for each vehicle. An element here correspond
% to all the unloading (end) events of the same vehicle (identified by
% vehId), each row of which will be [gpsTime, fileIdx].
estiGpsTimesEndUWithFileIdxForVehs = {};
% The corresponding vehicle ids.
estiGpsTimesEndUWithFileIdxVehIds = {};
% The (node) labels for these unloading events.
endUNodeLabelsForVehs = {};
for idxVehType = 1:length(vehTypes)
    curVehType = vehTypes{idxVehType};
    curVehTypeLabel = vehTypeLabels{idxVehType};
    
    % All unloading events.
    curAllUsVehType = findAllUsForAType(curVehType);
    % All vehicle ids of the same type.
    curVehIds = unique(curAllUsVehType.vehId);
    
    for curVehIdIdx = 1:length(curVehIds)
        curVehId = curVehIds{curVehIdIdx};
        curNodeCnt = 0;
        
        % Record the unloading (end) events and create the nodes
        % accordingly.
        assert(~ismember(curVehId, estiGpsTimesEndUWithFileIdxVehIds), ...
            'Current vehicle id should be new!');
        estiGpsTimesEndUWithFileIdxVehIds{end+1} = curVehId;
        
        % Fetch all the unloading events for this vehicle.
        allUsCurVeh = fetchEventsByIndices(curAllUsVehType, find(strcmp(curAllUsVehType.vehId, curVehId)));
        assert(issorted(allUsCurVeh.estiGpsTimeEnd), ...
            'For the same vehicle, the stop times of unloading should be sorted!');
        estiGpsTimesEndUWithFileIdxForVehs{end+1} ...
            = [allUsCurVeh.estiGpsTimeEnd allUsCurVeh.vehFileIdx];
        
        % Add nodes.
        endUNodeLabelsForVehs{end+1} = cell(1,length(allUsCurVeh.vehFileIdx));
        for uIdx = 1:length(allUsCurVeh.vehFileIdx)
            curNodeCnt = curNodeCnt+1;
            newNodeId = [curVehTypeLabel, num2str(curVehIdIdx), ...
                '-', num2str(curNodeCnt)];
            
            % Find the parent. Note that we are constructing the tree layer
            % by layer from the root so the parent should already have been
            % initiated.
            
            if strcmp(curVehTypeLabel, 'T')
                % The truck nodes' parents are identified by the elevator
                % name.
                parentNodeId = allUsCurVeh.idTo{uIdx};
            else
                % For grain carts and combines, we need to find their
                % parent according to the file index.
                nodeIndicesFilteredByToFileIdx ...
                    = find(arrayfun( ...
                    @(n) n.fileIdx == allUsCurVeh.fileIdxTo(uIdx), ...
                    traceabilityTree));
                nodeEstiGpsTimeEndUFilteredByToFileIdx ...
                    = [traceabilityTree(nodeIndicesFilteredByToFileIdx).estiGpsTimeEndUnloading];
                assert(issorted(nodeEstiGpsTimeEndUFilteredByToFileIdx), ...
                    'The end unloaiding moments for candidate parent nodes should be sorted!')
                try
                    parentNodeId = traceabilityTree(nodeIndicesFilteredByToFileIdx(...
                        find(allUsCurVeh.estiGpsTimeEnd(uIdx) ...
                        <=nodeEstiGpsTimeEndUFilteredByToFileIdx, 1)...
                        )).nodeId;
                catch
                    if DEBUG
                        disp(['Unable to find the parent node for ', ...
                            newNodeId, ' using fileIdx! Trying vehId...']);
                    end
                    % None of the nodes with the corresponding file index
                    % can be the parent node. We need to extend to the
                    % nodes with the same vehicle ID for the parent node
                    % searching.
                    nodeIndicesFilteredByToVehId ...
                        = find(arrayfun( ...
                        @(n) ~isnan(n.fileIdx)&&strcmp(files(n.fileIdx).id, allUsCurVeh.idTo{uIdx}), ...
                        traceabilityTree));
                    nodeEstiGpsTimeEndUFilteredByToVehId ...
                        = [traceabilityTree(nodeIndicesFilteredByToVehId).estiGpsTimeEndUnloading];
                    assert(issorted(nodeEstiGpsTimeEndUFilteredByToVehId), ...
                        'The end unloaiding moments for candidate parent nodes should be sorted!')
                    
                    try
                        parentNodeId = traceabilityTree(nodeIndicesFilteredByToVehId(...
                            find(allUsCurVeh.estiGpsTimeEnd(uIdx) ...
                            <=nodeEstiGpsTimeEndUFilteredByToVehId, 1)...
                            )).nodeId;
                        if DEBUG
                            disp(['    Found via vehId the parent node: ', parentNodeId]);
                        end
                    catch
                        warning(['Unable to find the parent node for ', ...
                            newNodeId, '! Setting its parent to be nan...']);
                        parentNodeId = nan;
                    end
                end
            end
            
            endUNodeLabelsForVehs{end}{uIdx} = newNodeId;
            
            traceabilityTree(end+1).nodeId = newNodeId;
            traceabilityTree(end).parent = parentNodeId;
            traceabilityTree(end).children = {};
            traceabilityTree(end).fileIdx = allUsCurVeh.vehFileIdx(uIdx);
            traceabilityTree(end).estiGpsTimeStartUnloading ...
                = allUsCurVeh.estiGpsTimeStart(uIdx);
            traceabilityTree(end).estiGpsTimeEndUnloading ...
                = allUsCurVeh.estiGpsTimeEnd(uIdx);
            
            % Also add this node as a child node of its parent.
            if ~isnan(parentNodeId)
                parentNodeidx = find(strcmp({traceabilityTree.nodeId}, parentNodeId));
                assert(length(parentNodeidx)==1, ...
                    ['Only one parent ', parentNodeId, ...
                    ' should be found in the tree!']);
                traceabilityTree(parentNodeidx).children{end+1} = newNodeId;
            end
        end
    end
end

% Construct field segment nodes.
for idxH = 1:length(allHs.vehId)
    curEventH = fetchEventByIdx(allHs, idxH);
    % Find the combine harvester.
    curVehIdC = curEventH.vehId;
    % Find its done unloading moments.
    idxForFetchingInfoViaVehId = find(strcmp(estiGpsTimesEndUWithFileIdxVehIds, curVehIdC));
    curEstiGpsTimesEndU = ...
        estiGpsTimesEndUWithFileIdxForVehs{idxForFetchingInfoViaVehId}(:,1);
    curUFileIndices = ...
        estiGpsTimesEndUWithFileIdxForVehs{idxForFetchingInfoViaVehId}(:,2);
    curUNodeIds = endUNodeLabelsForVehs{idxForFetchingInfoViaVehId};
    
    % Find the parent node to which the last harvested product will be
    % unloaded.
    try
        lastParentNodeId = curUNodeIds{...
            find(curEstiGpsTimesEndU>=curEventH.estiGpsTimeEnd,1)...
            };
    catch
        warning(['No unloading event after harvesting event #', ...
            num2str(idxH), ...
            '! Setting the parent node accepting its last swath as nan...']);
        lastParentNodeId = nan;
    end
    
    % We may need to further split this harvesting event into more because
    % of the unloading events of the combines.
    curEventsH = curEventH;
    curParentNodeIds = {lastParentNodeId};
    curUNodeIndicesForSplittingH = find( ...
        curEstiGpsTimesEndU>curEventH.estiGpsTimeStart ...
        & curEstiGpsTimesEndU<curEventH.estiGpsTimeEnd);
    curEventsH(length(curUNodeIndicesForSplittingH)+1) = curEventH;
    curParentNodeIds{length(curUNodeIndicesForSplittingH)+1} = lastParentNodeId;
    if ~isempty(curUNodeIndicesForSplittingH)
        % Convert Android GPS time (essentially the UTM time in ms) to
        % human readable strings. We need also to consider the time zone to
        % make the time stamps consistent.
        timeDiffDays = datenum(curEventH.estiTimeStart) ...
            - curEventH.estiGpsTimeStart/86400000;
        gpsTimeToStamp = @(t) datestr(timeDiffDays+t/86400000, ...
            'yyyy/mm/dd HH:MM:SS');
    end
    for idxSplit = 1:length(curUNodeIndicesForSplittingH)
        % Make a copy of the node info.
        curEventsH(idxSplit) = curEventH;
        curEstiGpsTimeSplit = curEstiGpsTimesEndU(...
            curUNodeIndicesForSplittingH(idxSplit));
        % Change the end time of this swath node.
        curEventsH(idxSplit).estiGpsTimeEnd = curEstiGpsTimeSplit;
        curEventsH(idxSplit).estiTimeEnd = gpsTimeToStamp(curEstiGpsTimeSplit);
        % Change the start time of the next swath node.
        curEventsH(idxSplit+1).estiGpsTimeStart = curEstiGpsTimeSplit;
        curEventsH(idxSplit+1).estiTimeStart = gpsTimeToStamp(curEstiGpsTimeSplit);
        % Record the corresponding parent node id.
        curParentNodeIds{idxSplit} = curUNodeIds{curUNodeIndicesForSplittingH(idxSplit)};
    end
    
    % Add these swath nodes to the tree.
    curNodeCnt = 0;
    for idxNodeS = 1:length(curEventsH)
        curNodeCnt = curNodeCnt+1;
        newNodeId = ['S', num2str(idxH), ...
            '-', num2str(curNodeCnt)];
        curEventH = curEventsH(idxNodeS);
        parentNodeId = curParentNodeIds{idxNodeS};
        
        traceabilityTree(end+1).nodeId = newNodeId;
        traceabilityTree(end).parent = parentNodeId;
        traceabilityTree(end).children = {};
        traceabilityTree(end).fileIdx = curEventH.vehFileIdx;
        traceabilityTree(end).estiGpsTimeStartUnloading ...
            = curEventH.estiGpsTimeStart;
        traceabilityTree(end).estiGpsTimeEndUnloading ...
            = curEventH.estiGpsTimeEnd;
        
        % Also add this node as a child node of its parent.
        if ~isnan(parentNodeId)
            parentNodeidx = find(strcmp({traceabilityTree.nodeId}, parentNodeId));
            assert(length(parentNodeidx)==1, ...
                ['Only one parent ', parentNodeId, ...
                ' should be found in the tree!']);
            traceabilityTree(parentNodeidx).children{end+1} = newNodeId;
        end
    end
end
% EOF