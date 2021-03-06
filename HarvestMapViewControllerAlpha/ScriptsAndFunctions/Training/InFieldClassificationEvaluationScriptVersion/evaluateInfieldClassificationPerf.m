%EVALUATEINFIELDCLASSIFICATIONPERF Evaluates the infield classification
%performance.
%
% It will evaluate the infield classification results in the file
% filesLoadedHistory.m (generated by the infield classificaiton algorithm)
% according to the correct classification results stored in the file
% filesLoadedHistory_ref.m (generated by the tool collectorForLocations.m).
% Both of these files are in the data set file folder specified by
% "fileFolder" under _AUTOGEN_IMPORTANT). After the evaluation, a log file
% will be save at the save filefolder.
%
% Yaguang Zhang, Purdue, 04/02/2015

%% User Specified Parameters

% The location of the data set. Please refer to mapViewController for more
% infomation.
fileFolder = fullfile('..', '..', '..',  'Harvest_Ballet_2015');
IS_RELATIVE_PATH = true;

% If the GPS data has already loaded, you can set this flag to be true and
% skip loading the variables for the data again. Just please make sure the
% variables in the current workspace are indeed corresponding to the files
% specified by "fileFolder".
USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE = true;

% File indices for training & testing set of combines.

%% Set Matlab Path.

% Clear command window. Close all plot & web map display windows.
clc;close all;wmclose all;

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
    clearvars -except INDEX_FILE_TO_START ...
        fileFolder fileFolderSet IS_RELATIVE_PATH ...
        MIN_SAMPLE_NUM_TO_IGNORE ...
        USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE ...
        ...
        files fileIndicesCombines fileIndicesTrucks ...
        fileIndicesGrainKarts ...
        fileIndicesSortedByStartRecordingGpsTime ...
        fileIndicesSortedByEndRecordingGpsTime ...
        ...
        SAVE_PLOTS_AS_PNG;
else
    disp('-------------------------------------------------------------');
    disp('Pre-processing: Loading GPS data...');
    tic;
    clearvars -except INDEX_FILE_TO_START ...
        fileFolder IS_RELATIVE_PATH ...
        MIN_SAMPLE_NUM_TO_IGNORE ...
        USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE ...
        ...
        SAVE_PLOTS_AS_PNG;
    loadGpsData;
    toc;
    disp('Pre-processing: Done!');
end

%% Load History Records of Locations

% The folder where the classification results of the algorithm are saved.
pathInFieldClassificationResultsFilefolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
pathLocationsFile = fullfile(...
    pathInFieldClassificationResultsFilefolder, ...
    strcat('filesLoadedLocations','.mat')...
    );
pathLocationsRefFile = fullfile(...
    pathInFieldClassificationResultsFilefolder, ...
    strcat('filesLoadedLocations_ref','.mat')...
    );

% Check whether these files are available.
if ~exist(pathLocationsFile, 'file')
    error('evaluateInfieldClassificationPerf: Couldn''t find the record file filesLoadedLocations.m. Please make sure the infield classificaiton algorithm has been run for this data set.');
end
if ~exist(pathLocationsRefFile, 'file')
    error('evaluateInfieldClassificationPerf: Couldn''t find the record file filesLoadedLocations_ref.m. Please make sure the infield classificaiton collector (collectorForLocations.m) has been run for this data set.');
end

% Load the variables.
load(pathLocationsFile);
load(pathLocationsRefFile);

% The log file path.
pathInFieldClassificationPerfEvalLogFile = fullfile(...
    pathInFieldClassificationResultsFilefolder, ...
    strcat('filesLoadedLocations_perfEvalLog','.txt')...
    );

%% More Pre-Processing
disp('-------------------------------------------------------------');
disp('Pre-Processing: Checking the validity of locations and locationsRef.');

% Parameters to use for the evaluation.
numSamplesInTotal = 0;
numSamplesForCombines = 0;
numSamplesForGrainKarts = 0;
numSamplesForTrucks = 0;
numSamplesForEachRoute = zeros(length(files),1);

% Especially, we want to evaluate the performance for training set and
% testing set of the combines.
numSamplesForCombinesTrainingSet = 0;
numSamplesForCombinesTestingSet = 0;

