%SAVEGUISTATES Sychronize the GUI states back to the base workspace and
%save them in file.
%
% Yaguang Zhang, Purdue, 05/19/2016

assignin('base', 'statesRef', handles.statesRef);
assignin('base', 'statesRefSetFlag', handles.statesRefSetFlag);
assignin('base', 'IDX_SELECTED_FILE', handles.IDX_SELECTED_FILE);
assignin('base', 'MOVIE_GPS_TIME_START', handles.MOVIE_GPS_TIME_START);
assignin('base', 'MOVIE_GPS_TIME_END', handles.MOVIE_GPS_TIME_END);
handles.AXIS = evalin('base', 'AXIS');

evalin('base',  'save(pathStateClassificationFile, ''statesRef'', ''statesRefSetFlag'', ''IDX_SELECTED_FILE'', ''MOVIE_GPS_TIME_START'', ''MOVIE_GPS_TIME_END'', ''AXIS'')');
disp(strcat(mfilename, ': GUI states saved!'));

updateAxesStateOverview;

% EOF