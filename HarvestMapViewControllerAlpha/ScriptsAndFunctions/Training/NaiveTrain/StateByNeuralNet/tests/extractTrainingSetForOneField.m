%EXTRACTTRAININGSETFORONEFIELD Extract the GPS and statesRef data as the
%training set for the alpha-version neural network.
%
% The training data set will be saved as a structure with fields inputs and
% targets, into the file extractTraningSetForOneField_results.mat under
% current folder.
%
% Yaguang Zhang, Purdue, 11/28/2016

cd(fileparts(which(mfilename)));

% Only try to generate inputs, targets and metaData when they are not
% available in the current workspace.
if ~(exist('inputs', 'var') && exist('targets', 'var') && exist('metaData', 'var'))
    % Only load the GPS data when they are not available in the current
    % workspace.
    if ~(exist('files', 'var') && exist('statesRef', 'var'))
        % Load files and statesRef via collectorForStates.m.
        cd(fullfile((which(mfilename)),'..', '..', '..', '..'));
        cd('StateClassificationEvalucationScriptVersion');
        collectorForStates;
        
        cd(fullfile('Training','NaiveTrain','StateByNeuralNet','tests'));
    end
    
    % Parameters used.
    % gpsTimeRange = [files(77).gpsTime(1), files(41).gpsTime(end)]; % 2015
    gpsTimeRange = [files(1).gpsTime(1), files(1).gpsTime(end)]; % 2015_manuallyLabeled
    
    % Extract the data set.
    [ inputs, targets, metaData ] = ...
        extractInputFromFilesByGpsTimeRange(files, ...
        fileIndicesSortedByStartRecordingGpsTime, ...
        fileIndicesSortedByEndRecordingGpsTime, statesRef, gpsTimeRange);
    
    % Save the results
    FILENAME = 'extractTraningSetForOneField_results.mat';
    save(FILENAME, 'inputs', 'targets', 'metaData');
end

% EOF