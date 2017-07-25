FULLPATH_SETTINGS_HISTORY = fullfile(fileFolderSet, 'settingsHistory.mat');

for i=1:100
    
   save(FULLPATH_SETTINGS_HISTORY, ...
            'currentWmLimits', '-append');
    
end