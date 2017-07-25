function [files, ...
    fileIndicesCombines,fileIndicesTrucks,fileIndicesGrainKarts, ...
    fileIndicesSortedByStartRecordingGpsTime, ...
    fileIndicesSortedByEndRecordingGpsTime]...
    = processGpsDataFiles(fileFolderSet, MIN_SAMPLE_NUM_TO_IGNORE)    
%PROCESSGPSDATAFILES Load and pre-process GPS data files.
%   PROCESSGPSDATAFILES finds all GPS data files in the directory
%   (including all subdirectories) specified by "fileFolderSet",
%   pre-processes the information carried by them and returns the
%   processing results.
%
%   Inputs:
%
%       - fileFolderSet
%
%       The absolute path to the directory containing GPS files to be
%       processed.
%      
%       - MIN_SAMPLE_NUM_TO_IGNORE
%
%       If the file doesn't contain more data than this, it will be
%       ignored.
%
%   Outputs:
%
%       - files
%   
%       An array of struct which stores all the data and vehicle
%       information drawn from the GPS files. Each element is a struct with
%       fields:
%             - type
%             - id
%               The type and id for the vehicle on which the data was
%               collected
%             - time
%             - gpsTime
%             - lat
%             - lon
%             - altitude
%             - speed
%             - bearing
%             - accuracy
%               Arrays of the corresponding data.
%
%       - fileIndicesCombines
%       - fileIndicesTrucks
%       - fileIndicesGrainKarts
%
%       The indices of "files" for combines, trucks and grain karts
%       (carts), respectively.
% 
%       - fileIndicesSortedByStartRecordingGpsTime
%       - fileIndicesSortedByEndRecordingGpsTime
% 
%       The indices of "files" which are ordered according to
%       start-recording time and end-recording time, respectively.
%       
%   Yaguang Zhang, Purdue, 02/11/2015

% Scan all existing log files in the file folder as well its
% subdirectories. Group them into combines, tracks and grain
% karts. 
%    Update 2017/07/21: Ignore files with no title line (~179 bytes). 
logFileList = rdir(fullfile(fileFolderSet,'**','gps*.txt'), 'bytes>170');
totalNumFiles = length(logFileList);

files =struct('type', {}, 'id', {}, ...
    'time', {}, 'gpsTime', {}, ...
    'lat', {}, 'lon', {}, 'altitude', {},...
    'speed', {}, 'bearing', {}, 'accuracy', {});

% File indices for the GPS data record variable "files" for each
% behicle group.
fileIndexCombines = 0;
fileIndexTrucks = 0;
fileIndexGrainKarts = 0;
fileIndicesCombines = zeros(totalNumFiles,1);
fileIndicesTrucks = fileIndicesCombines;
fileIndicesGrainKarts = fileIndicesCombines;
% For recording the min and max GPS time of each file.
startRecordingGpsTime = fileIndicesCombines;
endRecordingGpsTime = fileIndicesCombines;

% The number of files ignored because they have too less samples.
filesIgnoredNum = 0;
for fileIndx = 1:1:totalNumFiles
    recordIndx = fileIndx - filesIgnoredNum;
    disp(strcat('                Loading data from file', 32, ...
        num2str(fileIndx), '/',num2str(totalNumFiles)));
    % Import data from the specified file.
    filename = logFileList(fileIndx).name;
    [files(recordIndx).type, files(recordIndx).id, ...
        files(recordIndx).time, files(recordIndx).gpsTime, ...
        files(recordIndx).lat, files(recordIndx).lon, ...
        files(recordIndx).altitude, files(recordIndx).speed,...
        files(recordIndx).bearing, files(recordIndx).accuracy]...
        = loadGpsLogFileData(filename);
    
    % Test whether we've got valid data.
    if( length(files)>= recordIndx && iscell(files(recordIndx).time))
        if length(files(recordIndx).time) > MIN_SAMPLE_NUM_TO_IGNORE
            % Accept the file if its sample number is large enough.
            type = files(recordIndx).type;
            startRecordingGpsTime(recordIndx) = ...
                files(recordIndx).gpsTime(1);
            endRecordingGpsTime(recordIndx) = ...
                files(recordIndx).gpsTime(end);
            
            if strcmp(type, 'Combine')
                fileIndexCombines = fileIndexCombines + 1;
                fileIndicesCombines (fileIndexCombines) = recordIndx;
            elseif strcmp(type, 'Truck')
                fileIndexTrucks = fileIndexTrucks + 1;
                fileIndicesTrucks (fileIndexTrucks) = recordIndx;
            elseif strcmp(type, 'Grain Kart')
                fileIndexGrainKarts = fileIndexGrainKarts + 1;
                fileIndicesGrainKarts (fileIndexGrainKarts) = recordIndx;
            else
                error('Data pre-processing: Unknown vehicle type!');
            end
            
        else
            % If this file contains too few samples, ignore it.
            disp(['                Too few samples (', ...
                num2str(length(files(recordIndx).time)),'<=' , ...
                num2str(MIN_SAMPLE_NUM_TO_IGNORE), ')! File ignored.']);
            files(recordIndx) = [];
            filesIgnoredNum = filesIgnoredNum + 1;
        end
    else
        % If this file doesn't contain any sample, ignore it.
        files(recordIndx) = [];
        filesIgnoredNum = filesIgnoredNum + 1;
        disp(['                Too few samples (no valid sample at all)! File ignored.']);
    end
end

% Get rid of the ignored files (the corresponding element is 0).
startRecordingGpsTime = startRecordingGpsTime(startRecordingGpsTime~=0);
endRecordingGpsTime = endRecordingGpsTime(endRecordingGpsTime~=0);

% Sort them into increasing order.
fileIndicesSortedByStartRecordingGpsTime = ...
    sortrows([(1:length(files))' startRecordingGpsTime],2);
fileIndicesSortedByEndRecordingGpsTime = ...
    sortrows([(1:length(files))' endRecordingGpsTime],2);
% Get the indices for different kinds of vehicles.
fileIndicesCombines = fileIndicesCombines(1:fileIndexCombines);
fileIndicesTrucks = fileIndicesTrucks(1:fileIndexTrucks);
fileIndicesGrainKarts = fileIndicesGrainKarts(1:fileIndexGrainKarts);

% EOF