% Find the training set and testing set of combines that we used for the
% development of the algorithm. We used all combine routes with index less
% than or equal to 39 as the training set, and all other combine routes as
% the testing set. See testInFieldClassification.m for more info.
indicesCombinesTrainingSet = fileIndicesCombines(fileIndicesCombines<=39);
indicesCombinesTestingSet = fileIndicesCombines(fileIndicesCombines>39);

% And also evaluate the performance of classification for infield and
% on-the-road sample points, respectively.
numSamplesInFieldInTotal = 0;
numSamplesInFieldForCombines = 0;
numSamplesInFieldForGrainKarts = 0;
numSamplesInFieldForTrucks = 0;
numSamplesInFieldForEachRoute = zeros(length(files),1);
numSamplesInFieldForCombinesTrainingSet = 0;
numSamplesInFieldForCombinesTestingSet = 0;

numSamplesOnRoadInTotal = 0;
numSamplesOnRoadForCombines = 0;
numSamplesOnRoadForGrainKarts = 0;
numSamplesOnRoadForTrucks = 0;
numSamplesOnRoadForEachRoute = zeros(length(files),1);
numSamplesOnRoadForCombinesTrainingSet = 0;
numSamplesOnRoadForCombinesTestingSet = 0;

% Test whether files, locations and locationsRef match in length.
if length(locations) ~= length(locationsRef) || length(files) ~= length(locationsRef)
    error('Pre-Processing: files, locations and locaitonsRef don''t match in length!');
end

% Test whether locations and locationsRef match in the number of samples
% for each file.
for indexRoute = 1:1:length(locations)
    
    % The number of samples for this route.
    numSamples = length(locations{indexRoute});
    numSamplesInField = sum(locationsRef{indexRoute} == 0);
    numSamplesOnRoad = sum(locationsRef{indexRoute} == -100);
    
    if numSamples ~= length(locationsRef{indexRoute})
        disp(...
            strcat('The index for the current route:', 23, 23, ...
            num2str(indexRoute))...
            );
        error('Pre-Processing: locations and locationsRef don''t match in length for this route!')
    end
    
    if numSamples ~= numSamplesInField + numSamplesOnRoad
        disp(...
            strcat('The index for the current route:', 23, 23, ...
            num2str(indexRoute))...
            );
        error('Pre-Processing: locationsRef isn''t valid for this route! (numSamples ~= numSamplesInField + numSamplesOnRoad)')
    end
    
    % Update parameters. We do it here just to make the performance
    % evaluation easier.
    numSamplesInTotal = numSamplesInTotal + numSamples;
    numSamplesInFieldInTotal = ...
        numSamplesInFieldInTotal + numSamplesInField;
    numSamplesOnRoadInTotal = ...
        numSamplesInFieldInTotal + numSamplesOnRoad;
    
    switch files(indexRoute).type
        case 'Combine'
            
            numSamplesForCombines = ...
                numSamplesForCombines + numSamples;
            numSamplesInFieldForCombines = ...
                numSamplesInFieldForCombines + numSamplesInField;
            numSamplesOnRoadForCombines = ...
                numSamplesOnRoadForCombines + numSamplesOnRoad;
            
            if any(indicesCombinesTrainingSet == indexRoute)
                % This route is in the training set.
                numSamplesForCombinesTrainingSet = ...
                    numSamplesForCombinesTrainingSet + numSamples;
                numSamplesInFieldForCombinesTrainingSet = ...
                    numSamplesInFieldForCombinesTrainingSet + numSamplesInField;
                numSamplesOnRoadForCombinesTrainingSet = ...
                    numSamplesOnRoadForCombinesTrainingSet + numSamplesOnRoad;
            elseif any(indicesCombinesTestingSet == indexRoute)
                % This route is in the testing set.
                numSamplesForCombinesTestingSet = ...
                    numSamplesForCombinesTestingSet + numSamples;
                numSamplesInFieldForCombinesTestingSet = ...
                    numSamplesInFieldForCombinesTestingSet + numSamplesInField;
                numSamplesOnRoadForCombinesTestingSet = ...
                    numSamplesOnRoadForCombinesTestingSet + numSamplesOnRoad;
            else
                % Shouldn't occur.
                error('Unkown combine route!');
            end
            
        case 'Grain Kart'
            numSamplesForGrainKarts = ...
                numSamplesForGrainKarts + numSamples;
            numSamplesInFieldForGrainKarts = ...
                numSamplesInFieldForGrainKarts + numSamplesInField;
            numSamplesOnRoadForGrainKarts = ...
                numSamplesOnRoadForGrainKarts + numSamplesOnRoad;
        case 'Truck'
            numSamplesForTrucks = ...
                numSamplesForTrucks + numSamples;
            numSamplesInFieldForTrucks = ...
                numSamplesInFieldForTrucks + numSamplesInField;
            numSamplesOnRoadForTrucks = ...
                numSamplesOnRoadForTrucks + numSamplesOnRoad;
        otherwise
            disp(...
                strcat('The index for the current route:', 23, 23, ...
                num2str(indexRoute))...
                );
            error('Pre-Processing: Unkown vehicle type!')
    end
    numSamplesForEachRoute(indexRoute) = numSamples;
    numSamplesInFieldForEachRoute(indexRoute) = numSamplesInField;
    numSamplesOnRoadForEachRoute(indexRoute) = numSamplesOnRoad;
