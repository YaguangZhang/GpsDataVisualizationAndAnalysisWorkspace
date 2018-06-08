function [ sortedEventStruct ] = sortEventsByGpsTimeStart( eventStruct )
%SORTEVENTSBYGPSTIMESTART Sort the events in an event struct according the
%start GPS times.
%
% Yaguang Zhang, Purdue, 11/14/2017

sortedEventStruct = eventStruct;
[~, sortedIndices] = sort(eventStruct.estiGpsTimeStart);
sortedEventStruct.vehId = sortedEventStruct.vehId(sortedIndices);
sortedEventStruct.vehFileIdx = sortedEventStruct.vehFileIdx(sortedIndices);
sortedEventStruct.type = sortedEventStruct.type(sortedIndices);
sortedEventStruct.event = sortedEventStruct.event(sortedIndices);
sortedEventStruct.fileIdxFrom = sortedEventStruct.fileIdxFrom(sortedIndices);
sortedEventStruct.fileIdxTo = sortedEventStruct.fileIdxTo(sortedIndices);
sortedEventStruct.idFrom = sortedEventStruct.idFrom(sortedIndices);
sortedEventStruct.idTo = sortedEventStruct.idTo(sortedIndices);
sortedEventStruct.estiGpsTimeStart = sortedEventStruct.estiGpsTimeStart(sortedIndices);
sortedEventStruct.estiGpsTimeEnd = sortedEventStruct.estiGpsTimeEnd(sortedIndices);
sortedEventStruct.estiTimeStart = sortedEventStruct.estiTimeStart(sortedIndices);
sortedEventStruct.estiTimeEnd = sortedEventStruct.estiTimeEnd(sortedIndices);

end
% EOF