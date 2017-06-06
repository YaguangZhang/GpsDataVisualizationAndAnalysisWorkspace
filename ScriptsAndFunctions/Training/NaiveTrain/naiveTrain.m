%NAIVETRAIN
% This script went through the GPS data, labels the vehicle states
% according to a naive rule-based expert system, and saves the results
% accordingly in a .mat file.
%
% Yaguang Zhang, Purdue, 02/23/2015

%% User Specified Parameters

% Please refer to mapViewController for more infomation.
%   2015: fullfile('..', '..', '..',  'Harvest_Ballet_2015');
%   2016: fullfile('..', '..', '..',  'Harvest_Ballet_2016', 'harvests');
%   2016 mannually synchronized (tablet U06 isn't set to auto sync with the
% Internet time): 
%         fullfile('..', '..', '..',  'Harvest_Ballet_2016', 'harvests_synchronized');
%   2016 GPS samples rate test (after fixing the Android logging cur_time 
%   instead of location.time bug): 
%         C:\Users\Zyglabs\Google Drive\2014_Harvest\GpsDataVisualizationAndAnalysis\CKT_GpsSampleRateTest_2016_08_20
%   2017 auto GPS logging test 1 (JVK trip to Chicago): 
%         C:\Users\Zyglabs\Google Drive\2014_Harvest\GpsDataVisualizationAndAnalysis\CKT_AutoLoggingTest_JVK_2017_03_10\1_TripToChicago
%   2017 auto GPS logging test 2 (JVK trip further away): 
%         C:\Users\Zyglabs\Google Drive\2014_Harvest\GpsDataVisualizationAndAnalysis\CKT_AutoLoggingTest_JVK_2017_03_10\2_TripFurtherAway
%   2017 auto GPS logging test 3 (JVK trip near campus): 
%         C:\Users\Zyglabs\Google Drive\2014_Harvest\GpsDataVisualizationAndAnalysis\CKT_AutoLoggingTest_JVK_2017_03_10\3_TripAroundCampus
fileFolder = fullfile('C:\Users\Zyglabs\Google Drive\2014_Harvest\GpsDataVisualizationAndAnalysis\CKT_AutoLoggingTest_JVK_2017_03_10\3_TripAroundCampus');
IS_RELATIVE_PATH = false;
%fileFolder = fullfile('..', '..', '..',  'Harvest_Ballet_2015');
%IS_RELATIVE_PATH = true;
MIN_SAMPLE_NUM_TO_IGNORE = 20;

% If the GPS data has already loaded, you can set this flag to be true and
% skip loading the variables for the data again. Just please make sure the
% variables in the current workspace are indeed corresponding to the files
% specified by "fileFolder".
USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE = true;
% The same for the location classification results.
USE_LOCATIONS_IN_CURRENT_WORKSPACE = true;

% The length of the side of the square by meters. It's used for computing
% the device independent sample density of each sample point.
%   Device independent sample density
%     = Sample number in a square / sample rate / square area
% See testDevIndSampleDensity.m for more infomation.
SQUARE_SIDE_LENGTH = 200;

% Force redo infield classificaiton/state recognition.
FORCE_REDO_INFIELD_CLASSIFICATION = false;
FORCE_REDO_STATE_RECOGNITION = false;

%% Set Matlab Path.

% Clear command window. Close all plot & web map display windows.
%clc;
close all;wmclose all;

% Changed folder to "ScriptsAndFunctions" first.
cd(fullfile(fileparts(which(mfilename)),'..', '..'));
% Set path.
setMatlabPath;

%% Load GPS Data

