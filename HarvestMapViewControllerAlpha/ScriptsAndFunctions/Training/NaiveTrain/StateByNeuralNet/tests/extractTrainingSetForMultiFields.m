%EXTRACTTRAININGSETFORMULTIFIELDS Extract the GPS and statesRef data as the
%training set for the alpha-version neural network.
%
% The training data set will be saved as a structure with fields inputs and
% targets, into the file extractTraningSetForMultiField_results.mat under
% current folder.
%
% Yaguang Zhang, Purdue, 07/26/2017

cd(fileparts(which(mfilename)));

% Only try to generate inputs, targets and metaData when they are not
% available in the current workspace.
if ~(exist('inputs', 'var') && exist('targets', 'var') && exist('metaDatas', 'var'))
    % Only load the GPS data when they are not available in the current
    % workspace.
    if ~(exist('files', 'var') && exist('statesRef', 'var'))
        % Load files and statesRef via collectorForStates.m.
        cd(fullfile(fileparts(which(mfilename)), '..', '..', '..'));
        cd('StateClassificationEvaluationScriptVersion');
        collectorForStates;
        
        cd(fullfile('Training','NaiveTrain','StateByNeuralNet','tests'));
    end
    
    % Parameters used.
    gpsTimeRanges = [files(1).gpsTime(1), files(1).gpsTime(end); 
        files(12).gpsTime(1), files(12).gpsTime(end);
        files(17).gpsTime(1), files(23).gpsTime(end);
        files(28).gpsTime(1), files(27).gpsTime(end);
        files(42).gpsTime(1), files(42).gpsTime(end);
        files(45).gpsTime(1), files(50).gpsTime(end)]; % 2015_manuallyLabeled
    % We will randomize the order for which these fields show up.
    [numAvailabeFields, ~] = size(gpsTimeRanges);
    gpsTimeRanges = gpsTimeRanges(randperm(numAvailabeFields),:);
    
    FILENAME = 'extractTraningSetForMultiField_results.mat';
    if exist(FILENAME, 'file')
        load(FILENAME);
    else
        [numRanges, ~] = size(gpsTimeRanges);
        [inputs, targets] = deal([]);
        metaDatas = {};
        for idxGpsTimeRange = 1:numRanges
            gpsTimeRange = gpsTimeRanges(idxGpsTimeRange,:);
            % Extract the data set.
            [ inputsNew, targetsNew, metaDataNew ] = ...
                extractInputFromFilesByGpsTimeRange(files, ...
                fileIndicesSortedByStartRecordingGpsTime, ...
                fileIndicesSortedByEndRecordingGpsTime, statesRef, gpsTimeRange);
            inputs = [inputs, inputsNew];
            targets = [targets, targetsNew];
            metaDatas{end+1} = metaDataNew;
        end
        
        % Save the results
        save(FILENAME, 'inputs', 'targets', 'metaDatas');
    end
end

% EOF