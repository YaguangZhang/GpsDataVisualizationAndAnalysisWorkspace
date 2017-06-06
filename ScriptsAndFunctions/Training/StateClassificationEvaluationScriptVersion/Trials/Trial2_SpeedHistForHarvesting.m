% TRIAL2_SPEEDHISTFORHARVESTING Trial 2 - Plot the histogram for the speed
% of samples that are labeled as "harvesting".
%
% Yaguang Zhang, Purdue, 05/16/2017

% Load data and set the current Matlab directory.
cd(fileparts(mfilename('fullpath')));
prepareTrial;
cd(fileparts(mfilename('fullpath')));

% Find all the harvesting samples for each file.
numHarvestingSamples = 0;
% Allocate the memory in advance. Note that we only have 2507924 samples in
% this dataset.
harvestingSamplesSpeed = nan(2507924, 1); 
for idxFile = 1:length(files)
    indicesHarvestingSamples = find(statesRef{idxFile}(:,1)==0);
    harvestingSamplesSpeed( ...
        numHarvestingSamples+(1:length(indicesHarvestingSamples))) ...
        = files(idxFile).speed(indicesHarvestingSamples);
    numHarvestingSamples =  ...
        numHarvestingSamples+length(indicesHarvestingSamples);
end

hFig = figure; 
histogram(harvestingSamplesSpeed, 'BinWidth', 0.25);
grid on; title('Speed Histogram for Harvesting'); 
xlabel('Speed (m/s)');
ylabel('Number of Harvesting Samples');
saveas(hFig, 'Trial2_Results.png');
% EOF