end

disp('Pre-Processing: Done!');

%% Performance Evaluation

% Parameters to use for the evaluation.
numErrorsInTotal = 0;
numErrorsForCombines = 0;
numErrorsForGrainKarts = 0;
numErrorsForTrucks = 0;
numErrorsForEachRoute = zeros(length(files),1);

numErrorsForCombinesTrainingSet = 0;
numErrorsForCombinesTestingSet = 0;

numErrorsInFieldInTotal = 0;
numErrorsInFieldForCombines = 0;
numErrorsInFieldForGrainKarts = 0;
numErrorsInFieldForTrucks = 0;
numErrorsInFieldForEachRoute = zeros(length(files),1);

numErrorsInFieldForCombinesTrainingSet = 0;
numErrorsInFieldForCombinesTestingSet = 0;

numErrorsOnRoadInTotal = 0;
numErrorsOnRoadForCombines = 0;
numErrorsOnRoadForGrainKarts = 0;
numErrorsOnRoadForTrucks = 0;
numErrorsOnRoadForEachRoute = zeros(length(files),1);

numErrorsOnRoadForCombinesTrainingSet = 0;
numErrorsOnRoadForCombinesTestingSet = 0;

% Count the number of errors.
disp('-------------------------------------------------------------');
disp('Performance Evaluation: Collecting error information...');

for indexRoute = 1:1:length(locations)
    
    % Note that all negtive elements in locations should be treated the
    % same as -100 in locationsRef.
    location = locations{indexRoute};
    location(location<0) = -100;
    
    boolsInField = locationsRef{indexRoute} == 0;
    boolsOnRoad = locationsRef{indexRoute} == -100;
    
    % The number of errors for this route.
    numErrors = sum(location ~= locationsRef{indexRoute});
    numErrorsInField = sum(...
        location(boolsInField) ~= locationsRef{indexRoute}(boolsInField) ...
        );
    numErrorsOnRoad = sum(...
        location(boolsOnRoad) ~= locationsRef{indexRoute}(boolsOnRoad) ...
        );
    
    % Update parameters.
    numErrorsInTotal = numErrorsInTotal + numErrors;
    numErrorsInFieldInTotal = numErrorsInFieldInTotal + numErrorsInField;
    numErrorsOnRoadInTotal = numErrorsOnRoadInTotal + numErrorsOnRoad;
    
    switch files(indexRoute).type
        case 'Combine'
            
            numErrorsForCombines = numErrorsForCombines + numErrors;
            numErrorsInFieldForCombines = ...
                numErrorsInFieldForCombines + numErrorsInField;
            numErrorsOnRoadForCombines = ...
                numErrorsOnRoadForCombines + numErrorsOnRoad;
            
            if any(indicesCombinesTrainingSet == indexRoute)
                % This route is in the training set.
                numErrorsForCombinesTrainingSet = ...
                    numErrorsForCombinesTrainingSet + numErrors;
                numErrorsInFieldForCombinesTrainingSet = ...
                    numErrorsInFieldForCombinesTrainingSet + numErrorsInField;
                numErrorsOnRoadForCombinesTrainingSet = ...
                    numErrorsOnRoadForCombinesTrainingSet + numErrorsOnRoad;
            elseif any(indicesCombinesTestingSet == indexRoute)
                % This route is in the testing set.
                numErrorsForCombinesTestingSet = ...
                    numErrorsForCombinesTestingSet + numErrors;
                numErrorsInFieldForCombinesTestingSet = ...
                    numErrorsInFieldForCombinesTestingSet + numErrorsInField;
                numErrorsOnRoadForCombinesTestingSet = ...
                    numErrorsOnRoadForCombinesTestingSet + numErrorsOnRoad;
            else
                % Shouldn't occur.
                error('Unkown combine route!');
            end
            
        case 'Grain Kart'
            numErrorsForGrainKarts = numErrorsForGrainKarts + numErrors;
            numErrorsInFieldForGrainKarts = ...
                numErrorsInFieldForGrainKarts + numErrorsInField;
            numErrorsOnRoadForGrainKarts = ...
                numErrorsOnRoadForGrainKarts + numErrorsOnRoad;
        case 'Truck'
            numErrorsForTrucks = numErrorsForTrucks + numErrors;
            numErrorsInFieldForTrucks = ...
                numErrorsInFieldForTrucks + numErrorsInField;
            numErrorsOnRoadForTrucks = ...
                numErrorsOnRoadForTrucks + numErrorsOnRoad;
        otherwise
            disp(...
                strcat('The index for the current route:', 23, 23, ...
                num2str(indexRoute))...
                );
            error('Pre-Processing: Unkown vehicle type!')
    end
    numErrorsForEachRoute(indexRoute) = numErrors;
    numErrorsInFieldForEachRoute(indexRoute) = numErrorsInField;
    numErrorsOnRoadForEachRoute(indexRoute) = numErrorsOnRoad;
