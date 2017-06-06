% LABELLOCATIONSFORCOMBINES Carry out the infield classificaiton test for
% combines.
%
% This script will use the naive infield classification algorithm developed
% in testInFieldClassification.m. It can be used for other types of
% vehicles, too, which can be set by the variable "type".
%
% Update 04/10/2015: compute and save alpashapes. This requires Matlab
% 2014b or later to work.
%
% Yaguang Zhang, Purdue, 03/19/2015

% The variable "type" can be set before running this script to use this
% algorithm for other types of vehicle.
if ~exist('type', 'var')
    type = 'Combine';
end

% This is the density in ms/m^2 for a inline route with a rather low speed.
% 1000/SQUARE_SIDE_LENGTH for route 2.
THRESHOLD_REALLY_LOW_DENSITY = 1000/SQUARE_SIDE_LENGTH;

% Load parameters set for the infield test of combines.
inFieldClassificationForCombinesParameters;

% Prevent any figure from being generate by the scripts used.
MAP = false;

% Used for hints.
counterCombine = 0;
% This is for the cases where this algorithm is used for other types of
% vehicle.
switch type
    case 'Combine'
        totalNumCombines = length(fileIndicesCombines);
    case 'Grain Kart'
        totalNumCombines = length(fileIndicesGrainKarts);
    case 'Truck'
        totalNumCombines = length(fileIndicesTrucks);
    otherwise
        error('Unknow vehicle type!')
