% TRIAL0_MANUALLYLOACTEELEVATOR Trial 0 - Plot the truck GPS tracks to
% manually locate the elevators.
%
% Yaguang Zhang, Purdue, 11/14/2017

% Load data and set the current Matlab directory.
cd(fileparts(mfilename('fullpath')));
prepareTrial;
cd(fileparts(mfilename('fullpath')));
pathToSaveElevatorLocPoly = fullfile(pwd, 'elevatorLocPoly.mat');

% Each row has the elevator name and (lat, lon) polygons. Note it is better
% to define the polygons counter-clockwise.
elevatorLocPoly = { ...
    'Elevator Grainland Cooperative in Holyoke', [40.584841, -102.312603; ...
    40.585280, -102.301894; ...
    40.589542, -102.302052; ...
    40.584841, -102.312603];
    'Elevator Grainland Cooperative in Amherst', [40.679133, -102.168038; ...
    40.679041, -102.162715; ...
    40.684513, -102.162572; ...
    40.684480, -102.167784; ...
    40.679133, -102.168038];
    'Elevator Dracon Grain Co in Julesburg', [40.980244, -102.267699; ...
    40.987892, -102.253126; ...
    40.991428, -102.256431; ...
    40.984292, -102.271454; ...
    40.980244, -102.267699]};
save(pathToSaveElevatorLocPoly, 'elevatorLocPoly');

figure; hold on;
FLAG_SHOW_SPEED = false;
if  FLAG_SHOW_SPEED
    maxSpeedToShow = 20; % In m/s.
    minSpeedToShow = 0.01; % In m/s.
end
for idx = 1:length(files)
    if strcmp(files(idx).type, 'Truck')
        plot(files(idx).lon, files(idx).lat, 'LineWidth',1);
        if FLAG_SHOW_SPEED
            boolsShowSpeed = files(idx).speed >= minSpeedToShow ...
                & files(idx).speed <= maxSpeedToShow;
            plot3(files(idx).lon(boolsShowSpeed), ...
                files(idx).lat(boolsShowSpeed), ...
                files(idx).speed(boolsShowSpeed), '.', ...
                'MarkerSize', 6, 'LineWidth',1);
        end
    end
end
% Plot the elevators.
[numEles, ~] = size(elevatorLocPoly);
for idxEle = 1:numEles
    plot(elevatorLocPoly{idxEle, 2}(:,2), ...
        elevatorLocPoly{idxEle, 2}(:,1), 'r*-', 'LineWidth',1);
end
hold off;
plot_google_map('Maptype','satellite');

% EOF