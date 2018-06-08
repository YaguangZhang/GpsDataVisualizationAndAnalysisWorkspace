function eventsFetched = fetchEventsByIndices(events, indices)
%FETCHEVENTSBYINDICES Fetch events from a event list structure by indices.
%
% Yaguang Zhang, Purdue, 03/07/2018

eventsFetched = events;

fields = fieldnames(eventsFetched);
for idxF = 1:numel(fields)
    if iscell(events.(fields{idxF}))
          eventsFetched.(fields{idxF}) = {eventsFetched.(fields{idxF}){indices}}';
    else
          eventsFetched.(fields{idxF}) = eventsFetched.(fields{idxF})(indices);
    end
end
% EOF