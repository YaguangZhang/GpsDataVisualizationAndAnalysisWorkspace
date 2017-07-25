%UPDATEMAPLIMITS
% Callback function for the "Update map limits" button in the animation
% figure. Basically a duplicate of some code in the main file.
%
% Yaguang Zhang, Purdue, 01/27/2015

% In case the user has paused the animation, resume it ("up").
flagAnimationPaused = false;
set(togbtnPauseAnimation, 'Value', get(togbtnPauseAnimation, 'Min'));

disp('           Update map limits...')

UPDATE_MAP_LIMITS = true;

% Skip one frame loop to avoid strange animation updating results.
break;
% EOF