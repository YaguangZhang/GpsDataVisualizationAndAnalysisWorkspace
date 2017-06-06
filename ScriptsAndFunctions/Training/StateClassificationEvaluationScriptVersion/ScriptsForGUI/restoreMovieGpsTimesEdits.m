%RESTOREMOVIEGPSTIMESEDITS
%
% Yaguang Zhang, Purdue, 05/19/2016

% Restore the start and end GPS time in the state setter.
set(handles.hEditMovieGpsTimeStart,'String', num2str(handles.MOVIE_GPS_TIME_START(handles.IDX_SELECTED_FILE)));
set(handles.hEditMovieGpsTimeEnd,'String', num2str(handles.MOVIE_GPS_TIME_END(handles.IDX_SELECTED_FILE)));
handles.GpsTimeOffset = handles.timeRangeMovies(handles.IDX_SELECTED_FILE, 1);

% EOF