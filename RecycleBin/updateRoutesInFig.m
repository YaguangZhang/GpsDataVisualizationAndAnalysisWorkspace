if exist('hToShowPlot','var')
    if ~ishghandle(hToShowPlot)
        % Create routes.
        plotRoutes;
    else
        % Update existing routes.
        yNotStartedRec = -0.1:(-0.1):(-length(filesNotStartedRecInd)*0.1);
        yNotStartedRec = [yNotStartedRec; yNotStartedRec];
        
        yToShow = 0.1:0.1:length(filesToShow)*0.1;
        yToShow = [yToShow; yToShow];
        
        yFinishedRec = -0.1:(-0.1):(-length(filesFinishedRecInd)*0.1);
        yFinishedRec = [yFinishedRec; yFinishedRec];

        refreshdata(hTimelineFig);
    end
else
    plotRoutes;
end