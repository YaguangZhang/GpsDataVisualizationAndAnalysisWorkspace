%EXTRACTLABELEDFILES Extract files that are manually labeled (for states).
%
% The results are saved in outputFileFolder.
%
% Yaguang Zhang, Purdue, 07/05/2017

%% User Specified Parameters

% The location of the data set. Please refer to mapViewController for more
% infomation.
fileFolder = fullfile('..', '..', '..',  'Harvest_Ballet_2015');
IS_RELATIVE_PATH = true;
MIN_SAMPLE_NUM_TO_IGNORE = 20;

% Path to save the results.
outputFileFolder = fullfile('..', '..', '..',  'Harvest_Ballet_2015_ManuallyLabeled');

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
        fileFolder fileFolderSet outputFileFolder IS_RELATIVE_PATH ...
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
        fileFolder outputFileFolder IS_RELATIVE_PATH ...
        MIN_SAMPLE_NUM_TO_IGNORE ...
        USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE;
    loadGpsData;
    toc;
    disp('Pre-processing: Done!');
end

%% Extract and Save Files that are Manully Labeled.

disp('-------------------------------------------------------------');
disp('extractLabeledFiles: Extracting files ...');
tic;

% Make the folders if necessary.
outputFileFolderAbs = fullfile(pwd, outputFileFolder);
FULLPATH_OUTPUT_AUTOGEN_FILEFOLDER = fullfile(outputFileFolderAbs, ...
    '_AUTOGEN_IMPORTANT');
FULLPATH_OUTPUT_FILES_LOADED_HISTORY = fullfile(...
    FULLPATH_OUTPUT_AUTOGEN_FILEFOLDER, ...
    'filesLoadedHistory.mat'...
    );
% Create the directory if necessary.
if ~exist(FULLPATH_OUTPUT_AUTOGEN_FILEFOLDER, 'dir')
    mkdir(FULLPATH_OUTPUT_AUTOGEN_FILEFOLDER);
end

% The indices for all the files that are labeled.
INDICES_LABELED_FILES = [2,3,4,5,7,8,14,15,16,17, 118,119,120,121,122, 24,40,41,57,58,77,91,92, 25,42,59,60,78,79,80,81,82,93,94,95,96,97,98,99,100, 28,45,63,84, 29,46,64,65,85,103];
% We need to extract them and re-index them.
newFileIndices = 1:length(INDICES_LABELED_FILES);

files = files(INDICES_LABELED_FILES);
fileIndicesCombines = find(arrayfun(@(file) strcmp(file.type, 'Combine'), files))';
fileIndicesTrucks = find(arrayfun(@(file) strcmp(file.type, 'Truck'), files))';
fileIndicesGrainKarts = find(arrayfun(@(file) strcmp(file.type, 'Grain Kart'), files))';
fileIndicesSortedByStartRecordingGpsTime = sortrows([(1:length(files))', arrayfun(@(file) file.gpsTime(1), files)'],2);
fileIndicesSortedByEndRecordingGpsTime = sortrows([(1:length(files))', arrayfun(@(file) file.gpsTime(end), files)'],2);
save(FULLPATH_OUTPUT_FILES_LOADED_HISTORY, ...
    'files', 'fileIndicesCombines', 'fileIndicesTrucks', ...
    'fileIndicesGrainKarts', ...
    'fileIndicesSortedByStartRecordingGpsTime', ...
    'fileIndicesSortedByEndRecordingGpsTime');

% The reference states.
pathOriRefState = fullfile(...
    FULLPATH_FILEFOLDER_FOR_FILES_LOADED_HISTORY, ...
    'filesLoadedStates_ref.mat'...
    );
pathOutputRefState = fullfile(...
    FULLPATH_OUTPUT_AUTOGEN_FILEFOLDER, ...
    'filesLoadedStates_ref.mat'...
    );
load(pathOriRefState);
statesRef = statesRef(INDICES_LABELED_FILES);
% Update the indices.
for idxStateRef = 1:length(statesRef)
    [Lia, Locb] = ismember(statesRef{idxStateRef}, INDICES_LABELED_FILES);
    statesRef{idxStateRef}(Lia) = Locb(Lia);
end
% Now all the indices shown should be updated.
for idxStateRef = 1:length(statesRef)
    if any(~ismember(statesRef{idxStateRef}, INDICES_LABELED_FILES))
        warning('Not all indices shown are from the labeled files set!')
    end
end
statesRefSetFlag = statesRefSetFlag(INDICES_LABELED_FILES);
IDX_SELECTED_FILE = 1;
[MOVIE_GPS_TIME_START, MOVIE_GPS_TIME_END] = deal(zeros(length(files),1));
save(pathOutputRefState, 'statesRef', 'statesRefSetFlag', ...
        'IDX_SELECTED_FILE', 'MOVIE_GPS_TIME_START', 'MOVIE_GPS_TIME_END');
toc;
disp('extractLabeledFiles: Done!');
% EOF