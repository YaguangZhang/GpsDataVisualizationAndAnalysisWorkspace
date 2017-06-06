% TRIAL0_STATSMANUALLYMODSTATELABELS Trial 0 - Estimate the amount of
% statesByDist labels that has been modified manually to generate
% statesRef.
%
% Yaguang Zhang, Purdue, 05/15/2017

% Load data and set the current Matlab directory.
cd(fileparts(mfilename('fullpath')));
prepareTrial;
cd(fileparts(mfilename('fullpath')));

% Overall.
numSamples = sum(cellfun(@(x) length(x), statesRefSetFlag));
numModSamples = sum(cellfun(@(x) sum(x), statesRefSetFlag));
ratioModSam = numModSamples/numSamples;

% For combines.
numSamplesC = sum(cellfun(@(x) length(x), ...
    statesRefSetFlag(fileIndicesCombines)));
numModSamplesC = sum(cellfun(@(x) sum(x), ...
    statesRefSetFlag(fileIndicesCombines)));
ratioModSamC = numModSamplesC/numSamplesC;

% For grain carts.
numSamplesK = sum(cellfun(@(x) length(x), ...
    statesRefSetFlag(fileIndicesGrainKarts)));
numModSamplesK = sum(cellfun(@(x) sum(x), ...
    statesRefSetFlag(fileIndicesGrainKarts)));
ratioModSamK = numModSamplesK/numSamplesK;

% For trucks.
numSamplesT = sum(cellfun(@(x) length(x), ...
    statesRefSetFlag(fileIndicesTrucks)));
numModSamplesT = sum(cellfun(@(x) sum(x), ...
    statesRefSetFlag(fileIndicesTrucks)));
ratioModSamT = numModSamplesT/numSamplesT;

% Record the results.
fileID = fopen('Trial0_Results.txt','w');
fprintf(fileID,'Overall:          \n');
fprintf(fileID,'    numSamples:   %d\n', numSamples);
fprintf(fileID,'    ratioModSam:  %6.2f %s\n', ratioModSam*100, '%');
fprintf(fileID,'For combines:     \n');
fprintf(fileID,'    numSamplesC:   %d\n', numSamplesC);
fprintf(fileID,'    ratioModSamC:  %6.2f %s\n', ratioModSamC*100, '%');
fprintf(fileID,'For grain carts:  \n');
fprintf(fileID,'    numSamplesK:   %d\n', numSamplesK);
fprintf(fileID,'    ratioModSamK:  %6.2f %s\n', ratioModSamK*100, '%');
fprintf(fileID,'For trucks:       \n');
fprintf(fileID,'    numSamplesT:   %d\n', numSamplesT);
fprintf(fileID,'    ratioModSamT:  %6.2f %s\n', ratioModSamT*100, '%');
fclose(fileID);
% EOF