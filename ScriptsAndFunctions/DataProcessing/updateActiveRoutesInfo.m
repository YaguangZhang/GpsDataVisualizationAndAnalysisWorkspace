function [currentGpsTime, ...
    filesToShowIndices, filesToShow, filesToShowTimeRange, ...
    filesNotStartedRecInd, filesNotStartedRecTimeRange, ...
    filesFinishedRecInd, filesFinishedRecTimeRange]...
    = updateActiveRoutesInfo(files, currentTime, originGpsTime, ...
    fileIndicesSortedByStartRecordingGpsTime, fileIndicesSortedByEndRecordingGpsTime)
%UPDATEACTIVEROUTESINFO
% Regrouping the data files. The variables which will be updated according
% to currentGpsTime are:
% 
% filesStartedRecInd, filesNotStartedRecInd, filesNotStartedRecTimeRange,
% filesToShowIndices, filesToShow, filesToShowTimeRange,
% filesFinishedRecTimeRange, filesFinishedRecTimeRange
%
% Before executing this script, please make sure file data is loaded
% already. And the variable currentGpsTime is up to date.
%
% Yaguang Zhang, Purdue, 01/23/2015

currentGpsTime = currentTime + originGpsTime;

% filesNotStartedRecInd: start recording time > current time 
% filesStartedRecInd: start recording time <= current time 
filesStartedRecInd = find(fileIndicesSortedByStartRecordingGpsTime(:,2)>currentGpsTime, 1, 'first');
filesNotStartedRecInd = fileIndicesSortedByStartRecordingGpsTime(filesStartedRecInd:1:end,1);
filesStartedRecInd = fileIndicesSortedByStartRecordingGpsTime(1:1:(filesStartedRecInd-1),1);

% Similar for stop recording time.
filesNotStoppedRecInd = find(fileIndicesSortedByEndRecordingGpsTime(:,2)>=currentGpsTime, 1, 'first');
filesFinishedRecInd = fileIndicesSortedByEndRecordingGpsTime(1:1:(filesNotStoppedRecInd-1),1);
filesNotStoppedRecInd = fileIndicesSortedByEndRecordingGpsTime(filesNotStoppedRecInd:1:end,1);

% Only these files will be shown as animations on the map: start recording
% time <= current time <= end recording time
% Note that filesToShosIndices is already sorted.
filesToShowIndices = intersect(filesStartedRecInd,filesNotStoppedRecInd);
filesToShow = files(filesToShowIndices);

% Find the start time and end time of every route. Note that we treat the
% time of the first sample as 0.

filesNotStartedRecTimeRange = zeros(2,length(filesNotStartedRecInd));

for indexFilesNotStarted = 1:1:length(filesNotStartedRecInd)
    fileInd = filesNotStartedRecInd(indexFilesNotStarted);
    
    % Start time.
    filesNotStartedRecTimeRange(1,indexFilesNotStarted) = ...
        files(fileInd).gpsTime(1) - originGpsTime;
    % End time.
    filesNotStartedRecTimeRange(2,indexFilesNotStarted) = ...
        files(fileInd).gpsTime(end) - originGpsTime;
end

filesToShowTimeRange = zeros(2,length(filesToShowIndices));

for indexFilesToShow = 1:1:length(filesToShowIndices)
    fileInd = filesToShowIndices(indexFilesToShow);
    
    % Start time.
    filesToShowTimeRange(1,indexFilesToShow) = ...
        files(fileInd).gpsTime(1) - originGpsTime;
    % End time.
    filesToShowTimeRange(2,indexFilesToShow) = ...
        files(fileInd).gpsTime(end) - originGpsTime;
end

filesFinishedRecTimeRange = zeros(2,length(filesFinishedRecInd));

for indexFilesFinished= 1:1:length(filesFinishedRecInd)
    fileInd = filesFinishedRecInd(indexFilesFinished);
    
    % Start time.
    filesFinishedRecTimeRange(1,indexFilesFinished) = ...
        files(fileInd).gpsTime(1) - originGpsTime;
    % End time.
    filesFinishedRecTimeRange(2,indexFilesFinished) = ...
        files(fileInd).gpsTime(end) - originGpsTime;
end

% EOF