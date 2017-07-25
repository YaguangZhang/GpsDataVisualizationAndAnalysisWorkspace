%ASKFORHELP Pause the animation so that one can manually adjust the visible
%area.
%
% Yaguang Zhang, Purdue, 05/17/2016

% Sound notification.
load splat.mat;
soundsc(y, Fs);

% Instruction.
disp('The visible area doesn''t seem right. Please adjust it manually.')
disp('Press any key to continue...')

pause;
% EOF