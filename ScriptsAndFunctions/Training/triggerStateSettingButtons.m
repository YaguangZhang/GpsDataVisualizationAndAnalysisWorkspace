%TRIGGERSTATESETTINGBUTTONS
% Update the flag "flagStateSettingButtonsTriggered" to indicate whether
% the vehicle state collection buttons should be triggered.
%
% Yaguang Zhang, Purdue, 02/18/2015

% Depending on how the script "triggerStateSettingButtons.m" is called
% (with or without the flag variable being defined), we need to get the
% vehicle index using different methods.
if exist('FLAG_CALL_TRIGGER_STATE_SETTING_BUTTONS', 'var')
    indexMapVehiclePressed = indexMapVehicle;
else
    src = gco(hAnimationFig);
    labelMapVehiclePressed = get(src, 'Tag');
    indexMapVehiclePressed = str2double(labelMapVehiclePressed);
end

% If necessary, initialize what states we should write into the state flag
% at current time.
if ~exist('statesToWriteNow', 'var')
    statesToWriteNow = nan(length(filesToShow),1);
end

% If necessary, initialize the handle matrix for buttons and their
% corresponding vehicle label.
if ~exist('hMapStateSettingButtons', 'var')
    hMapStateSettingButtons = -ones(length(filesToShow),4);
end

% Trigger or disable the buttons for this vehicle.
flagStateSettingButtonsTriggered(indexMapVehiclePressed) ...
    = ~flagStateSettingButtonsTriggered(indexMapVehiclePressed);

% Clear hints.
if ishghandle(hMapStateSettingButtonsTriggeredHint)
    delete(hMapStateSettingButtonsTriggeredHint);
end

if(flagStateSettingButtonsTriggered(indexMapVehiclePressed))
    % Create buttons.
    positionHeight = STATE_SETTING_BUTTONS_HEIGHT_TOP ...
        - STATE_SETTING_BUTTONS_VERTICAL_EDGE*(sum(flagStateSettingButtonsTriggered)-1);
    
    % Attach one group of state setting buttons accordingly.
    createStatesSettingButtons;
    
    % Hints.
    hMapStateSettingButtonsTriggeredHint = uicontrol('Style', 'text', ...
        'String', ...
        strcat('State setting buttons triggered for: vehicle', 23, num2str(indexMapVehiclePressed)), ...
        'FontSize', 11, ...
        'Position', [10 HEIGHT_STATE_BUTTON_HINT_PIXELS ...
        WIDTH_LEFTSIDE_HINT_PIXELS HEIGHT_LEFTSIDE_HINT_PIXELS],...
        'BackgroundColor', get(hAnimationFig, 'Color'));
else
    % There's no need to rewrite states for this vehicle anymore.
    statesToWriteNow(indexMapVehiclePressed) = NaN;
    delete(hMapStateSettingButtons(indexMapVehiclePressed,:));
    hMapStateSettingButtons(indexMapVehiclePressed,:) = [-1 -1 -1 -1];
    
    % Relocate state setting button groups.
    relocateStateSettingButtonGroups;
    
    % Hints.
    hMapStateSettingButtonsTriggeredHint = uicontrol('Style', 'text', ...
        'String', ...
        strcat('State setting buttons disabled for: vehicle', 23, num2str(indexMapVehiclePressed)), ...
        'FontSize', 11, ...
        'Position', [10 HEIGHT_STATE_BUTTON_HINT_PIXELS ...
        WIDTH_LEFTSIDE_HINT_PIXELS HEIGHT_LEFTSIDE_HINT_PIXELS],...
        'BackgroundColor', get(hAnimationFig, 'Color'));
end

% EOF