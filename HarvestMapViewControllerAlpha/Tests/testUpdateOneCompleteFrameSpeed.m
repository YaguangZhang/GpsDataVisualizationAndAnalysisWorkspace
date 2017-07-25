if exist('currentTimeForThisFrame', 'var')
            currentTimeForLastFrame = currentTimeForThisFrame;
        end
        
        currentTimeForThisFrame = currentTime;
        % The animation generation of this loop will only use
        % currentGpsTime, in case the variable "currentTime" is updated
        % by the user unexpected.
        currentGpsTime = currentTimeForThisFrame + originGpsTime;
        
        % Update states if the user set it. We will change the state as
        % long as the state setting button is pressed.
        if exist('statesToWriteNow','var')
            % User has triggered at least one group of state setting
            % buttons.
            if ~all(isnan(statesToWriteNow))
                % At least one button is pressed.
                for indexVehicleUpdateState = 1:1:length(filesToShow)
                    if ~isnan(statesToWriteNow(indexVehicleUpdateState))
                        timeStartSetting = ...
                            max(currentTimeStateSettingButtonLastDown, ...
                            currentTimeForLastFrame);
                        timePointsTemp = ...
                            filesToShow(indexVehicleUpdateState).gpsTime ...
                            - originGpsTime;
                        % We will set all the states between
                        % timeStartSetting (included) and
                        % currentTimeForThisFrame (excluded).
                        indicesStateToSetTemp = intersect(...
                            find(timePointsTemp>=timeStartSetting),...
                            find(timePointsTemp<currentTimeForThisFrame));
                        states{filesToShowIndices(indexVehicleUpdateState)}(indicesStateToSetTemp) ...
                            = statesToWriteNow(indexVehicleUpdateState);
                        flagStatesManuallySet{filesToShowIndices(indexVehicleUpdateState)}(indicesStateToSetTemp) ...
                            = 1;
                    end
                end
            end
        end
        
        if UPDATE_MAP_LIMITS
            updateMapLimitsRem; %#ok<UNRCH>
        end
        
        % Update one frame for the animation.
        updateAnimationFrame;
        
        if strcmp(get(hAnimationFig, 'Visible'),'off')
            set(hAnimationFig, 'Visible', 'on');
        end
        
        if GENERATE_MOV
            if ~exist('animationFigPosition', 'var')
                animationFigPosition = get(hAnimationFig, 'Position');
            end
            set(hAnimationFig, 'Position', animationFigPosition);
            frameNum = frameNum + 1;
            F(frameNum) = getframe(hAnimationFig);
        end
        
        currentTime = currentTime + MILLISEC_PER_FRAME;