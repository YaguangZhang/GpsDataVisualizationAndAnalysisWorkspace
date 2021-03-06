%MAPVIEWCONTROLLER
% Script file to process the GPS data files collected by the app CKT for
% harvesting. It will interactively set the start time and map size and
% generate an animation of the data accordingly.
%
% Please specify the file folder location of the GPS data files first at
% the "user specified parameters" section. The program should work well for
% the basic animation generation once this loction is set correctly. For
% more functions, please set parameters accordingly at the "user specified
% parameters" section:
%
%       (Must be set correctly)
%
%     - fileFolder (Must be set correctly)
%
%     - IS_RELATIVE_PATH
%
%     The file folder where all the log files will be processed.
%
%     If it's the path relative to this matlab file, please aslo set
%     RELATIVE_PATH_USED to be ture. If it's the absolute path, please set
%     RELATIVE_PATH_USED to be false.
%
%     Note that if you are using data files which are not generated by the
%     app CKT, then you need to make sure the data in your files are
%     formatted in the same way as those in the demo dataset.
%     Alternatively, you can replace the function "loadGpsLogFileData.m"
%     with the one designed for your own data set.
%
%       (Optional)
%
%     - IS_JVK_HARVEST_BALLET_DATASET
%
%     It's recommended to set IS_JVK_HARVEST_BALLET_DATASET to be false if
%     you are using your own data set. You can optionally set it to be true
%     if you do use the demo data set. If you do so, when you run the
%     program using only the data files (with no history setting files),
%     the program can use the default settings for things like current time
%     and visible map area to help you find the default routes to be shown
%     in the animation.
%
%     - ALWAYS_RE_PREPROCESS
%
%     The flag for always reloading data from original data files.
%
%     The program won't try to save time during the pre-processing by
%     exploiting the history file generated before for the original GPS
%     data files.
%
%     - SKIP_INI_SETTINGS
%
%     The flag for skipping initial settings.
%
%     Set it to be true to skip the initial setting steps for current time
%     and map limits (Instead, history settings will be used). If the
%     history settings file doesn't exist, the program will set
%     SKIP_INI_SETTINGS = false automatically.
%
%     - GENERATE_MOV
%
%     The flag for generating movie from the animation.
%
%     If GENERATE_MOV is set to be true, the program will capture frames
%     from the animation window. And an additional button "Generate the
%     Movie Now" will be shown at the animation window. An avi video will
%     be generated at the location specified by the parameter "fileName"
%     below.
%
%     Note 1: it's recommended to set GENERATE_MOV to be false if there's
%     no need to generate movie clips, for example, when you only want to
%     record vehicle states / test training algorithms. Because this
%     setting will speed up the animation generation process.
%
%     Note 2: it's not garanteed that the video will be generated
%     successfully because the frame size may vary depending on how you
%     interact with the program when it's running. However, the frames will
%     be kept at the workspace in the variable "F" when the program
%     terminate and you can work with that directly then.
%
%     - fileName
%
%     The path (together with the name) of the avi video if it's generated
%     successfully.
%
%     Note: the old video will be overwritten if "fileName" doesn't change
%     but a new one is generated. So you may want to reset "fileName" or
%     simply rename or move the old video file before generating a new one
%     if you want to keep it.
%
%     - IS_RELATIVE_PATH_MOV = false;
%
%     Similar as "IS_RELATIVE_PATH", "IS_RELATIVE_PATH_MOV" specifies
%     whether "fileName" is a relative path. Set it to be true if it is.
%
% For training the computer to label vehicle states:
%
%     i. Preparations: Vehicle States Information Collection
%
%     A set of correct state labels for the route files is necessary for
%     developing supervised learning algorithms and is required for
%     algorithm performance evaluation.
%
%     During the animation, you are able to tell the program what the
%     vehicles shown are doing.
%
%     One way to do this is to click on the state label next to a vehicle
%     shown. Buttons for overwritting that vehicle's state at that time
%     will be tiggered. Then, if a button is clicked once and becomes
%     pressed-down, the state at the time points gone through by the
%     animation after that will be overwritten to the state shown by the
%     button. Note that the pressed-down state will only be released
%     automatically when you disable the triggered buttons. Otherwise, you
%     need to click that button again (or click another button) to release
%     it. Especially, even if a vehicle moves out of the visible animiation
%     area, its state is still updated according to its state buttons. You
%     can jump back to a time point when the buttons are visible or reset
%     current animation area if that happens.
%
%     The other way is to select the state points of the state time lines
%     at the bottom of the animation figure. Buttons for changing the state
%     of the selected time points will be shown after the selection. This
%     way has "higher priority" than the way above, which means it's well
%     suited for correcting states set by mistake using the first method.
%     The range of the time lines is determined by playback speed (which is
%     actually "time per frame in millisecond") shown at the left side of
%     the animation figure. It will be -11 to 11 times the playback speed.
%     (zzzzzz still under development)
%
%     It may be wise not try to collect all the vehicles' states shown
%     within one animation. You can collect all the combines' states for
%     the first loop of animation, but only indicating the state "loading"
%     so that you can use faster animation playing speed or jump forward a
%     lot and just get an overview of what's happening. The loading label
%     itself will be sufficient to locate the field these vehicles are
%     working on. Then, during a second loop of the animation, collect as
%     much information as possible by using the pause function. Note that a
%     combine can load/harvest and unload at the same time but it's not
%     necessary the case that whenever it's unloading, it's
%     loading/harvesting, too. For example, the combine may have to unload
%     to a truck directly because it has finished harvesting or it has been
%     full. So please make sure to indicate "not loading or unloading"
%     state before and after these "unloading" labels if these cases
%     happen, so that we know it's only unloading.
%
%     Please remember to click the "Save Vehicle States Now" button every
%     now and then to make sure the trainig results are recorded in a
%     history file.
%
%     By default, the states results will be actually saved in 2 history
%     files. One in the directory "_AUTOGEN_IMPORTANT", together with other
%     history files which will be loaded to run the program. The other is
%     in the the directory "Backup_for_Training" under "_AUTOGEN_IMPORTANT"
%     as a backup. The backup file will be named with its create time.
%
%     If you want to restore the state history file from one of the backup
%     files, please just make a copy of the one you want to restore, get
%     rid of the create time suffix, and use it to replace the state
%     history file in "_AUTOGEN_IMPORTANT".
%
% More about vehicle state:
%
%     A combine can be loading (or harvesting) and unloading at the same
%     time, but there isn't a label corresponding to that. So we indicate
%     this case by set the state label right before and after the
%     "unloading" label group. If both of them are "loading", then we say
%     during the unloading period, the combine is harvesting. On contary them are both "unloading"
%
% More parameters can be set in the "More Parameters" section to specify
% the behavior of the program.
%
% Note that the app CKT register grain cart as "Grain Kart", so we will
% also use "kart" instead of "cart".
%
% Enjoy!

