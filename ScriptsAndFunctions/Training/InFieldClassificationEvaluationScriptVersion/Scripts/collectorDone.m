%COLLECTORDONE Close the collectorGUI and save the collected info.
%
% Yaguang Zhang, Purdue, 03/31/2015

% Close the GUI.
set(hCollectorFig,'Visible','off');
drawnow;
close(hCollectorFig);

disp(' ')
disp('Collector: Saving the results...')
tic;
% Save the results into the history file.
save(pathInFieldClassificationFile, 'locationsRef');
toc;
disp('Collector: Done!')

% Change the flag.
flagCollectingInfo = false;

% EOF