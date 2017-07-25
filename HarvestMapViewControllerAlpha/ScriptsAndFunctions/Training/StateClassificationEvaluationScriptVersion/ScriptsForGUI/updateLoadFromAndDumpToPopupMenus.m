%UPDATELOADFROMANDDUMPTOPOPUPMENUS
%
% Yaguang Zhang, Purdue, 05/19/2016

updateIndicesForCurrentActiveFiles; % Results in handles.indicesActiveFiles

% Populate popupmenu_selected_file accordingly.
newPopupMenuString = '';
for idxFile = handles.indicesActiveFiles'
    fileInfo = strcat(num2str(idxFile), ':', 32, ...
        handles.files(idxFile).type, '-', handles.files(idxFile).id);
    newPopupMenuString = strvcat(newPopupMenuString, fileInfo);
end    
set(handles.hPopupMenuLoadFrom, 'String', strvcat(char({'Load From ...';'Field'}), newPopupMenuString));
set(handles.hPopupMenuDumpTo, 'String', strvcat('Dump To ...', newPopupMenuString, 'Factory'));
% Set the selected file.
set(handles.hPopupMenuLoadFrom,'Value', 1);
set(handles.hPopupMenuDumpTo,'Value', 1);

% EOF