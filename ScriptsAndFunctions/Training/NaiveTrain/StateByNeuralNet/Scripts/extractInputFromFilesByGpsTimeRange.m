function [ extractedInputs, extractedTargets, metaData ] = ...
    extractInputFromFilesByGpsTimeRange(files, ...
    fileIndicesSortedByStartRecordingGpsTime, ...
    fileIndicesSortedByEndRecordingGpsTime, statesRef, gpsTimeRange)
%EXTRACTINPUTFROMFILESBYGPSTIMERANGE Extract the input for the neural
%from the GPS data files and the GPS time range specified.
%
% This function will search the nearest vehicle in vehFiles.
%
% This function will generate the input matrix needed for exploring the
% possibility of using neural networks for state classification. It will
% sample the GPS data with 1Hz frequency and get the neareat close-enough
% GPS points.
%
% Inputs:
%
%   - files, fileIndicesSortedByStartRecordingGpsTime,
%   fileIndicesSortedByEndRecordingGpsTime
%     Relevant vehicles information loaded from the CKT GPS log files. See
%     loadGpsData.mat for more information.
%
%   - statesRef
%     The reference file for the state classificaiton. See
%     collectorForStates.m for more information.
%
%   - gpsTimeRange
%     [gpsTimeStart, gpsTimeEnd] in millisecond. All GPS data between (and
%     including) these two time points will be extracted.
%
% Outputs:
%
%   - extractedInputs
%     The GPS data extracted used as the inputs to the neural network. For
%     this version, it is a matrix with each column being a sample. Each
%     sample will have lat, lon and speed for two combines, one grain cart,
%     and two trucks (an error will occur if more vehicles show up and
%     TODO: these numbers may be adjustable in the future versions). NaN
%     will be filled for data not available. The length for each sample
%     will be determined by pastLen and futureLen.
%
%   - extractedTargets
%     The targets extracted. For this version, it is a boolean matrix with
%     10 rows (C1 Har, C1 to K, C1 to T1, C1 to T2, C2 Har, C2 to K, C2 to
%     T1, C2 to T2, K to T1, K to T2).
%
%   - metaData
%     The information for the data set extraced. This is a cell array with
%     each member representing one vechile. And the vehicle type, id,
%     and indices for trackes used are recorded.
%
% Yaguang Zhang, Purdue, 11/28/2016

%% Some adjustable parameters.

% How many GPS points (or time in second) to record into each sample before
% and after the time for that sample, respectively.
pastLen = 30;
futureLen = 30;
% How many different vehicles are allowed (default: 2, 1, 2). 
numComs = 2;
numKarts = 1;
numTrucks = 2;
% The maximum time difference (in second) allowed for the time sychronization.
maxTimeDiffAllowed = 1.5;

%% Get tracks by the GPS time range.

% C1, C2, K, T1, T2 (by default).
indicesForVehiclesOfInterest = cell(5,1);
gpsDataForVehiclesOfInterest = cell(5,1);
statesRefForVehiclesOfInterest = cell(5,1);
% Also, for the metadata output.
metaData = cell(5,1);

% % Only consider the tracks completely within the time range specified. 
% indicesFilesNeeded = intersect(fileIndicesSortedByStartRecordingGpsTime(fileIndicesSortedByStartRecordingGpsTime(:,2)>=gpsTimeRange(1),1), ...
%     fileIndicesSortedByEndRecordingGpsTime(fileIndicesSortedByEndRecordingGpsTime(:,2)<=gpsTimeRange(2),1));

% First find all tracks which intersect with the GPS time range specified.
indicesFilesNeeded = intersect(fileIndicesSortedByStartRecordingGpsTime(fileIndicesSortedByStartRecordingGpsTime(:,2)<=gpsTimeRange(2),1), ...
    fileIndicesSortedByEndRecordingGpsTime(fileIndicesSortedByEndRecordingGpsTime(:,2)>=gpsTimeRange(1),1));

