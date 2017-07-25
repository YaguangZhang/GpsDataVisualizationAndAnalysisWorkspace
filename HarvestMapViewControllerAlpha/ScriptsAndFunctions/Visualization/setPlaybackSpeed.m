%SETCURRENTTIME
% Callback function for the "Set playback speed" editable field in the
% animation figure. 
%
% Yaguang Zhang, Purdue, 01/28/2015

milliSecPerFrame = str2double(get(editSetPlaybackSpeed, 'String'));

if milliSecPerFrame > 0 && milliSecPerFrame < timeToUpdateAnimation / 10
        MILLISEC_PER_FRAME = milliSecPerFrame;
        set(editSetPlaybackSpeed, 'String', num2str(milliSecPerFrame));
else
    set(editSetPlaybackSpeed, 'String', strcat( 'Int: 0~', ...
        num2str(floor(timeToUpdateAnimation / 10))) );
end

% EOF