%UPDATEINDICESFORCURRENTACTIVEFILES
%
% Yaguang Zhang, Purdue, 05/19/2016

% Only files with gpsTimeRange covering by the range specifed are valid.
GPS_TIME_RANGE = handles.timeRangeMovies(handles.IDX_SELECTED_FILE,:);
handles.indicesActiveFiles = find(handles.gpsTimeRangesForFiles(:,1) <= GPS_TIME_RANGE(2) ...
    & handles.gpsTimeRangesForFiles(:,2) >= GPS_TIME_RANGE(1));

% EOF.