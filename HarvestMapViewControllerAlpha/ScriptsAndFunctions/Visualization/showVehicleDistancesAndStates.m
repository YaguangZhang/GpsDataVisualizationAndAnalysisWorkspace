%SHOWVEHICLEDISTANCES
% Compute the distances between vehicles shown on the animation. The
% external function lldistkm is used. The vehicles will be labeled by
% numbers. A line will be drawn between the vehicles with the distance
% plotted near the line. Also, all distances between the vehicles will be
% shown on the right-hand side of the window.
%
% Yaguang Zhang, Purdue, 02/05/2015

% Number of vehicles on the animation at current time.
vehicleNum = length(lastDotsToPlotLat);

% Initialize flags for the existing links if necessary.
if ~exist('flagMapVehicleDistsLinks', 'var')
    flagMapVehicleDistsLinks = zeros(length(lastDotsToPlotLat));
end

% Only plot the distances when there are more than 1 point shown.
if vehicleNum > 1
    
    % Initialization.
    pairCounter = 0; % How many links have been plotted.
    counterVehicleDistsText = 0; % How many distance labels (uicontrols) have been added.
    
    % Handlers for links between vehicles. Make it -1 to make sure it's
    % invalid for a hghandler.
    hMapVehicleDistsLinks = - ones(vehicleNum*(vehicleNum-1)/2,1);
    % Handlers distance labels on the links.
    hMapVehicleDistsText = hMapVehicleDistsLinks;
    hVehicleDistsText = hMapVehicleDistsLinks;
    hMapVehicleText = - ones(vehicleNum,1);
    distances = zeros(vehicleNum);
    
    % Add hints for where the labels will be shown.
    % Get the size of the animation figure.
    tempHAnimationFigPosition = get(hAnimationFig, 'Position');
    set(hAnimationFig, 'Units', 'pixels');
    % [left bottom width height]
    positionAnimationFig = get(hAnimationFig, 'Position');
    % Set the unit back.
    set(hAnimationFig, 'Units', 'normalized');
    set(hAnimationFig, 'Position',tempHAnimationFigPosition);
    
    % Compute the location for the vehicle distance label.
    % Parameters like VEHICLE_DISTS_TEXT_GROUP_RIGHT are
    % specified in createAnimationFig.m.
    tempPositionVehicleDistsText = zeros(1,2);
    % [left bottom]
    tempPositionVehicleDistsText(1) = ...
        positionAnimationFig(1)+positionAnimationFig(3)...
        -VEHICLE_DISTS_TEXT_GROUP_RIGHT-VEHICLE_DISTS_TEXT_WIDTH;
    tempPositionVehicleDistsText(2) = ...
        positionAnimationFig(2)+positionAnimationFig(4)...
        -VEHICLE_DISTS_TEXT_GROUP_TOP-VEHICLE_DISTS_TEXT_HEIGHT...
        -VEHICLE_DISTS_TEXT_HEIGHT*counterVehicleDistsText;
    
    hHintVehicleDistsText = uicontrol(...
        'Style', 'text', ...
        'String', 'Distances(m)', ...
        'FontSize', 11, ...
        'Position', ... // [left bottom width height]
        [tempPositionVehicleDistsText ...
        VEHICLE_DISTS_TEXT_WIDTH VEHICLE_DISTS_TEXT_HEIGHT],...
        'HorizontalAlignment','left',...
        'BackgroundColor', get(hAnimationFig, 'Color'));
    
    counterVehicleDistsText = counterVehicleDistsText + 1;
    
    for k=1:1:vehicleNum
        
        for l = 1:1:vehicleNum
            if k < l
                
                pairCounter = pairCounter + 1;
                
                % The output of lldistkm is in km. We use "meter" instead.
                % Also, we will get rid of everything after the decimal
                % point. We store distances in a upper-triangular matrice.
                distances(k,l) = ceil(lldistkm(...
                    [lastDotsToPlotLat(k) lastDotsToPlotLon(k)],...
                    [lastDotsToPlotLat(l) lastDotsToPlotLon(l)])*1000);
                
                % Only show the link and distance label on the animation if
                % the user has said so.
                if flagMapVehicleDistsLinks(k,l)
                    % Link the vehicles.
                    tempHMapVehicleDistsLink = geoshow(hMap, ...
                        lastDotsToPlotLat([k,l]), ...
                        lastDotsToPlotLon([k,l]), ...
                        'Color', COLOR_VEHICLE_DISTS_LINKS, ...
                        'DisplayType', 'line', 'LineWidth', 1, 'LineStyle', '-');
                    
                    if ~isempty(tempHMapVehicleDistsLink)
                        hMapVehicleDistsLinks(pairCounter) = tempHMapVehicleDistsLink;
                    end
                    
                    % Label the distances.
                    set(0,'currentFigure',hAnimationFig);
                    
                    hMapVehicleDistsText(pairCounter) = textm( ...
                        (lastDotsToPlotLat(k) + lastDotsToPlotLat(l))/2, ...
                        (lastDotsToPlotLon(k) + lastDotsToPlotLon(l))/2, ...
                        num2str(distances(k,l)), ...
                        'FontSize', 13, 'FontWeight', 'bold', ...
                        'HorizontalAlignment', 'center');
                end
                
                % Get the size of the animation figure.
                tempHAnimationFigPosition = get(hAnimationFig, 'Position');
                set(hAnimationFig, 'Units', 'pixels');
                % [left bottom width height]
                positionAnimationFig = get(hAnimationFig, 'Position');
                % Set the unit back.
                set(hAnimationFig, 'Units', 'normalized');
                set(hAnimationFig, 'Position',tempHAnimationFigPosition);
                
                % Compute the location for the vehicle distance label.
                % Parameters like VEHICLE_DISTS_TEXT_GROUP_RIGHT are
                % specified in createAnimationFig.m.
                tempPositionVehicleDistsText = zeros(1,2);
                % [left bottom]
                tempPositionVehicleDistsText(1) = ...
                    positionAnimationFig(1)+positionAnimationFig(3)...
                    -VEHICLE_DISTS_TEXT_GROUP_RIGHT-VEHICLE_DISTS_TEXT_WIDTH;
                tempPositionVehicleDistsText(2) = ...
                    positionAnimationFig(2)+positionAnimationFig(4)...
                    -VEHICLE_DISTS_TEXT_GROUP_TOP-VEHICLE_DISTS_TEXT_HEIGHT...
                    -VEHICLE_DISTS_TEXT_HEIGHT*counterVehicleDistsText;
                
                hVehicleDistsText(pairCounter) = uicontrol(...
                    'Style', 'text', ...
                    'String', strcat(num2str(k), 23, 'to', 23, num2str(l),':', 23, num2str(distances(k,l))), ...
                    'FontSize', 11, ...
                    'Position', ... // [left bottom width height]
                    [tempPositionVehicleDistsText ...
                    VEHICLE_DISTS_TEXT_WIDTH VEHICLE_DISTS_TEXT_HEIGHT],...
                    'HorizontalAlignment','left',...
                    'BackgroundColor', get(hAnimationFig, 'Color'));
                
                counterVehicleDistsText = counterVehicleDistsText + 1;
                
            end
        end
        
        % Label the vehicles.
        set(0,'currentFigure',hAnimationFig);
        
        hMapVehicleText(k) = textm( ...
            lastDotsToPlotLat(k), lastDotsToPlotLon(k), ...
            num2str(k), 'Color', 'white', ...
            'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'bottom', ...
            'FontSize', 13, 'FontWeight', 'bold', ...
            'ButtonDownFcn', 'updateFlagMapVehicleDistsLinks');
    end
    
    if ~exist('hMapVehicleDistsHintUpdateLinks', 'var')
        hMapVehicleDistsHintUpdateLinks = -1;
    end
    
    if ~ishghandle(hMapVehicleDistsHintUpdateLinks)
        % Hints for the user to link vehicles.
        hMapVehicleDistsHintUpdateLinks = uicontrol('Style', 'text', ...
            'String', ...
            'Click the number labels of two vehicles to link / unlink them and show their distance on the animation.', ...
            'FontSize', 11, ...
            'Position', [10 BOTTOM_DIST_HINT_PIXELS WIDTH_LEFTSIDE_HINT_PIXELS 50],...
            'BackgroundColor', get(hAnimationFig, 'Color'));
    end
end

% EOF