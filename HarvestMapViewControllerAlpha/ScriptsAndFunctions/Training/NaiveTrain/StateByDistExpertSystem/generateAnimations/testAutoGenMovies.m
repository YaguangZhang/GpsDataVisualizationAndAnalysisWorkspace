%TESTAUTOGENMOVIES Generate illustration movies for all data available with
%automatically set time ranges and visible areas.
%
% Please make sure the movies are numbered according to the vehicle number
% for the state collector to work.
% 
% Movies for all the data available. It will, for each valid segment of
% data where no new vehicle shows up, generate a movie clip showing
% (hopefully) the field. We will ignore trucks when computing the visible
% areas because they may run far away from the fields.
%
% Update: Improved the algorithm to caculate the visible area for each
% movie (zoom in more) to better show what the vehicles are doing. Zyg
% 05/17/2016
%
% Update: Added arrows for current direction. Zyg 05/18/2016
%
% Yaguang Zhang, Purdue, 05/20/2016

% Set this to be true if you'd like the program pause for your help on
% setting the visible area of the movie when it thinks the automatically
% computed results are not really good.
clear ASK_FOR_HELP;
ASK_FOR_HELP.flag = true; %true;
% The minimum diagonal length (in meter) of the visible area for the
% program to ask for help.
ASK_FOR_HELP.minDiagonalLength = 3000;
% Set this to be true to show the directions of the vehicles.
SHOW_VELOCITY_DIRECTIONS = true;
% Set this to be true plot the states for the vehicles.
FLAG_SHOW_VEH_ACTIVITIES = true;

%% Initialization

clc; close all;

% Changed folder to "NaiveTrain" first. Because this script isn't in the
% Matlab path, we use the 'fullpath' function of mfilename to get it's
% path.
cd(fullfile(fileparts(mfilename('fullpath')),'..', '..'));

% Get vehicle data and generate their state infomation.
naiveTrain;

%% Preprocessing for Movie Generation
% Automatically compute the time points (i.e. the time ranges for the
% movies) and the visible areas.

disp('-------------------------------------------------------------');
disp('Preprocessing for movie generation...')

% All variables to compute.

% Total number of movies.
numMovies = length(files);
% Time ranges for each movie.
timeRangeMovies = [fileIndicesSortedByStartRecordingGpsTime(:,2), nan(numMovies,1)];
% Visible areas for each movie.
axisVisibleMovies = nan(numMovies,4);

% Get all the first and last time point for harvesters for harvesting.
gpsTimeStartHarv = nan(numMovies, 1);
gpsTimeStopHarv = nan(numMovies, 1);

for idxFiles = 1:numMovies
    indexSampleStartHarv = find(statesByDist{idxFiles}(:,1)==0, 1, 'first');
    indexSampleStopHarv = find(statesByDist{idxFiles}(:,1)==0, 1, 'last');
    if ~isempty(indexSampleStartHarv)
        gpsTimeStartHarv(idxFiles) = files(idxFiles).gpsTime( ...
            indexSampleStartHarv ...
            );
    end
    if ~isempty(indexSampleStopHarv)
        gpsTimeStopHarv(idxFiles) = files(idxFiles).gpsTime( ...
            indexSampleStopHarv ...
            );
    end
end

% Get all the time points where the movies should stop. We will find all
% active vehicles between each pair of adjacent movie starting points and
% use the largest ending time for these vehicles as the end point for the
% corresponding movie.
timeRangeMovies(1:numMovies-1,2) = timeRangeMovies(2:numMovies,1);
timeRangeMovies(numMovies,2) = inf;

% Extend timeRangeMovies so that the last row can be treated just like
% others.
timeRangeMovies = [timeRangeMovies; nan inf];

% GPS time ranges for all vehicle data file.
gpsTimeRangesForFiles = [inf(length(files),1),  -inf(length(files),1)];
% Retrieve time ranges for all the elements in vehFiles.
for idxFiles = 1:length(files)
    % Start time.
    gpsTimeRangesForFiles(idxFiles,1) = files(idxFiles).gpsTime(1);
    % End time.
    gpsTimeRangesForFiles(idxFiles,2) = files(idxFiles).gpsTime(end);
end

