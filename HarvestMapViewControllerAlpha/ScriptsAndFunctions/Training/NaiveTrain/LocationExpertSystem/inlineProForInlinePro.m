% INLINEPROFORINLINEPRO Inline propagation for extended inline propagation.
%
% The ends of the road segment labeled by the extended inline propagation
% rule needs to be processed by in line propagation, too.
%
% Yaguang Zhang, Purdue, 03/05/2015

% Make sure at least 2 points are available for the linear fitting process.
if length(indicesExtendedRoadSequence)>=2
    extendedRoadSequenceStart = indicesExtendedRoadSequence(1);
    extendedRoadSequenceEnd = indicesExtendedRoadSequence(end);
    
    % x's of the road segment. We use far to indicate this propagation may
    % occur far away from the known road segment.
    x0Far = long(extendedRoadSequenceStart:extendedRoadSequenceEnd);
    % y's of the road segment.
    y0Far = lati(extendedRoadSequenceStart:extendedRoadSequenceEnd);
    
    % Fitting this data set to a line. Parameters needed for the line: ax +
    % by + c = 0. (Turquoise)
    if MAP
        [aFar,bFar,cFar] = fitPoly1(x0Far,y0Far,GRADIENT_BOUND_G_TO_DISCARD_F,hFigureMapInField, [0.25,0.88,0.82]);
    else
        [aFar,bFar,cFar] = fitPoly1(x0Far,y0Far,GRADIENT_BOUND_G_TO_DISCARD_F);
    end
    
    % Backward propagation. For simplicity we propagate the whole data set
    % of this route. It will stop rather early since not all points are on
    % the extended road line.
    indexBackwardProLimitFar = 1;
    % Point to consider.
    xBackwardPro = long(indexBackwardProLimitFar:extendedRoadSequenceStart-1);
    yBackwardpro = lati(indexBackwardProLimitFar:extendedRoadSequenceStart-1);
    % Nearest points.
    xBackwardNearest = (bFar.*( bFar.*xBackwardPro - aFar.*yBackwardpro) - aFar*cFar)./(aFar^2+bFar^2);
    yBackwardNearest = (aFar.*(-bFar.*xBackwardPro + aFar.*yBackwardpro) - bFar*cFar)./(aFar^2+bFar^2);
    
    % Distances in meter.
    distance = -ones(length(xBackwardPro),1); % Record distances computed for debugging.
    BACKWARD_DIST_BREAKED = false;
    for idxBackwardDist = length(xBackwardPro):-1:1
        distance(idxBackwardDist) = lldistkm([yBackwardpro(idxBackwardDist) xBackwardPro(idxBackwardDist)],...
            [yBackwardNearest(idxBackwardDist) xBackwardNearest(idxBackwardDist)])*1000;
        if distance(idxBackwardDist) > INLINE_DISTANCE_BOUND
            % Test the device independent sample density of this point.
            if dens(idxBackwardDist) <= ...
                    (mean(dens(location<0)) + std(dens(location<0))) ...
                    && ...
                    distance(idxBackwardDist) <= ...
                    INLINE_DISTANCE_BOUND_LOW_DENSITY
                % Its density is really low, and it's within the low
                % density inline distance bound, which means it's probably
                % still on the road, just not that sure as -50. So we will
                % label these points as -45.
                
            else
                BACKWARD_DIST_BREAKED = true;
                break;
            end
        end
    end
    
    if BACKWARD_DIST_BREAKED
        location(intersect( ...
            (indexBackwardProLimitFar + idxBackwardDist):(extendedRoadSequenceStart-1),...
            find(location == 0) ...
            )) = -45;
    else
        location(intersect( ...
            indexBackwardProLimitFar:(extendedRoadSequenceStart-1),...
            find(location == 0) ...
            )) = -45;
    end
    
    % Forward propagation.
    indexForwardProLimit = length(location);
    % Point to consider.
    xForwardPro = long(extendedRoadSequenceEnd+1:indexForwardProLimit);
    yForwardpro = lati(extendedRoadSequenceEnd+1:indexForwardProLimit);
    % Nearest points.
    xForwardNearest = (bFar.*( bFar.*xForwardPro - aFar.*yForwardpro) - aFar*cFar)./(aFar^2+bFar^2);
    yForwardNearest = (aFar.*(-bFar.*xForwardPro + aFar.*yForwardpro) - bFar*cFar)./(aFar^2+bFar^2);
    
    % Distances in meter.
    distance = -ones(length(xForwardPro),1); % Record distances computed for debugging.
    FORWARD_DIST_BREAKED = false;
    for idxForwardDist = 1:length(xForwardPro)
        distance(idxForwardDist) = lldistkm([yForwardpro(idxForwardDist) xForwardPro(idxForwardDist)],...
            [yForwardNearest(idxForwardDist) xForwardNearest(idxForwardDist)])*1000;
        if distance(idxForwardDist) > INLINE_DISTANCE_BOUND
            % Test the device independent sample density of this point.
            if dens((index4msRoadSequenceEnd+idxForwardDist-1)) <= ...
                    (mean(dens(location<0)) + std(dens(location<0)))...
                    && ...
                    distance(idxForwardDist) <= ...
                    INLINE_DISTANCE_BOUND_LOW_DENSITY
                % Its density is really low, and it's within the low
                % density inline distance bound, which means it's probably
                % still on the road, just not that sure as -50. So we will
                % label these points as -45.
                
            else
                FORWARD_DIST_BREAKED = true;
                break;
            end
        end
    end
    
    if FORWARD_DIST_BREAKED
        location(intersect( ...
            (extendedRoadSequenceEnd+1):(extendedRoadSequenceEnd+idxForwardDist-1),...
            find(location == 0) ...
            )) = -45;
    else
        location(intersect( ...
            (extendedRoadSequenceEnd+1):indexForwardProLimit, ...
            find(location == 0) ...
            )) = -45;
    end
end

% EOF