% LOWDENSITYCOLINEARSEQPROP Low-density colinear sequences' propagation.
%
% This script is the implementation of Rule 6. It will find the long-enough
% low-density colinear sequences from currently zero-labeled points, and
% does a proper inline propagation accordingly.
%
% Yaguang Zhang, Purdue, 03/17/2015

if any(location<0)
    % Find sequences which are still not labeled (location is 0). We will
    % use the same code for finding -100 sequences before. In order to do
    % that, we need to change 0 to -100 and all other labels (so far only
    % negative ones) to 0.
    diffLocation = -100*ones(length(location),1);
    diffLocation(location<0) = 0;
    diffLocation = diff([0;diffLocation;0]);
    
    indicesUnlabeledSequenceStart = find(diffLocation==-100); % start
    indicesUnlabeledSequenceEnd = find(diffLocation==100)-1; % end
    
    for indexUnlabeledSeq = 1:length(indicesUnlabeledSequenceStart)
        
        % Find sequences with really low sample densities (less or equal to
        % mean of sample points labeled -100, which are most likely to be
        % on the road). We will use here the same code for finding -100
        % sequences before. In order to do that, we need to change low
        % sample densities to -100 and all other labels (higher densities)
        % to 0.
        indicesUnlabeledSeq = indicesUnlabeledSequenceStart(indexUnlabeledSeq):...
            indicesUnlabeledSequenceEnd(indexUnlabeledSeq);
        
        % Stricter test of sample density. The mean sample density of the
        % sequence should be really low, if not less than the mean sample
        % density of the really-sure road (-100).
        thresholdLowDensity = max(mean(dens(location == -100)),...
            THRESHOLD_REALLY_LOW_DENSITY);
        
        % There's no need to test this sequence if it's always with low
        % sample density (e.g. runs into the field but come out with one
        % loop).
        if mean(indicesUnlabeledSeq) > thresholdLowDensity
            
            diffLowDens = -100*ones(length(indicesUnlabeledSeq),1);
            diffLowDens(dens(indicesUnlabeledSeq)>...
                thresholdLowDensity) = 0;
            diffLowDens = diff([0;diffLowDens;0]);
            
            % In terms of 1:indicesUnlabeledSeq.
            indicesUnlabeledLowDensSequenceStart = find(diffLowDens==-100); % start
            indicesUnlabeledLowDensSequenceEnd = find(diffLowDens==100)-1; % end
            
            % Test whether any of these sequences is in a line. If so, mark
            % that sequence as on the road (-60). Here, we will use the
            % stricter distance bound INLINE_DISTANCE_BOUND even though
            % there points are with low densities, just to make sure they
            % are more likely to be on the road.
            for indexUnlabeledLowDensSequence = 1:length(indicesUnlabeledLowDensSequenceStart)
                % Copy data of the low-density sequence.
                indicesLowDensUnlabeledSeq = ...
                    indicesUnlabeledSeq(...
                    indicesUnlabeledLowDensSequenceStart(indexUnlabeledLowDensSequence):...
                    indicesUnlabeledLowDensSequenceEnd(indexUnlabeledLowDensSequence)...
                    );
                % Make sure at least 2 points are available.
                if length(indicesLowDensUnlabeledSeq) > 1
                    longLow =  long(indicesLowDensUnlabeledSeq);
                    latiLow = lati(indicesLowDensUnlabeledSeq);
                    
                    % The line for those low-density points: aLow*x +
                    % bLow*y + cLow = 0.
                    if MAP
                        % Light grey.
                        [aLow,bLow,cLow] = fitPoly1(longLow,latiLow, ...
                            GRADIENT_BOUND_G_TO_DISCARD_F, hFigureMapInField, [0.75, 0.75, 0.75]);
                    else
                        [aLow,bLow,cLow] = fitPoly1(longLow,latiLow, ...
                            GRADIENT_BOUND_G_TO_DISCARD_F);
                    end
                    
                    % Test the distance of every point of the sequence to
                    % this line. First, find the nearest points.
                    xLowNearest = (bLow.*( bLow.*longLow - aLow.*latiLow) - aLow*cLow)./(aLow^2+bLow^2);
                    yLowNearest = (aLow.*(-bLow.*longLow + aLow.*latiLow) - bLow*cLow)./(aLow^2+bLow^2);
                    
                    % Distance in meter.
                    distance = -ones(length(latiLow),1);
                    % Low-density sequence inline test.
                    LOW_DEN_SEQ_INLINE_TEST_BREAKED = false;
                    for idxInlineTest = 1:length(latiLow)
                        distance(idxInlineTest) = lldistkm([latiLow(idxInlineTest) longLow(idxInlineTest)],...
                            [yLowNearest(idxInlineTest) xLowNearest(idxInlineTest)])*1000;
                    end
                    
                    % Find a long enough inline subsequence.
                    [indicesInlineSubSeqStart,indicesInlineSubSeqEnd] = ...
                        findConsecutiveSubSeq(...
                        distance<=INLINE_DISTANCE_BOUND_LOW_DEN_SEQ,1 ...
                        );
                    
                    if isempty(indicesInlineSubSeqStart)
                        % No subsequence was found. Nothing needs to be
                        % done.
                    else
                        for indexSubSeq = 1:length(indicesInlineSubSeqStart)
                            
                            if time(...
                                    indicesLowDensUnlabeledSeq(indicesInlineSubSeqEnd(indexSubSeq)) ...
                                    ) - time(...
                                    indicesLowDensUnlabeledSeq(indicesInlineSubSeqStart(indexSubSeq)) ...
                                    )>LOW_DEN_TIME_THRESHOLD ...
                                    && ...
                                    max(dens(indicesUnlabeledSeq))>mean(dens);
                                
                                % Long enough and near a high sample
                                % density area.
                                
                                indicesLowDenSubSeq = indicesLowDensUnlabeledSeq(...
                                    indicesInlineSubSeqStart(indexSubSeq):indicesInlineSubSeqEnd(indexSubSeq)...
                                    );
                                
                                % Use a special float label to indicate
                                % this sequence needs further tests.
                                location(intersect(...
                                    indicesLowDenSubSeq,...
                                    find(location==0)...
                                    )) = -60.5;
                                % Inline propagation.
                                inlineProForLowDenSubSeq;
                                
                            end % Test time length of the subsequence.
                        end % Loop for inline subsequences.
                    end % Make sure the low density subsequences isn't empty.
                end % And has at least 2 points.
            end % Loop for low density subsequences.
        end % Avoid mark one-loop field trip as on the road.
    end
end

% EOF