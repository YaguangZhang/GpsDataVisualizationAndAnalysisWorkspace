% %UPDATEANIMATION
% % Update the animation figure with one new frame according to currentTime.
% %
% % Yaguang Zhang, Purdue, 01/27/2015
% 
% currentGpsTime = currentTime + originGpsTime;
% 
% % Update the current sample to show according to currentGpsTime.
% currentSampleInd = zeros(length(filesToShow), 1);
% % Get the latitude, longitude and state for the shown vehicles.
% dotsToPlotLat = currentSampleInd;
% dotsToPlotLon = currentSampleInd;
% dotsToPlotSta = currentSampleInd;
% dateAndTime = ' '; %#ok<NASGU>
% 
% % Distinguish the routes where the vechicles have run on.
% hMapRoutesAlreadyRun = cell(length(filesToShow),1);
% for fileIndex = 1:1:length(filesToShow)
%     tempSampleInd = find(filesToShow(fileIndex).gpsTime > currentGpsTime,1,'first');
%     
%     if isempty(tempSampleInd)
%         tempSampleInd = length(filesToShow(fileIndex).gpsTime);
%     end
%     
%     currentSampleInd(fileIndex) = tempSampleInd;
%     dotsToPlotLat(fileIndex) = filesToShow(fileIndex).lat(tempSampleInd);
%     dotsToPlotLon(fileIndex) = filesToShow(fileIndex).lon(tempSampleInd);
%     dotsToPlotSta(fileIndex) = states{fileIndex}(tempSampleInd);
%     
%     hMapRoutesAlreadyRun{fileIndex} = geoshow(...
%         filesToShow(fileIndex).lat(1:tempSampleInd), ...
%         filesToShow(fileIndex).lon(1:tempSampleInd), ...
%         'Color', color{fileIndex}, ...
%         'DisplayType', 'line', 'LineWidth', 1, 'LineStyle', '-');
% end
% 
% dateAndTime = filesToShow(fileIndex).time{tempSampleInd};
% 
% % Plot current vehicle locations.
% % Color the vehicle accordingly.
% hMapVehicles = zeros(length(filesToShow),1);
% for indexMapVehicle = 1:1:length(filesToShow)
%     hMapVehiclesTemp =  geoshow(...
%         dotsToPlotLat(indexMapVehicle), dotsToPlotLon(indexMapVehicle), ...
%         'DisplayType', 'point', 'Marker', 'o',...
%         'LineWidth', 2, 'MarkerSize', 12, ...
%         'MarkerEdgeColor', 'red', 'MarkerFaceColor', color{indexMapVehicle});
%     if ~isempty(hMapVehiclesTemp)
%         hMapVehicles(indexMapVehicle) = hMapVehiclesTemp;
%     else
%         hMapVehicles(indexMapVehicle) = -1;
%     end
% end
% 
% % Use x to mark the locations more acurately.
% hMapVehiclesAcurateLoc = geoshow(dotsToPlotLat, dotsToPlotLon, ...
%     'DisplayType', 'point', 'Marker', 'x',...
%     'LineWidth', 1, 'MarkerSize', 12, ...
%     'Color', 'red');
% 
% if isempty(hMapVehiclesAcurateLoc)
%     hMapVehiclesAcurateLoc = -1;
% end
% 
% % Indicate the vehicle states beside the vehicle markers by
% % "L"(Loading),"U"(Unloading) and "-"(Unknown or anything else).
% hMapVehiclesStates = zeros(length(filesToShow),1);
% for indexMapVehicleState = 1:1:length(filesToShow)
%     
%     switch dotsToPlotSta(indexMapVehicleState)
%         case 1
%             tempCharState = 'L';
%         case 0
%             tempCharState = 'U';
%         otherwise
%             tempCharState = '-';
%     end
%     
%     % Adjust the parameter HorizontalAlignment so that vehicle number
%     % labels won't be obscured.
%     hMapVehiclesStatesTemp = textm( ...
%         dotsToPlotLat(indexMapVehicleState), dotsToPlotLon(indexMapVehicleState), ...
%         tempCharState, 'Color', color{indexMapVehicleState}, ...
%         'HorizontalAlignment', 'center', ...
%         'VerticalAlignment', 'bottom', ...
%         'FontSize', 13, 'FontWeight', 'bold');
%     
%     if ~isempty(hMapVehiclesStatesTemp)
%         hMapVehiclesStates(indexMapVehicleState) = hMapVehiclesStatesTemp;
%     else
%         hMapVehiclesStates(indexMapVehicleState) = -1;
%     end
% end
% 
% title1 = strcat('Current Time:', 23, num2str(currentTime));
% title2 = strcat('(', dateAndTime, ')');
% title({title1,  title2},'Interpreter','None','FontSize',12);
% 
% % Make sure the plots are effectively shown.
% pause(0.0000000001);
% 
% % EOF