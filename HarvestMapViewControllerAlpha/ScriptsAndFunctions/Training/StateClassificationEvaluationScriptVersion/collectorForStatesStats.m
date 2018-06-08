%COLLECTORFORSTATESSTATS Plot ranges of the files to show how much data
%have been manually labeled by collectorForStates.
%
% The time range for files are stacked vertically and black parts are
% manually labeled.
%
% Yaguang Zhang, Purdue, 07/03/2017

%% User Specified Parameters

% Whether to use the naiveTrain results as the starting point.
FLAG_USE_NAIVETRAIN_RESULTS = true;

% The location of the data set. Please refer to mapViewController for more
% infomation.
fileFolder = fullfile('..', '..', '..',  'Harvest_Ballet_2015_ManuallyLabeled'); %fullfile('..', '..', '..',  'Harvest_Ballet_2015');
IS_RELATIVE_PATH = true;
MIN_SAMPLE_NUM_TO_IGNORE = 20;

% If the GPS data has already loaded, you can set this flag to be true and
% skip loading the variables for the data again. Just please make sure the
% variables in the current workspace are indeed corresponding to the files
% specified by "fileFolder".
USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE = true;

%% Set Matlab Path.

% Clear command window. Close all plot & web map display windows.
clc;close all;wmclose all;

% Changed folder to "ScriptsAndFunctions" first.
cd(fileparts(mfilename('fullpath')));
cd(fullfile('..', '..'));
% Set path.
setMatlabPath;

%% Load GPS Data

% Clear variables.
if exist('files', 'var') && USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE
    disp('-------------------------------------------------------------');
    disp('Pre-processing: Reuse GPS data variables in the current workspace.');
    % Reuse GPS data variables in current workspace.
    clearvars -except ...
        FLAG_USE_NAIVETRAIN_RESULTS ...
        fileFolder fileFolderSet IS_RELATIVE_PATH ...
        MIN_SAMPLE_NUM_TO_IGNORE ...
        USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE ...
        ...
        files fileIndicesCombines fileIndicesTrucks ...
        fileIndicesGrainKarts ...
        fileIndicesSortedByStartRecordingGpsTime ...
        fileIndicesSortedByEndRecordingGpsTime;
else
    disp('-------------------------------------------------------------');
    disp('Pre-processing: Loading GPS data...');
    tic;
    clearvars -except ...
        FLAG_USE_NAIVETRAIN_RESULTS ...
        fileFolder IS_RELATIVE_PATH ...
        MIN_SAMPLE_NUM_TO_IGNORE ...
        USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE;
    loadGpsData;
    toc;
    disp('Pre-processing: Done!');
end

%% Log Files

disp('-------------------------------------------------------------');
disp('Collector: Initializing...');

% The folder where the classification results are saved. We will use the
% file filesLoadedStates_ref.mat to store the collected state information.
pathStateClassificationFilefolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
pathStateClassificationFile = fullfile(...
    pathStateClassificationFilefolder, ...
    strcat('filesLoadedStates_ref','.mat')...
    );
pathNariveTrainStateResults = fullfile(...
    pathStateClassificationFilefolder, ...
    strcat('filesLoadedStatesByDist','.mat')...
    );

% For backup files.
pathBackupFileFolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT', 'Backup_for_Training');
pathBackupStatesRefFile = fullfile(...
    pathBackupFileFolder, ...
    ...
    strcat(...
    'filesLoadedStates_', ...
    datestr(now,'mm_dd_yyyy_HH_MM_SS'), '.mat'...
    )...
    ...
    );

% Create the directory if necessary.
if ~exist(pathStateClassificationFilefolder,'dir')
    mkdir(pathStateClassificationFilefolder);
end

if ~exist(pathBackupFileFolder,'dir')
    mkdir(pathBackupFileFolder);
end

% Load the information for the generated movies.
load(fullfile(pathStateClassificationFilefolder, 'AutoGenMovies', 'MoviesInfo.mat'));

% Try loading corresponding history record first.
if exist(pathStateClassificationFile,'file')
    disp(' ');
    disp('Collector: Loading history results of statesRef...');
    tic;
    load(pathStateClassificationFile);
    toc;
    disp('Collector: Done!');
else
    disp(' ');
    disp('Collector: Couldn''t find history results of statesRef.');
    disp('Collector: Creating statesRef...');
    tic;
    
    % Create the variable states to store the results.
    if ~FLAG_USE_NAIVETRAIN_RESULTS
        % Use empty statesRef.
        disp('Use an empty state holder as the starting point.')
        
        % Use an empty state holder.
        statesRef = cell(length(files),1);
        for indexFile = 1:1:length(files)
            % Colomns: [loadFrom, unloadTo]. See genStateByDist.m under
            % StateByDistExpertSystem for more details.
            statesRef{indexFile} = nan(length(files(indexFile).gpsTime),2);
        end
    else
        % Use statesByDist as statesRef.
        disp('Use the naiveTrain results as the starting point.')
        % Load the results from the naiveTrain algorithm.
        if exist(pathNariveTrainStateResults, 'file')
            load(pathNariveTrainStateResults);
        else
            error('naiveTrain results not found! Please run naiveTrain.m for this data set at least once.')
        end
        % Colomns: [loadFrom, unloadTo]. See genStateByDist.m under
        % StateByDistExpertSystem for more details.
        statesRef = statesByDist;
    end
    
    statesRefSetFlag = statesRef;
    for indexFile = 1:1:length(files)
        % Indicate whether the data point has been viewed yet. If viewed,
        % we will set the corresponding flag as 1 to indicate it's already
        % been manually labeled.
        statesRefSetFlag{indexFile} = zeros(length(files(indexFile).gpsTime),1);
    end
    % Default GUI related info.
    numMovies = length(files);
    IDX_SELECTED_FILE = 1;
    MOVIE_GPS_TIME_START = zeros(numMovies,1);
    MOVIE_GPS_TIME_END = MOVIE_GPS_TIME_START;
    for movieIdx = 1:numMovies
        MOVIE_GPS_TIME_END(movieIdx) = timeRangeMovies(movieIdx,2)- timeRangeMovies(movieIdx,1);
    end
    % Save the results into the history file.
    save(pathStateClassificationFile, 'statesRef', 'statesRefSetFlag', ...
        'IDX_SELECTED_FILE', 'MOVIE_GPS_TIME_START', 'MOVIE_GPS_TIME_END');
    
    toc;
    disp('Collector: Done!');
end

%% The Progress Plot
LINE_WIDTH = 5;
figure; hold on; grid on; grid minor;
for idxFile=1:length(files)
    % Plot the ranges for files, with texts indicating the indices.
    plot([files(idxFile).gpsTime(1),files(idxFile).gpsTime(end)], [idxFile,idxFile], ...
        'LineWidth', LINE_WIDTH);
    text(files(idxFile).gpsTime(1), idxFile, num2str(idxFile), ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
        'FontSize', 9);
end
for idxFile=1:length(files)
    % Plot the labeled parts according to statesRefSetFlag.
    [indicesSs, indicesEs] = ...
        findConsecutiveSubSeq(statesRefSetFlag{idxFile},1);
    if (~isempty(indicesSs))
        yToPlot = idxFile.*ones(2,length(indicesSs));
        plot([files(idxFile).gpsTime(indicesSs)'; files(idxFile).gpsTime(indicesEs)'], yToPlot, ...
            'LineWidth', LINE_WIDTH, 'Color','k');
    end
end
hold off;

% EOF