for idxFileNeeded = indicesFilesNeeded'
    if strcmp(files(idxFileNeeded).type, 'Combine')
        flagTooManyComs = true;
        for idxCom = 1:numComs
            if isempty(gpsDataForVehiclesOfInterest{idxCom})
                indicesForVehiclesOfInterest{idxCom}(end+1) = idxFileNeeded;
                gpsDataForVehiclesOfInterest{idxCom} = files(idxFileNeeded);
                statesRefForVehiclesOfInterest{idxCom} = statesRef{idxFileNeeded};
                flagTooManyComs = false;
                
                metaData{idxCom}.type = files(idxFileNeeded).type;
                metaData{idxCom}.id = files(idxFileNeeded).id;
                
                break;
            elseif (strcmp(gpsDataForVehiclesOfInterest{idxCom}.type, files(idxFileNeeded).type) && ...
                    strcmp(gpsDataForVehiclesOfInterest{idxCom}.id, files(idxFileNeeded).id))
                indicesForVehiclesOfInterest{idxCom}(end+1) = idxFileNeeded;
                [gpsDataForVehiclesOfInterest{idxCom}, ...
                    statesRefForVehiclesOfInterest{idxCom}] = ...
                    concatenateFiles(...
                    gpsDataForVehiclesOfInterest{idxCom}, ...
                    files(idxFileNeeded), ...
                    statesRefForVehiclesOfInterest{idxCom}, ...
                    statesRef{idxFileNeeded} ...
                    );
                flagTooManyComs = false;
                break;
            end
        end
        if flagTooManyComs
            error('Too many combines!')
        end
    elseif strcmp(files(idxFileNeeded).type, 'Grain Kart')
        flagTooManyKarts = true;
        for idxKart = (1:numKarts)+numComs
            if isempty(gpsDataForVehiclesOfInterest{idxKart})
                indicesForVehiclesOfInterest{idxKart}(end+1) = idxFileNeeded;
                gpsDataForVehiclesOfInterest{idxKart} = files(idxFileNeeded);
                statesRefForVehiclesOfInterest{idxKart} = statesRef{idxFileNeeded};
                flagTooManyKarts = false;
                
                metaData{idxKart}.type = files(idxFileNeeded).type;
                metaData{idxKart}.id = files(idxFileNeeded).id;
                
                break;
            elseif (strcmp(gpsDataForVehiclesOfInterest{idxKart}.type, files(idxFileNeeded).type) && ...
                    strcmp(gpsDataForVehiclesOfInterest{idxKart}.id, files(idxFileNeeded).id))
                indicesForVehiclesOfInterest{idxKart}(end+1) = idxFileNeeded;
                [gpsDataForVehiclesOfInterest{idxKart}, ...
                    statesRefForVehiclesOfInterest{idxKart}] = ...
                    concatenateFiles(...
                    gpsDataForVehiclesOfInterest{idxKart}, ...
                    files(idxFileNeeded), ...
                    statesRefForVehiclesOfInterest{idxKart}, ...
                    statesRef{idxFileNeeded} ...
                    );
                flagTooManyKarts = false;
                break;
            end
        end
        if flagTooManyKarts
            error('Too many grain karts!')
        end
    elseif strcmp(files(idxFileNeeded).type, 'Truck')
        flagTooManyTrucks = true;
        for idxTruck = (1:numTrucks)+numComs+numKarts
            if isempty(gpsDataForVehiclesOfInterest{idxTruck})
                indicesForVehiclesOfInterest{idxTruck}(end+1) = idxFileNeeded;
                gpsDataForVehiclesOfInterest{idxTruck} = files(idxFileNeeded);
                statesRefForVehiclesOfInterest{idxTruck} = statesRef{idxFileNeeded};
                flagTooManyTrucks = false;

                metaData{idxTruck}.type = files(idxFileNeeded).type;
                metaData{idxTruck}.id = files(idxFileNeeded).id;
                
                break;
            elseif (strcmp(gpsDataForVehiclesOfInterest{idxTruck}.type, files(idxFileNeeded).type) && ...
                    strcmp(gpsDataForVehiclesOfInterest{idxTruck}.id, files(idxFileNeeded).id))
                indicesForVehiclesOfInterest{idxTruck}(end+1) = idxFileNeeded;
                [gpsDataForVehiclesOfInterest{idxTruck}, ...
                    statesRefForVehiclesOfInterest{idxTruck}] = ...
                    concatenateFiles(...
                    gpsDataForVehiclesOfInterest{idxTruck}, ...
                    files(idxFileNeeded), ...
                    statesRefForVehiclesOfInterest{idxTruck}, ...
                    statesRef{idxFileNeeded} ...
                    );
                flagTooManyTrucks = false;
                break;
            end
        end
        if flagTooManyTrucks
            error('Too many trucks!')
        end
    end
end

%% Time sychronization.
% Now we can just work on gpsDataForVehiclesOfInterest and
% statesRefForVehiclesOfInterest.

% Number of samples needed for the GPS time range specified. Note that we
% also need the GPS points in the past and future as specified.
sampleGpsTimes = (gpsTimeRange(1)-1000*pastLen):1000:(gpsTimeRange(2)+1000*futureLen);
numSampleGroups = length(sampleGpsTimes);

% We will save the synchronized data into two matrics.

% Lat, lon and speed for all vehicles of interest. We use a matrix here for
% convenience. Each column is the samples for one time point.
synchedGpsSamples = nan(3*length(gpsDataForVehiclesOfInterest), numSampleGroups);
% The corresponding states for those samples. 
synchedStatesRef = cell(5,1);
% Note we will now store the states into column vectors, i.e. [from; to].
[synchedStatesRef{:}] = deal(nan(2, numSampleGroups));

