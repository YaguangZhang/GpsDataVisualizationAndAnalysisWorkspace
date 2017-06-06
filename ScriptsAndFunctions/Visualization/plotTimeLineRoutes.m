%PLOTTIMELINEROUTES
% Update the plots in the timeline figure.
%
% Yaguang Zhang, Purdue, 01/23/2015

% Clear plots if necessary.
if exist('hNotStartedPlot', 'var')
    if ishghandle(hNotStartedPlot)
        delete([hNotStartedPlot;hToShowPlot;hFinishedPlot;hCurrentTime;hText;hXAxis]);
    end
end

% Adding plots to the figure.
hold on;

% Files that haven't started yet.
yNotStartedRec = -0.1:(-0.1):(-length(filesNotStartedRecInd)*0.1);
yNotStartedRec = [yNotStartedRec; yNotStartedRec];
hNotStartedPlot = plot(filesNotStartedRecTimeRange,yNotStartedRec,'LineWidth',LINE_WIDTH);

% Files to be show on the animation later.
yToShow = 0.1:0.1:length(filesToShow)*0.1;
yToShow = [yToShow; yToShow];
hToShowPlot = plot(filesToShowTimeRange,yToShow,'LineWidth',LINE_WIDTH);

% Files that have already finished.
yFinishedRec = -0.1:(-0.1):(-length(filesFinishedRecInd)*0.1);
yFinishedRec = [yFinishedRec; yFinishedRec];
hFinishedPlot = plot(filesFinishedRecTimeRange,yFinishedRec,'LineWidth',LINE_WIDTH);

% Plot the current time and x axis as references.
axis auto;

% Used for setting the location of the text and set the visible area.
yLim = get(gca,'ylim');
xLim = get(gca,'xlim');

% Used for plotting the currentTime line and x-axis. This method can avoid
% uncomplete currentTime plot after zooming.
yLimTotal = [-max(length(filesNotStartedRecInd),length(filesFinishedRecInd))*0.2, length(files)*0.11];
xLimTotal = gpsTimeLineRange - originGpsTime;

hold on;

hCurrentTime = plot([currentTime currentTime], yLimTotal, 'b-.');
set(gca,'ylim',yLim);

hText = text(currentTime, (yLim(2)+yLim(1))/2, num2str(currentTime), 'FontSize', 12);

hXAxis = plot(xLimTotal, [0 0], 'k');
set(gca,'xlim',xLim);

grid on;
xlabel('Current time');
ylabel('All routes');

% EOF