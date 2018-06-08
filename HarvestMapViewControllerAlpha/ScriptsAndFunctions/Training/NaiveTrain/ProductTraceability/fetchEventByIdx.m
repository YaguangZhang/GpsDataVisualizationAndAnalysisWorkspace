function event = fetchEventByIdx(events, idx)
%FETCHEVENTBYIDX Fetch one event from a event list structure events by idx.
%
% Yaguang Zhang, Purdue, 11/16/2017

fields = fieldnames(events);
for idxF = 1:numel(fields)
    if iscell(events.(fields{idxF}))
          event.(fields{idxF}) = events.(fields{idxF}){idx};
    else
          event.(fields{idxF}) = events.(fields{idxF})(idx);
    end
end
% EOF