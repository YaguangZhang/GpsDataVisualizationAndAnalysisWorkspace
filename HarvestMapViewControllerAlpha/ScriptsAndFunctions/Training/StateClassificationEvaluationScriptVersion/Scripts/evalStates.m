function [handles] = evalStates(states, statesRef, files)
%EVALSTATES Compare the state classification results with targets. 
%
% This function will ~~calculate the error rates of states compared to
% statesRef~~ plot the classification confusion matrices for the states
% compared to statesRef.
%
% The inputs for states are structures defined in
% ../../NaiveTrain/StatesByDistExpertSystem/genStatesByDist.m. And files is
% the variable holding corresponding GPS data, which is a structure defined
% in ../../loadGpsDat.m.
%
% The output will be ~~a structure holding relative results with meaningful
% field names~~ a cell array holding all plots generated.
%
% Yaguang Zhang, Purdue, 12/06/2016

handles = {};

numTracks = length(files);
assert(length(states) == numTracks);
assert(length(statesRef) == numTracks);

%% Make Sure All Inputs Are of the Same Number of Samples
for idxFile = 1:length(files)
   [numSamsState, ~] = size(states{idxFile});
   [numSamsStateRef, ~] = size(statesRef{idxFile});
   numSamsFile = length(files(idxFile).accuracy);
   expectedNumSams = min([numSamsState; numSamsStateRef; numSamsFile]);
   if ~all([numSamsState,numSamsStateRef,numSamsFile]==expectedNumSams)
       states{idxFile} = states{idxFile}(expectedNumSams,:);
       statesRef{idxFile} = statesRef{idxFile}(expectedNumSams,:);
       files(idxFile) = subFile(files(idxFile), 1, expectedNumSams);
   end
end

%% Is Harvesting Or Not for Combines

disp('-----------------------');
disp('Plotting the confusion matrix for Harvesting...');

% All samples for combines are relevant.
isCombine = strcmp({files.type}, 'Combine');

harvestingTargets = cellfun(@(x)x(:,1)==0, statesRef(isCombine), 'UniformOutput', false);
harvestingTargets = vertcat(harvestingTargets{:});
harvestingTargets = [~harvestingTargets, harvestingTargets]';

harvestingOutputs = cellfun(@(x)x(:,1)==0, states(isCombine), 'UniformOutput', false);
harvestingOutputs = vertcat(harvestingOutputs{:});
harvestingOutputs = [~harvestingOutputs, harvestingOutputs]';

handles{end+1} = figure;
plotconfusion(harvestingTargets, harvestingOutputs, ...
    'Harvesting (Yes Or No for Combines)');
set(gca, 'xticklabel',{'no', 'yes', ''});
set(gca, 'yticklabel',{'no', 'yes', ''});

% errorRates.harvesting.numSamples = 0;
% errorRates.harvesting.falsePositiveSampleNum = 0;
% errorRates.harvesting.falsePositiveRate = 1;
% errorRates.harvesting.falseNegativeSampleNum = 0;
% errorRates.harvesting.falseNegativeRate = 1;
% 
% % All samples for combines are relevant.
% isCombine = strcmp({files.type}, 'Combine');
% errorRates.harvesting.numSamples = sum(cellfun(@(x)size(x,1), states(isCombine)));

disp('Done!');
disp('-----------------------');

%% Unloading - V1

disp('-----------------------');
disp('Plotting the confusion matrix for Unloading...');

% All samples for combines and grain carts are relevant.
isCombineOrKart = strcmp({files.type}, 'Combine') | strcmp({files.type}, 'Grain Kart');

% We will use two groups, "unloading with correct label for the receipient"
% and not so, for the confusion matrix. That is, we will compare the
% outputs with the targets, and treat them as correct results only when the
% "unload to" label is exactly the same as that in the corresponding
% target.
unloadingTargets = cellfun(@(x)x(:,2)>0, statesRef(isCombineOrKart), 'UniformOutput', false);
unloadingTargets = vertcat(unloadingTargets{:});
unloadingTargets = [~unloadingTargets, unloadingTargets]';

unloadingOutputs = cellfun(@(x,y)x(:,2)==y(:,2), states(isCombineOrKart), statesRef(isCombineOrKart), 'UniformOutput', false);
unloadingOutputs = vertcat(unloadingOutputs{:});
unloadingOutputs = [~unloadingOutputs, unloadingOutputs]';

handles{end+1} = figure;
plotconfusion(unloadingTargets, unloadingOutputs, ...
    'Unloading (Correct Or No for Combines and Carts)');
set(gca, 'xticklabel',{'not unloading', 'unloading', ''});
set(gca, 'yticklabel',{'not unloading or unloading with wrong labels', 'unloading with correct labels', ''});

disp('Done!');
disp('-----------------------');

%% Unloading - V2

disp('-----------------------');
disp('Plotting the confusion matrix for Unloading (Improved)...');

% All samples for combines and grain carts are relevant.
isCombineOrKart = strcmp({files.type}, 'Combine') | strcmp({files.type}, 'Grain Kart');

% We will use 3 groups, "unloading with correct label for the receipient",
% not so (i.e. "unloading with wrong label for the receipient"), and "not unloading", for the confusion matrix. 
unloadingTargets = cellfun(@(x)x(:,2)>0, statesRef(isCombineOrKart), 'UniformOutput', false);
unloadingTargets = vertcat(unloadingTargets{:});
unloadingTargets = [~unloadingTargets, unloadingTargets, false(length(unloadingTargets),1)]';

notUnloadingOutputs = cellfun(@(x)isnan(x(:,2)), states(isCombineOrKart), 'UniformOutput', false);
notUnloadingOutputs = vertcat(notUnloadingOutputs{:});
unloadingCorrectOutputs = cellfun(@(x,y)x(:,2)==y(:,2), states(isCombineOrKart), statesRef(isCombineOrKart), 'UniformOutput', false);
unloadingCorrectOutputs = vertcat(unloadingCorrectOutputs{:});
unloadingWrongOutputs = cellfun(@(x,y)(x(:,2)>0&x(:,2)~=y(:,2)), states(isCombineOrKart), statesRef(isCombineOrKart), 'UniformOutput', false);
unloadingWrongOutputs = vertcat(unloadingWrongOutputs{:});
unloadingOutputs = [notUnloadingOutputs, unloadingCorrectOutputs, unloadingWrongOutputs]';

handles{end+1} = figure;
plotconfusion(unloadingTargets, unloadingOutputs, ...
    'Unloading (Not, Correct Or Wrong for Combines and Carts)');
set(gca, 'xticklabel',{'not unloading', 'unloading', '-', ''});
set(gca, 'yticklabel',{'not unloading', 'unloading (correct)', 'unloading (wrong)', ''});

disp('Done!');
disp('-----------------------');
% EOF