% Yaguang Zhang, Purdue, 01/20/2015

%% Set matlab path.

clc;close all;wmclose all;
% Changed folder to "ScriptsAndFunctions" first.
cd(fullfile(fileparts(which(mfilename)),'ScriptsAndFunctions'));
% Set path.
setMatlabPath;

%% User specified parameters
% More parameters can be set in the More Parameters section.

% The file folder where all the log files will be processed. If it's the
% path relative to "setMatlabPath.m" in the folder "ScriptsAndFunctions",
% please aslo set RELATIVE_PATH_USED to be ture. If it's the absolute path,
% please set RELATIVE_PATH_USED to be false.
%
% Use function fullfile to make sure this will work regardless of which
% operation system is used.
fileFolder = fullfile('..', '..', '..',  'Harvest_Ballet_2017');
IS_RELATIVE_PATH = true;
IS_JVK_HARVEST_BALLET_DATASET = true;

% The flag for always reloading data from original data files.
ALWAYS_RE_PREPROCESS = false;

% The flag for skipping initial settings.
SKIP_INI_SETTINGS = true;

% The flag for generating movie from the animation.
GENERATE_MOV = true;

fileName = '/Users/Zyglabs/Desktop/Demo';
IS_RELATIVE_PATH_MOV = false;

%% Initialization

