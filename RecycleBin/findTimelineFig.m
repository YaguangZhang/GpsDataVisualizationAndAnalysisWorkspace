if exist('hTimelineFig','var')
    if ~ishghandle(hTimelineFig)
        hTimelineFig = figure('Name','Timeline','NumberTitle','off');
    else
        clf(hTimelineFig);
        set(0,'CurrentFigure',hTimelineFig);
    end
else
    hTimelineFig = figure('Name','Timeline','NumberTitle','off');
end