%GENMOVIEBYGPSTIME Generate illustration movies according to the specified
%GPS time range.
%
% Generate illustration movies for the ITSC presentation. Please make sure
% naiveTrain runs well first to get all vehicle info, because naiveTrain is
% still under development at the time this script is written.
%
% Update: Write the frame to disc as they are generated to avoid taking too
% much memory. 11/19/2015
% 
% Update: The length for the speed arrow was adjusted by the function
% quiver before and now it's manully set so that the arrows won't be too
% large to show or too small to be seen. 05/27/2016
%
% Yaguang Zhang, Purdue, 09/16/2015

%% Initialization

% clc;
close all;

% Changed folder to "NaiveTrain" first. Because this script isn't in the
% Matlab path, we use the 'fullpath' function of mfilename to get it's
% path.
cd(fullfile(fileparts(mfilename('fullpath')),'..', '..'));

% Get vehicle data and generate their state infomation.
naiveTrain;

%% Parameters for Movie Generation
disp('-------------------------------------------------------------');
disp('genMovieByGpsTime: Capturing frames...');

% Set this to be true to show loading/unloading activities in the movie.
if ~exist('FLAG_SHOW_VEH_ACTIVITIES','var')
    FLAG_SHOW_VEH_ACTIVITIES = true;
end

% Set this to be true to show vehicle number labels.
if ~exist('FLAG_SHOW_VEH_LABELS','var')
    FLAG_SHOW_VEH_LABELS = true;
end

% Set this to be true to pause the movie after the first frame so that it's
% possible to set the visible area.
if exist('ASK_FOR_HELP', 'var')
    if ASK_FOR_HELP.flag
        PAUSE_AFTER_FIRST_FRAME = true;
    end
end
if ~exist('FLAG_SHOW_VEH_ACTIVITIES','var')
    PAUSE_AFTER_FIRST_FRAME = false;
end

if ~exist('GPS_TIME_RANGE', 'var')
    % GPS time range [gpsTimeStart, gpsTimeEnd] for the movie in
    % milliseconds.
    GPS_TIME_RANGE = [1404921635151,1404921635151+120000];
end

if ~exist('PLAYBACK_SPEED', 'var')
    % Playback speed for the movie.
    PLAYBACK_SPEED = 20; % Eg. 10 times speed: 1 hour => 6 min.
end

% [1404921367589, 1404937635151] is a good range to observe.
%    ~4.5 hours long with 2 fields harvested.
% Set PLAYBACK_SPEED = 20 to make a ~13-min-long movie.

% Figure window size. (For MPEG-4 limited by 1920*1088)
%    480P with 4:3 aspect ratio: 640*480
%   720P with 4:3 aspect ratio: 720*540
%  1080P with 4:3 aspect ratio: 1080*810
% 1280/4*3 = 960; 2160/4*3 = 1620
% FIG_HEIGHT = 960;
% FIG_WIDTH = 1280;
FIG_HEIGHT = 720;
FIG_WIDTH = 700;
% Colors for the vehicles.
COLOR.COMBINE = 'yellow';
COLOR.GRAIN_KART = 'blue';
COLOR.TRUCK = 'black';
% Used to highlight the vehicle marker
COLOR.HIGH_LIGHT = 'red';
% For font size in the figure.
LENGTH_UNIT = 'points';
FONT_SIZE = 8;

% Parameters for the movie.

% Compression method.
%          'MPEG-4'; really small in size but poor quality.
% 'Motion JPEG AVI': default by Matlab but not much better.
PROFILE = 'MPEG-4';
FPS = 30; % Frames per second.
QUALITY = 100; % Default 75.

% Path to save the movie. If IND_FILE_FOR_GEN_MOVIE (the index of the file
% which corresponds to the movie in the variable files) is provided, we
% will record it in the file name.
if ~exist('pathFolderToSaveMovies', 'var')
    pathFolderToSaveMovies = fileparts(mfilename('fullpath'));
end
if exist('IND_FILE_FOR_GEN_MOVIE','var')
    MOV_FILE_PATH = fullfile(pathFolderToSaveMovies, ...
        strcat(...
        'genMovieByGpsTime_', ...
        num2str(IND_FILE_FOR_GEN_MOVIE), '_', ...
        datestr(now,'yyyymmddHHMMSS')...
        )...
        );
    currentFileForGenMovie = IND_FILE_FOR_GEN_MOVIE;
