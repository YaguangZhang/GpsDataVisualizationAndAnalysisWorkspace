%UPDATEFLAGMAPVEHICLEDISTSLINKS
% Update the variable flagMapVehicleDistsLinks.
%
% flagMapVehicleDistsLinks indicates whether there will be links plotted
% for the vehicle pairs.
%
% Yaguang Zhang, Purdue, 02/06/2015

src = gco(hAnimationFig);
pressedVehicleLabel = get(src, 'String');
pressedVehicleNum = str2double(pressedVehicleLabel);

% Clear hints if necessary.
if ishghandle(hMapVehicleDistsHintUpdateLinks)
    delete(hMapVehicleDistsHintUpdateLinks);
end

if ~exist('currentActivatedVehicleFirstNode', 'var')
    currentActivatedVehicleFirstNode = -1;
end

% Clear flags if the first node is -1.
if currentActivatedVehicleFirstNode == -1
    currentActivatedVehicleSecondNode = -1;
end

% If (-1, -1), update the first node.
if currentActivatedVehicleFirstNode == -1 && currentActivatedVehicleSecondNode == -1;
    % Check the pressed vehicle label just to be safe.
    if(pressedVehicleNum ~= -1)
        
        currentActivatedVehicleFirstNode = pressedVehicleNum;
        
        % Hints for the user to notify that the first node of the link is
        % successfully chosen.
        hMapVehicleDistsHintUpdateLinks = uicontrol('Style', 'text', ...
            'String', strcat('The first node chosen is', 23, pressedVehicleLabel), ...
            'FontSize', 11, ...
            'Position', [10 500 WIDTH_LEFTSIDE_HINT_PIXELS 40],...
            'BackgroundColor', get(hAnimationFig, 'Color'));
        
    end
elseif currentActivatedVehicleFirstNode ~= -1 && currentActivatedVehicleSecondNode == -1;
    % Or, if (not -1, -1), update the second node and activate the link.
    currentActivatedVehicleSecondNode = pressedVehicleNum;
    
    % Update link flags only if the two nodes are different.
    if currentActivatedVehicleFirstNode ~= currentActivatedVehicleSecondNode
        
        indexFlageMapVehicleDistsLink(1) = min(currentActivatedVehicleFirstNode,currentActivatedVehicleSecondNode);
        indexFlageMapVehicleDistsLink(2) = max(currentActivatedVehicleFirstNode,currentActivatedVehicleSecondNode);
        
        % Update link flag.
        flagMapVehicleDistsLinks(indexFlageMapVehicleDistsLink(1),indexFlageMapVehicleDistsLink(2)) = ...
            ~flagMapVehicleDistsLinks(indexFlageMapVehicleDistsLink(1),indexFlageMapVehicleDistsLink(2));
        
        % Re-plot links.
        clearVehicleDistancesAndStates;
        showVehicleDistancesAndStates;
        
        % Clear hints if necessary.
        if ishghandle(hMapVehicleDistsHintUpdateLinks)
            delete(hMapVehicleDistsHintUpdateLinks);
        end

        if flagMapVehicleDistsLinks(indexFlageMapVehicleDistsLink(1),indexFlageMapVehicleDistsLink(2))
            % A new link is activated.
            hMapVehicleDistsHintUpdateLinks = uicontrol('Style', 'text', ...
                'String', strcat('New link activated:', 23, ...
                num2str(indexFlageMapVehicleDistsLink(1)),' to', 23, ...
                num2str(indexFlageMapVehicleDistsLink(2))), ...
                'FontSize', 11, ...
                'Position', [10 BOTTOM_DIST_HINT_PIXELS ...
                WIDTH_LEFTSIDE_HINT_PIXELS HEIGHT_LEFTSIDE_HINT_PIXELS],...
                'BackgroundColor', get(hAnimationFig, 'Color'));
        else
            % A link is de-activated.
            hMapVehicleDistsHintUpdateLinks = uicontrol('Style', 'text', ...
                'String', strcat('Link de-activated:', 23, ...
                num2str(indexFlageMapVehicleDistsLink(1)),' to', 23, ...
                num2str(indexFlageMapVehicleDistsLink(2))), ...
                'FontSize', 11, ...
                'Position', [10 BOTTOM_DIST_HINT_PIXELS ...
                WIDTH_LEFTSIDE_HINT_PIXELS HEIGHT_LEFTSIDE_HINT_PIXELS],...
                'BackgroundColor', get(hAnimationFig, 'Color'));
        end
    else
        % No change occurs.
            hMapVehicleDistsHintUpdateLinks = uicontrol('Style', 'text', ...
                'String', 'Two nodes are the same. No change occurs.', ...
                'FontSize', 11, ...
                'Position', [10 BOTTOM_DIST_HINT_PIXELS ...
                WIDTH_LEFTSIDE_HINT_PIXELS HEIGHT_LEFTSIDE_HINT_PIXELS],...
                'BackgroundColor', get(hAnimationFig, 'Color'));
    end
    
    % Clear the first node.
    currentActivatedVehicleFirstNode = -1;
else
    % Clear the first node.
    currentActivatedVehicleFirstNode = -1;
end

% EOF