function [ allEvents ] = combineEvents( eventStrArray )
%COMBINEEVENTS Combine event structs into one single event struct.
%
% Yaguang Zhang, Purdue, 11/14/2017

disp(' ')
disp('    convertStatesToVehEvents: ')
if isempty(eventStrArray)
    allEvents = struct('vehId', {}, 'vehFileIdx', [], ...
        'type', {}, 'event', {}, ...
        'fileIdxFrom', [], 'fileIdxTo', [], ...
        'idFrom', {}, 'idTo', {}, ...
        'estiGpsTimeStart', [], 'estiGpsTimeEnd', [], ...
        'estiTimeStart', {}, 'estiTimeEnd', {});
else
    numEvents = sum(arrayfun(@(e) length(e.vehId), eventStrArray));
    [allEvents.vehId, allEvents.type, allEvents.event, ...
        allEvents.idFrom, allEvents.idTo, allEvents.estiTimeStart, ...
        allEvents.estiTimeEnd ]= deal(cell(numEvents,1));
    [allEvents.vehFileIdx, allEvents.fileIdxFrom, allEvents.fileIdxTo, ...
        allEvents.estiGpsTimeStart, allEvents.estiGpsTimeEnd] = deal(nan(numEvents,1));
    
    eventCnt = 0;
    for idxE = 1:length(eventStrArray)
        numNewEvents = length(eventStrArray(idxE).vehId);
        indicesToWrite = (eventCnt+1):1:(eventCnt+numNewEvents);
        
        allEvents.vehId(indicesToWrite) = eventStrArray(idxE).vehId;
        allEvents.vehFileIdx(indicesToWrite) = eventStrArray(idxE).vehFileIdx;
        allEvents.type(indicesToWrite) = eventStrArray(idxE).type;
        allEvents.event(indicesToWrite) = eventStrArray(idxE).event;
        allEvents.fileIdxFrom(indicesToWrite) = eventStrArray(idxE).fileIdxFrom;
        allEvents.fileIdxTo(indicesToWrite) = eventStrArray(idxE).fileIdxTo;
        allEvents.idFrom(indicesToWrite) = eventStrArray(idxE).idFrom;
        allEvents.idTo(indicesToWrite) = eventStrArray(idxE).idTo;
        allEvents.estiGpsTimeStart(indicesToWrite) = eventStrArray(idxE).estiGpsTimeStart;
        allEvents.estiGpsTimeEnd(indicesToWrite) = eventStrArray(idxE).estiGpsTimeEnd;
        allEvents.estiTimeStart(indicesToWrite) = eventStrArray(idxE).estiTimeStart;
        allEvents.estiTimeEnd(indicesToWrite) = eventStrArray(idxE).estiTimeEnd;
        
        eventCnt = eventCnt+numNewEvents;
    end
end
allEvents = sortEventsByGpsTimeStart(allEvents);
disp('    Done!')
end
% EOF