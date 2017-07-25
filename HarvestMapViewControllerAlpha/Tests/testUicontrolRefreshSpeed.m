figure
i=100;
tic
while i>0
    editSetPlaybackSpeed = uicontrol('Style', 'edit', ...
    'String', num2str(SAMPLES_PER_FRAME), ...
    'FontSize', 10, ...
    'Position', [10 90 140 30],...
    'Callback', 'setPlaybackSpeed');
pause(0.0000000001);
delete(editSetPlaybackSpeed);
i = i-1;

end
toc