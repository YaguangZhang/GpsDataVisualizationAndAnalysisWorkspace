function vehEvents = genVehEventsForVeh(vehId, files, states)
%GENVEHEVENTSFORVEH Convert the GPS tracks stored in files and the
%cooresponding harvesting state labels for one vehicle whose id is
%specified by the input vehId.
%
% Inputs:
%   - vehId
%     A string uniquely identifies the vehicle.
%   - files, states
%     GPS tracks and their corresponding harvesting state labels.
% Output:
%   - vehEvents
%     A struct array with fields:
%         - vehId, vehFileIdx, type
%           The ID, file index, and type for the vehicle according to whose
%           state labels the event is found. We put this redundant
%           information into each event entry for possible future data
%           importation to a database.
%         - event
%           A string specifying the type of the event. This can be:
%             - 'h' for harvesting,
%              - 'u2k' for unloading to a grain cart,
%             - 'u2t' for unloading to a truck,
%              - and 'u2e' for unloading to an elevator.
%         - fileIdxFrom, fileIdxTo
%           The integer indices for involced vehicles of the activity. Just
%           like the state label, we use 0 for fields and inf for
%           elevators.
%         - idFrom, idTo
%           The string IDs for involced vehicles of the activity. We will
%           use "Fields" for the orgin of harvesting activities, and
%           "Elevator xxx" for grain elevators.
%         - estiGpsTimeStart, estiGpsTimeEnd
%           The estimated start and end GPS time points (scalars) of the
%           activity.
%         - estiTimeStart, estiTimeEnd
%           The estimated human-readable time points (strings) of the
%           activity.
%
% Yaguang Zhang, Purdue, 11/10/2017

% Load the polygons for the grain elevators.
pathToSaveElevatorLocPoly = fullfile(fileparts(mfilename('fullpath')), ...
    '..', '..', 'ProductBackTraceabilityEvaluationScriptVersion', ...
    'Trials', 'elevatorLocPoly.mat');
assert(exist(pathToSaveElevatorLocPoly, 'file') == 2, ...
    'Please run Trial0_ManuallyLocateElevators.m first to generate the polygons for the grain elevators!')
% Get elevatorLocPoly.
load(pathToSaveElevatorLocPoly);

vehEvents = struct('vehId', {}, 'vehFileIdx', [], 'type', {}, 'event', {}, ...
    'fileIdxFrom', [], 'fileIdxTo', [], ...
    'idFrom', {}, 'idTo', {}, ...
    'estiGpsTimeStart', [], 'estiGpsTimeEnd', [], ...
    'estiTimeStart', {}, 'estiTimeEnd', {});

% Temporarily store the event parameters.
[types, vehIds, events, idFroms, idTos, estiTimeStarts, estiTimeEnds] ...
    = deal({});
[vehFileIdxs, fileIdxFroms, fileIdxTos, estiGpsTimeStarts, estiGpsTimeEnds] ...
    = deal([]);

