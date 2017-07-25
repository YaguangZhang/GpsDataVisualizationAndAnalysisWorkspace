%UPDATEVEHICLEMARKERS
% Update the vehicle markers in the animation figure.
%
% Update 02/05/2015: record the locations for computing the distance
% between vehicles.
%
% Yaguang Zhang, Purdue, 01/27/2015

% Handles.
hMapVehicles = -ones(length(filesToShow),1);
hMapVehiclesAcurateLoc = hMapVehicles;
hMapVehiclesVelocity = [-1; -1]; % If the value is not -1, it has been updated. 
hMapVehiclesDoneAcurateLoc = hMapVehicles;
hMapVehiclesStates = hMapVehicles;

% Keep a record of visible vehicles' indices regard to "filesToShow".
indicesVisibleVehicles = [];

% Initialize flags for the trigged state setting buttons if necessary.
if ~exist('flagStateSettingButtonsTriggered', 'var')
    flagStateSettingButtonsTriggered = zeros(length(filesToShow),1);
end

% Make sure we are working on the map area of the animation figure.
if gca ~= hAnimationMapArea
    set(0,'CurrentFigure',hAnimationFig);
    set(hAnimationFig, 'CurrentAxes', hAnimationMapArea);
end

% Color the vehicle accordingly.
for indexMapVehicle = 1:1:length(filesToShow)
    % Use another color for vehicles which are shown but are not active
    % anymore.
    if colorAsDone(indexMapVehicle)
        markerEdgeColor = COLOR.DONE;
        markerFaceColor = COLOR.DONE;
        
        % We can disable the state setting buttons if they are triggered
        % since there's no need to rewrite its state.
        if(flagStateSettingButtonsTriggered(indexMapVehicle))
            % Call the script.m directly.
            FLAG_CALL_TRIGGER_STATE_SETTING_BUTTONS = 1;
            triggerStateSettingButtons;
            clear FLAG_CALL_TRIGGER_STATE_SETTING_BUTTONS;
            
            statesToWriteNow(indexMapVehicle) = NaN;
        end
        
    else
        markerEdgeColor = COLOR.HIGH_LIGHT;
        markerFaceColor = color{indexMapVehicle};
    end
    
    hMapVehiclesTemp =  geoshow(hMap, ...
        dotsToPlotLat(indexMapVehicle), dotsToPlotLon(indexMapVehicle), ...
        'DisplayType', 'point', 'Marker', 'o',...
        'LineWidth', 2, 'MarkerSize', 12, ...
        'MarkerEdgeColor', markerEdgeColor, ...
        'MarkerFaceColor', color{indexMapVehicle});
    
    % Record the locations of the vehicles on the animation for computing
    % the distances between them.
    lastDotsToPlotLat = dotsToPlotLat;
    lastDotsToPlotLon = dotsToPlotLon;
    
    % Note that the elements of hMapVehicles have already been initialized
    % as -1's.
    if ~isempty(hMapVehiclesTemp)
        % Returned handle is valid, which means the mark can be seen in the
        % animation.
        hMapVehicles(indexMapVehicle) = hMapVehiclesTemp;
        
        % Use x to mark the locations more acurately. Althought these markers
        % are of the same color and thus can be set using only one geoshow, we
        % need to make sure different parts of one vehicle's marker are always
        % together. So we use a slower methed and plot them separately.
        
        hMapVehiclesAcurateLocTemp = geoshow(hMap, ...
            dotsToPlotLat(indexMapVehicle), dotsToPlotLon(indexMapVehicle), ...
            'DisplayType', 'point', 'Marker', 'x',...
            'LineWidth', 1, 'MarkerSize', 12, ...
            'MarkerEdgeColor', markerEdgeColor);
        
        if ~isempty(hMapVehiclesAcurateLocTemp)
            hMapVehiclesAcurateLoc(indexMapVehicle) = hMapVehiclesAcurateLocTemp;
        end
        
        % Used to estimate current vehicles' velocity directions.
        indicesVisibleVehicles = [indicesVisibleVehicles indexMapVehicle];
        
        % Indicate the vehicle states beside the vehicle markers by
        % "L"(Loading),"U"(Unloading) and "-"(Unknown or anything else).
        switch dotsToPlotSta(indexMapVehicle)
            case 1
                tempCharState = 'L';
            case -1
                tempCharState = 'U';
            otherwise
                tempCharState = '-';
        end
        
        % Adjust the parameter HorizontalAlignment to be left so that vehicle
        % number labels won't be obscured. The state labels are where the
        % state setting buttons can be triggered.
        hMapVehiclesStatesTemp = textm( ...
            dotsToPlotLat(indexMapVehicle), dotsToPlotLon(indexMapVehicle), ...
            tempCharState, 'Color', 'white', ...
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'bottom', ...
            'FontSize', 13, 'FontWeight', 'bold', ...
            'Tag', num2str(indexMapVehicle), ...
            'ButtonDownFcn', 'triggerStateSettingButtons');
        
        if ~isempty(hMapVehiclesStatesTemp)
            hMapVehiclesStates(indexMapVehicle) = hMapVehiclesStatesTemp;
        end
   
    end
end

% Show the estimated velocity directions.
if exist('dotsToPlotLatNext','var') & SHOW_VELOCITY_DIRECTIONS
    if ~any(isnan(dotsToPlotLatNext(indicesVisibleVehicles))) ...
            && ~isempty(indicesVisibleVehicles)
        hMapVehiclesVelocity = quiverm(dotsToPlotLat(indicesVisibleVehicles), ...
            dotsToPlotLon(indicesVisibleVehicles), ...
            dotsToPlotLatNext(indicesVisibleVehicles) - dotsToPlotLat(indicesVisibleVehicles),...
            dotsToPlotLonNext(indicesVisibleVehicles) - dotsToPlotLon(indicesVisibleVehicles),...
            'r');
    end
end

% EOF