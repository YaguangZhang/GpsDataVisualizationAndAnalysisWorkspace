%SPLITDATASETTOFIELDS Extract the GPS and statesRef data as the training
%set for neural network, with data for different fields separately stored.
%
% The training data set will be saved as a structure array with fields
% inputs and targets, into the file splitDataSetToFields_results.mat under
% current folder.
%
% Yaguang Zhang, Purdue, 07/23/2018

% We will follow the procedure for feedforwardTestMultiFields.m to split
% the data set.

cd(fileparts(which(mfilename)));

% Only try to generate inputs, targets and metaData when they are not
% available in the current workspace.
if ~(exist('alphaNeuralNetDataForFields', 'var'))
    
    disp(' ');
    disp('    Preparing to split data set ...')
    
    % Only load the GPS data when they are not available in the current
    % workspace.
    if ~(exist('files', 'var') && exist('statesRef', 'var'))
        % Load files and statesRef via collectorForStates.m.
        cd(fullfile(fileparts(which(mfilename)), '..', '..'));
        cd('StateClassificationEvaluationScriptVersion');
        collectorForStates;
        
        cd(fullfile('Training','NaiveTrain','StateByNeuralNet'));
    end
    
    cd('tests');
    
    % Parameters used. The manually labeled 2015 data set is devided into 6
    % field groups according to continuous operations revealed by the state
    % collector GUI.
    gpsTimeRanges = [files(1).gpsTime(1), files(1).gpsTime(end);
        files(12).gpsTime(1), files(12).gpsTime(end);
        files(17).gpsTime(1), files(23).gpsTime(end);
        files(28).gpsTime(1), files(27).gpsTime(end);
        files(42).gpsTime(1), files(42).gpsTime(end);
        files(45).gpsTime(1), files(50).gpsTime(end)]; % 2015_manuallyLabeled
    % We will randomize the order for which these fields show up.
    [numAvailabeFields, ~] = size(gpsTimeRanges);
    gpsTimeRanges = gpsTimeRanges(randperm(numAvailabeFields),:);
    [numRanges, ~] = size(gpsTimeRanges);
    
    FILENAME = fullfile('..', 'splitDataSetToFields_results.mat');
    if exist(FILENAME, 'file')
        disp(' ');
        disp('    splitDataSetToFields_results.mat is detected ...');
        disp('    Loading results ...');
        load(FILENAME);
    else
        % The struct array we will generate.
        [inputs, targets, metaDatas] = deal(cell(numRanges, 1));
        
        for idxGpsTimeRange = 1:numRanges
            disp(['    Processing field ', ...
                num2str(idxGpsTimeRange), '/', num2str(numRanges)])
            
            gpsTimeRange = gpsTimeRanges(idxGpsTimeRange,:);
            % Extract the data set.
            [ inputsNew, targetsNew, metaDataNew ] = ...
                extractInputFromFilesByGpsTimeRange(files, ...
                fileIndicesSortedByStartRecordingGpsTime, ...
                fileIndicesSortedByEndRecordingGpsTime, ...
                statesRef, gpsTimeRange);
            inputs{idxGpsTimeRange} = inputsNew;
            targets{idxGpsTimeRange} = targetsNew;
            metaDatas{idxGpsTimeRange} = metaDataNew;
        end
        
        % Translate all the GPS (lat, lon) together, so that the first
        % sample in inputs will be (0,0).
        inputsTranslated = inputs;
        for idxFieldGroup = 1:length(inputs)
            [~, numSamps] = size(inputs{idxFieldGroup});
            for idxSamp = 1:numSamps
                % Find the first non-zero (lat, lon) pair in this sample.
                for idxVeh = 1:5
                    idxOffset = 183*(idxVeh-1);
                    firstVehLats = inputs{idxFieldGroup}((1:61)+idxOffset,idxSamp);
                    firstVehLons = inputs{idxFieldGroup}((62:122)+idxOffset,idxSamp);
                    idxFirstNonZeroLat = find(firstVehLats~=0, 1);
                    idxFirstNonZeroLon = find(firstVehLons~=0, 1);
                    if ~isempty(idxFirstNonZeroLat)
                        deltaLat = firstVehLats(idxFirstNonZeroLat);
                        deltaLon = firstVehLats(idxFirstNonZeroLon);
                        break
                    end
                end
                assert(idxFirstNonZeroLat==idxFirstNonZeroLon, ...
                    'The indices for the first non-zero lat & lon should match!');
                
                for idxVeh = 1:5
                    idxOffset = 183*(idxVeh-1);
                    indicesCurVehLat = (1:61)+idxOffset;
                    indicesCurVehLon = (62:122)+idxOffset;
                    
                    indicesCurVehLatLon ...
                        = [indicesCurVehLat indicesCurVehLon];
                    
                    boolsZeroLatLons = ...
                        inputsTranslated{idxFieldGroup}(indicesCurVehLatLon)==0;
                    
                    inputsTranslated{idxFieldGroup}(indicesCurVehLat) = ...
                        inputsTranslated{idxFieldGroup}(indicesCurVehLat) ...
                        -deltaLat;
                    inputsTranslated{idxFieldGroup}(indicesCurVehLon) = ...
                        inputsTranslated{idxFieldGroup}(indicesCurVehLon) ...
                        -deltaLon;
                    
                    inputsTranslated{idxFieldGroup}(boolsZeroLatLons) = nan;
                end
            end
        end
        
        alphaNeuralNetDataForFields.inputs = inputs;
        alphaNeuralNetDataForFields.inputsTranslated = inputsTranslated;
        alphaNeuralNetDataForFields.targets = targets;
        alphaNeuralNetDataForFields.metaDatas = metaDatas;
        
        disp(' ');
        disp('    Saving results ...');
        % Save the results
        save(FILENAME, 'alphaNeuralNetDataForFields', '-v7.3');
    end
    
    % Plot GPS samples for each field.
    disp(' ');
    disp('    Plotting fields separately ...')
    
    for idxField = 1:numRanges
        hCurMap = figure; hold on;
        [ curGpsInfo ] = recoverGpsFromInput( ...
            alphaNeuralNetDataForFields.inputs{idxField});
        numCurVehs = length(curGpsInfo);
        [curLat, curLon, curSpeed] = deal([]);
        for idxVeh = 1:numCurVehs
            curLat = [curLat; curGpsInfo(idxVeh).lat];
            curLon = [curLon; curGpsInfo(idxVeh).lon];
            curSpeed = [curSpeed; curGpsInfo(idxVeh).speed];
        end
        plot3k([curLon, curLat, curSpeed]);
        view(2);
        plot_google_map('MapType', 'satellite');
        % The command plot_google_map messes up the color legend of plot3k,
        % so we will have to fix it here.
        hCb = findall( allchild(gcf), 'type', 'colorbar');
        hCb.Ticks = linspace(1,length(colormap)+1,length(hCb.TickLabels));
        set(gca,'xTick',[],'xTickLabel',[],'yTick',[],'yTickLabel',[]);
        title('Speed (m/s) on Map');
        
        saveas(hCurMap, fullfile('..', ...
            ['fieldGroup_', num2str(idxField), '.png']));
    end
else
    disp(' ');
    disp('    alphaNeuralNetDataForFields is detected in current workspace ...');
    disp('    Exiting ...');
end

disp(' ');
disp('Done!')

% EOF