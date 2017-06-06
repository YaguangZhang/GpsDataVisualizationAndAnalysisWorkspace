% TRIAL1_DISTHISTFORUNLOADING Trial 1 - Plot the histogram for distance
% between unloading & loading vehicle pairs.
%
% Yaguang Zhang, Purdue, 05/15/2017

% Load data and set the current Matlab directory.
cd(fileparts(mfilename('fullpath')));
prepareTrial;
cd(fileparts(mfilename('fullpath')));

% Find all the unloading states for each file.
MAX_TIME_DIFF = 2000; % In miliseconds.

numUnloadingPairs = 0;
% Allocate the memory in advance. Note that we only have 2507924 samples in
% this dataset.
unloadingPairDists = nan(2507924, 1); 
for idxUnloadingFile = 1:length(files)
    [xUnloading, yUnloading, ~] = deg2utm(files(idxUnloadingFile).lat, ...
        files(idxUnloadingFile).lon);
    
    for idxUnloadingSample = ...
            find(~isnan(statesRef{idxUnloadingFile}(:,2)))'
        idxLoadingFile = statesRef{idxUnloadingFile}(idxUnloadingSample,2);
        curGpsTime = files(idxUnloadingFile).gpsTime(idxUnloadingSample);
        
        % The indices for possible loading samples.
        indicesPosLoadingSamples = find( ...
            files(idxLoadingFile).gpsTime<curGpsTime+MAX_TIME_DIFF ...
            & files(idxLoadingFile).gpsTime>curGpsTime-MAX_TIME_DIFF);
        
        % Valid if there is at least one candidate.
        if(~isempty(indicesPosLoadingSamples))
            [~, idxLoadingSample] = min(abs( ...
                files(idxLoadingFile).gpsTime(indicesPosLoadingSamples) ...
                - curGpsTime));
            idxLoadingSample = indicesPosLoadingSamples(idxLoadingSample);
            [xLoading, yLoading, ~] = deg2utm( ...
                files(idxLoadingFile).lat(idxLoadingSample), ...
                files(idxLoadingFile).lon(idxLoadingSample));
            numUnloadingPairs = numUnloadingPairs+1;
            d = [xUnloading(idxUnloadingSample), ...
                yUnloading(idxUnloadingSample)] ...
                - [xLoading, yLoading];
            unloadingPairDists(numUnloadingPairs) = sqrt(d * d');
        end
    end
end

hFig = figure; 
histogram(unloadingPairDists, 'BinWidth', 1);
grid on; title('Distance Histogram for Unloading Vehicle Pairs'); 
xlabel('Distance (m)');
ylabel('Number of Unloading Vehicle Pairs');
saveas(hFig, 'Trial1_Results.png');
% EOF