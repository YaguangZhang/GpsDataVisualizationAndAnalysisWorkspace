%TESTSTATECLASSIFICATIONFORCOMBINES
%
% We will develop the algorithm to generate the yield map here.
%
% Yaguang Zhang, Purdue, 03/22/2015

%% Codes Copied from naiveTrain to Load JVK Route Information

% Please refer to mapViewController for more infomation.
fileFolder = fullfile('..', '..', '..',  'Harvest_Ballet_2015');
IS_RELATIVE_PATH = true;
MIN_SAMPLE_NUM_TO_IGNORE = 20;

% If the GPS data has already loaded, you can set this flag to be true and
% skip loading the variables for the data again. Just please make sure the
% variables in the current workspace are indeed corresponding to the files
% specified by "fileFolder".
USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE = true;

% The length of the side of the square by meters. It's used for computing
% the device independent sample density of each sample point.
%   Device independent sample density
%     = Sample number in a square / sample rate / square area
% See testDevIndSampleDensity.m for more infomation.
SQUARE_SIDE_LENGTH = 200;

% Set Matlab Path.

% Clear command window. Close all plot & web map display windows.
clc;close all;wmclose all;

% Changed folder to "ScriptsAndFunctions" first.
cd(fullfile(fileparts(which(mfilename)),'..', '..'));
% Set path.
setMatlabPath;

% Load GPS Data

% Clear variables.
if exist('files', 'var') && USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE
    disp('-------------------------------------------------------------');
    disp('Pre-processing: Reuse GPS data variables in the current workspace.');
    % Reuse GPS data variables in current workspace.
    clearvars -except fileFolder fileFolderSet IS_RELATIVE_PATH ...
        MIN_SAMPLE_NUM_TO_IGNORE ...
        USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE ...
        SQUARE_SIDE_LENGTH ...
        ...
        files fileIndicesCombines fileIndicesTrucks ...
        fileIndicesGrainKarts ...
        fileIndicesSortedByStartRecordingGpsTime ...
        fileIndicesSortedByEndRecordingGpsTime;
else
    disp('-------------------------------------------------------------');
    disp('Pre-processing: Loading GPS data...');
    tic;
    clearvars -except fileFolder IS_RELATIVE_PATH ...
        MIN_SAMPLE_NUM_TO_IGNORE ...
        USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE ...
        SQUARE_SIDE_LENGTH;
    loadGpsData;
    toc;
    disp('Pre-processing: Done!');
end

% Compute Device-Independent Sample Densities

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

% In the Field or Not?

disp('-------------------------------------------------------------');
disp('naiveTrain: "In the field" classification...');

% The folder where the classification results are saved.
pathInFieldClassificationFilefolder = fullfile(fileFolderSet, ...
    '_AUTOGEN_IMPORTANT');
pathInFieldClassificationFile = fullfile(...
    pathInFieldClassificationFilefolder, ...
    strcat('filesLoadedLocations','.mat')...
    );

% Try loading corresponding history record first.
if exist(pathInFieldClassificationFile,'file')
    disp(' ');
    disp('naiveTrain: Loading history results of locations...');
    tic;
    load(pathInFieldClassificationFile);
    toc;
    disp('naiveTrain: Done!');
else
    % Create the variable locations to store the results.
    locations = cell(length(files),1);
    
    % Label locaitons for all vehicles using naive infield classification.
    labelLocations;
    
    % Save locations in a history .mat file.
    disp(' ');
    disp('naiveTrain: Saving locations...');
    tic;
    save(pathInFieldClassificationFile, 'locations');
    toc;
    disp('naiveTrain: Done!');
end

%% Yield Map

% Yield map algorithm development start here.

% The maximum distance in meters for a vehicle to be considered as
% "nearby".
DISTANCE_NEARBY_VEHICLES = 20;
DISTANCE_NEARBY_VEHICLES_PADDING = 1;

% The minimum time in seconds for a vehicle to stay "nearby" before it's
% considered to take any actions like loading or unloading.
MIN_TIME_BEING_NEARBY_TO_TAKE_ACTIONS = 5;

% Our algorithm is combine-centered.
TYPE = 'Combine';

% The product gotten from the harvesting by each vehicle. It?s a cell array
% containing cell elements.
%   For combines
%       A matrix of 3x1 arrays, each array contains
%           The start index of this harvested sequence
%           The end index of this harvested sequence
%           Unload to which vehicle
%   For grain carts and trucks
%       A cell of structures, each structure contains
%           Loading range
%           The index to start loading this sequence
%           The index to end loading this sequence
%           Loading from which vehicle
%           Coordinates of this product sequence
products = cell(length(files),1);

% Record the number of unloading activities found during the algorithm. It
% will also be used as the unique ID to link the elements in the varialbe
% "products" for the loader and unloader.
counterUnloadingActivities = 0;