if IS_RELATIVE_PATH
    fileFolder = fullfile(pwd, fileFolder);
end

if IS_RELATIVE_PATH_MOV
    fileName = fullfile(pwd, fileName); %#ok<UNRCH>
end

disp(' ');
disp('Selected folder to process: ');
disp(strcat(32, 32, 32, 32, fileFolder));

if ALWAYS_RE_PREPROCESS == true
    disp(' ');
    disp('ALWAYS_RE_PREPROCESS: ture');
    disp('                      Will reload data from original data files...');
    
    % Flag for skip loading data. If it's true, we will use varialbes in
    % the current Matlab workspace instead.
    SKIP_LOADING_DATA = false;
    fileFolderSet = fileFolder;
else
    disp(' ');
    disp('ALWAYS_RE_PREPROCESS: false');
    disp('                      Will avoid processing original data files if ');
    disp('                      possible.');
    
    % For faster pre-processing. Skip loading data to save time if the data
    % in the specified folder have been loaded already.
    if exist('fileFolderSet', 'var') && strcmp(fileFolderSet, fileFolder)
        SKIP_LOADING_DATA = true;
    else
        SKIP_LOADING_DATA = false;
        fileFolderSet = fileFolder;
    end
end

if GENERATE_MOV == true
    disp(' ');
    disp('GENERATE_MOV: true');
    disp('              The video file specified is:');
    disp(strcat(32, 32, 32, 32, fileName, '.avi'));
end

if SKIP_LOADING_DATA == false
    % Only keep variables set by the user.
    clearvars -except fileFolderSet fileName ...
        IS_JVK_HARVEST_BALLET_DATASET...
        ALWAYS_RE_PREPROCESS SKIP_LOADING_DATA ...
        SKIP_INI_SETTINGS GENERATE_MOV;
end

if SKIP_LOADING_DATA == true
    % Keep user specified variables and history records.
    clearvars -except fileFolderSet fileName ...
        IS_JVK_HARVEST_BALLET_DATASET...
        ALWAYS_RE_PREPROCESS SKIP_LOADING_DATA ...
        SKIP_INI_SETTINGS GENERATE_MOV ...
        files fileIndicesCombines fileIndicesTrucks ...
        fileIndicesGrainKarts ...
        fileIndicesSortedByStartRecordingGpsTime ...
        fileIndicesSortedByEndRecordingGpsTime ...
        currentTime currentWmLimits currentZoomLevel;
end

%% More Parameters

% Reduce the amount of data to speed up rendering in web map display.
SAMPLE_RATE_FOR_WEB_MAP = 20;

% You can show the detailed info on the web map by setting this flag to be
% true. Then every time the web map is updated, the vehicles with detailed
% information will also be shown at the up-to-date locations. However,
% rendering vehicles will slow down the process. What's more, there is a
% confirmed bug for web map if you use Matlab 2014a or 2014b for Mac. The
% vehicles markers may be added at the wrong locations.
RENDER_VEHICLES_ON_WEB_MAP = false;

% 20 is about 20 seconds. The device we used is Nexus 7. When stable, it
% will provide around 1 sample per second. If the file doesn't contain more
% data than this, it will be ignored. All files not ignored will get an
% integer label and these labels will be used also for training. So after
% you have collected states infomation manually for the files you want to
% process, please don't change this variable anymore, or the program may
% correspond the states you've collected to the wrong vehicle. zzzzz We may
% change this variable to device independent criterion like time span in
% the future.
MIN_SAMPLE_NUM_TO_IGNORE = 20;

% Height for the training area (the state timelines in the animation
% figure) in percentage (multiple of 0.1).
HEIGHT_ANIMATION_STATE_TIMELINES_AREA = 0.2;

% Paremeters for the map size.
IMAGE_HEIGHT = 480;
IMAGE_WIDTH = 640;

