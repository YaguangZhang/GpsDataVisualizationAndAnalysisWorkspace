function gpsTimeRangeActive = getGpsTimeRangeActive(gpsTimeLineRange, filesToShow)
%GETGPSTIMERANGEACTIVE Computes gpsTimeRangeActive.
%   GETGPSTIMERANGEACTIVE computes the total gps time range for active
%   routes "gpsTimeRangeActive".
%
%   Inputs:
%
%       - gpsTimeLineRange
%
%       The total time range for all files available.
%
%       - filesToShow
%
%       Detailed information files about the active routes. 
%   
%   Yaguang Zhang, Purdue, 02/12/2015

gpsTimeRangeActive = gpsTimeLineRange(2:-1:1,1);

for filesToShowIndex = 1:1:length(filesToShow)
    gpsTime = [filesToShow(filesToShowIndex).gpsTime(1);
        filesToShow(filesToShowIndex).gpsTime(end)];
    if gpsTime(1)<gpsTimeRangeActive(1)
        gpsTimeRangeActive(1) = gpsTime(1);
    end
    if gpsTime(2)>gpsTimeRangeActive(2)
        gpsTimeRangeActive(2) = gpsTime(2);
    end
end

% EOF