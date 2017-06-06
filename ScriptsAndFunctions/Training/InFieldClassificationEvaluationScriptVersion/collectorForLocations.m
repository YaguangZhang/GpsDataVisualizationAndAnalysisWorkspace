%COLLECTORFORLOCATIONS A GUI collector for the variable locations.
%
% For performance evaluation of the infield-classification test, we need
% the correct classification results. This script will create a graphical
% user interface (GUI) for manually setting the variable locations. The
% results will be saved in the file filesLoadedLocations_ref.mat.
%
% Note: works well using Matlab 2014b. May not work in 2014a. 
%
% Yaguang Zhang, Purdue, 03/29/2015

%% User Specified Parameters

% From which file to start info collection.
INDEX_FILE_TO_START = 24;

% The location of the data set. Please refer to mapViewController for more
% infomation.
fileFolder = fullfile('..', '..', '..',  'Harvest_Ballet_2015');
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
cd(fullfile(fileparts(which(mfilename)),'..', '..'));
% Set path.
setMatlabPath;
addpath(fullfile(fileparts(which(mfilename)),'Scripts'));

%% Load GPS Data

% Clear variables.
if exist('files', 'var') && USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE
    disp('-------------------------------------------------------------');
    disp('Pre-processing: Reuse GPS data variables in the current workspace.');
    % Reuse GPS data variables in current workspace.
    clearvars -except INDEX_FILE_TO_START ...
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
    clearvars -except INDEX_FILE_TO_START ...
        fileFolder IS_RELATIVE_PATH ...
        MIN_SAMPLE_NUM_TO_IGNORE ...
        USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE;
    loadGpsData;
    toc;
    disp('Pre-processing: Done!');
end

%% The Collector for "locations"

disp('-------------------------------------------------------------');
disp('Collector: Initializing...');

% The folder where the classification results are saved.
pathInFieldClassificationFilefolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
pathInFieldClassificationFile = fullfile(...
    pathInFieldClassificationFilefolder, ...
    strcat('filesLoadedLocations_ref','.mat')...
    );
% For backup files.
pathBackupFileFolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT', 'Backup_for_Training');
pathBackupLocationsRefFile = fullfile(...
    pathBackupFileFolder, ...
    ...
    strcat(...
    'filesLoadedLocations_ref_', ...
    datestr(now,'mm_dd_yyyy_HH_MM_SS'), '.mat'...
    )...
    ...
    );

% Create the directory if necessary.
if ~exist(pathInFieldClassificationFilefolder,'dir')
    mkdir(pathInFieldClassificationFilefolder);
end

if ~exist(pathBackupFileFolder,'dir')
    mkdir(pathBackupFileFolder);
end

% Try loading corresponding history record first.
if exist(pathInFieldClassificationFile,'file')
    disp(' ');
    disp('Collector: Loading history results of locationsRef...');
    tic;
    load(pathInFieldClassificationFile);
    toc;
    disp('Collector: Done!');
else
    disp(' ');
    disp('Collector: Couldn''t find history results of locationsRef.');
    disp('Collector: Creating locationsRef...');
    tic;
    
    % Create the variable locations to store the results.
    locationsRef = cell(length(files),1);
    
    for indexFile = 1:1:length(files)
        % Load data.
        lengthLat = length(files(indexFile).lat);
        lengthSpeed = length(files(indexFile).speed);
        
        % Label the corresponding locations as on the road (-100). Discard
        % the last sample if it's not complete.
        locationsRef{indexFile} = -100*ones(min(lengthLat,lengthSpeed),1);
    end
    
    % Save the results into the history file.
    save(pathInFieldClassificationFile, 'locationsRef');
    
    toc;
    disp('Collector: Done!');
end

% Now the variable locationsRef is in the workspace, so we will create the
% GUI figure for each route and collect location info. We will set the
% figure to be visible once the map is ready to be shown.

disp(' ');
disp('Collector: Please use the GUI to collect info for locations...');
for indexFile = INDEX_FILE_TO_START:1:length(files) 
    disp('-------------------------------------------------------------');
    disp(strcat('Collector: Current route', 23, 23, ...
        num2str(indexFile),'/',num2str(length(files)),'...'));
    
    % Load data into a structure used for collectorGUI.
    routeInfo.locationsRef = locationsRef{indexFile};
    routeInfo.lati = files(indexFile).lat(1:length(routeInfo.locationsRef));
    routeInfo.long = files(indexFile).lon(1:length(routeInfo.locationsRef));
    
    % Clear workspace and create GUI of the collector.
    refreshCollectorGUI;
    
    % Wait until the user indicate that the info collection is done.
    while(flagCollectingInfo)
        pause(0.1);
    end
    
end

disp('-------------------------------------------------------------');
disp('Collector: Saving a copy of locationsRef as backup.')

save(pathBackupLocationsRefFile, 'locationsRef');

disp('Collector: Done!');
disp('-------------------------------------------------------------');

% EOF