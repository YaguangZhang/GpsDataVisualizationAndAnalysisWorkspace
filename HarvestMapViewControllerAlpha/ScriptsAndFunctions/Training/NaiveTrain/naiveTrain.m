%NAIVETRAIN
% This script went through the GPS data, labels the vehicle states
% according to a naive rule-based expert system, and saves the results
% accordingly in a .mat file.
%
% Yaguang Zhang, Purdue, 02/23/2015

%% User Specified Parameters

% Please refer to mapViewController for more infomation.
%   2015:
%       fullfile('..', '..', '..',  'Harvest_Ballet_2015');
%   2015 labeled:
%       fullfile('..', '..', '..',  'Harvest_Ballet_2015_ManuallyLabeled');
%   2016:
%       fullfile('..', '..', '..',  'Harvest_Ballet_2016', 'harvests');
%   2016 mannually synchronized (tablet U06 isn't set to auto sync with the
% Internet time):
%         fullfile('..', '..', '..',  'Harvest_Ballet_2016',
%         'harvests_synchronized');
%   2016 GPS samples rate test (after fixing the Android logging cur_time
%   instead of location.time bug):
%         C:\Users\Zyglabs\Documents\MEGAsync\GpsDataVisualizationAndAnalysis\2016_08_20_CKT_GpsSampleRateTest
%   2017 auto GPS logging test 1 (JVK trip to Chicago):
%         C:\Users\Zyglabs\Documents\MEGAsync\GpsDataVisualizationAndAnalysis\2017_03_10_CKT_AutoLoggingTest_JVK\1_TripToChicago
%   2017 auto GPS logging test 2 (JVK trip further away):
%         C:\Users\Zyglabs\Documents\MEGAsync\GpsDataVisualizationAndAnalysis\2017_03_10_CKT_AutoLoggingTest_JVK\2_TripFurtherAway
%   2017 auto GPS logging test 3 (JVK trip near campus):
%         C:\Users\Zyglabs\Documents\MEGAsync\GpsDataVisualizationAndAnalysis\2017_03_10_CKT_AutoLoggingTest_JVK\3_TripAroundCampus
%   2017 auto GPS logging more tests (Before 2017 harvest):
%         C:\Users\Zyglabs\Documents\MEGAsync\GpsDataVisualizationAndAnalysis\2017_03_10_CKT_AutoLoggingTest_JVK\4_MoreTestsBefore2017Harvest
%   2017 harvest:
%         C:\Users\Zyglabs\Documents\MEGAsync\GpsDataVisualizationAndAnalysis\Harvest_Ballet_2017
%        or fullfile('..', '..', '..',  'Harvest_Ballet_2017');
%   2017 harvest for only CKT (combines, gran carts and trucks):
%         C:\Users\Zyglabs\Documents\MEGAsync\GpsDataVisualizationAndAnalysis\Harvest_Ballet_2017_CktOnly
%        or fullfile('..', '..', '..',  'Harvest_Ballet_2017_CktOnly');
%
%   2017 data from Amelia:
%         C:\Users\Zyglabs\Documents\MEGAsync\GpsDataVisualizationAndAnalysis\2017_Amelia\Valid
%        or fullfile('..', '..', '..',  '2017_Amelia','Valid');
%
%   2017 drilling (temperary):
%         C:\Users\Zyglabs\Documents\MEGAsync\GpsDataVisualizationAndAnalysis\2017_Harvest_Ballet_Drilling\20171108
%        or fullfile('..', '..', '..',  '2017_Harvest_Ballet_Drilling',
%        '20171108');
%   2017 drilling (full data set):
%         C:\Users\Zyglabs\Documents\MEGAsync\GpsDataVisualizationAndAnalysis\2017_Harvest_Ballet_Drilling\20171204
%        or fullfile('..', '..', '..',  '2017_Harvest_Ballet_Drilling',
%        '20171204');
%
% Update 01/22/2018: Data moved to OneDrive.
%
%   2018 data from Amelia:
%         C:\Users\Zyglabs\OneDrive -
%         purdue.edu\GpsDataVisualizationAndAnalysis\Amelia_2018_01\Valid
%        or fullfile('..', '..', '..',  'Amelia_2018_01','Valid');
%
%   2018 rate test with mesh network at Purdue:
%         C:\Users\Zyglabs\OneDrive -
%         purdue.edu\GpsDataVisualizationAndAnalysis\CKT_20180627_RateTestWithMeshNet\
%        or fullfile('..', '..', '..',
%        'CKT_20180627_RateTestWithMeshNet');
%
%   2018 wheat harvesting:
%       fullfile('..', '..', '..',  'Harvest_Ballet_2018');
%
%   2018 speed test during wheat harvesting:
%       fullfile('..', '..', '..',  'Harvest_Ballet_2018_Wifi_Test');
%
%   2018 data for He and Amy:
%       fullfile('..', '..', '..',  '2018_GpsCollectionForHeAndAmy',
%       'AtAaronsFarm');
%
%   2019:
%       fullfile('..', '..', '..',  'Harvest_Ballet_2019');
%
%   2019 data from Aaron:
%       fullfile('..', '..', '..',  '2019_12_06_Aaron');
%
%   2020:
%       fullfile('..', '..', '..',  'Harvest_Ballet_2020');
%
%   2020 data for writing "OATS" with GPS tracks from Matt:
%       fullfile('..', '..', '..',  '2020_11_17_TrackForOats_Matt');