end

disp('Performance Evaluation: Done!');

% Compute error rate.
disp('-------------------------------------------------------------');
disp('Performance Evaluation: Computing & logging the error rates...');

tic;

% Error rates.
errorRateInTotal = numErrorsInTotal / numSamplesInTotal;
errorRateForCombines = numErrorsForCombines / numSamplesForCombines;
errorRateForGrainKarts = numErrorsForGrainKarts / numSamplesForGrainKarts;
errorRateForTrucks = numErrorsForTrucks / numSamplesForTrucks;
errorRatesForEachRoute = numErrorsForEachRoute ./ numSamplesForEachRoute;

errorRateForCombinesTrainingSet = numErrorsForCombinesTrainingSet / numSamplesForCombinesTrainingSet;
errorRateForCombinesTestingSet = numErrorsForCombinesTestingSet / numSamplesForCombinesTestingSet;

errorRateInFieldInTotal = numErrorsInFieldInTotal / numSamplesInFieldInTotal;
errorRateInFieldForCombines = numErrorsInFieldForCombines / numSamplesInFieldForCombines;
errorRateInFieldForGrainKarts = numErrorsInFieldForGrainKarts / numSamplesInFieldForGrainKarts;
errorRateInFieldForTrucks = numErrorsInFieldForTrucks / numSamplesInFieldForTrucks;
errorRatesInFieldForEachRoute = numErrorsInFieldForEachRoute ./ numSamplesInFieldForEachRoute;

errorRateInFieldForCombinesTrainingSet = numErrorsInFieldForCombinesTrainingSet / numSamplesInFieldForCombinesTrainingSet;
errorRateInFieldForCombinesTestingSet = numErrorsInFieldForCombinesTestingSet / numSamplesInFieldForCombinesTestingSet;

errorRateOnRoadInTotal = numErrorsOnRoadInTotal / numSamplesOnRoadInTotal;
errorRateOnRoadForCombines = numErrorsOnRoadForCombines / numSamplesOnRoadForCombines;
errorRateOnRoadForGrainKarts = numErrorsOnRoadForGrainKarts / numSamplesOnRoadForGrainKarts;
errorRateOnRoadForTrucks = numErrorsOnRoadForTrucks / numSamplesOnRoadForTrucks;
errorRatesOnRoadForEachRoute = numErrorsOnRoadForEachRoute ./ numSamplesOnRoadForEachRoute;

