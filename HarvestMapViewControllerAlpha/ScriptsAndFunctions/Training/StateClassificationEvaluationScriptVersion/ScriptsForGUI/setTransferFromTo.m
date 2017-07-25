function handles = setTransferFromTo(idxFrom, idxTo, timeStart, timeEnd, handles)
%SETTRANSFERFROMTO Set the states.
%
% Inputs:
%   - idxFrom, idxTo
%     The indices for the source vehicle and destination vehicle,
%     respectively. Note that idxFrom = 0 is harvesting and idxTo = inf is
%     dumping to factory.
%   - timeStart, timeEnd
%     The absolute GPS time range for the transfering process.
%   - handles
%     The GUI variable handles.
%
% Yaguang Zhang, Purdue, 05/19/2016

% Loading from this vehicle.(So it's dumping.)
if idxFrom ~=0 % Not harvesting.
    indicesToSetLoadFrom = find(handles.files(idxFrom).gpsTime >= timeStart & handles.files(idxFrom).gpsTime <= timeEnd);
    handles.statesRef{idxFrom}(indicesToSetLoadFrom,2) = ones(length(indicesToSetLoadFrom),1)*idxTo;
end

% Dumping to this vehicle. (So it's loading.)
if ~isinf(idxTo) % Not dumping to the factory.
    indicesToSetDumpTo = find(handles.files(idxTo).gpsTime >= timeStart & handles.files(idxTo).gpsTime <= timeEnd);
    handles.statesRef{idxTo}(indicesToSetDumpTo,1) = ones(length(indicesToSetDumpTo),1)*idxFrom;
end

% Set the corresponding statesRefSetFlag.
if idxFrom == 0 && isinf(idxTo)
    warning(strcat(mfilename, ': statesRefSetFlag setting ignored because it''s not possible to directly transfer from a field to a factory.'));
else
    if idxFrom ~=0 
        handles.statesRefSetFlag{idxFrom}(indicesToSetLoadFrom) = ones(length(indicesToSetLoadFrom),1);
    end
    if ~isinf(idxTo)
        handles.statesRefSetFlag{idxTo}(indicesToSetDumpTo) = ones(length(indicesToSetDumpTo),1);
    end
end

end

% EOF