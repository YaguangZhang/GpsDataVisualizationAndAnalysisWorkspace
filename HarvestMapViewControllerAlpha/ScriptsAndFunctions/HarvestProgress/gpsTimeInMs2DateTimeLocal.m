function dateTimeLocal = gpsTimeInMs2DateTimeLocal( ...
    gpsTimeInMs, timeZone, dataTimeFormat)
%GPSTIMEINMS2DATETIMELOCAL Convert a GPS time stamp in millisecond,
%gpsTimeInMs, to a datetime local time, optionally with a specified
%datetime format.
%
% Example:
%   dateTimeLocal = gpsTimeInMs2DateTimeLocal(1562787034000, '-04:00');
% Expected output value for dateTimeLocal:
%   07/10/2019 15:30:15
%
% Yaguang Zhang, Purdue, 11/03/2020

if ~exist('dataTimeFormat', 'var')
    dataTimeFormat = 'MM/dd/yyyy HH:mm:ss';
end
gpsTimeDateTime = datetime( ...
    gpsTimeInMs./1000, 'convertfrom', 'posixtime', ...
    'Format', dataTimeFormat, 'TimeZone', 'UTC');
dateTimeLocal = datetime(gps2utc(gpsTimeDateTime), ...
    'ConvertFrom', 'datenum', 'TimeZone', 'UTC', ...
    'Format', dataTimeFormat);
dateTimeLocal.TimeZone = timeZone;
end
% EOF