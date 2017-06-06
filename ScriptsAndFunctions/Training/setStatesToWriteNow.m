%SETSTATESTOWRITENOW
% Set the variable statesToWriteNow which is used for updating collected
% vehicle states.
%
% Yaguang Zhang, Purdue, 02/18/2015

% Get the button's information.
src = gco(hAnimationFig);
button_state = get(src,'Value');
if button_state == get(src,'Max')
   
    % Get vehicle number.
    labelMapVehiclePressed = get(src, 'Tag');
    indexMapVehiclePressed = str2double(labelMapVehiclePressed);
    
     % Button down. Record the time point.
    currentTimeStateSettingButtonLastDown{indexMapVehiclePressed} ...
        = currentTimeForThisFrame;
    
    % Corresponding state. Note that we used '--' instead of '-' on the
    % buttons.
    labelStateToSet = get(src, 'String');
    switch labelStateToSet
        case 'U'
            stateToSet = -1;
            % Used for reset other buttons' state to be "up".
            indicesOtherButtonsInTheSameGroup = [2 3];
        case '--'
            stateToSet = 0;
            indicesOtherButtonsInTheSameGroup = [1 3];
        case 'L'
            stateToSet = 1;
            indicesOtherButtonsInTheSameGroup = [1 2];
        otherwise
            stateToSet = NaN;
            indicesOtherButtonsInTheSameGroup = [1 2 3];
    end
    
    % Force other buttons in the same group to be up.
    for indexAnotherButton = 1:length(indicesOtherButtonsInTheSameGroup)
        set(hMapStateSettingButtons(indexMapVehiclePressed, ...
            indicesOtherButtonsInTheSameGroup(indexAnotherButton)), ...
            'Value', 0);
    end
    
    % Update the key variable for state collection "statesToWriteNow".
    statesToWriteNow(indexMapVehiclePressed) = stateToSet;
    
elseif button_state == get(src,'Min')
    % Button up.
    statesToWriteNow(indexMapVehiclePressed) = NaN;
end

clear button_state;

% EOF