fileFolder = fullfile('..', '..', '..', '2020_11_17_TrackForOats_Matt');
IS_RELATIVE_PATH = true;
% fileFolder = fullfile('..', '..', '..',  'Harvest_Ballet_2015');
% IS_RELATIVE_PATH = true;
MIN_SAMPLE_NUM_TO_IGNORE = 20;

% If the GPS data has already loaded, you can set this flag to be true and
% skip loading the variables for the data again. Just please make sure the
% variables in the current workspace are indeed corresponding to the files
% specified by "fileFolder".
USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE = true;
% The same for the location classification results.
USE_LOCATIONS_IN_CURRENT_WORKSPACE = true;

% The length of the side of the square in meters. It's used for computing
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
close all; wmclose all;

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
        statesRef enhancedFieldShapes ...
        enhancedFieldShapesUtm enhancedFieldShapesUtmZones;
    
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
        statesRef enhancedFieldShapes ...
        enhancedFieldShapesUtm enhancedFieldShapesUtmZones;
    loadGpsData;
    toc;
    disp('Pre-processing: Done!');
end

%% Generate Four Overview Figures for the GPS Data

% For the data collected among the AgriNovus, generate some customized
% visualization results, instead.
[~, fileFolderName] = fileparts(fileFolder);
if strcmp(fileFolderName, '2020_11_17_TrackForOats_Matt')
    % This will also terminate the script.
    genVisualizationsForAgriNovusChallenge;
end

% Overview.
hGpsOverview = figure; hold on;
hT = plot(vertcat(files(fileIndicesTrucks).lon), ...
    vertcat(files(fileIndicesTrucks).lat), '.', 'Color', [1 1 1].*0.8);
hC = plot(vertcat(files(fileIndicesCombines).lon), ...
    vertcat(files(fileIndicesCombines).lat), '.', 'Color', 'y');
hK = plot(vertcat(files(fileIndicesGrainKarts).lon), ...
    vertcat(files(fileIndicesGrainKarts).lat), '.', 'Color', 'b');
plot_google_map('MapType', 'satellite');
xticks([]);
yticks([]);
xlabel('Longitude')
ylabel('Latitude')
legend([hC, hK, hT], 'Combine', 'Grain kart', 'Truck')

% Combine.
hGpsOverviewC = figure;
hC = plot(vertcat(files(fileIndicesCombines).lon), ...
    vertcat(files(fileIndicesCombines).lat), '.', 'Color', 'y');
plot_google_map('MapType', 'satellite');
xticks([]);
yticks([]);
xlabel('Longitude')
ylabel('Latitude')
legend(hC, 'Combine')

