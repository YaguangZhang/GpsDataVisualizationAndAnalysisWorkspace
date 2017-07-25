% INLINEPROPAGATION Extend the road sequence by adding the GPS points on
% the same line of the road.
%
% Variables required to be up-to-date before running this script:
%
%   - BACKWARD_PROPAGATION - FORWARD_PROPAGATION
%
%   Flags (true or false) to control the direction of the propagation.
%
%   - index4msRoadSequenceStart - index4msRoadSequenceEnd
%
%   The start and end indices of the road squence to be extended,
%   determined by the ONROAD_SPEED_BOUND m/s bounding rule.
%
%   - indexBackwardProLimit - indexForwardProLimit
%
%   The limit for the propagations.
%
%   - devIndSampleDensities
%
%   The device independent sample densities computed by naiveTrain. See
%   testOnRoadClassification.m for more information.
%
% Also, INLINE_DISTANCE_BOUND and INLINE_DISTANCE_BOUND_FAR set the range
% of "road" in meters.
%
% Yaguang Zhang, Purdue, 03/02/2015

% Make sure at least 2 points are available for the linear fitting process.
if index4msRoadSequenceEnd>index4msRoadSequenceStart && ...
        (BACKWARD_PROPAGATION || FORWARD_PROPAGATION)
    
    % x's of the road segment.
    x0 = long(index4msRoadSequenceStart:index4msRoadSequenceEnd);
    % y's of the road segment.
    y0 = lati(index4msRoadSequenceStart:index4msRoadSequenceEnd);
    
    % Fitting this data set to a line.
    if MAP
        [a,b,c] = fitPoly1(x0,y0,GRADIENT_BOUND_G_TO_DISCARD_F,hFigureMapInField,'red');
    else
        [a,b,c] = fitPoly1(x0,y0,GRADIENT_BOUND_G_TO_DISCARD_F);
    end
    
    % Backward propagation.
    if BACKWARD_PROPAGATION
        % Point to consider.
        xBackwardPro = long(indexBackwardProLimit:index4msRoadSequenceStart-1);
        yBackwardPro = lati(indexBackwardProLimit:index4msRoadSequenceStart-1);
        
        if MAP
            % Show the first point find by the backward propagation on the
            % map as reference.
            set(0,'CurrentFigure', hFigureMapInField);
            hold on;
            geoshow(yBackwardPro(end),xBackwardPro(end), ...
                'DisplayType', 'point', 'MarkerEdgeColor', 'magenta', ...
                'LineWidth', 2, 'MarkerSize', 10, 'Marker', '^');
            hold off;
            % pause;
        end
        
        % Nearest points.
        xBackwardNearest = (b.*( b.*xBackwardPro - a.*yBackwardPro) - a*c)./(a^2+b^2);
        yBackwardNearest = (a.*(-b.*xBackwardPro + a.*yBackwardPro) - b*c)./(a^2+b^2);
        
        % Distances in meter.
        distance = -ones(length(xBackwardPro),1); % Record distances computed for debugging.
        BACKWARD_DIST_BREAKED = false;
        % We will count how many low-sample-density points are added
        % according to this line. If the number grows larger than the
        % number of points in the line, we will update the line by
        % including the newly added points.
        numPointsFitted = length(x0);
        numPointsAdded = 0;
        numPointSNewlyAdded = 0;
        indicesPointsAdded = -ones(length(xBackwardPro),1);
        for idxBackwardDist = length(xBackwardPro):-1:1
            distance(idxBackwardDist) = lldistkm([yBackwardPro(idxBackwardDist) xBackwardPro(idxBackwardDist)],...
                [yBackwardNearest(idxBackwardDist) xBackwardNearest(idxBackwardDist)])*1000;
            if distance(idxBackwardDist) > INLINE_DISTANCE_BOUND
                % Test the device independent sample density of this point.
                if dens(indexBackwardProLimit + idxBackwardDist) <= ...
                        (mean(dens(location<0)) + std(dens(location<0))) ...
                        && ...
                        distance(idxBackwardDist) <= ...
                        INLINE_DISTANCE_BOUND_LOW_DENSITY
                    % Its density is really low, and it's within the low
                    % density inline distance bound, which means it's
                    % probably still on the road, just not that sure as
                    % -80. So we will label these points as -70.
                    location(indexBackwardProLimit + idxBackwardDist) = -70;
                    
                    numPointsAdded = numPointsAdded+1;
                    numPointSNewlyAdded = numPointSNewlyAdded+1;
                    indicesPointsAdded(numPointsAdded) = indexBackwardProLimit + idxBackwardDist;
                    
                else
                    % Update the line if necessary.
                    if numPointSNewlyAdded>=numPointsFitted/3
                        % Update points to be fit.
                        x0New = [long(index4msRoadSequenceStart:index4msRoadSequenceEnd); ...
                            long(indicesPointsAdded(indicesPointsAdded>0))];
                        y0New = [lati(index4msRoadSequenceStart:index4msRoadSequenceEnd); ...
                            lati(indicesPointsAdded(indicesPointsAdded>0))];
                        % Re-fit. (Maroon)
                        if MAP
                            [aNew,bNew,cNew] = fitPoly1(x0New,y0New,GRADIENT_BOUND_G_TO_DISCARD_F,hFigureMapInField, [0.5,0,0]);
                        else
                            [aNew,bNew,cNew] = fitPoly1(x0New,y0New,GRADIENT_BOUND_G_TO_DISCARD_F);
                        end
                        % Update nearest points.
                        xBackwardNearest = (bNew.*( bNew.*xBackwardPro - aNew.*yBackwardPro) - aNew*cNew)./(aNew^2+bNew^2);
                        yBackwardNearest = (aNew.*(-bNew.*xBackwardPro + aNew.*yBackwardPro) - bNew*cNew)./(aNew^2+bNew^2);
                        
                        % Update counters.
                        numPointsFitted = numPointsFitted+numPointSNewlyAdded;
                        numPointSNewlyAdded = 0;
                    end
                    distance(idxBackwardDist) = lldistkm([yBackwardPro(idxBackwardDist) xBackwardPro(idxBackwardDist)],...
                        [yBackwardNearest(idxBackwardDist) xBackwardNearest(idxBackwardDist)])*1000;
                    
                    if dens(indexBackwardProLimit + idxBackwardDist) <= ...
                            (mean(dens(location<0)) + std(dens(location<0))) ...
                            && ...
                            distance(idxBackwardDist) <= ...
                            INLINE_DISTANCE_BOUND_LOW_DENSITY
                        % After updating, it passes inline test.
                        location(indexBackwardProLimit + idxBackwardDist) = -70;
                        
                        numPointsAdded = numPointsAdded+1;
                        numPointSNewlyAdded = numPointSNewlyAdded+1;
                        indicesPointsAdded(numPointsAdded) = indexBackwardProLimit + idxBackwardDist;
                    else
                        BACKWARD_DIST_BREAKED = true;
                        break;
                    end
                end
            else
                % Normal inline propagation.
                numPointsAdded = numPointsAdded+1;
                numPointSNewlyAdded = numPointSNewlyAdded+1;
                indicesPointsAdded(numPointsAdded) = indexBackwardProLimit + idxBackwardDist;
            end
        end
        
        if BACKWARD_DIST_BREAKED
            location(intersect( ...
                (indexBackwardProLimit + idxBackwardDist):(index4msRoadSequenceStart-1),...
                find(location == 0) ...
                )) = -80;
        else
            location(intersect( ...
                indexBackwardProLimit:(index4msRoadSequenceStart-1),...
                find(location == 0) ...
                )) = -80;
        end
        
    end
    
    % Extended in line propagation. This algorithm goes beyond the
    % "connected" segment to this road sequence and tries to find points on
    % the same road.
    
    % The varialbes EXTENDED_PRO_TIME_THRESHOLD and
    % INLINE_DISTANCE_BOUND_FAR are used.
    
    % Point to consider.
    xBackwardProEx = long(1:indexBackwardProLimitEx-1);
    yBackwardProEx = lati(1:indexBackwardProLimitEx-1);
    % Nearest points.
    xBackwardNearestEx = (b.*( b.*xBackwardProEx - a.*yBackwardProEx) - a*c)./(a^2+b^2);
    yBackwardNearestEx = (a.*(-b.*xBackwardProEx + a.*yBackwardProEx) - b*c)./(a^2+b^2);
    
    % Distances from the points to the extended road in meter.
    distance = -ones(length(xBackwardProEx),1);
    FIND_ONE_POSSIBLE_SEQ_BACKWARD = false;
    for idxBackwardDist = 1:length(xBackwardProEx)
        distance(idxBackwardDist) = lldistkm([yBackwardProEx(idxBackwardDist) xBackwardProEx(idxBackwardDist)],...
            [yBackwardNearestEx(idxBackwardDist) xBackwardNearestEx(idxBackwardDist)])*1000;
        if distance(idxBackwardDist) <= INLINE_DISTANCE_BOUND_FAR
            if ~FIND_ONE_POSSIBLE_SEQ_BACKWARD
                % Found the first point on the extended road.
                FIND_ONE_POSSIBLE_SEQ_BACKWARD = true;
                idxPossibleSeqStartBackward = idxBackwardDist;
                
                if MAP
                    % Show the first point find by the extended backward
                    % propagation on the map as reference. (Plum)
                    set(0,'CurrentFigure', hFigureMapInField);
                    hold on;
                    geoshow(yBackwardProEx(idxPossibleSeqStartBackward),xBackwardProEx(idxPossibleSeqStartBackward), ...
                        'DisplayType', 'point', 'MarkerEdgeColor', [0.87,0.63,0.87], ...
                        'LineWidth', 2, 'MarkerSize', 10, 'Marker', 'pentagram');
                    hold off;
                    % pause;
                end
                
            else
                % This point and the last point are both on the extended
                % road. Keep scaning unless it's the last point.
                if idxBackwardDist == length(xBackwardProEx)
                    FIND_ONE_POSSIBLE_SEQ_BACKWARD = false;
                    % This is the end of the possible on-the-road sequence.
                    idxPossibleSeqEndBackward = idxBackwardDist;
                    if time(idxPossibleSeqEndBackward)-time(idxPossibleSeqStartBackward)>EXTENDED_PRO_TIME_THRESHOLD
                        % This possible sequence is long enough to be
                        % marked as on the road. Need to check it's not
                        % -100 first and only change the labels of "0"
                        % points.
                        indicesExtendedRoadSequence = idxPossibleSeqStartBackward:idxPossibleSeqEndBackward;
                        
                        % Run inlineProForInlinePro if the sequence passes
                        % the validity check.
                        inlineProForInlineProWithValidityCheck;
                    end
                end
            end
        else
            if FIND_ONE_POSSIBLE_SEQ_BACKWARD
                FIND_ONE_POSSIBLE_SEQ_BACKWARD = false;
                % This is the end of the possible on-the-road sequence.
                idxPossibleSeqEndBackward = idxBackwardDist-1;
                if time(idxPossibleSeqEndBackward)-time(idxPossibleSeqStartBackward)>EXTENDED_PRO_TIME_THRESHOLD
                    % This possible sequence is long enough to be marked as
                    % on the road. Note that idxForwardDist is the same as
                    % the actual indices for location.
                    indicesExtendedRoadSequence = idxPossibleSeqStartBackward:idxPossibleSeqEndBackward;
                    
                    % Run inlineProForInlinePro if the sequence passes the
                    % validity check.
                    inlineProForInlineProWithValidityCheck;
                end
            end
        end
    end
    
    % Forward propagation.
    if FORWARD_PROPAGATION
        % Point to consider.
        xForwardPro = long(index4msRoadSequenceEnd+1:indexForwardProLimit);
        yForwardPro = lati(index4msRoadSequenceEnd+1:indexForwardProLimit);
        
        if MAP
            % Show the first point find by the forward propagation on the
            % map as reference.
            set(0,'CurrentFigure', hFigureMapInField);
            hold on;
            geoshow(yForwardPro(1),xForwardPro(1), ...
                'DisplayType', 'point', 'MarkerEdgeColor', 'green', ...
                'LineWidth', 2, 'MarkerSize', 10, 'Marker', '^');
            hold off;
            % pause;
        end
        
        % Nearest points.
        xForwardNearest = (b.*( b.*xForwardPro - a.*yForwardPro) - a*c)./(a^2+b^2);
        yForwardNearest = (a.*(-b.*xForwardPro + a.*yForwardPro) - b*c)./(a^2+b^2);
        
        % Distances in meter.
        distance = -ones(length(xForwardPro),1); % Record distances computed for debugging.
        FORWARD_DIST_BREAKED = false;
        % We will count how many low-sample-density points are added
        % according to this line. If the number grows larger than the
        % number of points in the line, we will update the line by
        % including the newly added points.
        numPointsFitted = length(x0);
        numPointsAdded = 0;
        numPointSNewlyAdded = 0;
        indicesPointsAdded = -ones(length(xForwardPro),1);
        for idxForwardDist = 1:length(xForwardPro)
            distance(idxForwardDist) = lldistkm([yForwardPro(idxForwardDist) xForwardPro(idxForwardDist)],...
                [yForwardNearest(idxForwardDist) xForwardNearest(idxForwardDist)])*1000;
            if distance(idxForwardDist) > INLINE_DISTANCE_BOUND
                % Test the device independent sample density of this point.
                if dens((index4msRoadSequenceEnd+idxForwardDist-1)) <= ...
                        (mean(dens(location<0)) + std(dens(location<0)))...
                        && ...
                        distance(idxForwardDist) <= ...
                        INLINE_DISTANCE_BOUND_LOW_DENSITY
                    % Its density is really low, and it's within the low
                    % density inline distance bound, which means it's
                    % probably still on the road, just not that sure as
                    % -80. So we will label these points as -70.
                    location(index4msRoadSequenceEnd+idxForwardDist-1) = -70;
                    
                    numPointsAdded = numPointsAdded+1;
                    numPointSNewlyAdded = numPointSNewlyAdded+1;
                    indicesPointsAdded(numPointsAdded) = index4msRoadSequenceEnd+idxForwardDist-1;
                    
                else
                    % Update the line if necessary.
                    if numPointSNewlyAdded>=numPointsFitted/3
                        % Update points to be fit.
                        x0New = [long(index4msRoadSequenceStart:index4msRoadSequenceEnd); ...
                            long(indicesPointsAdded(indicesPointsAdded>0))];
                        y0New = [lati(index4msRoadSequenceStart:index4msRoadSequenceEnd); ...
                            lati(indicesPointsAdded(indicesPointsAdded>0))];
                        % Re-fit. (Maroon)
                        if MAP
                            [aNew,bNew,cNew] = fitPoly1(x0New,y0New,GRADIENT_BOUND_G_TO_DISCARD_F,hFigureMapInField, [0.5,0,0]);
                        else
                            [aNew,bNew,cNew] = fitPoly1(x0New,y0New,GRADIENT_BOUND_G_TO_DISCARD_F);
                        end
                        % Update nearest points.
                        xForwardNearest = (bNew.*( bNew.*xForwardPro - aNew.*yForwardPro) - aNew*cNew)./(aNew^2+bNew^2);
                        yForwardNearest = (aNew.*(-bNew.*xForwardPro + aNew.*yForwardPro) - bNew*cNew)./(aNew^2+bNew^2);
                        
                        % Update counters.
                        numPointsFitted = numPointsFitted+numPointSNewlyAdded;
                        numPointSNewlyAdded = 0;
                    end
                    distance(idxForwardDist) = lldistkm([yForwardPro(idxForwardDist) xForwardPro(idxForwardDist)],...
                        [yForwardNearest(idxForwardDist) xForwardNearest(idxForwardDist)])*1000;
                    
                    if dens((index4msRoadSequenceEnd+idxForwardDist-1)) <= ...
                            (mean(dens(location<0)) + std(dens(location<0)))...
                            && ...
                            distance(idxForwardDist) <= ...
                            INLINE_DISTANCE_BOUND_LOW_DENSITY
                        % After updating, it passes inline test.
                        location(index4msRoadSequenceEnd+idxForwardDist-1) = -70;
                        
                        numPointsAdded = numPointsAdded+1;
                        numPointSNewlyAdded = numPointSNewlyAdded+1;
                        indicesPointsAdded(numPointsAdded) = index4msRoadSequenceEnd+idxForwardDist-1;
                    else
                        FORWARD_DIST_BREAKED = true;
                        break;
                    end
                end
            else
                % Normal inline propagation.
                numPointsAdded = numPointsAdded+1;
                numPointSNewlyAdded = numPointSNewlyAdded+1;
                indicesPointsAdded(numPointsAdded) = index4msRoadSequenceEnd+idxForwardDist-1;
            end
        end
        
        if FORWARD_DIST_BREAKED
            location(intersect( ...
                (index4msRoadSequenceEnd+1):(index4msRoadSequenceEnd+idxForwardDist-1),...
                find(location == 0) ...
                )) = -80;
        else
            location(intersect( ...
                (index4msRoadSequenceEnd+1):indexForwardProLimit,...
                find(location == 0) ...
                )) = -80;
        end
        
    end
    
    % Forward extended in line propagation.
    
    % Point to consider.
    xForwardProEx = long(indexForwardProLimitEx+1:end);
    yForwardProEx = lati(indexForwardProLimitEx+1:end);
    % Nearest points.
    xForwardNearestEx = (b.*( b.*xForwardProEx - a.*yForwardProEx) - a*c)./(a^2+b^2);
    yForwardNearestEx = (a.*(-b.*xForwardProEx + a.*yForwardProEx) - b*c)./(a^2+b^2);
    
    % Distances from the points to the extended road in meter.
    distance = -ones(length(xForwardProEx),1);
    FIND_ONE_POSSIBLE_SEQ_FORWARD = false;
    for idxForwardDist = 1:length(xForwardProEx)
        distance(idxForwardDist) = lldistkm([yForwardProEx(idxForwardDist) xForwardProEx(idxForwardDist)],...
            [yForwardNearestEx(idxForwardDist) xForwardNearestEx(idxForwardDist)])*1000;
        if distance(idxForwardDist) <= INLINE_DISTANCE_BOUND_FAR
            if ~FIND_ONE_POSSIBLE_SEQ_FORWARD
                % Found the first point on the extended road.
                FIND_ONE_POSSIBLE_SEQ_FORWARD = true;
                idxPossibleSeqStartForward = idxForwardDist;
                
                if MAP
                    % Show the first point find by the extended forward
                    % propagation on the map as reference. (Yellow green)
                    set(0,'CurrentFigure', hFigureMapInField);
                    hold on;
                    geoshow(yForwardProEx(idxPossibleSeqStartForward),xForwardProEx(idxPossibleSeqStartForward), ...
                        'DisplayType', 'point', 'MarkerEdgeColor', [0.6,0.8,0.2], ...
                        'LineWidth', 2, 'MarkerSize', 10, 'Marker', 'pentagram');
                    hold off;
                    % pause;
                end
            else
                % This point and the last point are both on the extended
                % road. Keep scaning unless it's the last point.
                if idxForwardDist == length(xForwardProEx)
                    FIND_ONE_POSSIBLE_SEQ_FORWARD = false;
                    % This is the end of the possible on-the-road sequence.
                    idxPossibleSeqEndForward = idxForwardDist;
                    if time(idxPossibleSeqEndForward)-time(idxPossibleSeqStartForward)>EXTENDED_PRO_TIME_THRESHOLD
                        % This possible sequence is long enough to be
                        % marked as on the road.
                        indicesExtendedRoadSequence = (idxPossibleSeqStartForward:idxPossibleSeqEndForward)+indexForwardProLimitEx;
                        
                        % Run inlineProForInlinePro if the sequence passes
                        % the validity check.
                        inlineProForInlineProWithValidityCheck;
                    end
                end
            end
        else
            if FIND_ONE_POSSIBLE_SEQ_FORWARD
                FIND_ONE_POSSIBLE_SEQ_FORWARD = false;
                % This is the end of the possible on-the-road sequence.
                idxPossibleSeqEndForward = idxForwardDist-1;
                if time(idxPossibleSeqEndForward)-time(idxPossibleSeqStartForward)>EXTENDED_PRO_TIME_THRESHOLD
                    % This possible sequence is long enough to be marked as
                    % on the road. Note that idxForwardDist is
                    % indexForwardProLimitEx less than the actual indices
                    % for location.
                    indicesExtendedRoadSequence = (idxPossibleSeqStartForward:idxPossibleSeqEndForward)+indexForwardProLimitEx;
                    
                    % Run inlineProForInlinePro if the sequence passes the
                    % validity check.
                    inlineProForInlineProWithValidityCheck;
                end
            end
        end
    end
end

% EOF