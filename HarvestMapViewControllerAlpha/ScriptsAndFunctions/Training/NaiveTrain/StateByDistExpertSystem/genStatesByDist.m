%GENSTATESBYDIST Generate state labels for all vehicles according to the
%distances to nearest vehicles.
%
% The results are arranged in the cell array statesByDist. Each element of
% it is a matrix with 2 colomns: loadFrom and unloadTo. If no
% loading/unloading activity is being done, NaN will be recorded. And 0 in
% loadFrom means loading from the land (i.e. harvesting), while Inf in
% unloadTo means unloading to the factory. Otherwise, the value of these
% elements are the index of the vehicle in the variable files. Each row is
% the state info for the cooresponding sample.
%
% Yaguang Zhang, Purdue, 09/15/2015

% Set this to be true to turn on the debugging function.
FLAG_DEBUG = false;

if FLAG_DEBUG
    clear hDebugFig;
    close all;
end
% Parameters. Distance rule to tell nearby vehicles + Time threshold to
% make sure it's valid.
DISTANCE_NEARBY_VEHICLES = 20; % In meters.
% Added to avoid the influence of noise. Only vehicles with less distance
% than the difference of them will be treated as "nearby vehicles", if it's
% not nearby before; and it will go out of nearby state only if the
% distance goes beyond the sum of these two parameters.
DISTANCE_NEARBY_VEHICLES_PADDING = 1; % In meters.
% Time threshold. Note: 5s was used for generate data for manual labeling
% the states. Now we use 30s to get a better performance (by getting rid of
% passing by situations).
MIN_TIME_BEING_NEARBY_TO_TAKE_ACTIONS = 30; % In seconds.
% For segment to be classified as unloading, the majority should be
% unloading to the left hand side.
MIN_RATIO_UNLOAD_TO_LEFT = 0.5;

% Initialize statesByDist.
statesByDist = cell(length(files),1);
for idxFile = 1:length(files)
    % Colomns: [loadFrom, unloadTo].
    statesByDist{idxFile} = nan(length(files(idxFile).gpsTime),2);
end

% Label combines.
disp('Labeling combines...')
% Will label all possible actions from fromType to toType.
fromType = 'Combine';
toType = {'Grain Kart','Truck'};
labelStatesByDist;

% Label unloading from grain carts to trucks.
disp('Labeling grain carts...')
fromType = 'Grain Kart';
toType = 'Truck';
labelStatesByDist;

% EOF