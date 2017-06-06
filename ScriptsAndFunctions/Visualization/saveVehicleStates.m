%GENERATEMOV
% Callback function for the "Save vehicle states now" button in the animation
% figure.
%
% Yaguang Zhang, Purdue, 01/28/2015

disp('Saving vehicle states info...');

% Update the "states" history file.
save(FULLPATH_FILES_LOADED_STATES, 'states', 'flagStatesManuallySet');

% Make a copy as backup. We will indicate the create time in the file name.
fullPathBackupTraining = fullfile(fileFolderBackupTraining, ...
    strcat('filesLoadedStates_',datestr(now,'mm_dd_yyyy_HH_MM_SS'),'.mat'));

save(fullPathBackupTraining, 'states', 'flagStatesManuallySet');

% Also, set the currentTime and map limits settings, because the user
% probably want to continue state collection process next time if he sets
% some states this time.
save(FULLPATH_SETTINGS_HISTORY, ...
    'currentTime', 'currentWmLimits', 'currentZoomLevel');

disp('Done!');

% EOF