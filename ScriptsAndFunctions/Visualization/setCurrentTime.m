%SETCURRENTTIME Set the variable currentTime on time line figure.
% Script to interactively set the variable currentTime on the time line
% figure if SKIP_CURRENT_TIME_SETTING is false. Otherwise, the time line
% figure will only show the history value of currentTime without setting
% it.
%
% Yaguang Zhang, Purdue, 02/12/2015

if SKIP_CURRENT_TIME_SETTING == false
    
    title1 = 'Zoom in and out if necessary.';
    title2 = 'Press any key to start the setting.';
    title({title1,  title2},'Interpreter','None','FontSize',12);
    
    % Bring the figure to the user.
    figure(hTimelineFig);
    pause;
    
    currentTimeOriginal = currentTime;
    flagUseHistorySettings = false;
    
    while true
        title1 = 'Click on the plot to set current time.';
        title2 = 'Press return to finish setting.';
        title({title1,  title2},'Interpreter','None','FontSize',12);
        
        figure(hTimelineFig);
        [xClicked,yClicked] = ginputCurrentTime(1, gca, hCurrentTime, hText);
        
        if isempty(xClicked)
            % If no mouse input, keep the original value.
            currentTime = currentTimeOriginal;
            flagUseHistorySettings = true;
        else
            currentTime = floor(xClicked(end));
        end
        
        [currentGpsTime, ...
            filesToShowIndices, filesToShow, filesToShowTimeRange, ...
            filesNotStartedRecInd, filesNotStartedRecTimeRange, ...
            filesFinishedRecInd, filesFinishedRecTimeRange]...
            = updateActiveRoutesInfo(files, currentTime, originGpsTime, ...
            fileIndicesSortedByStartRecordingGpsTime, fileIndicesSortedByEndRecordingGpsTime);
        
        hTimelineFig = resetFigWithHandleNameAndFigName('hTimelineFig', 'Timeline');
        
        set(0,'CurrentFigure',hTimelineFig);
        plotTimeLineRoutes;
        
        title1 = 'Zoom in and out to see the resulting groups.';
        title2 = 'Press any key to continue.';
        title({title1,  title2},'Interpreter','None','FontSize',12);
        
        figure(hTimelineFig);
        pause;
        
        set(0,'CurrentFigure',hTimelineFig);
        title1 = 'Press return to confirm setting.';
        title2 = 'Press any other key to reset.';
        title({title1,  title2},'Interpreter','None','FontSize',12);
        
        figure(hTimelineFig);
        % Ignore mouse clickings.
        while ~waitforbuttonpress
        end
        
        pressedKey = get(gcf,'currentcharacter');
        if pressedKey == 13
            break;
        end
    end
else
    flagUseHistorySettings = true;
end

title1 = 'Timeline';
title2 = ' ';
title({title1,  title2},'Interpreter','None','FontSize',12);

hold off;

% Make sure the tile is refreshed.
pause(0.0000000001);

if SKIP_CURRENT_TIME_SETTING == false
    % Save the setting result to history file.
    save(FULLPATH_SETTINGS_HISTORY, ...
        'currentTime', '-append');
    if RESET_CURRENT_TIME
        disp(strcat('           currentTime is set to be', ...
            23, num2str(currentTime),'.'));
    else
        disp(strcat('                 currentTime is set to be', ...
            23, num2str(currentTime),'.'));
    end
end

% EOF