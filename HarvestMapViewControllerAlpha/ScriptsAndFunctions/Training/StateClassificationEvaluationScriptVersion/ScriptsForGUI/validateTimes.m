%VALIDATETIMES
%
% Yaguang Zhang, Purdue, 05/19/2016

FLAG_TIMES_ARE_VALID = false;

timeMovieRange = handles.timeRangeMovies(handles.IDX_SELECTED_FILE, :); 
timeOffset = handles.GpsTimeOffset;
timeStart = str2num(get(handles.hEditMovieGpsTimeStart,'String'))+timeOffset;
timeEnd = str2num(get(handles.hEditMovieGpsTimeEnd,'String'))+timeOffset;

% Update 07/03/2017: loosen the rule for validating time so that state
% outside of the movie can be set, too.
if timeStart<=timeEnd % timeMovieRange(1)<=timeStart && timeStart<=timeEnd && timeEnd<=timeMovieRange(2)
    FLAG_TIMES_ARE_VALID = true;
else
    warning(strcat(mfilename, ': Input GPS times are not valid! The states were not set.'));
end

% EOF