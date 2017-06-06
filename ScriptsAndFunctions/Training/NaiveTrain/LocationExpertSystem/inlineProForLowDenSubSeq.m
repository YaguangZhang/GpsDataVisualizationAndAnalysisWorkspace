% INLINEPROFLOWDENSUBSEQ Inline propagation for low density subsequences.
%
% This script is basibally a copy of inlineProForInlinePro.m, with changes
% of variable names and label value.
%
% Update 03/17/2015: add new on-the-road sequence map range compare with
% that of the zero-labeled sequence that it's in.
%
% Yaguang Zhang, Purdue, 03/11/2015

% Make sure at least 2 points are available for the linear fitting process.
if length(indicesLowDenSubSeq)>=2
    % Make sure what we get is a column vector.
    if ~iscolumn(indicesLowDenSubSeq)
        indicesLowDenSubSeq = indicesLowDenSubSeq';
    end
    
    lowDenSubSeqStart = indicesLowDenSubSeq(1);
    lowDenSubSeqEnd = indicesLowDenSubSeq(end);
    
    % x's of the road segment. We use far to indicate this propagation may
    % occur far away from the known road segment.
    x0Low = long(lowDenSubSeqStart:lowDenSubSeqEnd);
    % y's of the road segment.
    y0Low = lati(lowDenSubSeqStart:lowDenSubSeqEnd);
    
    % Fitting this data set to a line. Parameters needed for the line: ax +
    % by + c = 0.
    if MAP % Yellow green.
        [aLow,bLow,cLow] = fitPoly1(x0Low,y0Low,GRADIENT_BOUND_G_TO_DISCARD_F,hFigureMapInField, [0.6,0.8,0.2]);
    else
        [aLow,bLow,cLow] = fitPoly1(x0Low,y0Low,GRADIENT_BOUND_G_TO_DISCARD_F);
    end
    
    % Backward propagation. For simplicity we propagate the whole data set
    % of this route. It will stop rather early since not all points are on
    % the extended road line.
    indexBackwardProLimitLow = 1;
    % Point to consider.
    xBackwardPro = long(indexBackwardProLimitLow:lowDenSubSeqStart-1);
    yBackwardPro = lati(indexBackwardProLimitLow:lowDenSubSeqStart-1);
    % Nearest points.
    xBackwardNearest = (bLow.*( bLow.*xBackwardPro - aLow.*yBackwardPro) - aLow*cLow)./(aLow^2+bLow^2);
    yBackwardNearest = (aLow.*(-bLow.*xBackwardPro + aLow.*yBackwardPro) - bLow*cLow)./(aLow^2+bLow^2);
    
    % Distances in meter.
    distance = -ones(length(xBackwardPro),1); % Record distances computed for debugging.
    BACKWARD_DIST_BREAKED = false;
    % We will count how many low-sample-density points are added according
    % to this line. If the number grows larger than the number of points in
    % the line, we will update the line by including the newly added
    % points.
    numPointsFitted = length(x0);
    numPointsAdded = 0;
    numPointSNewlyAdded = 0;
    indicesPointsAdded = -ones(length(xBackwardPro),1);
    for idxBackwardDist = length(xBackwardPro):-1:1
        distance(idxBackwardDist) = lldistkm([yBackwardPro(idxBackwardDist) xBackwardPro(idxBackwardDist)],...
            [yBackwardNearest(idxBackwardDist) xBackwardNearest(idxBackwardDist)])*1000;
        if distance(idxBackwardDist) > INLINE_DISTANCE_BOUND
            % Test the device independent sample density of this point.
            if dens(idxBackwardDist) <= ...
                    max(...
                    (mean(dens(location<0)) + std(dens(location<0))), ...
                    THRESHOLD_REALLY_LOW_DENSITY*2 ...
                    ) ...
                    && ...
                    distance(idxBackwardDist) <= ...
                    INLINE_DISTANCE_BOUND_LOW_DENSITY
                % Its density is really low, and it's within the low
                % density inline distance bound, which means it's probably
                % still on the road, just not that sure as -60. So we will
                % label these points as -55.
                numPointsAdded = numPointsAdded+1;
                numPointSNewlyAdded = numPointSNewlyAdded + 1;
                indicesPointsAdded(numPointsAdded) = idxBackwardDist;
            else
                % Update the line if necessary.
                if numPointSNewlyAdded>=numPointsFitted/3
                    % Update points to be fit.
                    x0LowNew = [long(lowDenSubSeqStart:lowDenSubSeqEnd); ...
                        long(indicesPointsAdded(indicesPointsAdded>0))];
                    y0LowNew = [lati(lowDenSubSeqStart:lowDenSubSeqEnd); ...
                        lati(indicesPointsAdded(indicesPointsAdded>0))];
                    % Re-fit. (Grey)
                    if MAP
                        [aLowNew,bLowNew,cLowNew] = fitPoly1(x0LowNew,y0LowNew,GRADIENT_BOUND_G_TO_DISCARD_F,hFigureMapInField, [0.5,0.5,0.5]);
                    else
                        [aLowNew,bLowNew,cLowNew] = fitPoly1(x0LowNew,y0LowNew,GRADIENT_BOUND_G_TO_DISCARD_F);
                    end
                    % Update nearest points.
                    xBackwardNearest = (bLowNew.*( bLowNew.*xBackwardPro - aLowNew.*yBackwardPro) - aLowNew*cLowNew)./(aLowNew^2+bLowNew^2);
                    yBackwardNearest = (aLowNew.*(-bLowNew.*xBackwardPro + aLowNew.*yBackwardPro) - bLowNew*cLowNew)./(aLowNew^2+bLowNew^2);
                    
                    % Update counters.
                    numPointsFitted = numPointsFitted+numPointSNewlyAdded;
                    numPointSNewlyAdded = 0;
                end
                distance(idxBackwardDist) = lldistkm([yBackwardPro(idxBackwardDist) xBackwardPro(idxBackwardDist)],...
                    [yBackwardNearest(idxBackwardDist) xBackwardNearest(idxBackwardDist)])*1000;
                
                if distance(idxBackwardDist) > INLINE_DISTANCE_BOUND
                    if dens(idxBackwardDist) <= ...
                            max(...
                            (mean(dens(location<0)) + std(dens(location<0))), ...
                            THRESHOLD_REALLY_LOW_DENSITY*2 ...
                            ) ...
                            && ...
                            distance(idxBackwardDist) <= ...
                            INLINE_DISTANCE_BOUND_LOW_DENSITY
                        
                        % After updating, it passes inline test.
                        numPointsAdded = numPointsAdded+1;
                        numPointSNewlyAdded = numPointSNewlyAdded+1;
                        indicesPointsAdded(numPointsAdded) = idxBackwardDist;
                    else
                        BACKWARD_DIST_BREAKED = true;
                        break;
                    end
                else
                    % Normal inline propagation.
                    numPointsAdded = numPointsAdded+1;
                    numPointSNewlyAdded = numPointSNewlyAdded+1;
                    indicesPointsAdded(numPointsAdded) = idxBackwardDist;
                end
            end
        else
            % Better rules are needed for this, especially for case when
            % the vehicle is  near a field.
            %             % For square field, we still need to check the
            %             sample density % since it's for low density
            %             sub-sequences. But we will use a % relatively
            %             loose bound for this test. if
            %             dens(idxBackwardDist) > ...
            %                     max(... (mean(dens(location<0)) +
            %                     std(dens(location<0))), ...
            %                     THRESHOLD_REALLY_LOW_DENSITY*2 ... ) ...
            %                     && flagSquareField
            %                 % It is a square field and the density for
            %                 this location is % too high.
            %                 BACKWARD_DIST_BREAKED = true; break;
            %             else
            
            % Normal inline propagation.
            numPointsAdded = numPointsAdded+1;
            numPointSNewlyAdded = numPointSNewlyAdded+1;
            indicesPointsAdded(numPointsAdded) = idxBackwardDist;
            
            %             end
        end
    end
    
    if BACKWARD_DIST_BREAKED
        indicesBackwardInlineSubSeq = intersect( ...
            (indexBackwardProLimitLow+idxBackwardDist):(lowDenSubSeqStart-1),...
            find(location == 0) ...
            );
    else
        indicesBackwardInlineSubSeq = intersect( ...
            indexBackwardProLimitLow:(lowDenSubSeqStart-1),...
            find(location == 0) ...
            );
    end
    % Make sure what we get is a column vector.
    if ~iscolumn(indicesBackwardInlineSubSeq)
        indicesBackwardInlineSubSeq = indicesBackwardInlineSubSeq';
    end
    
    % Forward propagation.
    indexForwardProLimit = length(location);
    % Point to consider.
    xForwardPro = long(lowDenSubSeqEnd+1:indexForwardProLimit);
    yForwardPro = lati(lowDenSubSeqEnd+1:indexForwardProLimit);
    % Nearest points.
    xForwardNearest = (bLow.*( bLow.*xForwardPro - aLow.*yForwardPro) - aLow*cLow)./(aLow^2+bLow^2);
    yForwardNearest = (aLow.*(-bLow.*xForwardPro + aLow.*yForwardPro) - bLow*cLow)./(aLow^2+bLow^2);
    
    % Distances in meter.
    distance = -ones(length(xForwardPro),1); % Record distances computed for debugging.
    FORWARD_DIST_BREAKED = false;
    % We will count how many low-sample-density points are added according
    % to this line. If the number grows larger than the number of points in
    % the line, we will update the line by including the newly added
    % points.
    numPointsFitted = length(x0);
    numPointsAdded = 0;
    numPointSNewlyAdded = 0;
    indicesPointsAdded = -ones(length(xForwardPro),1);
    for idxForwardDist = 1:length(xForwardPro)
        distance(idxForwardDist) = lldistkm([yForwardPro(idxForwardDist) xForwardPro(idxForwardDist)],...
            [yForwardNearest(idxForwardDist) xForwardNearest(idxForwardDist)])*1000;
        if distance(idxForwardDist) > INLINE_DISTANCE_BOUND
            % Test the device independent sample density of this point.
            if dens((lowDenSubSeqEnd+idxForwardDist-1)) <= ...
                    max(...
                    (mean(dens(location<0)) + std(dens(location<0))), ...
                    THRESHOLD_REALLY_LOW_DENSITY*2 ...
                    ) ...
                    && ...
                    distance(idxForwardDist) <= ...
                    INLINE_DISTANCE_BOUND_LOW_DENSITY
                % Its density is really low, and it's within the low
                % density inline distance bound, which means it's probably
                % still on the road, just not that sure as -60. So we will
                % label these points as -55.
                numPointsAdded = numPointsAdded+1;
                numPointSNewlyAdded = numPointSNewlyAdded+1;
                indicesPointsAdded(numPointsAdded) = lowDenSubSeqEnd+idxForwardDist-1;
            else
                % Update the line if necessary.
                if numPointSNewlyAdded>=numPointsFitted/3
                    % Update points to be fit.
                    x0LowNew = [long(lowDenSubSeqStart:lowDenSubSeqEnd); ...
                        long(indicesPointsAdded(indicesPointsAdded>0))];
                    y0LowNew = [lati(lowDenSubSeqStart:lowDenSubSeqEnd); ...
                        lati(indicesPointsAdded(indicesPointsAdded>0))];
                    % Re-fit. (Grey)
                    if MAP
                        [aLowNew,bLowNew,cLowNew] = fitPoly1(x0LowNew,y0LowNew,GRADIENT_BOUND_G_TO_DISCARD_F,hFigureMapInField, [0.5,0.5,0.5]);
                    else
                        [aLowNew,bLowNew,cLowNew] = fitPoly1(x0LowNew,y0LowNew,GRADIENT_BOUND_G_TO_DISCARD_F);
                    end
                    % Update nearest points.
                    xForwardNearest = (bLowNew.*( bLowNew.*xForwardPro - aLowNew.*yForwardPro) - aLowNew*cLowNew)./(aLowNew^2+bLowNew^2);
                    yForwardNearest = (aLowNew.*(-bLowNew.*xForwardPro + aLowNew.*yForwardPro) - bLowNew*cLowNew)./(aLowNew^2+bLowNew^2);
                    
                    % Update counters.
                    numPointsFitted = numPointsFitted+numPointSNewlyAdded;
                    numPointSNewlyAdded = 0;
                end
                distance(idxForwardDist) = lldistkm([yForwardPro(idxForwardDist) xForwardPro(idxForwardDist)],...
                    [yForwardNearest(idxForwardDist) xForwardNearest(idxForwardDist)])*1000;
                
                if distance(idxForwardDist) > INLINE_DISTANCE_BOUND
                    if dens((lowDenSubSeqEnd+idxForwardDist-1)) <= ...
                            max(...
                            (mean(dens(location<0)) + std(dens(location<0))), ...
                            THRESHOLD_REALLY_LOW_DENSITY*2 ...
                            ) ...
                            && ...
                            distance(idxForwardDist) <= ...
                            INLINE_DISTANCE_BOUND_LOW_DENSITY
                        
                        % After updating, it passes inline test.
                        numPointsAdded = numPointsAdded+1;
                        numPointSNewlyAdded = numPointSNewlyAdded+1;
                        indicesPointsAdded(numPointsAdded) = lowDenSubSeqEnd+idxForwardDist-1;
                    else
                        FORWARD_DIST_BREAKED = true;
                        break;
                    end
                else
                    % Normal inline propagation.
                    numPointsAdded = numPointsAdded+1;
                    numPointSNewlyAdded = numPointSNewlyAdded+1;
                    indicesPointsAdded(numPointsAdded) = lowDenSubSeqEnd+idxForwardDist-1;
                end
            end
        else
            %             % For square field, we still need to check the
            %             sample density % since it's for low density
            %             sub-sequences. But we will use a % relatively
            %             loose bound for this test. if
            %             dens((lowDenSubSeqEnd+idxForwardDist-1)) > ...
            %                     max(... (mean(dens(location<0)) +
            %                     std(dens(location<0))), ...
            %                     THRESHOLD_REALLY_LOW_DENSITY*2 ... ) ...
            %                     && flagSquareField
            %                 % It is a square field and the density for
            %                 this location is % too high.
            %                 FORWARD_DIST_BREAKED = true; break;
            %             else
            
            % Normal inline propagation.
            numPointsAdded = numPointsAdded+1;
            numPointSNewlyAdded = numPointSNewlyAdded+1;
            indicesPointsAdded(numPointsAdded) = lowDenSubSeqEnd+idxForwardDist-1;
            
            %             end
        end
    end
    
    if FORWARD_DIST_BREAKED
        indicesForwardInlineSubSeq = intersect( ...
            (lowDenSubSeqEnd+1):(lowDenSubSeqEnd+idxForwardDist-1),...
            find(location == 0) ...
            );
    else
        indicesForwardInlineSubSeq = intersect( ...
            (lowDenSubSeqEnd+1):indexForwardProLimit, ...
            find(location == 0) ...
            );
    end
    % Make sure what we get is a column vector.
    if ~iscolumn(indicesForwardInlineSubSeq)
        indicesForwardInlineSubSeq = indicesForwardInlineSubSeq';
    end
    % Not a good test.
    %     if sum(dens(...
    %             setdiff(indicesUnlabeledSeq, ... [indicesLowDenSubSeq;
    %             ... indicesBackwardInlineSubSeq;...
    %             indicesForwardInlineSubSeq])... ) >
    %             max(dens(indicesLowDenSubSeq) ... )) ... / length(...
    %             setdiff(indicesUnlabeledSeq, ... [indicesLowDenSubSeq;
    %             ... indicesBackwardInlineSubSeq;...
    %             indicesForwardInlineSubSeq])... ) ... > 0.97
    %         % Most of the other points are with higher density than the
    %         inline % sequence, so the other points may form a field but
    %         we still need % to make sure the sequence isn't inside the
    %         field area.
    
    % Check whether the remaining unlabeled area a circle (roughly
    % speaking). First, get the boundary of it.
    [remainingUnlabeledBound, remainingUnlabeledArea] = ...
        convhull(long(indicesUnlabeledSeq),lati(indicesUnlabeledSeq));
    % Simplify the boundary.
    [latSimplifiedBound,lonSimplifiedBound] = reducem(...
        long(indicesUnlabeledSeq(remainingUnlabeledBound)),...
        lati(indicesUnlabeledSeq(remainingUnlabeledBound))...
        );
    
    if length(latSimplifiedBound) <= MIN_NUM_POINTS_NEEDED_FOR_CIRCLE
        % The field is not a circle.
        flagNotCircleField = true;
        % Further determine whether it's a square. We assume the square
        % fields are always along the meridians/parallels.
        
        latSimpleBoundSquareArea = ...
            (max(latSimplifiedBound) - min(latSimplifiedBound)) ...
            * (max(lonSimplifiedBound) - min(lonSimplifiedBound));
        if remainingUnlabeledArea < latSimpleBoundSquareArea*1.1 ...
                && remainingUnlabeledArea > latSimpleBoundSquareArea*0.9
            flagSqareField = true;
        else
            flagSqareField = false;
        end
    else
        flagNotCircleField = false;
    end
    
    if flagNotCircleField
        
        if flagSqareField
            % The field is a square. We need to conduct the overlap ratio
            % test.
            
            % Check the map range of the new added low-density sequence.
            slope = -aLow/bLow;
            if -1<=slope && slope<=1
                % More "horizontal". Compare the range of x, i.e.
                % longtitude.
                dataInlineSeq = long(...
                    [indicesLowDenSubSeq; ...
                    indicesBackwardInlineSubSeq;...
                    indicesForwardInlineSubSeq]...
                    );
                % Note that we need to further exclude the to-be-marked
                % sub-sequences.
                dataUnlabeledSeq = long(setdiff(...
                    indicesUnlabeledSeq,...
                    [indicesLowDenSubSeq;...
                    indicesBackwardInlineSubSeq;...
                    indicesForwardInlineSubSeq]...
                    ));
            else
                % More "vertical". Compare the range of y, i.e. latitude.
                dataInlineSeq = lati(...
                    [indicesLowDenSubSeq; ...
                    indicesBackwardInlineSubSeq;...
                    indicesForwardInlineSubSeq]...
                    );
                % Note that we need to further exclude the inline
                % sub-sequences.
                dataUnlabeledSeq = lati(setdiff(...
                    indicesUnlabeledSeq,...
                    [indicesLowDenSubSeq;...
                    indicesBackwardInlineSubSeq;...
                    indicesForwardInlineSubSeq]...
                    ));
            end
            
            rangeInlineSeq = [min(dataInlineSeq); ...
                max(dataInlineSeq)];
            rangeUnlabeledSeq = [min(dataUnlabeledSeq); ...
                max(dataUnlabeledSeq)];
            rangeOverlapped = [max(rangeInlineSeq(1),rangeUnlabeledSeq(1)); ...
                min(rangeInlineSeq(2),rangeUnlabeledSeq(2))];
            if rangeOverlapped(2)-rangeOverlapped(1)>0
                % There is an overlop of the ranges. Need to check the
                % ratio.
                OverlapToInlineSeqRatio = (rangeOverlapped(2)-rangeOverlapped(1))...
                    / (rangeInlineSeq(2)-rangeInlineSeq(1));
                
                if OverlapToInlineSeqRatio > MAX_OVERLAP_TO_INLINE_SEQ_RATIO
                    % This sequence fails the test. Change the -60.5 labels
                    % in this sequence back to 0.
                    location(location==-60.5) = 0;
                else
                    % This sequence passes the test.
                    locainlineProForLowDenSubSeqConfirmOnRoad;
                end
                
            else
                % No overlapping. This sequence passes the test.
                inlineProForLowDenSubSeqConfirmOnRoad;
            end
        else
            % Not a sqare. No need to test overlap ratio.
           inlineProForLowDenSubSeqConfirmOnRoad;
        end
    else
        % The field is a circle. No need to test overlap ratio.
        inlineProForLowDenSubSeqConfirmOnRoad;
    end
    %     else
    %
    %     end
    
else
    % The sequence is too short.
    location(location==-60.5) = 0;
end

% EOF