errorRateOnRoadForCombinesTrainingSet = numErrorsOnRoadForCombinesTrainingSet / numSamplesOnRoadForCombinesTrainingSet;
errorRateOnRoadForCombinesTestingSet = numErrorsOnRoadForCombinesTestingSet / numSamplesOnRoadForCombinesTestingSet;

% Log.
idInFieldClassificationPerfEvalLogFile = ...
    fopen(pathInFieldClassificationPerfEvalLogFile, 'wt');
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '-------------------------------------------------------------\n' ...
    );
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    ...
    strcat(...
    'Infield Classification Log: created at', ...
    datestr(now,' mm_dd_yyyy_HH_MM_SS'), '\n' ...
    )...
    ...
    );
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '-------------------------------------------------------------\n' ...
    );

% First for the general cases.
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '-------------------------------------------------------------\n' ...
    );
totalNumVehicles = length(files);
totalNumCombines = length(fileIndicesCombines);
totalNumGrainKarts = length(fileIndicesGrainKarts);
totalNumTrucks = length(fileIndicesTrucks);

fprintf(idInFieldClassificationPerfEvalLogFile, ...
    'In total %i vehicles:\n    numSamplesInTotal = %i\n    numErrorsInTotal = %i\n    errorRateInTotal = %.10f\n    accuracyInTotal = %.10f\n',...
    totalNumVehicles, numSamplesInTotal, numErrorsInTotal, ...
    errorRateInTotal, 1-errorRateInTotal);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '    accuracyInFieldInTotal = %.10f\n    accuracyOnRoadInTotal = %.10f\n',...
    1-errorRateInFieldInTotal, 1-errorRateOnRoadInTotal);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '-------------------------------------------------------------\n' ...
    );
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    'For combines (%i):\n    numSamplesForCombines = %i\n    numErrorsForCombines = %i\n    errorRateForCombines = %.10f\n    accuracyForCombines = %.10f\n',...
    totalNumCombines, numSamplesForCombines, numErrorsForCombines, ...
    errorRateForCombines, 1-errorRateForCombines);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '    accuracyInFieldForCombines = %.10f\n    accuracyOnRoadForCombines = %.10f\n',...
    1-errorRateInFieldForCombines, 1-errorRateOnRoadForCombines);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '    numSamplesInFieldForCombines = %i\n    numSamplesOnRoadForCombines = %i\n',...
    numSamplesInFieldForCombines, numSamplesOnRoadForCombines);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    'For grain carts (%i):\n    numSamplesForGrainKarts = %i\n    numErrorsForGrainKarts = %i\n    errorRateForGrainKarts = %.10f\n    accuracyForGrainKarts = %.10f\n',...
    totalNumGrainKarts, numSamplesForGrainKarts, numErrorsForGrainKarts, ...
    errorRateForGrainKarts, 1-errorRateForGrainKarts);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '    accuracyInFieldForGrainKarts = %.10f\n    accuracyOnRoadForGrainKarts = %.10f\n',...
    1-errorRateInFieldForGrainKarts, 1-errorRateOnRoadForGrainKarts);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    'For trucks (%i):\n    numSamplesForTrucks = %i\n    numErrorsForTrucks = %i\n    errorRateForTrucks = %.10f\n    accuracyForTrucks = %.10f\n',...
    totalNumTrucks, numSamplesForTrucks, numErrorsForTrucks, ...
    errorRateForTrucks, 1-errorRateForTrucks);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '    accuracyInFieldForTrucks = %.10f\n    accuracyOnRoadForTrucks = %.10f\n',...
    1-errorRateInFieldForTrucks, 1-errorRateOnRoadForTrucks);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '-------------------------------------------------------------\n' ...
    );