% Colors for the vehicles.
COLOR.TRUCK = 'black';
COLOR.COMBINE = 'yellow';
COLOR.GRAIN_KART = 'blue';
% Used to highlight the vehicle marker
COLOR.HIGH_LIGHT = 'red';
% Used to indicate shown but inactive vehicles.
COLOR.DONE = [0.5 0.5 0.5]; % Dark grey.
% When we show the distance between two vehicles, there will be a link for
% it. This is the color of the link.
COLOR_VEHICLE_DISTS_LINKS = 'green';

% Parameters for the movie.
% For playback speed in the animation figure. The larger this varialbe, the
% faster the animation will run.
MILLISEC_PER_FRAME_DEFAULT = 20000;
% For generateMov. Every second of the movie will show 3 frames.
FRAMES_PER_SECOND = 3;

% Compression method used.
COMPRESSION = 'None';

% Default value for the flag indicating whether to show the velocity
% directions.
SHOW_VELOCITY_DIRECTIONS = true;

%% Data pre-processing

% For updating the map limits while the animation is generated. We use a
% flag to indicate the update of map limits and carry out the update
% outside of the callback function. Because we are using a while loop as
% the main part of the animation, as long as this flag is set to be true,
% the map limit adjust procedure will be carried out smoothly.
UPDATE_MAP_LIMITS = false;
% Used to set the speed of the animation.
MILLISEC_PER_FRAME = MILLISEC_PER_FRAME_DEFAULT;

% Full paths for history files.
FULLPATH_FILES_LOADED_HISTORY = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT', 'filesLoadedHistory.mat');
FULLPATH_SETTINGS_HISTORY = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT', 'settingsHistory.mat');
FULLPATH_FILES_LOADED_STATES = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT', 'filesLoadedStates.mat');

% For movie generation.
if GENERATE_MOV
    % Used to store movie frames.
    F = struct('cdata', [], 'colormap', []); %#ok<UNRCH>
    % Used to count how many frames have been created.
    frameNum = 0;
end

% For saving training results . The state history file will be save at the
% same directory as the one for files of "files" and settings. But we will
% also store a copy of the "states" info in the directory specified below
% whenever we manually save the training results, because the training
% involves too much human work and we can't risk losing it somehow.
fileFolderBackupTraining = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT', 'Backup_for_Training');

% Create the directory if it doesn't exist.
if ~exist(fileFolderBackupTraining,'dir')
    mkdir(fileFolderBackupTraining);
end

% Load GPS data from FULLPATH_FILES_LOADED_HISTORY.
flagFilesLoadedExist = exist(FULLPATH_FILES_LOADED_HISTORY, 'file');
% If there is no history GPS data record for this directory, we will force
% SKIP_INI_SETTINGS to be false regardless of the existence of the history
% setting record file.
if SKIP_INI_SETTINGS == true
    if flagFilesLoadedExist
        disp(' ');
        disp('SKIP_INI_SETTINGS: ture');
        disp('                   Will skip the initial settings...');
    else
        disp(' ');
        disp('SKIP_INI_SETTINGS: Set to be false because couldn''t find the history ');
        disp('                   file...');
        SKIP_INI_SETTINGS = false;
    end
end

disp('----------------------------');
        