flagFirstRoute = true;
for indexFile = 1:1:length(files)
    if strcmp(files(indexFile).type, TYPE)
        
        % Pause after each route if there are more than 1 route.
        if flagFirstRoute
            flagFirstRoute = false;
        else
            % Pause the program accordingly.
            if PAUSE_AFTER_EACH_ROUTE
                % We put the pause here to make sure the program will just
                % exist instead of pausing for the last route.
                disp('Press any key to continue...');
                pause;
                % Bring commandwindow to front.
                commandwindow;
                disp('Loading next route. Please wait...')
            end
        end
        
        close all;
        
        % Load data needed.
        lati = files(indexFile).lat;
        long = files(indexFile).lon;
        time = files(indexFile).gpsTime;
        location = locations{indexFile};
        
        % According to testLatAndSpeedLength.m, files(50) misses a speed
        % sample. We need to discard the last sample if it's incomplete.
        if length(lati)~=length(time)
            endIdx = min(length(lati),length(time));
            lati = lati(1:endIdx);
            long = long(1:endIdx);
            location = location(1:endIdx);
        end
        
        % Find routes overlapping with this one. Note that we have
        % discarded routes with too few samples when we load the route
        % information, so there are always more than 2 time sample points
        % available.
        timeStart = time(1);
        timeEnd = time(end);
        % Routes that start before this route ends (start time < timeEnd).
        indicesFilesStart = find(fileIndicesSortedByStartRecordingGpsTime(:,2)<timeEnd, 1, 'last');
        indicesFilesStart = fileIndicesSortedByStartRecordingGpsTime(1:1:indicesFilesStart,1);
        % Routes that stop after this route starts (end time > timeStart).
        indicesFilesStop = find(fileIndicesSortedByEndRecordingGpsTime(:,2)>timeStart, 1, 'first');
        indicesFilesStop = fileIndicesSortedByEndRecordingGpsTime(indicesFilesStop:1:end,1);
        % Routes overlapping with this route. Note that we also get rid of
        % this route here and the result will be ordered increasingly.
        indicesFilesOverlapped = setdiff( ...
        intersect(indicesFilesStart,indicesFilesStop), indexFile...
        );
    
        % Get rid of any other combines.
        for idxFileOverlappedIndex = 1:1:length(indicesFilesOverlapped)
            if strcmp(files(indicesFilesOverlapped(idxFileOverlappedIndex)).type, TYPE)
                indicesFilesOverlapped(idxFileOverlappedIndex) = NaN;
            end
        end
        indicesFilesOverlapped(isnan(indicesFilesOverlapped)) = [];
        
        % Record the time limits of these routes.
        timeLimits = zeros(2,length(indicesFilesOverlapped));
        for idxFileOverlapped = 1:1:length(indicesFilesOverlapped)
            timeLimits(:,idxFileOverlapped) = ...
                [files(indicesFilesOverlapped(idxFileOverlapped)).gpsTime(1);
                files(indicesFilesOverlapped(idxFileOverlapped)).gpsTime(end)];
        end
        
        % Find sequences in the field. It's the same code snippet used in
        % testInFieldClassification.m.
        diffLocation = -100*ones(length(location),1);
        diffLocation(location<0) = 0;
        diffLocation = diff([0;diffLocation;0]);
        
        indicesUnlabeledSequenceStart = find(diffLocation==-100); % start
        indicesUnlabeledSequenceEnd = find(diffLocation==100)-1; % end
        
        % For each field, we will try to link the geo-points to the yield
        % ticket. Here for simplicity, every contineuous infield sequence
        % will be treated as one field.
        
        for indexInfieldSeq = 1:1:length(indicesUnlabeledSequenceStart)
            
            % Indices are in terms of this combine file.
            indicesInfieldSequence = ...
                indicesUnlabeledSequenceStart(indexInfieldSeq) ...
                :indicesUnlabeledSequenceEnd(indexInfieldSeq);
            
            % Assume the combine is always harvesting while it's in the
            % field. We'll scan the sequence first for the "nearby
            % in-action" vehicles.
            
            % Distances and indices for the nearest vehicle for each time
            % point corresponding to the field dequence represented by
            % indicesInfieldSequence. The first column is the nearest
            % distance, the second column is the corresponding index for
            % that vehicle, and the third column is the index of the sample
            % for that time in terms of that vehicle. Note that poisitions
            % with the nearest distance larger than the sum of the two
            % distance shresholds, they will be marked as NaN.
            distAndIndiForNearestVehicles = nan(length(indicesInfieldSequence),3);
            
            % First, record all the nearest distances less or equal to the
            % sum of the 2 distance shresholds, and the corresponding
            % vehicle indices.
            for indexSample = indicesInfieldSequence
                % Scan the whole sequence in time.
                currentTime = time(indexSample);
                
                % Find other active vehicles at current time point.
                indicesActiveRoutes = indicesFilesOverlapped( ...
                    intersect( ...
                    find(timeLimits(1,:)<currentTime), ... Start time.
                    find(timeLimits(2,:)>currentTime)... End time.
                    )...
                    );
                
                % Compute the distances in meter between current vehicle
                % and vehicles of these active routes.
                distancesTemp = nan(length(indicesActiveRoutes),1);
                idxCurrentSampleActiveVehicle = distancesTemp;
                for idxActiveRoute = 1:1:length(indicesActiveRoutes)
                    
                    % Find the current location of this active vehicle.
                    idxCurrentSampleActiveVehicle(idxActiveRoute) = ...
                        find(files(indicesActiveRoutes(idxActiveRoute)).gpsTime>=currentTime,1,'first');
                    currentLatActiveVehicle = ...
                        files(indicesActiveRoutes(idxActiveRoute))...
                        .lat(idxCurrentSampleActiveVehicle(idxActiveRoute));
                    currentLonActiveVehicle = ...
                        files(indicesActiveRoutes(idxActiveRoute))...
                        .lon(idxCurrentSampleActiveVehicle(idxActiveRoute));
                    
                    % Distances for this specific points.
                    distancesTemp(idxActiveRoute) = ...
                        lldistkm(...
                        [lati(indexSample) long(indexSample)],...
                        [currentLatActiveVehicle currentLonActiveVehicle]...
                        )*1000;
                end
                
                % Use the distance rule to determine what the vehicles are
                % doing.
                [distForNearestVehicle, indeForNearestVehicle] = min(distancesTemp);
                
                % If the distance is beyond the sum of the two distance
                % parameters, the corresponding vehicle won't be considered
                % as nearby for sure. So the distances will be recorded
                % only if it's not the case.
                if distForNearestVehicle ...
                        <= DISTANCE_NEARBY_VEHICLES+DISTANCE_NEARBY_VEHICLES_PADDING
                    distAndIndiForNearestVehicles(indexSample-indicesInfieldSequence(1)+1,:) ...
                        = [distForNearestVehicle, ...
                        indicesActiveRoutes(indeForNearestVehicle), ...
                        idxCurrentSampleActiveVehicle(indeForNearestVehicle)];
                end
            end
            
            % Initialize the "product", i.e. the harvested area, carried by
            % this combine. The index is in terms of this combine file.
            
            indexHarvestedSeqEnd = indicesInfieldSequence(1)-1;
            
            % Initialize the indices for the unloading activity. The indices are in
            % terms of this filed sequence.
            indexUnloadingStart = find(...
                distAndIndiForNearestVehicles(:,1)...
                <DISTANCE_NEARBY_VEHICLES-DISTANCE_NEARBY_VEHICLES_PADDING,...
                1,'first');
            if ~isempty(indexUnloadingStart)
                % A possible sequence of "unloading" for this combine is
                % found.
                indexVehicleUnloadedTo = ...
                    distAndIndiForNearestVehicles(indexUnloadingStart,2);
                indexUnloadingEnd = find(...
                    distAndIndiForNearestVehicles(indexUnloadingStart:end,2)...
                    ~=indexVehicleUnloadedTo,...
                    1, 'first');
                if ~isempty(indexUnloadingEnd)
                    % It's now confirmed a sequence of "unloading".
                    
                    % Harvested sequence. The index is in terms of this
                    % combine file.
                    indexHarvestedSeqStart = indexHarvestedSeqEnd+1;
                    
                    % Convert indexUnloadingEnd to match
                    % indexUnloadingStart.
                    indexUnloadingEnd = indexUnloadingEnd+indexUnloadingStart-2;
                    
                    indicesSamplesUnloaded ...
                        = indicesInfieldSequence(indexUnloadingStart:indexUnloadingEnd);
                    
                     %% %%%%%%%%%%%%%
                    
                    % For the vehicle to which the combine is unloading, we
                    % store the information in a structure.
                    product.indexRangeLoadingActivity = [];
                    product.loadingFrom = indexFile;
                    product.lat = lati(indicesSamplesUnloaded);
                    product.lon = long(indicesSamplesUnloaded);
                    
                    % Also extend the cell for the next product
                    % structure for the vehicle to which this combine
                    % is unloading.
                    products{indexVehicleUnloadedTo}(end+1)...
                        = product;
                    
                    
                    %%
                    
                    % For the combine, we store this set of information in
                    % a array, indicating the indices of the start and end
                    % of this sequence, and to which vehicle this product
                    % is unloaded to.
                    
                    % Extend the cell for the next array.
                    products{indexFile}{end+1} = ...
                        [indicesInfieldSequence(indexUnloadingStart);...
                        indicesInfieldSequence(indexUnloadingEnd);...
                        indexVehicleUnloadedTo];
                    
                   
                end
            end
            
            

            
        end
    end
end



% EOF