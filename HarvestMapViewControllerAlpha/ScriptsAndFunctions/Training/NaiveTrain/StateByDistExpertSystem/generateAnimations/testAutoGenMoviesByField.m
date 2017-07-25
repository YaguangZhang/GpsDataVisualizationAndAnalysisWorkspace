%TESTAUTOGENMOVIESBYFIELD Generate illustration movies for all fields found
%with automatically set time ranges and visible areas, with vehicles drawn
%according to statesRef.
%
% Revised from testAutoGenMovies.m.
%
% Yaguang Zhang, Purdue, 07/03/2017

% Set this to be true if you'd like the program pause for your help on
% setting the visible area of the movie when it thinks the automatically
% computed results are not really good.
clear ASK_FOR_HELP;
ASK_FOR_HELP.flag = false;
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

% All variables to compute. We will use the enhancedFieldShapes to
% determine what movies to generate.
if(~exist('enhancedFieldShapes','var'))
    load(fullfile(fileFolderSet, ...
        '_AUTOGEN_IMPORTANT', 'enhancedFieldShapes.mat'));
end

% Total number of movies.
numMovies = length(files);
% Time ranges for each movie.
timeRangeMovies = [fileIndicesSortedByStartRecordingGpsTime(:,2), nan(numMovies,1)];
% Visible areas for each movie.
axisVisibleMovies = nan(numMovies,4);
% For this script, the movie number is the same as file number.
indicesMovieToVeh = 1:numMovies;

% Make a record for time ranges that have been covered for each field.
numFields = length(enhancedFieldShapes);
timeRangesCoveredForFields = cell(numFields,1);
% For each field, choose the file which covers the field the longest in
% time for the movie.
for idxField = 1:numFields
    disp(['    Field: ', num2str(idxField), '/', num2str(numFields)])
    [gpsTimesFirstInField, gpsTimesLastInField] = ...
        deal(nan(numMovies,1));
    for idxFile = 1:numMovies
        % Only consider combines and grain carts.
        if(ismember(files(idxFile).type, {'Combine','Kart'}))
            booleansInCurField = inShape(enhancedFieldShapes{idxField}, ...
                files(idxFile).lon, files(idxFile).lat);
            if any(booleansInCurField)
                gpsTimesFirstInField(idxFile) = files(idxFile).gpsTime( ...
                    find(booleansInCurField,1,'first'));
                gpsTimesLastInField(idxFile) = files(idxFile).gpsTime( ...
                    find(booleansInCurField,1,'last'));
            end
        end
    end
    [~,idxFileToUse] = max(gpsTimesLastInField-gpsTimesFirstInField);
    
    % Set timeRangeMovies.
    if(~any(isnan(timeRangeMovies(idxFileToUse,:))))
        warning('Field already associated with another field!');
        disp(['    Current field number: ', num2str(idxField)]);
    end
    timeRangeMovies(idxFileToUse,:) = [gpsTimesFirstInField(idxFileToUse), ...
        gpsTimesLastInField(idxFileToUse)];
    
    % Set axisVisibleMovies.
    shapePts = enhancedFieldShapes{idxField}.Points;
    latMin = min(shapePts(:,2));
    latMax = max(shapePts(:,2));
    lonMin = min(shapePts(:,1));
    lonMax = max(shapePts(:,1));
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
    axisVisibleMovies(idxFileToUse,:) = [lonMin, lonMax, latMin, latMax];
end

%% Save necessary parameters for the state collector.
pathFolderToSaveMovies = fullfile(pathInFieldClassificationFilefolder, 'AutoGenMoviesStatesRef');
if ~exist(pathFolderToSaveMovies,'dir')
    mkdir(pathFolderToSaveMovies);
end

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

for indexMoviesToGen = 1:numMovies
    PLAYBACK_SPEED = 60;
    AXIS_VISIBLE = axisVisibleMovies(indexMoviesToGen,:);
    
    if ~any(isnan(AXIS_VISIBLE))
        disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
        disp(strcat(num2str(indexMoviesToGen),'/',num2str(length(files))));
        disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
        GPS_TIME_RANGE = timeRangeMovies(indexMoviesToGen,:);
        IND_FILE_FOR_GEN_MOVIE = indexMoviesToGen;
        genMovieByGpsTime;
        %genMovieByGpsTimeForStateRef; % This will clean the unecessary variables by calling NaiveTrain.
    end
end

% Done!
disp('Done!')
disp('-------------------------------------------------------------');

load gong.mat;
soundsc(y, 2*Fs);

% EOF