% Especially, for the training set and testing set.
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '-------------------------------------------------------------\n' ...
    );
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    strcat(...
    'For combines in the training set (', ...
    repmat('%i ',1,length(indicesCombinesTrainingSet)),'):\n' ...
    ), ...
    indicesCombinesTrainingSet);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '    numSamplesForCombinesTrainingSet = %i\n    numErrorsForCombinesTrainingSet = %i\n    errorRateForCombinesTrainingSet = %.10f\n    accuracyForCombinesTrainingSet = %.10f\n',...
    numSamplesForCombinesTrainingSet, numErrorsForCombinesTrainingSet, ...
    errorRateForCombinesTrainingSet, 1-errorRateForCombinesTrainingSet);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '    accuracyInFieldForCombinesTrainingSet = %.10f\n    accuracyOnRoadForCombinesTrainingSet = %.10f\n',...
    1-errorRateInFieldForCombinesTrainingSet, 1-errorRateOnRoadForCombinesTrainingSet);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '    numSamplesInFieldForCombinesTrainingSet = %i\n    numSamplesOnRoadForCombinesTrainingSet = %i\n',...
    numSamplesInFieldForCombinesTrainingSet, numSamplesOnRoadForCombinesTrainingSet);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    strcat(...
    'For combines in the testing set (', ...
    repmat('%i ',1,length(indicesCombinesTestingSet)),'):\n' ...
    ), ...
    indicesCombinesTestingSet);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '    numSamplesForCombinesTestingSet = %i\n    numErrorsForCombinesTestingSet = %i\n    errorRateForCombinesTestingSet = %.10f\n    accuracyForCombinesTestingSet = %.10f\n',...
    numSamplesForCombinesTestingSet, numErrorsForCombinesTestingSet, ...
    errorRateForCombinesTestingSet, 1-errorRateForCombinesTestingSet);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '    accuracyInFieldForCombinesTestingSet = %.10f\n    accuracyOnRoadForCombinesTestingSet = %.10f\n',...
    1-errorRateInFieldForCombinesTestingSet, 1-errorRateOnRoadForCombinesTestingSet);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '    numSamplesInFieldForCombinesTestingSet = %i\n    numSamplesOnRoadForCombinesTestingSet = %i\n',...
    numSamplesInFieldForCombinesTestingSet, numSamplesOnRoadForCombinesTestingSet);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '-------------------------------------------------------------\n' ...
    );

% For each route of combines (sorted by training/testing set and accuracy).
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '-------------------------------------------------------------\n' ...
    );
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    'Individual combine routes are ordered by training/testing set \nand accuracy for each type. \n-------------------------------------------------------------\n' ...
    );
errorRatesForEachRouteSorted = ...
    sortrows([(1:length(files))' 1-errorRatesForEachRoute],2);
indexRoutesSorted = errorRatesForEachRouteSorted(:,1)';

% Training set.
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    strcat(...
    'Combine routes in the training set (', ...
    repmat('%i ',1,length(indicesCombinesTrainingSet)),'):\n' ...
    ), ...
    indicesCombinesTrainingSet);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '-------------------------------------------------------------\n' ...
    );
counterForThisType = 0;
counterForCombinesTraingSet = 0;
% Note that we have set indexRoutesSorted to be a row vector so it can be
% used in this way.
for indexRoute = indexRoutesSorted
    typeRoute = files(indexRoute).type;
    if strcmp(typeRoute, 'Combine') ...
            && any(indicesCombinesTrainingSet == indexRoute)
        % Training set.
        totalNumThisType = length(indicesCombinesTrainingSet);
        counterForCombinesTraingSet = counterForCombinesTraingSet + 1;
        counterForThisType = counterForCombinesTraingSet;
        
        fprintf(idInFieldClassificationPerfEvalLogFile, ...
            'Route %i (%s, %i/%i):\n    numSamples = %i\n    numErrors = %i\n    errorRate = %.10f\n    accuracy = %.10f\n',...
            indexRoute, typeRoute, counterForThisType, totalNumThisType, ...
            numSamplesForEachRoute(indexRoute), ...
            numErrorsForEachRoute(indexRoute), ...
            errorRatesForEachRoute(indexRoute), ...
            1-errorRatesForEachRoute(indexRoute) ...
            );
        fprintf(idInFieldClassificationPerfEvalLogFile, ...
            '    accuracyInField = %.10f\n    accuracyOnRoad = %.10f\n',...
            1-errorRatesInFieldForEachRoute(indexRoute), ...
            1-errorRatesOnRoadForEachRoute(indexRoute) ...
            );
    end
end

% Testing set.
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '-------------------------------------------------------------\n' ...
    );
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    strcat(...
    'Combine routes in the testing set (', ...
    repmat('%i ',1,length(indicesCombinesTestingSet)),'):\n' ...
    ), ...
    indicesCombinesTestingSet);
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '-------------------------------------------------------------\n' ...
    );