% Grain cart.
hGpsOverviewK = figure;
hK = plot(vertcat(files(fileIndicesGrainKarts).lon), ...
    vertcat(files(fileIndicesGrainKarts).lat), '.', 'Color', 'b');
plot_google_map('MapType', 'satellite');
xticks([]);
yticks([]);
xlabel('Longitude')
ylabel('Latitude')
legend(hK, 'Grain kart')

% Truck.
hGpsOverviewT = figure;
hT = plot(vertcat(files(fileIndicesTrucks).lon), ...
    vertcat(files(fileIndicesTrucks).lat), '.', 'Color', [1 1 1].*0.8);
plot_google_map('MapType', 'satellite');
xticks([]);
yticks([]);
xlabel('Longitude')
ylabel('Latitude')
legend(hT, 'Truck')

pathToSaveGpsOverviewPlots = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
saveas(hGpsOverview, fullfile(pathToSaveGpsOverviewPlots, 'GpsOverview.png'));
saveas(hGpsOverviewC, fullfile(pathToSaveGpsOverviewPlots, 'GpsOverviewC.png'));
saveas(hGpsOverviewK, fullfile(pathToSaveGpsOverviewPlots, 'GpsOverviewK.png'));
saveas(hGpsOverviewT, fullfile(pathToSaveGpsOverviewPlots, 'GpsOverviewT.png'));

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
pathFigLocLablesForC = fullfile(...
    pathInFieldClassificationFilefolder, ...
    'filesLoadedLocationsForCombine');

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
        % exactly what we build from infield points, so they may contain
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
        
        % Plot the labels for combines for debugging.
        hFigLocLablesForC = figure;
        plot3k([vertcat(files(fileIndicesCombines).lon), ...
            vertcat(files(fileIndicesCombines).lat), ...
            vertcat(locations{fileIndicesCombines})]);
        curAspect = daspect; daspect([1 1 curAspect(3)]);
        saveas(hFigLocLablesForC, [pathFigLocLablesForC, '.fig']);
        saveas(hFigLocLablesForC, [pathFigLocLablesForC, '.png']);
    end
end
disp('naiveTrain: Done!');

%% Better Field Shapes

disp('-------------------------------------------------------------');
disp('naiveTrain: Extract better field shapes...');
disp(' ');

% For naiveTrain, we do not have to generate and save plots for the field
% shapes. One can easily run extractFieldShapes independently to get those
% results if necessary.
FLAG_GEN_AND_SAVE_FIELD_SHAPES = true;
extractFieldShapes;

disp(' ');
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

%% Compute the Headings
%
% Also save the results in a .mat file.

disp('-------------------------------------------------------------');
disp('Pre-processing: Computing headins for all vehicles...');

% The folder where the sample density results are saved.
pathHeadingsFilefolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT', 'naiveTrain');
pathHeadingsFile = fullfile(...
    pathHeadingsFilefolder, ...
    strcat('Headings.mat')...
    );

% Try loading corresponding history record first.
if exist(pathHeadingsFile,'file')
    disp(' ');
    disp('Pre-processing: Loading history results...');
    tic;
    load(pathHeadingsFile);
    toc;
    disp('Pre-processing: Done!');
else
    tic;
    % Create the directory if necessary.
    if ~exist(pathHeadingsFilefolder,'dir')
        mkdir(pathHeadingsFilefolder);
    end
    
    % Precompute the vehicle headings.
    disp('    Precomputing vehicle headings...')
    [vehsHeading, isForwarding, x, y, utmZones] = deal(cell(length(files),1));
    for idxFile = 1:length(files)
        disp(['        File: ', num2str(idxFile), '/', num2str(length(files))]);
        [ vehsHeading{idxFile}, isForwarding{idxFile}, x{idxFile}, y{idxFile}, ...
            utmZones{idxFile}] = estimateVehicleHeading(files(idxFile), false);
    end
    
    toc;
    disp('Pre-processing: Done!');
    
    % Save the results in a history .mat file.
    disp(' ');
    disp('Pre-processing: Saving the results...');
    tic;
    save(pathHeadingsFile, 'vehsHeading', 'isForwarding', ...
        'x', 'y', 'utmZones');
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
    if ~exist(pathStatesByDistFilefolder,'dir')
        mkdir(pathStatesByDistFilefolder);
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