end
for indexFile = 1:1:length(files)
    
    if strcmp(files(indexFile).type, type)
        %% Load data.
        
        counterCombine = counterCombine+1;
        % Hints for the user.
        disp(strcat(num2str(counterCombine),'/',num2str(totalNumCombines), 23, 23, ...
            '(Counter for "', type, ...
            '" / Total Number of "', type, '")'));
        
        lati = files(indexFile).lat;
        long = files(indexFile).lon;
        spee = files(indexFile).speed;
        time = files(indexFile).gpsTime;
        %         bear = files(indexFile).bearing;
        dens = devIndSampleDensities{indexFile};
        
        % According to testLatAndSpeedLength.m, files(50) misses a speed
        % sample. We need to discard the last sample if it's incomplete.
        if length(lati)~=length(spee)
            endIdx = min(length(lati),length(spee));
            lati = lati(1:endIdx);
            long = long(1:endIdx);
            spee = spee(1:endIdx);
            dens = dens(1:endIdx);
        end
        
        
        %% Gap filling (On the road testing)
        
        % Location labels: -100 (on the road) to 0 (in the field).
        location = zeros(length(lati),1);
        
        % Rule 0: ONROAD_SPEED_BOUND m/s bound + gap filling. This will
        % always be used.
        location(spee>= ONROAD_SPEED_BOUND) = -100;
        
        diffidx3D4msNa = diff([0;location;0]);
        indices4msRoadSequenceStart = find(diffidx3D4msNa==-100); % start
        indices4msRoadSequenceEnd = find(diffidx3D4msNa==100)-1; % end
        
        % Get rid of singular points (the vehicle may be on the road if it
        % runs at ONROAD_SPEED_BOUND m/s for only one sample). Also, we
        % need at least 2 point to fit a line.
        indicesSickPoints = (indices4msRoadSequenceStart==indices4msRoadSequenceEnd);
        indices4msRoadSequenceStart(indicesSickPoints) = [];
        indices4msRoadSequenceEnd(indicesSickPoints) = [];
        location(indicesSickPoints) = 0;
        
        % Fill gaps which last less than the time bound using -95.
        if ~isempty(indices4msRoadSequenceStart)
            % Use GAP_FILLING_TIME_THRESHOLD/2 as a bound to fill the start
            % if necessary.
            if indices4msRoadSequenceStart(1)>1
                timeBeforeRoadSeqs = ...
                    time(indices4msRoadSequenceStart(1)-1) - time(1);
                if timeBeforeRoadSeqs <= GAP_FILLING_TIME_THRESHOLD / 2
                    % Gap filling.
                    location(1:(indices4msRoadSequenceStart(1)-1)) = -95;
                end
            end
            
            % Take care of the gaps on the road.
            for indexSequence = 1:(length(indices4msRoadSequenceStart)-1)
                timeBetweenSeqs = ...
                    time(indices4msRoadSequenceStart(indexSequence+1)-1) - time(indices4msRoadSequenceEnd(indexSequence)+1);
                if timeBetweenSeqs <= GAP_FILLING_TIME_THRESHOLD
                    % Gap filling.
                    location((indices4msRoadSequenceEnd(indexSequence)+1):...
                        (indices4msRoadSequenceStart(indexSequence+1)-1)) = -95;
                end
            end
            
            % Also, use GAP_FILLING_TIME_THRESHOLD/2 as a bound to fill the
            % end if necessary.
            if indices4msRoadSequenceEnd(end)<length(location)
                timeBeforeRoadSeqs = ...
                    time(end)- time(indices4msRoadSequenceEnd(end)+1);
                if timeBeforeRoadSeqs <= GAP_FILLING_TIME_THRESHOLD / 2
                    % Gap filling.
                    location((indices4msRoadSequenceEnd(end)+1):end) = -95;
                end
            end
            
        end
        
        %% In the field testing
        % This test is based on the "on the road testing".
        
        % Quasi-colinear road extension.
        if ~isempty(indices4msRoadSequenceStart)
            % Always compute the limits for extended propatation.
            if indexSequence == 1
                indexBackwardProLimitEx = 1;
            else
                indexBackwardProLimitEx = indices4msRoadSequenceEnd(indexSequence-1)+1;
            end
            
            if indexSequence == length(indices4msRoadSequenceStart)
                indexForwardProLimitEx = length(location);
            else
                indexForwardProLimitEx = indices4msRoadSequenceStart(indexSequence+1)-1;
            end
            
            if length(indices4msRoadSequenceStart) > 1
                % Take care of the start.
                if indices4msRoadSequenceStart(1)>1
                    % Case indexSequence == 1.
                    index4msRoadSequenceStart = indices4msRoadSequenceStart(1);
                    index4msRoadSequenceEnd = indices4msRoadSequenceEnd(1);
                    
                    BACKWARD_PROPAGATION = true;
                    FORWARD_PROPAGATION = false;
                    
                    if location(index4msRoadSequenceEnd+1) == 0
                        % The forward direction isn't filled by gap
                        % filling.
                        indexForwardProLimit = indices4msRoadSequenceStart(indexSequence+1)-1;
                        FORWARD_PROPAGATION = true;
                    end
                    
                    indexBackwardProLimit = 1;
                    % Label GPS points in the same road (line) as -100;
                    inlinePropagation;
                end
                
                % Take care of the middle part.
                for indexSequence = 2:(length(indices4msRoadSequenceStart)-1)
                    
                    index4msRoadSequenceStart = indices4msRoadSequenceStart(indexSequence);
                    index4msRoadSequenceEnd = indices4msRoadSequenceEnd(indexSequence);
                    BACKWARD_PROPAGATION = false;
                    FORWARD_PROPAGATION = false;
                    
                    if location(index4msRoadSequenceStart-1) == 0
                        % The backward direction isn't filled by gap
                        % filling.
                        indexBackwardProLimit = indices4msRoadSequenceEnd(indexSequence-1)+1;
                        BACKWARD_PROPAGATION = true;
                    end
                    
                    if location(index4msRoadSequenceEnd+1) == 0
                        % The forward direction isn't filled by gap
                        % filling.
                        indexForwardProLimit = indices4msRoadSequenceStart(indexSequence+1)-1;
                        FORWARD_PROPAGATION = true;
                    end
                    
                    inlinePropagation;
                end
                
                % Take care of the end.
                if indices4msRoadSequenceEnd(end)<length(location)
                    % Case indexSequence equals to
                    % length(indices4msRoadSequenceStart).
                    index4msRoadSequenceStart = indices4msRoadSequenceStart(end);
                    index4msRoadSequenceEnd = indices4msRoadSequenceEnd(end);
                    
                    BACKWARD_PROPAGATION = false;
                    FORWARD_PROPAGATION = true;
                    
                    if location(index4msRoadSequenceStart-1) == 0
                        % The backward direction isn't filled by gap
                        % filling.
                        indexBackwardProLimit = indices4msRoadSequenceEnd(indexSequence-1)+1;
                        BACKWARD_PROPAGATION = true;
                    end
                    
                    indexForwardProLimit = length(location);
                    inlinePropagation;
                    
                else
                    % Only one sequence is found. The start is also the
                    % end.
                    index4msRoadSequenceStart = indices4msRoadSequenceStart(1);
                    index4msRoadSequenceEnd = indices4msRoadSequenceEnd(1);
                    
                    BACKWARD_PROPAGATION = true;
                    FORWARD_PROPAGATION = true;
                    
                    indexForwardProLimit = length(lati);
                    indexBackwardProLimit = 1;
                    
                    % Label GPS points in the same road (line) as -100;
                    inlinePropagation;
                end
            end
        end
        
        % RULE 6. Find the long-enough low-density colinear sequences from
        % currently zero-labeled points
        lowDensityColinearSeqProp;
        
        % Update sequences which are still not labeled (location is 0). We
        % will use the same code for finding -100 sequences before. In
        % order to do that, we need to change 0 to -100 and all other
        % labels (so far only negative ones) to 0.
        diffLocation = -100*ones(length(location),1);
        diffLocation(location<0) = 0;
        diffLocation = diff([0;diffLocation;0]);
        
        indicesUnlabeledSequenceStart = find(diffLocation==-100); % start
        indicesUnlabeledSequenceEnd = find(diffLocation==100)-1; % end
        
        if any(location<0)
            % Last check: check whether there are enough points available
            % in each "field" sequence. If not, mark those points to be
            % -30.
            indicesUnlabeledSequenceLength = ...
                indicesUnlabeledSequenceEnd-indicesUnlabeledSequenceStart;
            if any(indicesUnlabeledSequenceLength<MIN_NUM_FIELD_SEQ)
                indicesUnlabeledSequenceStartDiscarded = ...
                    indicesUnlabeledSequenceStart(indicesUnlabeledSequenceLength<MIN_NUM_FIELD_SEQ);
                indicesUnlabeledSequenceEndDiscarded = ...
                    indicesUnlabeledSequenceEnd(indicesUnlabeledSequenceLength<MIN_NUM_FIELD_SEQ);
                indicesUnlabeledSequenceStart(indicesUnlabeledSequenceLength<MIN_NUM_FIELD_SEQ)=[];
                indicesUnlabeledSequenceEnd(indicesUnlabeledSequenceLength<MIN_NUM_FIELD_SEQ)=[];
                
                % Mark these discarded points in the variable "location".
                for idxUnlabeledSequenceDiscarded = 1:length(indicesUnlabeledSequenceStartDiscarded)
                    location(...
                        indicesUnlabeledSequenceStartDiscarded(idxUnlabeledSequenceDiscarded):...
                        indicesUnlabeledSequenceEndDiscarded(idxUnlabeledSequenceDiscarded)...
                        ) = -30;
                end
            end
            
            % Also check whether the "field" is large enough. Note that
            % the length has already been checked.
            indicesFieldDeleted = [];
            for idxField = 1:length(indicesUnlabeledSequenceStart)
                indicesFieldSeq = indicesUnlabeledSequenceStart(idxField):...
                    indicesUnlabeledSequenceEnd(idxField);
                if fieldDiameter(lati(indicesFieldSeq),long(indicesFieldSeq))...
                        < MIN_FIELD_DIAMETER
                    % Not large enough.
                    location(indicesFieldSeq) = -30;
                    indicesFieldDeleted = [indicesFieldDeleted;idxField];
                end
            end
            
            indicesUnlabeledSequenceStart(indicesFieldDeleted) = [];
            indicesUnlabeledSequenceEnd(indicesFieldDeleted) = [];
        end
        
        % Save the result to locations.
        locations{indexFile} = location;
        
        %% Update 04/10/2015: compute and save alpashapes.
        
        % Compute the convex polygons which can contain all points of
        % each unlabeled sequence.
        
        for indexPolygon = 1:length(indicesUnlabeledSequenceStart)
            % X: long. Y: lati.
            longInField = long(indicesUnlabeledSequenceStart(indexPolygon):...
                indicesUnlabeledSequenceEnd(indexPolygon));
            latiInField = lati(indicesUnlabeledSequenceStart(indexPolygon):...
                indicesUnlabeledSequenceEnd(indexPolygon));
            
            % Alpha shape function is available (require 2014b or
            % newer). We'll remove duplicated coordinates first.
            uniqueCoorTemp = unique([latiInField,longInField],'rows');
            latiInField = uniqueCoorTemp(:,1);
            longInField = uniqueCoorTemp(:,2);
            
            alphaShapeTemp = alphaShape(longInField, latiInField);
            % Increase alpha a little bit to avoid unecessary small
            % holes in the field.
            alphaShapeTemp.Alpha = alphaShapeTemp.Alpha*2;
            
            if ~isempty(alphaShapeTemp)
                fieldShapes{end+1} = alphaShapeTemp;
            end
            
            % Not necessary here. But in case we need to extract the boundary
            % coordinates... Just remember to initiate fieldPolygons first.
            
            % % indicesFieldPolygonsTemp = boundaryFacets(alphaShapeTemp);
            %  % indicesFieldPolygonsTemp = indicesFieldPolygonsTemp(:,1);
            % %
            %  % % Record the coordinates of the field polygon.
            % % fieldPolygons{indexPolygon} = ...
            %  %     [latiInField(indicesFieldPolygonsTemp), ...
            % %     longInField(indicesFieldPolygonsTemp)];
            
        end
    end
end

% EOF