if SKIP_LOADING_DATA == false
    % Need to load GPS data from the history record or the original data
    % files if SKIP_LOADING_DATA is false.
    if ALWAYS_RE_PREPROCESS == false && flagFilesLoadedExist
        % Can load data from the record file.

        disp('Pre-processing: Files in the specified folder has been processed ');
        disp('                before.');
        disp('                Loading history results...');
        
        load(FULLPATH_FILES_LOADED_HISTORY);
    else
        % Need to process the original files to get the data.
        disp('Pre-processing: Scanning specified folder for data files...');
        
        % See processGpsDataFiles.m for more infomation.
        [files, ...
            fileIndicesCombines,fileIndicesTrucks,fileIndicesGrainKarts, ...
            fileIndicesSortedByStartRecordingGpsTime, ...
            fileIndicesSortedByEndRecordingGpsTime]...
            = processGpsDataFiles(fileFolderSet, MIN_SAMPLE_NUM_TO_IGNORE);
        
        % Create the history record file for the GPS data. We also saved
        % the pre-processing results for future use.
        disp(' ');
        disp('Pre-processing: Saving results...');
        save(FULLPATH_FILES_LOADED_HISTORY, ...
            'files', 'fileIndicesCombines', 'fileIndicesTrucks', ...
            'fileIndicesGrainKarts', ...
            'fileIndicesSortedByStartRecordingGpsTime', ...
            'fileIndicesSortedByEndRecordingGpsTime');
        
        % A set of default values for currentTime and currentWmLimits are
        % assigned here if the demo data files are used. currentTime is the
        % current time point for the animation in milliseconds since the
        % earliest file in the data file set starts being recorded.
        if IS_JVK_HARVEST_BALLET_DATASET
            currentTime = 1.713*10^9;
            currentWmLimits = [40.7941 40.8131 -102.2989 -102.2657];
            currentZoomLevel = 15;
        else
            currentTime = 0; %#ok<UNRCH>
            currentWmLimits = [-71.1310 71.1310 -135.8789 135.8789];
            currentZoomLevel = 2;
        end
        
        save(FULLPATH_SETTINGS_HISTORY, ...
            'currentTime', 'currentWmLimits', 'currentZoomLevel');
        
        disp('History files created at:');
        disp( strcat(32, 32, 32, 32, ...
            FULLPATH_FILES_LOADED_HISTORY) );
        disp( strcat(32, 32, 32, 32, ...
            FULLPATH_SETTINGS_HISTORY) );
    end
else
    disp('Pre-processing: The data in the specified folder have been loaded ');
    disp('                already.');
end

% Vehicle state history
if ~exist(FULLPATH_FILES_LOADED_STATES,'file')
    
    disp('                Wasn''t able to find history training file. ');
    disp('                Initialize the vechicle states...');
    
    % Initial automatic training and saving.
    initializeTrainingStates;
else
    disp('                Loading the vechicle state history file...');
    
    % Initial automatic training and saving.
    load(FULLPATH_FILES_LOADED_STATES);
end

%% Find all routes / files into which the current time point falls
% Group all the routes into "haven't started recording", "being recorded"
% and "have finished recording" according to currentGpsTime. And plot a
% timeline to show these routes.

load(FULLPATH_SETTINGS_HISTORY);

% The earliest time stamp available for all the data files.
originGpsTime = fileIndicesSortedByStartRecordingGpsTime(1,2);
% Total gps time range for these data. It will stay the same since the data
% set won't change during the program is running.
gpsTimeLineRange = [originGpsTime; ...
    fileIndicesSortedByEndRecordingGpsTime(end, 2)];

disp(' ');
disp('Overview: Updating the timeline for all routes available...');

% updateActiveRoutesInfo.m
[currentGpsTime, ...
    filesToShowIndices, filesToShow, filesToShowTimeRange, ...
    filesNotStartedRecInd, filesNotStartedRecTimeRange, ...
    filesFinishedRecInd, filesFinishedRecTimeRange]...
    = updateActiveRoutesInfo(files, currentTime, originGpsTime, ...
    fileIndicesSortedByStartRecordingGpsTime, fileIndicesSortedByEndRecordingGpsTime);

%% Plot the timeline, with past and future routes lower than the x-axis.

% Line width for the files on the timeline figure.
LINE_WIDTH = 3;

% See resetFigWithHandleNameAndFigName.m for more information.
hTimelineFig = resetFigWithHandleNameAndFigName('hTimelineFig', 'Timeline');

% Plot
plotTimeLineRoutes;

if ~SKIP_INI_SETTINGS
    % Used modified ginput function to set currentTime line in the figure.
    % Set instructions as the title.
    disp(' ');
    disp('Set currentTime: Please follow the instructions in the figure to set ')
    disp('                 the startTime for the animation...');
end

% setCurrentTime.m
SKIP_CURRENT_TIME_SETTING = SKIP_INI_SETTINGS;
RESET_CURRENT_TIME = false;
setCurrentTime;