%% Extend Field Shapes by Statistical Harvesting

disp('-------------------------------------------------------------');
disp('naiveTrain: Extending field shapes by statistical harvesting...');

% The folder where the results are saved.
pathExtendedEnhancedFieldShapesFolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
pathExtendedEnhancedFieldShapesFile = fullfile(...
    pathExtendedEnhancedFieldShapesFolder, ...
    strcat('extendedEnhancedFieldShapes','.mat')...
    );
pathExtendedEnhancedFieldShapesUtmFile = fullfile(...
    pathExtendedEnhancedFieldShapesFolder, ...
    strcat('extendedEnhancedFieldShapesUtm','.mat')...
    );

% Try loading corresponding history record first.
if exist(pathExtendedEnhancedFieldShapesFile,'file') ...
        && ~FORCE_REDO_STATE_RECOGNITION
    disp(' ');
    disp(['naiveTrain: Loading history results from ', ...
        'extendedEnhancedFieldShapes.m...']);
    tic;
    load(pathExtendedEnhancedFieldShapesFile);
    toc;
    disp('naiveTrain: Done!');
else
    disp(' ');
    disp('naiveTrain: Generating extendedEnhancedFieldShapes...');
    tic;
    
    % Create the directory if necessary.
    if ~exist(pathExtendedEnhancedFieldShapesFolder,'dir')
        mkdir(pathExtendedEnhancedFieldShapesFolder);
    end
    
    % Extend field shape boundaries.
    extendFieldShapes;
    
    toc;
    disp('naiveTrain: Done!');
    
    % Save extendedEnhancedFieldShapes in a history .mat file.
    disp(' ');
    disp('naiveTrain: Saving extendedEnhancedFieldShapes...');
    tic;
    save(pathExtendedEnhancedFieldShapesFile, ...
        'extendedEnhancedFieldShapes');
    save(pathExtendedEnhancedFieldShapesUtmFile, ...
        'extendedEnhancedFieldShapesUtm');
    toc;
    disp('naiveTrain: Done!');
end

%% Product Back Traceability

disp('-------------------------------------------------------------');
disp('naiveTrain: Generating harvesting events for vehicles...');

% The folder where the results are saved.
pathProductTraceabilityFilefolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
pathVehicleEventsFile = fullfile(...
    pathProductTraceabilityFilefolder, ...
    strcat('vehicleEvents','.mat')...
    );

% Try loading corresponding history record first.
if exist(pathVehicleEventsFile,'file') ...
        && ~FORCE_REDO_STATE_RECOGNITION
    disp(' ');
    disp('naiveTrain: Loading history results from vehicleEvents.m...');
    tic;
    load(pathVehicleEventsFile);
    toc;
    disp('naiveTrain: Done!');
else
    disp(' ');
    disp('naiveTrain: Generating vehicleEvents...');
    tic;
    
    % Create the directory if necessary.
    if ~exist(pathProductTraceabilityFilefolder,'dir')
        mkdir(pathProductTraceabilityFilefolder);
    end
    
    % Extract events from statesByDist.
    vehicleEvents = convertStatesToVehEvents(files, statesByDist);
    
    toc;
    disp('naiveTrain: Done!');
    
    % Save vehicleEvents in a history .mat file.
    disp(' ');
    disp('naiveTrain: Saving vehicleEvents...');
    tic;
    save(pathVehicleEventsFile, 'vehicleEvents');
    toc;
    disp('naiveTrain: Done!');
end

%% Traceability Tree

disp('-------------------------------------------------------------');
disp('naiveTrain: Generating traceability tree for the harvesting events...');

