% Set timer to update wmLimits. StartDelay in seconds.
timerUpdateWmLimits = timer('TimerFcn', 'disp(''timer done'');',...
    'StartDelay',10);
start(timerUpdateWmLimits);

i = 3;
while i>0
    i=i-1;
    disp('.')
    pause(1)
end

stop

delete(timerUpdateWmLimits);