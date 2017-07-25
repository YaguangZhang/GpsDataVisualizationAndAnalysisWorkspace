%SETLOADFROM Set the statesRefSetFlag.
%
% Yaguang Zhang, Purdue, 05/19/2016

indicesToSet = find(handles.files(handles.IDX_SELECTED_FILE).gpsTime >= timeStart & handles.files(handles.IDX_SELECTED_FILE).gpsTime <= timeEnd);
handles.statesRefSetFlag{handles.IDX_SELECTED_FILE}(indicesToSet) = ones(length(indicesToSet),1);

% EOF