else
    MOV_FILE_PATH = fullfile(pathFolderToSaveMovies, ...
        strcat(...
        'genMovieByGpsTime_', ...
        datestr(now,'yyyymmddHHMMSS')...
        )...
        );
end

clear IND_FILE_FOR_GEN_MOVIE;

%% Movie Generation

% Compute some parameters first.
colorsVehicle = {COLOR.COMBINE, ...
    COLOR.GRAIN_KART, ...
    COLOR.TRUCK};
typesColorVeh = {'Combine','Grain Kart','Truck'};

% For the movie.
movieLengthInSecond = (GPS_TIME_RANGE(2)-GPS_TIME_RANGE(1))/1000/PLAYBACK_SPEED;
numFrames = max(floor(movieLengthInSecond * FPS),1);
gpsTimePerFrame = (GPS_TIME_RANGE(2)-GPS_TIME_RANGE(1))/(numFrames-1);
% Active files during the specified GPS time range.
if ~exist('gpsTimeRangesForFiles', 'var')
    gpsTimeRangesForFiles = [inf(length(files),1),  -inf(length(files),1)];
    % Retrieve time ranges for all the elements in vehFiles.
    for idxFiles = 1:length(files)
        % Start time.
        gpsTimeRangesForFiles(idxFiles,1) = files(idxFiles).gpsTime(1);
        % End time.
        gpsTimeRangesForFiles(idxFiles,2) = files(idxFiles).gpsTime(end);
    end
end
% Only files with gpsTimeRange covering by the range specifed are valid.
indicesActiveFilesAll = find(gpsTimeRangesForFiles(:,1) <= GPS_TIME_RANGE(2) ...
    & gpsTimeRangesForFiles(:,2) >= GPS_TIME_RANGE(1));

% Create the figure.
hFig =  figure('Name', 'genMovieByGpsTime', ...
    'NumberTitle', 'off', 'ToolBar', 'figure', ...
    'Units','pixels', ...
    'OuterPosition',[50 50 FIG_WIDTH FIG_HEIGHT]);

% Set font size to be screen resolution independent.
set(gca,'FontUnits', LENGTH_UNIT);
set(gca,'FontSize',FONT_SIZE);

% First plot all tracks of active files in "uncovered" style.
hold on;
for idxActiveFile = 1:length(indicesActiveFilesAll)
    plot(files(indicesActiveFilesAll(idxActiveFile)).lon, ...
        files(indicesActiveFilesAll(idxActiveFile)).lat, ...
        'Color', colorsVehicle{strcmpi(typesColorVeh, files(indicesActiveFilesAll(idxActiveFile)).type)}, ...
        'LineWidth', 0.5, ... % Default LineWidth = 0.5 point.
        'LineStyle', ':' ...
        )
end
% Create vehicle markers at current time.
currentGpsTime = GPS_TIME_RANGE(1);
plotForGenMovieByGpsTime;
hold off;
% Not necessary to show tick labels.
set(gca,'XTick',[])
set(gca,'YTick',[])
% Only show the axis labels.
xlabel('Lon');
ylabel('Lat');

disp(' ');
if exist('AXIS_VISIBLE','var')
    if (AXIS_VISIBLE(1)<AXIS_VISIBLE(2) && AXIS_VISIBLE(3)<AXIS_VISIBLE(4))
        axis(AXIS_VISIBLE);
        disp('The currently visible area has been set programmatically.');
        if exist('ASK_FOR_HELP', 'var')
            % Ask for help (human adjustment of the visible area) if necessary.
            if(ASK_FOR_HELP.flag && ...
                    lldistkm(AXIS_VISIBLE([1,3]),AXIS_VISIBLE([2,4]))*1000 >= ...
                    ASK_FOR_HELP.minDiagonalLength...
                    )
                askForHelp;
            end
        end
    end
else
    disp('Please set the currently visible area for the movie on the map.');
    disp('Press any key to continue...')
    pause;
end
plot_google_map('MapType', 'satellite');

% Pushbuttons.
pbSelectOnRoad = uicontrol( ...
    'Style', 'pushbutton', ...
    'String', '||', ...
    'FontUnit', LENGTH_UNIT, ...
    'FontSize', FONT_SIZE, ...
    'Units', LENGTH_UNIT, ...
    'Position', [10 10 [1 1]*(FONT_SIZE*1.25)], ...
    'CallBack', 'pause', ...
    'BusyAction', 'cancel');