% The files where the results are saved.
pathTraceabilityTreeFile = fullfile(...
    pathProductTraceabilityFilefolder, ...
    strcat('traceabilityTree','.mat')...
    );
pathTraceabilityTreeOverview = fullfile(...
    pathProductTraceabilityFilefolder, ...
    'traceabilityTreeOverview'...
    );
% Try loading corresponding history record first.
if exist(pathTraceabilityTreeFile,'file') ...
        && ~FORCE_REDO_STATE_RECOGNITION
    disp(' ');
    disp('naiveTrain: Loading history results from traceabilityTree.m...');
    tic;
    load(pathTraceabilityTreeFile);
    toc;
    disp('naiveTrain: Done!');
else
    disp(' ');
    disp('naiveTrain: Generating traceabilityTree...');
    tic;
    
    % Convert the events to a traceability tree.
    traceabilityTree = convertVehEventsToTraceTree(files, vehicleEvents);
    
    toc;
    disp('naiveTrain: Done!');
    
    % Save traceabilityTree in a history .mat file.
    disp(' ');
    disp('naiveTrain: Saving traceabilityTree...');
    tic;
    save(pathTraceabilityTreeFile, 'traceabilityTree');
    toc;
    disp('naiveTrain: Done!');
    
    % Plot an overview of the tree.
    disp(' ');
    disp('naiveTrain: Plotting overviews for the traceabilityTree...');
    tic;
    
    SPACE_NODE_BY_PRODUCT_AMOUNT = false;
    hTreeOverview = plotTraceTreeOverview(traceabilityTree, files, ...
        SPACE_NODE_BY_PRODUCT_AMOUNT);
    saveas(hTreeOverview, [pathTraceabilityTreeOverview, '_SpacedByChildrenNum.fig']);
    
    toc;
    disp('naiveTrain: Done!');
end

%% Traceability Tree via Estimated Product Amount

% The files where the results are saved.
pathTraceTreeEstiProdAmouFile = fullfile(...
    pathProductTraceabilityFilefolder, ...
    strcat('traceabilityTreeEstiProductAmount','.mat')...
    );

% Try loading corresponding history record first.
if exist(pathTraceTreeEstiProdAmouFile,'file') ...
        && ~FORCE_REDO_STATE_RECOGNITION
    disp(' ');
    disp('naiveTrain: Loading history results from traceabilityTreeEstiProductAmount.m...');
    tic;
    load(pathTraceTreeEstiProdAmouFile);
    toc;
    disp('naiveTrain: Done!');
else
    disp(' ');
    disp('naiveTrain: Generating estimatedProductAmountForTraceTreeNodes...');
    tic;
    
    % Estimate the product amount for each node.
    estimatedProductAmountForTraceTreeNodes ...
        = estiAllProductAmountForTraceTree(traceabilityTree, files);
    
    toc;
    disp('naiveTrain: Done!');
    
    % Save traceabilityTree in a history .mat file.
    disp(' ');
    disp('naiveTrain: Saving estimatedProductAmountForTraceTreeNodes...');
    tic;
    save(pathTraceTreeEstiProdAmouFile, ...
        'estimatedProductAmountForTraceTreeNodes');
    toc;
    disp('naiveTrain: Done!');
    
    % Plot a new overview of the tree.
    disp(' ');
    disp('naiveTrain: Plotting overviews for the traceabilityTree...');
    tic;
    
    SPACE_NODE_BY_PRODUCT_AMOUNT = true;
    [hTreeOverviewPro, nodeCoors] ...
        = plotTraceTreeOverview(traceabilityTree, files, ...
        SPACE_NODE_BY_PRODUCT_AMOUNT);
    saveas(hTreeOverviewPro, [pathTraceabilityTreeOverview, '_SpacedByEstiProductAmount.fig']);
    toc;
    disp('naiveTrain: Done!');
end

%% Interative Traceability Tree

% The files where the results are saved.
pathGpsSegsForAllNodes = fullfile(...
    pathProductTraceabilityFilefolder, ...
    strcat('traceabilityTreeGpsSegs','.mat')...
    );

