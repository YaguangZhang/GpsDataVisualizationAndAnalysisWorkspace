%LOADGPSDATA
% This script loads GPS data from the dirctory set by the variable
% "fileFolder".
%
% It first tries to load data from the .mat file "filesLoadedHistory" which
% may have been created by mapViewController.m if it has been run for that
% dirctory before. If "filesLoadedHistory.mat" doesn't exist, it will
% process the GPS files directly and generate "filesLoadedHistory.mat" by
% itself.
%
% Yaguang Zhang, Purdue, 02/23/2015

FLAG_PLOT_AND_SAVE_CKT_DATA_LOADED = false;

% Full paths for the history file.
if IS_RELATIVE_PATH
    fileFolderSet = fullfile(pwd, fileFolder);
else
    fileFolderSet = fileFolder;
end

FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
FULLPATH_FILES_LOADED_HISTORY = fullfile(...
    FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY, ...
    'filesLoadedHistory.mat'...
    );
FULLPATH_FILES_OVERVIEW_FIG = fullfile(...
    FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY, ...
    'filesLoadedHistoryOverview'...
    );
% Create the directory if necessary.
if ~exist(FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY, 'dir')
    mkdir(FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY);
end

if exist(FULLPATH_FILES_LOADED_HISTORY, 'file')
    % The history file exists.
    disp('Pre-processing: Files in the specified folder has been processed ');
    disp('                before.');
    disp('                Loading history results...');
    
    load(FULLPATH_FILES_LOADED_HISTORY);
else
    % Couldn't found the hisory file. Need to process the GPS data files
    % directly. Need to process the original files to get the data.
    disp('Pre-processing: Scanning specified folder for data files...');
    
    % See processGpsDataFiles.m for more infomation.
    [files, ...
        fileIndicesCombines,fileIndicesTrucks,fileIndicesGrainKarts, ...
        fileIndicesSortedByStartRecordingGpsTime, ...
        fileIndicesSortedByEndRecordingGpsTime]...
        = processGpsDataFiles(fileFolderSet, MIN_SAMPLE_NUM_TO_IGNORE);
    
    % Discard Incomplete GPS Samples
    disp('Pre-processing: Discarding incomplete GPS samples to prepare for statistical harvesting...');
    
    for idxFile = 1:length(files)
        % Make sure all fields of each file are of the same length.
        numSamplesExpected = length(files(idxFile).accuracy);
        if(length(files(idxFile).gpsTime) ~= numSamplesExpected)
            files(idxFile) = subFile(files(idxFile),1,numSamplesExpected);
        end
    end
    
    disp('naiveTrain: Done!');
    
    % Create the history record file for the GPS data. We also saved the
    % pre-processing results for future use.
    disp(' ');
    disp('Pre-processing: Saving results...');
    save(FULLPATH_FILES_LOADED_HISTORY, ...
        'files', 'fileIndicesCombines', 'fileIndicesTrucks', ...
        'fileIndicesGrainKarts', ...
        'fileIndicesSortedByStartRecordingGpsTime', ...
        'fileIndicesSortedByEndRecordingGpsTime');
    
    if FLAG_PLOT_AND_SAVE_CKT_DATA_LOADED
        % Also save an overview figure.
        hFilesOverview = plotFilesOnMapByType(files);
        %saveas(hFilesOverview, [FULLPATH_FILES_OVERVIEW_FIG, '.fig']);
        saveas(hFilesOverview, [FULLPATH_FILES_OVERVIEW_FIG, '.png']);
    end
end
% EOF