% Shrink the time ranges if possible according to VEH_TYPE_CONSIDERED..
for indexMovies = 1:numMovies
    
    % Active files during the specified GPS time range. Only files with
    % gpsTimeRange covering by the range specifed are valid.
    currentGpsTimeRange = timeRangeMovies(indexMovies,:);
    indicesActiveFiles = find(gpsTimeRangesForFiles(:,1) < currentGpsTimeRange(2) ...
        & gpsTimeRangesForFiles(:,2) > currentGpsTimeRange(1));
    
    % We will only consider combines.
    VEH_TYPE_CONSIDERED = {'Combine'};
    indicesVehConsidered = indicesActiveFiles( ...
        ismember({files(indicesActiveFiles).type},VEH_TYPE_CONSIDERED) ...
        );
    
    if ~isempty(indicesVehConsidered) && ~any(isnan(gpsTimeStartHarv(indicesVehConsidered)))
        
        % Initialize the start time for the movie as the smallest start GPS
        % time for all the active files considered.
        timeRangeMovies(indexMovies,1) = min( ...
            fileIndicesSortedByStartRecordingGpsTime( ...
            ismember(fileIndicesSortedByStartRecordingGpsTime(:,1),indicesVehConsidered), ...
            2) ...
            );
        
        % Set the end time for the movie as the largest end GPS time for
        % all the active files considered, if it's less than the start time
        % of the next movie.
        timeRangeMovies(indexMovies,2) = min( timeRangeMovies(indexMovies,2), ...
            fileIndicesSortedByEndRecordingGpsTime( ...
            find(ismember(fileIndicesSortedByEndRecordingGpsTime(:,1),indicesVehConsidered),1,'last'), ...
            2)...
            );
        
        % Then shrink the time ranges even more according to the harvesting
        % times.
        timeRangeMovies(indexMovies,1) = max([timeRangeMovies(indexMovies,1); ...
            min(gpsTimeStartHarv(indicesVehConsidered))]...
            );
        timeRangeMovies(indexMovies,2) = min([timeRangeMovies(indexMovies,2); ...
            max(gpsTimeStopHarv(indicesVehConsidered))]...
            );
        
        % At last be more agressive on the start time to avoid generating
        % redundent clips, by setting it at least the same as the end time
        % of the previous movie.
        if indexMovies > 1
            timeRangeMovies(indexMovies,1) = max([ ...
                timeRangeMovies(indexMovies,1); ...
                timeRangeMovies(1:indexMovies-1,2)]...
                );
        end
        
        % Only compute the visible area if the movie range is valid
        if timeRangeMovies(indexMovies,1)<=timeRangeMovies(indexMovies,2)
            % Set visible areas according to VEH_TYPE_CONSIDERED.
            latConsidered = {};
            lonConsidered = {};
            for indexVehConsidered = indicesVehConsidered'
                % Samples when this vehicle is harvesting.
                boolHavSamples = statesByDist{indexVehConsidered}(:,1)==0;
                % Only consider the samples within the movie time range.
                boolHavSamplesInMovie = false(size(boolHavSamples));
                indicesSamplesInMovie = find( ...
                    files(indexVehConsidered).gpsTime ...
                    >= timeRangeMovies(indexMovies,1) ...
                    & ...
                    files(indexVehConsidered).gpsTime ...
                    <= timeRangeMovies(indexMovies,2)...
                    );
                boolHavSamplesInMovie(indicesSamplesInMovie) = ...
                    boolHavSamples(indicesSamplesInMovie);
                latConsidered{end+1} = files(indexVehConsidered).lat(boolHavSamplesInMovie);
                lonConsidered{end+1} = files(indexVehConsidered).lon(boolHavSamplesInMovie);
            end
            % Make it a column cell because all its elements are column
            % arrays.
            latConsidered = latConsidered';
            latConsidered = cell2mat(latConsidered);
            lonConsidered = lonConsidered';
            lonConsidered = cell2mat(lonConsidered);
            latMin = min(latConsidered);
            latMax = max(latConsidered);
            lonMin = min(lonConsidered);
            lonMax = max(lonConsidered);
            % Extend the area a little bit (30 % here for each side).
            factorExtend = 0.3;
            meanLat = (latMin+latMax)/2;
            deltaLat = (latMax - latMin)*(1+factorExtend)/2;
            latMin = meanLat - deltaLat;
            latMax = meanLat + deltaLat;
            meanLon = (lonMin+lonMax)/2;
            deltaLon = (lonMax - lonMin)*(1+factorExtend)/2;
            lonMin = meanLon - deltaLon;
            lonMax = meanLon + deltaLon;
            
            if(isempty([lonMin, lonMax, latMin, latMax]))
                % Discard this movie.
                axisVisibleMovies(indexMovies,:) = nan(1,4);
            else
                axisVisibleMovies(indexMovies,:) = [lonMin, lonMax, latMin, latMax];
            end
        end
    else
        % Set the stop time as the largest stop time for the active
        % vehicles.
        timeRangeMovies(indexMovies,2) = max(gpsTimeRangesForFiles(indicesActiveFiles,2));
    end
end

% Discard the last row of timeRangeMovies which was extend by us.
timeRangeMovies = timeRangeMovies(1:end-1,:);

% Save necessary parameters for the state collector.
pathFolderToSaveMovies = fullfile(pathInFieldClassificationFilefolder, 'AutoGenMovies');
if ~exist(pathFolderToSaveMovies,'dir')
    mkdir(pathFolderToSaveMovies);
end

indicesMovieToVeh = fileIndicesSortedByStartRecordingGpsTime(:,1);
% % Extra end of 51: used for correcting some labels using
% % collectorForStates.
% timeRangeMovies(51,:) = [timeRangeMovies(51,1)+440000 timeRangeMovies(52,1)+1000];

save(...
    fullfile(...
    pathFolderToSaveMovies, ...
    'MoviesInfo.mat'...
    ), ...
    'timeRangeMovies', ...
    'indicesMovieToVeh');

%% Generate Movies
disp('-------------------------------------------------------------');
disp('Generating movies...')

for indexMoviesToGen = 4    %1:numMovies
    PLAYBACK_SPEED = 60;
    AXIS_VISIBLE = axisVisibleMovies(indexMoviesToGen,:);
    
    if ~any(isnan(AXIS_VISIBLE))
        disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
        disp(strcat(num2str(indexMoviesToGen),'/',num2str(length(files))));
        disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
        GPS_TIME_RANGE = timeRangeMovies(indexMoviesToGen,:);
        IND_FILE_FOR_GEN_MOVIE = indexMoviesToGen;
        genMovieByGpsTime; % This will clean the unecessary variables by calling NaiveTrain.
    end
end

% Done!
disp('Done!')
disp('-------------------------------------------------------------');

load gong.mat;
soundsc(y, 2*Fs);

% EOF