% Clear variables.
if exist('files', 'var') && USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE
    disp('-------------------------------------------------------------');
    disp('Pre-processing: Reuse GPS data variables in the current workspace.');
    % Reuse GPS data variables in current workspace.
    clearvars -except fileFolder fileFolderSet IS_RELATIVE_PATH ...
        FULLPATH_FILES_LOADED_STATES ...
        MIN_SAMPLE_NUM_TO_IGNORE ...
        USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE ...
        USE_LOCATIONS_IN_CURRENT_WORKSPACE ...
        SQUARE_SIDE_LENGTH FORCE_REDO_INFIELD_CLASSIFICATION...
        FORCE_REDO_INFIELD_CLASSIFICATION FORCE_REDO_STATE_RECOGNITION ...
        ...
        files fileIndicesCombines fileIndicesTrucks ...
        fileIndicesGrainKarts ...
        fileIndicesSortedByStartRecordingGpsTime ...
        fileIndicesSortedByEndRecordingGpsTime ...
        locations ... Also keep locations in case we want to reuse it too.
        GPS_TIME_RANGE PLAYBACK_SPEED AXIS_VISIBLE FLAG_SHOW_VEH_ACTIVITIES ... % For genMovieByGpsTime.m
        axisVisibleMovies timeRangeMovies indicesMovieToVeh IND_FILE_FOR_GEN_MOVIE ASK_FOR_HELP SHOW_VELOCITY_DIRECTIONS pathFolderToSaveMovies ... % For testAutoGenMovies.m
        statesRef; 
    
else
    disp('-------------------------------------------------------------');
    disp('Pre-processing: Loading GPS data...');
    tic;
    clearvars -except fileFolder IS_RELATIVE_PATH ...
        FULLPATH_FILES_LOADED_STATES ...
        MIN_SAMPLE_NUM_TO_IGNORE ...
        USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE ...
        USE_LOCATIONS_IN_CURRENT_WORKSPACE ...
        SQUARE_SIDE_LENGTH FORCE_REDO_INFIELD_CLASSIFICATION ...
        FORCE_REDO_INFIELD_CLASSIFICATION FORCE_REDO_STATE_RECOGNITION ...
        GPS_TIME_RANGE PLAYBACK_SPEED AXIS_VISIBLE FLAG_SHOW_VEH_ACTIVITIES ... % For genMovieByGpsTime.m
        axisVisibleMovies timeRangeMovies indicesMovieToVeh IND_FILE_FOR_GEN_MOVIE ASK_FOR_HELP SHOW_VELOCITY_DIRECTIONS pathFolderToSaveMovies ... % For testAutoGenMovies.m
        statesRef; 
    loadGpsData;
    toc;
    disp('Pre-processing: Done!');
end

%% Compute Device-Independent Sample Densities
% Implements algorithm 1 without excluding adjacent points. See
% testDevIndSampleDensity.m for more infomation.

disp('-------------------------------------------------------------');
disp('Pre-processing: Computing device independent sample densities...');

% The folder where the sample density results are saved.
pathDevIndSampleDensitiesFilefolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT', 'naiveTrain');
pathDevIndSampleDensitiesFile = fullfile(...
    pathDevIndSampleDensitiesFilefolder, ...
    strcat('DevIndSampleDensities_SQUARE_SIDE_LENGTH_',num2str(SQUARE_SIDE_LENGTH),'.mat')...
    );

% Try loading corresponding history record first.
if exist(pathDevIndSampleDensitiesFile,'file')
    disp(' ');
    disp('Pre-processing: Loading history results...');
    tic;
    load(pathDevIndSampleDensitiesFile);
    toc;
    disp('Pre-processing: Done!');
else
    tic;
    % Create the directory if necessary.
    if ~exist(pathDevIndSampleDensitiesFilefolder,'dir')
        mkdir(pathDevIndSampleDensitiesFilefolder);
    end
    
    computeDevIndSampleDensities;
    
    toc;
    disp('Pre-processing: Done!');
    
    % Save the results in a history .mat file.
    disp(' ');
    disp('Pre-processing: Saving devIndSampleDensities...');
    tic;
    save(pathDevIndSampleDensitiesFile, 'devIndSampleDensities');
    toc;
    disp('Pre-processing: Done!');
    
end

%% In the Field or Not?

disp('-------------------------------------------------------------');
disp('naiveTrain: "In the field" classification...');

% The folder where the classification results are saved.
pathInFieldClassificationFilefolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
pathInFieldClassificationFile = fullfile(...
    pathInFieldClassificationFilefolder, ...
    strcat('filesLoadedLocations','.mat')...
    );
