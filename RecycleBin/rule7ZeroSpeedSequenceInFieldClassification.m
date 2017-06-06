% RULE 7.
            
            % Find subsequences where the vehicle is of 0 speed (or almost
            % 0).
            [indicesZeroSpeedSeqStart,indicesZeroSpeedSeqEnd] = ...
                findConsecutiveSubSeq(spee<=0.2,1);
            % Find members long enough.
            indicesLongZeroSpeedSeqs = find(...
                time(indicesZeroSpeedSeqEnd)-time(indicesZeroSpeedSeqStart)...
                >STATIC_MIN_TIME_THRESHOLD...
                );
            % Only keep those long enough.
            indicesZeroSpeedSeqStart = indicesZeroSpeedSeqStart(indicesLongZeroSpeedSeqs);
            indicesZeroSpeedSeqEnd = indicesZeroSpeedSeqEnd(indicesLongZeroSpeedSeqs);
            
            % Should be only a few left. So using loops now should be fine.
            for idxLongZeroSpeedSeq = 1:length(indicesLongZeroSpeedSeqs)
                indicesLongZeroSpeedSeq = ...
                    indicesZeroSpeedSeqStart(idxLongZeroSpeedSeq): ...
                    indicesZeroSpeedSeqEnd(idxLongZeroSpeedSeq);
                locLongZeroSpeedSeq = location(indicesLongZeroSpeedSeq);
                if all(locLongZeroSpeedSeq==0)
                    % No point is labeled yet. Need to label them all.
                    
                    % If the tale after (or head before) the sequence is
                    % short enough, we will mark them as -90. In this case,
                    % we've taken care the stop at the begining and at the
                    % end of the whole route, if there's any.
                    headTimeLength = max(0,time(indicesLongZeroSpeedSeq(1))-time(1));
                    taleTimeLength = max(0,time(end)-time(indicesLongZeroSpeedSeq(end)));
                    if ...
                            headTimeLength<STATIC_MAX_TALE_TIME_THRESHOLD ...
                            ||...
                            taleTimeLength<STATIC_MAX_TALE_TIME_THRESHOLD
                        location(indicesLongZeroSpeedSeq) = -90;
                    end
                    
                    % Other cases can be too complicated. So we do nothing
                    % for now.
                    
                else
                    % Check the consistency of those labeled points.
                    indicesLabeledElements = find(locLongZeroSpeedSeq~=0);
                    loc = locLongZeroSpeedSeq(indicesLabeledElements(1));
                    
                    if any(locLongZeroSpeedSeq~=loc)
                        % Not consistent. Give a warning and use the first
                        % label anyway.
                        disp('Found a sequence of zero speed but not labeled at the same location.');
                        warning('Inconsistently labeled zero-speed sequence.');
                    end
                    
                    % Label the unlabeled points in this sequence.
                    location(setdiff(...
                        indicesZeroSpeedSeqStart(idxLongZeroSpeedSeq): ...
                        indicesZeroSpeedSeqEnd(idxLongZeroSpeedSeq),...
                        indicesLongZeroSpeedSeq(indicesLabeledElements)...
                        ))=loc;
                    
                end
            end