% Find all the files that are collected for this vehicle.
indicesVehFile = find(strcmp({files.id}, vehId));
for idxVehFile = indicesVehFile
    curFile = files(idxVehFile);
    curLoadingFromLabels = states{idxVehFile}(:,1);
    curUnloadingToLabels = states{idxVehFile}(:,2);
    % We will only use the first state label column (loading from) to
    % determine the 'h' state.
    [indicesHStarts, indicesHEnds] ...
        = findConsecutiveSubSeq(curLoadingFromLabels, 0);
    
    for idxHEvent = 1:length(indicesHStarts)
        curStartIdx = indicesHStarts(idxHEvent);
        curEndIdx = indicesHEnds(idxHEvent);
        
        vehIds{end+1} = vehId;
        vehFileIdxs(end+1) = idxVehFile;
        types{end+1} = curFile.type;
        events{end+1} = 'h';
        fileIdxFroms(end+1) = 0;
        fileIdxTos(end+1) = idxVehFile;
        idFroms{end+1} = 'Fields';
        idTos{end+1} = curFile.id;
        estiGpsTimeStarts(end+1) = curFile.gpsTime(curStartIdx);
        estiGpsTimeEnds(end+1) = curFile.gpsTime(curEndIdx);
        estiTimeStarts{end+1} = curFile.time{curStartIdx};
        estiTimeEnds{end+1} = curFile.time{curEndIdx};
    end
    
    % We will use the second state label column (unloading to) to determine
    % the 'u2k' and 'u2t' states.
    [indicesUStarts, indicesUEnds, idxFileUnloadTo] ...
        = findConsecutiveSubSeqs(curUnloadingToLabels);
    for idxUEvent = 1:length(indicesUStarts)
        curStartIdx = indicesUStarts(idxUEvent);
        curEndIdx = indicesUEnds(idxUEvent);
        curUToFileIdx = idxFileUnloadTo(idxUEvent);
        
        vehIds{end+1} = vehId;
        vehFileIdxs(end+1) = idxVehFile;
        types{end+1} = curFile.type;
        switch files(curUToFileIdx).type
            case 'Grain Kart'
                events{end+1} = 'u2k';
            case 'Truck'
                events{end+1} = 'u2t';
            otherwise
                error(['Unknown loading vehicle type: ', ...
                    files(curUToFileIdx).type])
        end
        fileIdxFroms(end+1) = idxVehFile;
        fileIdxTos(end+1) = curUToFileIdx;
        idFroms{end+1} = vehId;
        idTos{end+1} = files(curUToFileIdx).id;
        estiGpsTimeStarts(end+1) = curFile.gpsTime(curStartIdx);
        estiGpsTimeEnds(end+1) = curFile.gpsTime(curEndIdx);
        estiTimeStarts{end+1} = curFile.time{curStartIdx};
        estiTimeEnds{end+1} = curFile.time{curEndIdx};
    end
end

