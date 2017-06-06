%LABELSTATESBYDIS A helper script for genStatesByDis.m.
%
% Actually carries out the state labeling task. Please set fromType (a
% string) and toType (a string or a string cell if multiple types are
% needed) accordingly to confine the labeling to specific types of
% vehicles.
%
% Yaguang Zhang, Purdue, 09/16/2015

% For labeling combines as harvesting.
% [0.044704, 6.7056] m/s (i.e. ~[0.1, 15] MPH)
MIN_HARVEST_SPE = 0.044704;
MAX_HARVEST_SPE = 6.7056;

for idxFile = 1:length(files)
    if strcmpi(files(idxFile).type, fromType)
        disp(strcat(...
            num2str(idxFile),'/',num2str(length(files))...
            ));
        % Only label combines for harvesting.
        if strcmpi(files(idxFile).type, 'Combine')
            % Treat as harvesting as long as it's in-field and moving in
            % the speed range of [MIN_HARVEST_SPE, MAX_HARVEST_SPE] m/s.
            statesByDist{idxFile}(...
                locations{idxFile}==0 & files(idxFile).speed>=MIN_HARVEST_SPE & files(idxFile).speed<=MAX_HARVEST_SPE, ...
                1) ... loadFrom
                = 0; % Loading from the fields, i.e. harvesting.
        end
        
%         % Only label trucks for dumpting to a factory.
%         if strcmpi(files(idxFile).type, 'Truck')
%             % Treat as harvesting as long as it's in-field.
%             statesByDist{idxFile}(locations{idxFile}==0,1) ... loadFrom
%                 = 0; % Loading from the fields, i.e. harvesting.
%         end
        
        % For unloading part, we need to first find the consecutive nearest
        % vehicles.
        indexNearestVehFile = nearestVehicles{idxFile}(:,1);
        % Discard samples beforing ever coming into a field.
        [indicesStarts, indicesEnds] = ...
            findConsecutiveSubSeq(locations{idxFile}~=0,1);
        if ~isempty(indicesStarts)
            if indicesStarts(1) == 1
                indexNearestVehFile(1:indicesEnds(1)) = nan;
            end
        end
        [indicesConsNearestStarts, indicesConsNearestEnds, consNearestValues] ...
            = findConsecutiveSubSeqs(indexNearestVehFile);
        % Find tentative "in action" samples.
        possibleInActionStartAll = find( ...
            nearestVehicles{idxFile}(:,2) ... minDist
            < DISTANCE_NEARBY_VEHICLES - DISTANCE_NEARBY_VEHICLES_PADDING);
        possibleInActionEndAll = find( ...
            nearestVehicles{idxFile}(:,2) ... minDist
            > DISTANCE_NEARBY_VEHICLES + DISTANCE_NEARBY_VEHICLES_PADDING);
        
        for idxConsNearestVeh = 1:length(indicesConsNearestStarts)
            % Check the toType.
            if any(strcmpi( ...
                    files(consNearestValues(idxConsNearestVeh)).type, ...
                    toType ...
                    ))
                
                % Truncate variables.
                possibleInActionStart = ...
                    possibleInActionStartAll( ...
                    possibleInActionStartAll>=indicesConsNearestStarts(idxConsNearestVeh) ...
                    & ...
                    possibleInActionStartAll<=indicesConsNearestEnds(idxConsNearestVeh) ...
                    );
                
                possibleInActionEnd = ...
                    possibleInActionEndAll( ...
                    possibleInActionEndAll>=indicesConsNearestStarts(idxConsNearestVeh) ...
                    & ...
                    possibleInActionEndAll<=indicesConsNearestEnds(idxConsNearestVeh) ...
                    );
                
                lastInActionEnd = 0;
                for idxInActionStart = 1:length(possibleInActionStart)
                    flagDoneLooping = false;
                    % Skip elements in the "in-action" sequence.
                    if possibleInActionStart(idxInActionStart) > lastInActionEnd
                        lastInActionEnd = possibleInActionEnd(find( ...
                            possibleInActionEnd > possibleInActionStart(idxInActionStart), ...
                            1, 'first'));
                        
                        if isempty(lastInActionEnd)
                            % No skipping the in-action state for this
                            % vehicle.
                            lastInActionEnd = ...
                                indicesConsNearestEnds(idxConsNearestVeh);
                            flagDoneLooping = true;
                        end
                        
                        % Set unloadTo if the subsequence passes the time
                        % threshold test.
                        if files(idxFile).gpsTime(lastInActionEnd) ...
                                - files(idxFile).gpsTime(possibleInActionStart(idxInActionStart)) ...
                                >= MIN_TIME_BEING_NEARBY_TO_TAKE_ACTIONS * 1000
                            indexFileUnloadTo = consNearestValues(idxConsNearestVeh);
                            statesByDist{idxFile}( ...
                                possibleInActionStart(idxInActionStart):lastInActionEnd, ...
                                2) ... unloadTo
                                = indexFileUnloadTo;
                            
                            % Accordingly, set loadFrom for the other
                            % vehicle.
                            statesByDist{indexFileUnloadTo}( ...
                                files(indexFileUnloadTo).gpsTime >= files(idxFile).gpsTime(possibleInActionStart(idxInActionStart)) ...
                                &files(indexFileUnloadTo).gpsTime <= files(idxFile).gpsTime(lastInActionEnd), ...
                                1) ... loadFrom
                                = idxFile;
                        end
                        
                        if flagDoneLooping
                            break;
                        end
                        
                    end % if possibleInActionStart(idxInActionStart) > lastInActionEnd
                end % for idxInActionStart = 1:length(possibleInActionStart)
            end % Check the toType.
        end % for idxConsNearestVeh = 1:length(indicesConsNearestStarts)
        
        
        % Generate debug plot if necessary.
        if FLAG_DEBUG
            if ~exist('hDebugFig','var')
                hDebugFig =  figure('Name', 'genStatesByDist_DEBUG', ...
                    'NumberTitle', 'off', ...
                    'Units','normalized', ...
                    'OuterPosition',[0.05 0.05 0.9 0.9]);
            end
            
            hDebugFigEle = nan(3,1);
            
            hold on;
            hDebugFigEle(1) = plot( ...
                nearestVehicles{idxFile}(:, 1), ... indexNearestVehFile
                'k*');
            hDebugFigEle(2) = plot( ...
                nearestVehicles{idxFile}(:, 2), ... minDist
                'b-');
            hDebugFigEle(3) = plot( ...
                statesByDist{idxFile}(:, 2), ... unloadTo
                'r+');
            hold off;
            grid on;
            legend('indexNearestVehFile', 'minDist', 'unloadTo');
            
            disp('Press any key to continue...');
            pause;
            
            delete(hDebugFigEle);
        end
    end
end

% EOF