counterForThisType = 0;
counterForCombinesTestingSet = 0;
% Note that we have set indexRoutesSorted to be a row vector so it can be
% used in this way.
for indexRoute = indexRoutesSorted
    typeRoute = files(indexRoute).type;
    if strcmp(typeRoute, 'Combine') ...
            && any(indicesCombinesTestingSet == indexRoute)
        % Testing set.
        totalNumThisType = length(indicesCombinesTestingSet);
        counterForCombinesTraingSet = counterForCombinesTraingSet + 1;
        counterForThisType = counterForCombinesTraingSet;
        
        fprintf(idInFieldClassificationPerfEvalLogFile, ...
            'Route %i (%s, %i/%i):\n    numSamples = %i\n    numErrors = %i\n    errorRate = %.10f\n    accuracy = %.10f\n',...
            indexRoute, typeRoute, counterForThisType, totalNumThisType, ...
            numSamplesForEachRoute(indexRoute), ...
            numErrorsForEachRoute(indexRoute), ...
            errorRatesForEachRoute(indexRoute), ...
            1-errorRatesForEachRoute(indexRoute) ...
            );
        fprintf(idInFieldClassificationPerfEvalLogFile, ...
            '    accuracyInField = %.10f\n    accuracyOnRoad = %.10f\n',...
            1-errorRatesInFieldForEachRoute(indexRoute), ...
            1-errorRatesOnRoadForEachRoute(indexRoute) ...
            );
    end
end

% Then for each route (sorted by type and accuracy).
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '-------------------------------------------------------------\n' ...
    );
fprintf(idInFieldClassificationPerfEvalLogFile, ...
    'Individual routes below are ordered by vehicle type and \naccuracy for each type. \n-------------------------------------------------------------\n' ...
    );

listType = {'Combine','Grain Kart','Truck'};
for idxListType = 1:length(listType)
    % This part of script works for any type of vehicle.
    counterForCombines = 0;
    counterForGrainKarts = 0;
    counterForTrucks = 0;
    % Note that we have set indexRoutesSorted to be a row vector so it can
    % be used in this way.
    for indexRoute = indexRoutesSorted
        
        typeRoute = files(indexRoute).type;
        
        if strcmp(typeRoute, listType{idxListType})
            switch typeRoute
                case 'Combine'
                    totalNumThisType = totalNumCombines;
                    counterForCombines = counterForCombines + 1;
                    counterForThisType = counterForCombines;
                case 'Grain Kart'
                    totalNumThisType = totalNumGrainKarts;
                    counterForGrainKarts = counterForGrainKarts + 1;
                    counterForThisType = counterForGrainKarts;
                case 'Truck'
                    totalNumThisType = totalNumTrucks;
                    counterForTrucks = counterForTrucks + 1;
                    counterForThisType = counterForTrucks;
                otherwise
                    error('Unknow vehicle type!')
            end
            
            fprintf(idInFieldClassificationPerfEvalLogFile, ...
                'Route %i (%s, %i/%i):\n    numSamples = %i\n    numErrors = %i\n    errorRate = %.10f\n    accuracy = %.10f\n',...
                indexRoute, typeRoute, counterForThisType, totalNumThisType, ...
                numSamplesForEachRoute(indexRoute), ...
                numErrorsForEachRoute(indexRoute), ...
                errorRatesForEachRoute(indexRoute), ...
                1-errorRatesForEachRoute(indexRoute) ...
                );
            fprintf(idInFieldClassificationPerfEvalLogFile, ...
                '    accuracyInField = %.10f\n    accuracyOnRoad = %.10f\n',...
                1-errorRatesInFieldForEachRoute(indexRoute), ...
                1-errorRatesOnRoadForEachRoute(indexRoute) ...
                );
        end
    end
    fprintf(idInFieldClassificationPerfEvalLogFile, ...
        '-------------------------------------------------------------\n' ...
        );
end

fprintf(idInFieldClassificationPerfEvalLogFile, ...
    '-------------------------------------------------------------\n' ...
    );
% Close the file.
fclose(idInFieldClassificationPerfEvalLogFile);

toc;

disp('Performance Evaluation: Done!');
disp('-------------------------------------------------------------');
% EOF