% If this vehicle is a truck, we will use the grain elevator polygons to
% determine the 'u2e' state.
minTimeInMsU2E = 180000; % 3 min.
maxTimeInMsU2E = 10800000; % 3h. % 1800000; % 30 min.
if strcmp(curFile.type, 'Truck')
    % First of all, we need to sort and concatenate all the files for this
    % vehicle, in case the unloading to elevator event is splitted into two
    % separate files.
    curVehFiles = files(indicesVehFile);
    startGpsTimeCurVehFiles = arrayfun(@(f) f.gpsTime(1), curVehFiles);
    [~, sortedCurVehFileIndices] = sort(startGpsTimeCurVehFiles);
    % All the files with the same id as that for the current file, sorted
    % by start GPS time.
    sortedCurVehFiles = curVehFiles(sortedCurVehFileIndices);
    % sortedCurVehStates = states{indicesVehFile(sortedCurVehFileIndices)};
    
    % We will start with the first file in sortedCurVehFiles and
    % concatenate more to it when necessary.
    concatenatedVehFile = sortedCurVehFiles(1);
    % Keep track of the file indices (sample-wise), so that even for
    % samples in the resulting huge file, we are still able to trace it
    % back to its origin file.
    concatenatedVehFileIndices = ...
        indicesVehFile(sortedCurVehFileIndices(1)) ...
        .* ones(length(concatenatedVehFile.gpsTime), 1);
    for idxNewSortedCurVehFile = 2:length(sortedCurVehFiles)
        timeInMsU2E = ...
            sortedCurVehFiles(idxNewSortedCurVehFile).gpsTime(1) ...
            - concatenatedVehFile.gpsTime(end);
        if ~(timeInMsU2E>=minTimeInMsU2E && minTimeInMsU2E<=maxTimeInMsU2E)
            % This is not one unloading to the elevator event that are
            % splitted into two files. Just concatenate a padding invalid
            % file (and state) with one GPS sample to indicate this.
            paddingFile = struct('type', concatenatedVehFile.type, ...
                'id', concatenatedVehFile.id, ...
                'time', concatenatedVehFile.time(end), ...
                'gpsTime', concatenatedVehFile.gpsTime(end)+1, ...
                'lat', nan, 'lon', nan, 'altitude', nan,...
                'speed', nan, 'bearing', nan, 'accuracy', nan);
            [concatenatedVehFile, ~] = concatenateFiles( ...
                concatenatedVehFile, paddingFile);
            concatenatedVehFileIndices = [concatenatedVehFileIndices; nan];
        end
        [concatenatedVehFile, ~] = concatenateFiles( ...
            concatenatedVehFile, ...
            sortedCurVehFiles(idxNewSortedCurVehFile));
        concatenatedVehFileIndices = [ concatenatedVehFileIndices; ...
            indicesVehFile(sortedCurVehFileIndices(idxNewSortedCurVehFile)) ...
            .* ones(...
            length(sortedCurVehFiles(idxNewSortedCurVehFile).gpsTime), 1) ]; %#ok<*AGROW>
    end
    assert(length(concatenatedVehFile.gpsTime) ...
        ==  length(concatenatedVehFileIndices), ...
        'The concatenatedVehFileIndices does not agree with concatenatedVehFile!');
    % Determine the segment for unloading to elevators according to whether
    % the vehicle stays in any of the grain elevator polygons.
    [numElePoly, ~] = size(elevatorLocPoly); %#ok<USENS>
    inPolyIndices = nan(length(concatenatedVehFile.gpsTime),1);
    for idxElePoly = 1:numElePoly
        curPolyLats = elevatorLocPoly{idxElePoly, 2}(:,1);
        curPolyLons = elevatorLocPoly{idxElePoly, 2}(:,2);
        boolsInPoly = inpolygon(concatenatedVehFile.lon, ...
            concatenatedVehFile.lat, curPolyLons, curPolyLats);
        assert(all(isnan(inPolyIndices(boolsInPoly))), ...
            'One sample can be in at most one grain elevator polygon!');
        inPolyIndices(boolsInPoly) = idxElePoly;
    end
    
    % Assign u2e events accordingly.
    if any(~isnan(inPolyIndices))
        [indicesU2EStarts, indicesU2EEnds, polyIndices] ...
            = findConsecutiveSubSeqs(inPolyIndices);
        for idxU2EEvent = 1:length(indicesU2EStarts)
            curStartIdx = indicesU2EStarts(idxU2EEvent);
            curEndIdx = indicesU2EEnds(idxU2EEvent);
            curElePolyIdx = polyIndices(idxU2EEvent);
            
            % Only call this a valid unloading to elevator event if the
            % time length is valid.
            timeLengthStayingAtE = concatenatedVehFile.gpsTime(curEndIdx) ...
                - concatenatedVehFile.gpsTime(curStartIdx);
            if(timeLengthStayingAtE>=minTimeInMsU2E && timeLengthStayingAtE<=maxTimeInMsU2E)
                vehIds{end+1} = vehId;
                vehFileIdxs(end+1) = concatenatedVehFileIndices(curStartIdx);
                types{end+1} = 'Truck';
                events{end+1} = 'u2e';
                fileIdxFroms(end+1) = concatenatedVehFileIndices(curStartIdx);
                fileIdxTos(end+1) = inf;
                idFroms{end+1} = vehId;
                idTos{end+1} = elevatorLocPoly{curElePolyIdx, 1};
                estiGpsTimeStarts(end+1) = concatenatedVehFile.gpsTime(curStartIdx);
                estiGpsTimeEnds(end+1) = concatenatedVehFile.gpsTime(curEndIdx);
                estiTimeStarts{end+1} = concatenatedVehFile.time{curStartIdx};
                estiTimeEnds{end+1} = concatenatedVehFile.time{curEndIdx};
            end
        end
    end
end

vehEvents(1).vehId = vehIds';
vehEvents(1).vehFileIdx = vehFileIdxs';
vehEvents(1).type = types';
vehEvents(1).event = events';
vehEvents(1).fileIdxFrom = fileIdxFroms';
vehEvents(1).fileIdxTo = fileIdxTos';
vehEvents(1).idFrom = idFroms';
vehEvents(1).idTo = idTos';
vehEvents(1).estiGpsTimeStart = estiGpsTimeStarts';
vehEvents(1).estiGpsTimeEnd = estiGpsTimeEnds';
vehEvents(1).estiTimeStart = estiTimeStarts';
vehEvents(1).estiTimeEnd = estiTimeEnds';

vehEvents = sortEventsByGpsTimeStart(vehEvents);
end
% EOF