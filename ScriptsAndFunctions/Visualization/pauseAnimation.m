%PAUSEANIMATION
% We use a flag to pause the animation. 
%
% Yaguang Zhang, Purdue, 02/03/2015

% Although the extra variable flagAnimationPaused will basically be the same as
% get(togbtnPauseAnimation,'Max'), we use it to indicate "pause the
% animation" better.
flagAnimationPaused = get(togbtnPauseAnimation,'Value');

% togbtnPauseAnimationState = get(togbtnPauseAnimation,'Value');
% 
% if togbtnPauseAnimationState == get(togbtnPauseAnimation,'Max')
%     % The button is down.
% 	flagAnimationPaused = true;
% elseif togbtnPauseAnimationState == get(togbtnPauseAnimation,'Min')
%     % The button is up.
%     flagAnimationPaused = false;
% end

% No break here because the animation can continue even if it's interrupted
% by the toggle button here.

% EOF