%% Show Active Routes on a Web Map Page

% Counter for new added inactive routes.
numNewAddedFileToShow = 0;
flagFirstTime = true;

% zzzzzzz Uncomment try / catch for release versions.
% try
% Loop within this to keep the program running.
while true
    
    disp(' ');
    disp('Active routes: Loading active routes'' info...');
    
    % Reduce the amount of data used for web map display by sampling.
    [latSampled,lonSampled] = sampleCoordinates(filesToShow, SAMPLE_RATE_FOR_WEB_MAP);
    
    % Open a web map display page if necessary.
    
    if exist('hWebMap','var')
        if ~isvalid(hWebMap)
            disp('               Creating new web map display window...');
            hWebMap = webmap('MapQuest Open Aerial Map');
            hRoutesToShow = cell(1,length(filesToShow));
            % We will still add vehicle markers on the web map display when
            % it's been initialezed regard less of the value of
            % RENDER_VEHICLES_ON_WEB_MAP.
            hVehiclesToShow = cell(1,length(filesToShow));
        else
            disp('               Reuse detected web map display window...')
            if numNewAddedFileToShow ==0
                % Now new file to be actived now. Need to render the
                % routes.
                overlayerLines = repmat(hRoutesToShow{1},length(hRoutesToShow),1);
                % Only need to remove vehicle markers when
                % RENDER_VEHICLES_ON_WEB_MAP is true.
                if RENDER_VEHICLES_ON_WEB_MAP
                    overlayerMarkers = repmat(hVehiclesToShow{1},length(hRoutesToShow),1);
                end
                for wmRemoveIndex = 1:1:length(hRoutesToShow)
                    overlayerLines(wmRemoveIndex) = hRoutesToShow{wmRemoveIndex};
                    if RENDER_VEHICLES_ON_WEB_MAP
                        overlayerMarkers(wmRemoveIndex) = hVehiclesToShow{wmRemoveIndex};
                    end
                end
                wmremove(overlayerLines);
                if RENDER_VEHICLES_ON_WEB_MAP
                    wmremove(overlayerMarkers);
                elseif first
                        
                end
            else
                % Just add new route, no need to update old ones.
                if RENDER_VEHICLES_ON_WEB_MAP
                    overlayerMarkers = repmat(hVehiclesToShow{1},length(hRoutesToShow),1);
                    for wmRemoveIndex = 1:1:length(hRoutesToShow)
                        overlayerMarkers(wmRemoveIndex) = hVehiclesToShow{wmRemoveIndex};
                    end
                    wmremove(overlayerMarkers);
                end
            end
        end
    else
        disp('               Creating new web map display window...');
        hWebMap = webmap('USGS Imagery');
        hRoutesToShow = cell(1,length(filesToShow));
        if RENDER_VEHICLES_ON_WEB_MAP
            hVehiclesToShow = cell(1,length(filesToShow));
        end
    end
    
    % Add routes.
    disp('               Rendering active routes...');
    
    % Assign colors for these routes according to vehicle types.
    % Set the initial value for the index indexRoute.
    if numNewAddedFileToShow == 0
        % For initial case we need to show all the active routes.
        color = cell(length(filesToShow),1);
        indexRoute = 1;
    else
        % We assume every time there will be one new route being
        % activated, so we only need to add the last file.
        indexRoute = length(filesToShow);
    end
    
    for indexRoute = indexRoute:1:length(filesToShow)
        routeType = filesToShow(indexRoute).type;
        switch routeType
            case 'Combine'
                color{indexRoute} = COLOR.COMBINE;
            case 'Truck'
                color{indexRoute} = COLOR.TRUCK;
            case 'Grain Kart'
                color{indexRoute} = COLOR.GRAIN_KART;
            otherwise
                error('Error in Adding Routes: unknow vehicle type!')
        end
    end
    
    % Add routes.
    indexRoute = 1;
    
    if numNewAddedFileToShow > 0
        indexRoute = length(filesToShow);
    end
    
    for indexRoute = indexRoute:1:length(filesToShow)
        routeType = filesToShow(indexRoute).type;
        routeId = filesToShow(indexRoute).id;
        timeStart = filesToShow(indexRoute).time(1);
        timeEnd = filesToShow(indexRoute).time(end);
        
        hRoutesToShow{indexRoute} = wmline(hWebMap, ...
            latSampled{indexRoute},lonSampled{indexRoute}, ...
            'Color',color{indexRoute}, 'Width', 3, 'FeatureName', 'Route', ...
            'Description', ...
            strcat(routeType,':',{' '},routeId,{' '},timeStart,' to',{' '},timeEnd),...
            'OverlayName', ...
            strcat('Route', {' '}, routeType, ':', {' '}, routeId));
    end
    
    %% Current Vehicle Labels for Active Routes
    % Update overlayed vehicle markers on the web map display.
    updateWmVehicleMarkers;
    
    % Apply history settings for map limits.
    if flagFirstTime
        if flagUseHistorySettings
            wmlimits(hWebMap,currentWmLimits(1:2),currentWmLimits(3:4));
            wmzoom(hWebMap, currentZoomLevel);
        end
    else
        wmlimits(hWebMap,currentWmLimits(1:2),currentWmLimits(3:4));
        wmzoom(hWebMap, currentZoomLevel);
    end
    
    % Only activate the intial settings when SKIP_INI_SETTINGS is false.
    if SKIP_INI_SETTINGS == false
        disp(' ');
        disp('               Please zoom in and out to set the map limits for the ');
        disp('               animation. Press any key to confirm setting...');
        
        % Bring the web map to user.
        webmap(hWebMap)
        pause;
        
        disp('               Saving setting results...');
        
        [currentWmLimits(1:2),currentWmLimits(3:4)] = wmlimits(hWebMap);
        currentZoomLevel = wmzoom(hWebMap);
        
        save(FULLPATH_SETTINGS_HISTORY, ...
            'currentWmLimits', 'currentZoomLevel', '-append');
    end
    
    %% Animation
    
    disp(' ');
    disp('Animation: Downloading map from server...');
    
    % Total gps time range for active routes.
    gpsTimeRangeActive = getGpsTimeRangeActive(gpsTimeLineRange, filesToShow);
    
    % Create the animation figure with UI.
    if exist('hAnimationFig','var')
        if ~ishghandle(hAnimationFig)
            createAnimationFig;
        else
            if hAnimationFig == hTimelineFig
                createAnimationFig;
            end
            set(0,'CurrentFigure',hAnimationFig);
            set(hAnimationFig, 'Visible', 'off');
        end
    else
        createAnimationFig;
    end
    
    % Set parameters for the map.
    initializeAnimation;
    
    disp('           Enjoy the animation!');
    disp('----------------------------');
    
    % Animation for the vehicles on these routes.
    % Bring animation figure to front. Used for debugging.
    figure(hAnimationFig);
    
    % Generate a screen shot. Not very useful.
    %     if GENERATE_MOV
    %     % Save the first frame.
    %         saveas(hAnimationFig, fileName, 'jpg');
    %     end
    
    while currentTime <= timeToUpdateAnimation
        
        while flagAnimationPaused
            % Animiation is paused. Pause the program for # seconds.
            pause(0.1);
        end
        
        % Keep a record of the currentTime used for this (and last) frame.
        if exist('currentTimeForThisFrame', 'var')
            currentTimeForLastFrame = currentTimeForThisFrame;
        end
        
        currentTimeForThisFrame = currentTime;
        % The animation generation of this loop will only use
        % currentGpsTime, in case the variable "currentTime" is updated
        % by the user unexpected.
        currentGpsTime = currentTimeForThisFrame + originGpsTime;
        
        % Update states if the user set it. We will change the state as
        % long as the state setting button is pressed.
        if exist('statesToWriteNow','var')
            % User has triggered at least one group of state setting
            % buttons.
            if ~all(isnan(statesToWriteNow))
                % At least one button is pressed.
                for indexVehicleUpdateState = 1:1:length(filesToShow)
                    if ~isnan(statesToWriteNow(indexVehicleUpdateState))
                        timeStartSetting = ...
                            max(currentTimeStateSettingButtonLastDown{indexVehicleUpdateState}, ...
                            currentTimeForLastFrame);
                        timePointsTemp = ...
                            filesToShow(indexVehicleUpdateState).gpsTime ...
                            - originGpsTime;
                        % We will set all the states between
                        % timeStartSetting (included) and
                        % currentTimeForThisFrame (excluded).
                        indicesStateToSetTemp = intersect(...
                            find(timePointsTemp>=timeStartSetting),...
                            find(timePointsTemp<currentTimeForThisFrame));
                        states{filesToShowIndices(indexVehicleUpdateState)}(indicesStateToSetTemp) ...
                            = statesToWriteNow(indexVehicleUpdateState);
                        flagStatesManuallySet{filesToShowIndices(indexVehicleUpdateState)}(indicesStateToSetTemp) ...
                            = 1;
                    end
                end
            end
        end
        
        if UPDATE_MAP_LIMITS
            updateMapLimitsRem; %#ok<UNRCH>
        end
        
        % Update one frame for the animation.
        updateAnimationFrame;
        
        if strcmp(get(hAnimationFig, 'Visible'),'off')
            set(hAnimationFig, 'Visible', 'on');
        end
        
        if GENERATE_MOV
            if ~exist('animationFigPosition', 'var')
                animationFigPosition = get(hAnimationFig, 'Position');
            end
            set(hAnimationFig, 'Position', animationFigPosition);
            frameNum = frameNum + 1;
            F(frameNum) = getframe(hAnimationFig);
        end
        
        currentTime = currentTime + MILLISEC_PER_FRAME;
        drawnow;
    end
    
    % Make the figure invisibe while processing.
    set(hAnimationFig, 'Visible', 'off');
    
    % Save states just in case.
    if exist('statesToWriteNow','var')
        saveVehicleStates;
    end
    
    % A new file should be activated now. Update active files.
    filesToShow(length(filesToShow) + 1) = newRouteToBeAdded;
    filesToShowIndices = [filesToShowIndices;newRouteToBeAddedIndex];
    numNewAddedFileToShow = numNewAddedFileToShow + 1;
    % Add more space for the show-distance flag.
    flagMapVehicleDistsLinks = [flagMapVehicleDistsLinks zeros(length(filesToShow)-1,1);
        zeros(1,length(filesToShow))];
    % Add more space for the state-setting-buttons-trigged flag,
    % what-state-to-record-now flag and handle matrix for state setting
    % buttons if necessary.
    flagStateSettingButtonsTriggered = [flagStateSettingButtonsTriggered;0];
    if exist('statesToWriteNow', 'var')
        statesToWriteNow = [statesToWriteNow; NaN];
    end
    if exist('hMapStateSettingButtons', 'var')
        hMapStateSettingButtons = [hMapStateSettingButtons;-ones(1,4)];
    end
    
    % Clear the map area without deleting the handles to the figure.
    cla(hAnimationMapArea,'reset');
    
    flagFirstTime = false;
    % Reset playback speed.
    MILLISEC_PER_FRAME = MILLISEC_PER_FRAME_DEFAULT;
    set(editSetPlaybackSpeed, 'String', MILLISEC_PER_FRAME);
    
    [currentGpsTime, ...
        filesToShowIndices, filesToShow, filesToShowTimeRange, ...
        filesNotStartedRecInd, filesNotStartedRecTimeRange, ...
        filesFinishedRecInd, filesFinishedRecTimeRange]...
        = updateActiveRoutesInfo(files, currentTime, originGpsTime, ...
        fileIndicesSortedByStartRecordingGpsTime, fileIndicesSortedByEndRecordingGpsTime);
    
end
% catch err
%
%     disp(' ');
%     disp('Sorry! An unexpected error just occurred...');
%     disp(err);
%     disp('Existing...');
%
% end

% EOF