% For each time point, get the GPS information for all the vehicles of
% interest.
for idxCurGpsTime = 1:numSampleGroups
    currentGpsTime = sampleGpsTimes(idxCurGpsTime);
    
    for idxVehicle = 1:length(gpsDataForVehiclesOfInterest)
        if ~isempty(gpsDataForVehiclesOfInterest{idxVehicle})
            indexTentativeSample = find(...
                gpsDataForVehiclesOfInterest{idxVehicle}.gpsTime >= currentGpsTime, ...
                1, 'first');
            gpsTimeDiffTentative = ...
                gpsDataForVehiclesOfInterest{idxVehicle}.gpsTime(indexTentativeSample) ...
                - currentGpsTime;

            if indexTentativeSample > 1
                % Need to check the adjacent sample, too.
                gpsTimeDiffTentativeNew = currentGpsTime ...
                    - gpsDataForVehiclesOfInterest{idxVehicle}.gpsTime(indexTentativeSample-1);
                if  gpsTimeDiffTentativeNew < gpsTimeDiffTentative
                    indexTentativeSample = indexTentativeSample-1;
                    gpsTimeDiffTentative = gpsTimeDiffTentativeNew;
                end
            end

            % This is the current sample if the GPS time difference is small
            % enough.
            if gpsTimeDiffTentative <= maxTimeDiffAllowed * 1000
                synchedGpsSamples((idxVehicle*3-2):(idxVehicle*3),idxCurGpsTime) = ...
                    [gpsDataForVehiclesOfInterest{idxVehicle}.lat(indexTentativeSample); ...
                    gpsDataForVehiclesOfInterest{idxVehicle}.lon(indexTentativeSample); ...
                    gpsDataForVehiclesOfInterest{idxVehicle}.speed(indexTentativeSample)];
                synchedStatesRef{idxVehicle}(:,idxCurGpsTime) = ...
                    statesRefForVehiclesOfInterest{idxVehicle}(indexTentativeSample,:)';
            end
        end
    end
end

%% Final outputs.

% Corresponding output structure.
duplicatedRowIndices = repmat(1:15,(pastLen+futureLen+1),1);
duplicatedRowIndices = duplicatedRowIndices(:);
extractedInputs = synchedGpsSamples(duplicatedRowIndices,:); % Lat, lon and speed.

% Circular shift.
extractedInputs = circshift_columns(extractedInputs', repmat((pastLen+futureLen):-1:0,1,15))';
extractedInputs = extractedInputs(:,(pastLen+1):(end-futureLen));

% Change NaNs to zeros.
extractedInputs(isnan(extractedInputs)) = 0;

% The target part needs some tranformation.
extractedTargets = zeros(10, numSampleGroups);
% Target 1: C1 harv.
extractedTargets(1,:) = synchedStatesRef{1}(1,:)==0;
% Target 2: C1 to K.
extractedTargets(2,:) = ismember(synchedStatesRef{1}(2,:),indicesForVehiclesOfInterest{3});
% Target 3: C1 to T1.
extractedTargets(3,:) = ismember(synchedStatesRef{1}(2,:),indicesForVehiclesOfInterest{4});
% Target 4: C1 to T2.
extractedTargets(4,:) = ismember(synchedStatesRef{1}(2,:),indicesForVehiclesOfInterest{5});
% Target 5: C2 harv.
extractedTargets(5,:) = synchedStatesRef{2}(1,:)==0;
% Target 6: C2 to K.
extractedTargets(6,:) = ismember(synchedStatesRef{2}(2,:),indicesForVehiclesOfInterest{3});
% Target 7: C2 to T1.
extractedTargets(7,:) = ismember(synchedStatesRef{2}(2,:),indicesForVehiclesOfInterest{4});
% Target 8: C2 to T2.
extractedTargets(8,:) = ismember(synchedStatesRef{2}(2,:),indicesForVehiclesOfInterest{5});
% Target 9: K to T1.
extractedTargets(9,:) = ismember(synchedStatesRef{3}(2,:),indicesForVehiclesOfInterest{4});
% Target 10: K to T2.
extractedTargets(10,:) = ismember(synchedStatesRef{3}(2,:),indicesForVehiclesOfInterest{5});

% Discard the extra samples (in the past and in the future).
extractedTargets = extractedTargets(:,(pastLen+1):(end-futureLen));

% Check the dimentions of the outputs. 
assert(all(size(extractedInputs)==[3*(pastLen+1+futureLen)*length(gpsDataForVehiclesOfInterest), numSampleGroups-pastLen-futureLen]));
assert(all(size(extractedTargets)==[10, numSampleGroups-pastLen-futureLen]));

% Output the metadata for indices recorded.
for idxVeh = 1:length(indicesForVehiclesOfInterest)
    if ~isempty(indicesForVehiclesOfInterest{idxVeh})
        metaData{idxVeh}.tracks = indicesForVehiclesOfInterest{idxVeh};
    end
end

end

% EOF