% % Not working well for skipping frames. pbSelectOnRoad = uicontrol( ...
%     'Style', 'pushbutton', ... 'String', '>>', ... 'FontUnit',
%     LENGTH_UNIT, ... 'FontSize', FONT_SIZE, ... 'Units', LENGTH_UNIT, ...
%     'Position', [10+FONT_SIZE*1.5 10 [1 1]*(FONT_SIZE*1.25)], ...
%     'CallBack', 'currentGpsTime = currentGpsTime + 3600000;
%     updateFrameForGenMovieByGpsTime;', ... Forward 1 hour. 'BusyAction',
%     'cancel');

% Create each frame.
F(numFrames) = struct('cdata',[],'colormap',[]);

% Capture the first frame.
F(1) = getframe(hFig);
disp('Done. ');
disp('You can also push the ''||'' button at the bottom left coner of the figure to set the visible area during the movie generation.')
disp(' ');

% Save the movie as an AVI file.
videoWritter = VideoWriter(MOV_FILE_PATH, PROFILE);
videoWritter.FrameRate = FPS;  % Default 30
myVideo.Quality = QUALITY;     % Default 75
open(videoWritter);

% We will only cashe at most MAX_NUM_FRAMES_IN_MEMORY frames in memory to
% avoid using too much memory.
MAX_NUM_FRAMES_IN_MEMORY = 1000;
indexFirstValidFrameInF = 1;
numFramesInMemory = 1;
% Note that
%   indexLastValidFrameInF
% = indexFirstValidFrameInF+numFramesInMemory-1.

% How many feedbacks (e.g. 10 if we want a feedback every 10%) to display.
NUM_FEEDBACK = 10;
processInPercentage = (1:NUM_FEEDBACK)/NUM_FEEDBACK*100;
effectiveFrame = numFrames/NUM_FEEDBACK:numFrames/NUM_FEEDBACK:numFrames;
format short;

if exist('PAUSE_AFTER_FIRST_FRAME', 'var')
    if PAUSE_AFTER_FIRST_FRAME
        askForHelp;
    end
end

