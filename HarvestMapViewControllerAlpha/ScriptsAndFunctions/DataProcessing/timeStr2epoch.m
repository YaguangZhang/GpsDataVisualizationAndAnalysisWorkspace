function [ epochTime ] = timeStr2epoch(timeStr, timeZone)
%DATE2EPOCH Converts date to epoch time.
% This function converts the time string recorded by the app CTK, in the
% form of 'yyyy/mm/dd HH:MM:SS' (eg. '2014/06/30 21:46:33'), to epoch time,
% the time that have elapsed since 00:00:00 Coordinated Universal Time
% (UTC), Thursday, 1 January 1970, in millisecond.
%
% Inputs:
%
%   - timeStr
%
%   The string specifying the date and time to convert in the form of
%   'yyyy/mm/dd HH:MM:SS'.
%
%   - timeZone
%
%   The time zone of the input timeStr. It's an integer between (including)
%   -12 to +12. Because UTC is always used in the conversion, we need to
%   know in which time zone the timeStr is recorded. 
%
% Output:
%
%   - epochTime
%
%   The convert result (epoch time) in millisecond.
%
% References:
%   http://en.wikipedia.org/wiki/Unix_time
%   http://stackoverflow.com/questions/12661862/converting-epoch-to-date-in-matlab
%
% Yaguang Zhang, Purdue, 03/23/2015

timeToConvert = datenum(timeStr,'yyyy/mm/dd HH:MM:SS');
t0 = datenum('1970/01/01 00:00:00','yyyy/mm/dd HH:MM:SS');
epochTime=round((timeToConvert-t0)*86400000) - timeZone*3600000; % Round to fix truncation

end

% EOF
