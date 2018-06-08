function [hTimelineFig]...
    = plotTimeLineOverview(files, ...
    fileIndicesSortedByStartRecordingGpsTime, ...
    fileIndicesSortedByEndRecordingGpsTime)
%PLOTTIMELINEOVERVIEW
% Plot a timeline overview for files.
%
% Yaguang Zhang, Purdue, 03/22/2018

currentTime = 0; 

% The earliest time stamp available for all the data files.
originGpsTime = fileIndicesSortedByStartRecordingGpsTime(1,2);
% Total gps time range for these data. It will stay the same since the data
% set won't change during the program is running.
gpsTimeLineRange = [originGpsTime; ...
    fileIndicesSortedByEndRecordingGpsTime(end, 2)];

[currentGpsTime, ...
    filesToShowIndices, filesToShow, filesToShowTimeRange, ...
    filesNotStartedRecInd, filesNotStartedRecTimeRange, ...
    filesFinishedRecInd, filesFinishedRecTimeRange]...
    = updateActiveRoutesInfo(files, currentTime, min(arrayfun(@(f) min(f.gpsTime), files)), ...
    fileIndicesSortedByStartRecordingGpsTime, fileIndicesSortedByEndRecordingGpsTime);

% Line width for the files on the timeline figure.
LINE_WIDTH = 3;

% See resetFigWithHandleNameAndFigName.m for more information.
hTimelineFig = resetFigWithHandleNameAndFigName('hTimelineFig', 'Timeline');

% Plot
plotTimeLineRoutes;

end
% EOF