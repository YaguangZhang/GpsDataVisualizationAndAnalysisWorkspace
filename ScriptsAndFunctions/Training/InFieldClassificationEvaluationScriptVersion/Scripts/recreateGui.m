% RECREATEGUI Close current collector GUI and recreate a new one.
%
% Yaguang Zhang, Purdue, 04/01/2015

disp('-------------------------------------------------------------');
disp('CollectorGUI: Recreating collector GUI...')

% First make the GUI invisible.
set(hCollectorFig,'Visible','off');
drawnow;
% Close the GUI.
close(hCollectorFig);
% Create a new one.
refreshCollectorGUI;

disp(' ');
disp('CollectorGUI: Done!');
disp('-------------------------------------------------------------');

% EOF