for idxFrame = 2:numFrames
    % Display feedback when necessary.
    processStage = find(effectiveFrame<=idxFrame,1,'last');
    if ~isempty(processStage)
        disp(strcat(num2str( ...
            processInPercentage(processStage) ...
            ), '%'));
        effectiveFrame(processStage) = numFrames+1;
    end
    
    currentGpsTime = currentGpsTime + gpsTimePerFrame;
    updateFrameForGenMovieByGpsTime;
    
    % If the visible area is too large, or if a vehicle (except trucks) left the visible area, ask for help.
    if exist('ASK_FOR_HELP', 'var')
        if(FLAG_SHOW_VEH_LABELS)
            currentAxis = axis;
            currentLonsToShow = nan(length(filesToShow),1);
            currentLatsToShow = currentLonsToShow;
            if SHOW_VELOCITY_DIRECTIONS
                currentSpeedToShow = currentLonsToShow;
                nextLons = currentLonsToShow;
                nextLats = currentLonsToShow;
            end
            for idxFileToShow = 1:length(filesToShow)
                currentLonsToShow(idxFileToShow) = filesToShow(idxFileToShow).lon(indicesCurrentSample{idxFileToShow});
                currentLatsToShow(idxFileToShow) = filesToShow(idxFileToShow).lat(indicesCurrentSample{idxFileToShow});
                if SHOW_VELOCITY_DIRECTIONS
                    currentSpeedToShow(idxFileToShow) = filesToShow(idxFileToShow).speed(indicesCurrentSample{idxFileToShow});
                    % Update: use the log function to adjust the speed
                    % value.
                    % currentSpeedToShow(idxFileToShow) = log(currentSpeedToShow(idxFileToShow)+1)/log(10);
                    if currentSpeedToShow(idxFileToShow) ~= 0 && length(filesToShow(idxFileToShow).lon)>indicesCurrentSample{idxFileToShow}
                        nextLons(idxFileToShow) = filesToShow(idxFileToShow).lon(indicesCurrentSample{idxFileToShow}+1);
                        nextLats(idxFileToShow) = filesToShow(idxFileToShow).lat(indicesCurrentSample{idxFileToShow}+1);
                    end
                end
            end
            % Ask for help (human adjustment of the visible area) if necessary.
            if(ASK_FOR_HELP.flag)
                if isfield('ASK_FOR_HELP', 'numCurrentlyVisibleVeh')
                    ASK_FOR_HELP.locPastVisibleVeh = ASK_FOR_HELP.locCurrentlyVisibleVeh;
                    ASK_FOR_HELP.numPastVisibleVeh = ASK_FOR_HELP.numCurrentlyVisibleVeh;
                end
                ASK_FOR_HELP.indicesCurrentlyVisibleVeh = indicesFilesToShow( ...
                    currentLonsToShow >= currentAxis(1) & ...
                    currentLonsToShow <= currentAxis(2) & ...
                    currentLatsToShow >= currentAxis(3) & ...
                    currentLatsToShow <= currentAxis(4) ...
                    );
                ASK_FOR_HELP.numCurrentlyVisibleVeh = length(ASK_FOR_HELP.indicesCurrentlyVisibleVeh);
                if isfield('ASK_FOR_HELP', 'numPastVisibleVeh')
                    if(ASK_FOR_HELP.numPastVisibleVeh>ASK_FOR_HELP.numCurrentlyVisibleVeh)
                        % Check the type of vehicles that left the visible
                        % area.
                        indicesVehLeft = setdiff(ASK_FOR_HELP.locPastVisibleVeh, ASK_FOR_HELP.locCurrentlyVisibleVeh);
                        for idxVehLeft = 1:length(indicesVehLeft)
                            if (~strcmp(files(indicesVehLeft(idxVehLeft)).type, 'Truck'))
                                askForHelp;
                            end
                        end
                    end
                end
            end
        end
    end
    
    % Show the estimated velocity directions.
    if SHOW_VELOCITY_DIRECTIONS
        if(exist('hMapVehiclesVelocity', 'var'))
            if isvalid(hMapVehiclesVelocity)
                delete(hMapVehiclesVelocity);
            end
        end
        if ~isempty(nextLons)
            % Only show the speed for vehicles with valid nextLon value.
            indicesValideNextLons = ~isnan(nextLons);
            velocity = 0.001 * normr([nextLons(indicesValideNextLons) - currentLonsToShow(indicesValideNextLons) ...
                nextLats(indicesValideNextLons) - currentLatsToShow(indicesValideNextLons)]) ...
                .* [currentSpeedToShow(indicesValideNextLons) currentSpeedToShow(indicesValideNextLons)];
            if ~isempty(velocity)
                hMapVehiclesVelocity = quiver(...
                    currentLonsToShow(indicesValideNextLons), ...
                    currentLatsToShow(indicesValideNextLons), ...
                    velocity(:, 1), ...
                    velocity(:, 2), ...
                    0,'w');
            end
        end
    end
    
    F(idxFrame) = getframe(hFig);
    numFramesInMemory = numFramesInMemory+1;
    
    % Need to spare more memory by writing into the movie if too many
    % frames are stored.
    if numFramesInMemory >= MAX_NUM_FRAMES_IN_MEMORY
        disp('genMovieByGpsTime: Too many frames are stored.');
        disp('                   Saving movie to spare memory...');
        indexLastValidFrameInF = indexFirstValidFrameInF+numFramesInMemory-1;
        writeVideo(videoWritter, F(indexFirstValidFrameInF:indexLastValidFrameInF));
        F(indexFirstValidFrameInF:indexLastValidFrameInF) = struct('cdata',[],'colormap',[]);
        numFramesInMemory = 0;
        indexFirstValidFrameInF = indexLastValidFrameInF+1;
    end
    
end

disp('                   Done!');

% Store the rest valid frames.
if numFramesInMemory>0
    disp(' ');
    disp('genMovieByGpsTime: Saving movie...');
    indexLastValidFrameInF = indexFirstValidFrameInF+numFramesInMemory-1;
    writeVideo(videoWritter, F(indexFirstValidFrameInF:indexLastValidFrameInF));
    close(videoWritter);
    clear F numFramesInMemory indexFirstValidFrameInF indexLastValidFrameInF;
    disp('                   Done!');
end
disp('-------------------------------------------------------------');

% catch err
%     disp(err); disp(' ');
% end EOF