pathInFieldClassificationFieldShapes = fullfile(...
    pathInFieldClassificationFilefolder, ...
    strcat('filesLoadedLocationsFieldShapes','.mat')...
    );

if USE_LOCATIONS_IN_CURRENT_WORKSPACE && exist('locations', 'var')
    disp('naiveTrain: Reuse the variable locations in the current workspace.');
else
    % Try loading corresponding history record first.
    if exist(pathInFieldClassificationFile,'file') ...
            && exist(pathInFieldClassificationFieldShapes,'file')...
            && ~FORCE_REDO_INFIELD_CLASSIFICATION
        disp(' ');
        disp('naiveTrain: Loading history results of locations...');
        tic;
        load(pathInFieldClassificationFile);
        load(pathInFieldClassificationFieldShapes);
        toc;
    else
        % Create the variables locations and fieldShapes to store the
        % results. Note that filedShapes contains the alpha shapes are
        % exactly what we build from infield points, so they man contain
        % holes.
        locations = cell(length(files),1);
        % Since we don't know how many field shapes will be generated,
        % we'll initialize this by an empty cell.
        fieldShapes = cell(0,0);
        
        % Label locaitons for all vehicles using naive infield
        % classification.
        labelLocations;
        
        % Save locations in a history .mat file.
        disp(' ');
        disp('naiveTrain: Saving locations and fieldshapes...');
        tic;
        save(pathInFieldClassificationFile, 'locations');
        save(pathInFieldClassificationFieldShapes, 'fieldShapes');
        toc;
    end
end
disp('naiveTrain: Done!');

%% Searching for the Nearest Vehicle for Each Sample
%
% Also save the results in a .mat file.

disp('-------------------------------------------------------------');
disp('Pre-processing: Searching for the nearest vehicles...');

% The folder where the sample density results are saved.
pathNearestVehFilefolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT', 'naiveTrain');
pathNearestVehFile = fullfile(...
    pathNearestVehFilefolder, ...
    strcat('NearestVehicles.mat')...
    );

% Try loading corresponding history record first.
if exist(pathNearestVehFile,'file')
    disp(' ');
    disp('Pre-processing: Loading history results...');
    tic;
    load(pathNearestVehFile);
    toc;
    disp('Pre-processing: Done!');
else
    tic;
    % Create the directory if necessary.
    if ~exist(pathNearestVehFilefolder,'dir')
        mkdir(pathNearestVehFilefolder);
    end
    
    findNearestVehicles;
    
    toc;
    disp('Pre-processing: Done!');
    
    % Save the results in a history .mat file.
    disp(' ');
    disp('Pre-processing: Saving nearestVehicles...');
    tic;
    save(pathNearestVehFile, 'nearestVehicles');
    toc;
    disp('Pre-processing: Done!');
    
end

%% Vehicle State

disp('-------------------------------------------------------------');
disp('naiveTrain: Vehicle state recognition (by distance)...');

% The folder where the recognition results are saved.
pathStatesByDistFilefolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
pathStatesByDistFile = fullfile(...
    pathStatesByDistFilefolder, ...
    strcat('filesLoadedStatesByDist','.mat')...
    );

% Try loading corresponding history record first.
if exist(pathStatesByDistFile,'file') ...
        && ~FORCE_REDO_STATE_RECOGNITION
    disp(' ');
    disp('naiveTrain: Loading history results of statesByDist...');
    tic;
    load(pathStatesByDistFile);
    toc;
    disp('naiveTrain: Done!');
else
    disp(' ');
    disp('naiveTrain: Generating statesByDist...');
    tic;
    
    % Create the directory if necessary.
    if ~exist(pathNearestVehFilefolder,'dir')
        mkdir(pathNearestVehFilefolder);
    end
    
    % Label statesByDist for all vehicles.
    genStatesByDist;
    
    toc;
    disp('naiveTrain: Done!');
    
    % Save statesByDist in a history .mat file.
    disp(' ');
    disp('naiveTrain: Saving statesByDist...');
    tic;
    save(pathStatesByDistFile, 'statesByDist');
    toc;
    disp('naiveTrain: Done!');
end

%% Yield Map



% EOF