function [] = updateAxis(hObject, handles)
%UPDATEAXIS The callback function to update AXIS in the state
%collector GUI.
%
% Yaguang Zhang, Purdue, 05/20/2016

AXIS = evalin('base', 'AXIS');
guiHandles = guidata(hObject);
AXIS{guiHandles.IDX_SELECTED_FILE} = axis(handles.hAxesStateOverview);
drawnow;
% Update handles structure
assignin('base', 'AXIS', AXIS);

end

% EOF