% Load the polygons representing the elevator areas.
pathToSaveElevatorLocPoly = fullfile(fileparts(mfilename('fullpath')), ...
    '..', 'ProductBackTraceabilityEvaluationScriptVersion', ...
    'Trials', 'elevatorLocPoly.mat');
assert(exist(pathToSaveElevatorLocPoly, 'file') == 2, ...
    'Please run Trial0_ManuallyLocateElevators.m first to generate the polygons for the grain elevators!')
% Get elevatorLocPoly.
load(pathToSaveElevatorLocPoly);

% Try loading corresponding history record first.
if exist(pathGpsSegsForAllNodes,'file') ...
        && ~FORCE_REDO_STATE_RECOGNITION
    disp(' ');
    disp('naiveTrain: Loading history results from traceabilityTreeGpsSegs.m...');
    tic;
    load(pathGpsSegsForAllNodes);
    toc;
    disp('naiveTrain: Done!');
else
    disp(' ');
    disp('naiveTrain: Generating unloadingGpsSegsForAllNodes...');
    tic;
    
    % Also fetch all the GPS segments required for the interactive
    % traceability tree.
    unloadingGpsSegsForAllNodes = fetchGpsTrackSegsForNodes(traceabilityTree, ...
        files, 1:length(traceabilityTree));
    
    toc;
    disp('naiveTrain: Done!');
    
    % Save traceabilityTree in a history .mat file.
    disp(' ');
    disp('naiveTrain: Saving unloadingGpsSegsForAllNodes...');
    tic;
    save(pathGpsSegsForAllNodes, ...
        'unloadingGpsSegsForAllNodes');
    toc;
    disp('naiveTrain: Done!');
    
    % Is the tree already drawn?
    disp(' ');
    disp('naiveTrain: Plotting overviews for the traceabilityTree...');
    tic;
    
    if ~(exist('hTreeOverviewPro', 'var') && isvalid(hTreeOverviewPro))
        SPACE_NODE_BY_PRODUCT_AMOUNT = true;
        [hTreeOverviewPro, nodeCoors] ...
            = plotTraceTreeOverview(traceabilityTree, files, ...
            SPACE_NODE_BY_PRODUCT_AMOUNT);
    end
    
    % Make the figure interactive.
    evalin('base', 'clear interactiveTraceTreeOverviewCallbackMeta');
    hTreeOverviewProAxes = findall(hTreeOverviewPro, 'type', 'axes');
    set(hTreeOverviewProAxes,'ButtonDownFcn', @(src,evnt) ...
        interactiveTraceTreeOverviewCallback(src, evnt, ...
        nodeCoors, traceabilityTree, files, elevatorLocPoly),...
        'HitTest','on');
    
    saveas(hTreeOverviewPro, [pathTraceabilityTreeOverview, '_Interactive.fig']);
    toc;
    disp('naiveTrain: Done!');
end

%% Convert the Tree Object to JSON String for External Programs

% The files where the results are saved.
pathToSaveTreeJsonStr = fullfile(...
    pathProductTraceabilityFilefolder, ...
    strcat('traceabilityTreeJsonStr','.json')...
    );

% Checking whether the JSON has already been created or not.
if exist(pathToSaveTreeJsonStr,'file') ...
        && ~FORCE_REDO_STATE_RECOGNITION
    disp(' ');
    disp('naiveTrain: traceabilityTreeJsonStr.json is already generated.');
    disp('naiveTrain: Done!');
else
    disp(' ');
    disp('naiveTrain: Generating traceabilityTreeJsonStr.json ...');
    tic;
    
    traceabilityTreeJsonStr = convertTreeToJson(traceabilityTree);
    
    fIdTreeJsonStr = fopen(pathToSaveTreeJsonStr,'wt');
    fprintf(fIdTreeJsonStr, traceabilityTreeJsonStr);
    fclose(fIdTreeJsonStr);
    
    toc;
    disp('naiveTrain: Done!');
end

%% Yield Map



% EOF