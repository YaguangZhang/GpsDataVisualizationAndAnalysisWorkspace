%JUMPBACKFRAMES
% Play control for jump back some frames.
%
% Yaguang Zhang, Purdue, 02/03/2015

currentTime = currentTime - MILLISEC_PER_FRAME*5; 

% No break here because the animation can continue even if it's interrupted
% by the toggle button here.

% EOF