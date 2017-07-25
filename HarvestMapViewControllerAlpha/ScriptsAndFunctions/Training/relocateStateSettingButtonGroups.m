%RELOCATESTATESETTINGBUTTONGROUPS
% Relocate the existing state setting button groups.
%
% Yaguang Zhang, Purdue, 02/18/2015

% Find the number label of triggered button groups.
triggeredButtonGroups = find(flagStateSettingButtonsTriggered==1);

for indexStateSettingButtonGroup = 1:length(triggeredButtonGroups)
    
    % Relocate one group of state setting buttons accordingly.
    positionHeight = STATE_SETTING_BUTTONS_HEIGHT_TOP ...
        - STATE_SETTING_BUTTONS_VERTICAL_EDGE*(indexStateSettingButtonGroup-1);
    
    % "U" (unloading) button.
    set(hMapStateSettingButtons(triggeredButtonGroups(indexStateSettingButtonGroup),1), ...
        'Position', [39 positionHeight 30 15]);
    
    % "-" (neither loading nor unloading) button.
    set(hMapStateSettingButtons(triggeredButtonGroups(indexStateSettingButtonGroup),2), ...
        'Position', [69 positionHeight 30 15]);
    
    % "L" (loading) button.
    set(hMapStateSettingButtons(triggeredButtonGroups(indexStateSettingButtonGroup),3), ...
        'Position', [99 positionHeight 30 15]);
    
    % Vehicle label.
    set(hMapStateSettingButtons(triggeredButtonGroups(indexStateSettingButtonGroup),4), ...
        'Position', [10 positionHeight 30 15]);
end

% EOF