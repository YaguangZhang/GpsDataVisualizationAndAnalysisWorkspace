%UPDATEAXESSTATEOVERVIEW Update the axes_state_overview in the GUI.
%
% Yaguang Zhang, Purdue, 05/19/2016

updateIndicesForCurrentActiveFiles;
validateTimes;

COLOR_MOVIE_RANGE = 0.7*ones(1,3); % Gray.
COLOR_DEFAULT_BACKGROUND = 'white';
COLOR_HARVESTING = 0.9*ones(1,3);
COLOR_FACTORY = 0.1*ones(1,3);
if FLAG_TIMES_ARE_VALID
    numActiveFiles = length(handles.indicesActiveFiles);
    % Plot to the state overview axes.
    axes(handles.hAxesStateOverview);
    % Clear the axes. 
    cla;
    set(gca, 'XTick', []);
    xlabel('Absolute GPS time', 'FontSize',9); %     xlabel('Absolute GPS time (ms)', 'FontSize',7);
    ylabel('File Index', 'FontSize',9);
%     hYLabel = get(gca,'YLabel');
%     set(hYLabel,'Position',get(hYLabel,'Position') + [0.015 0 0]);
    % Generate file index labels for YTickLabel.
    if numActiveFiles>0
        set(gca,'YTick',3:7:(numActiveFiles*7-4));
        newYTickLabel = cell(1,numActiveFiles);
        for idxEle = 1:numActiveFiles
            newYTickLabel{idxEle} = num2str(handles.indicesActiveFiles(idxEle));
        end
        set(gca,'YTickLabel',newYTickLabel);
    end
    
    % Plot the squares showing the movie time range.
    timeStart = handles.timeRangeMovies(handles.IDX_SELECTED_FILE,1);
    timeEnd = handles.timeRangeMovies(handles.IDX_SELECTED_FILE,2);
    yBottom = -1;
    yTop = numActiveFiles*7;
    prepareToPatchASquare; % Generate f and v according to yTop, yBottom, timeStart and timeEnd.
    patch('Faces',f,'Vertices',v,...
        'EdgeColor',COLOR_MOVIE_RANGE,'FaceColor',COLOR_MOVIE_RANGE,'LineWidth',1);
    text((timeStart+timeEnd)/2,yTop+1,'MovieRange','HorizontalAlignment','center', 'VerticalAlignment', 'top','FontSize',9);
    yTop = yTop-1;
    yBottom = yBottom+1;
    
    colorsForAllElements = colormap;
    % If there are more active vehicles than that for the predefined
    % colors, we will assign colors randomly.
    if (numActiveFiles>size(colormap,1))
        colorsForAllElements = rand(numActiveFiles,3);
    else
        colorsForAllElements = colorsForAllElements(floor((1:numActiveFiles)*size(colormap,1)/numActiveFiles),:);
    end
    colorsForAllElements = [COLOR_FACTORY; colorsForAllElements;COLOR_HARVESTING]; % The first: for factory; the last: for havesting.
    for idxEle = 1:numActiveFiles
        idxFile = handles.indicesActiveFiles(idxEle);
        yBottom = 7*(idxEle-1);
        yTop = yBottom+6;
        
        timeStart =  handles.files(idxFile).gpsTime(1);
        timeEnd = handles.files(idxFile).gpsTime(end);
        % Plot the square showing the whole "already manually set" area.
        prepareToPatchASquare;
        patch('Faces',f,'Vertices',v,...
            'EdgeColor','black','FaceColor',COLOR_DEFAULT_BACKGROUND,'LineWidth',1);
        % Plot each "already manually set" square.
        [indicesStarts, indicesEnds] = findConsecutiveSubSeq(handles.statesRefSetFlag{idxFile}, 1);
        for idxAlreadySet = 1:length(indicesStarts)
            timeStart = handles.files(idxFile).gpsTime(indicesStarts(idxAlreadySet));
            timeEnd = handles.files(idxFile).gpsTime(indicesEnds(idxAlreadySet));
            prepareToPatchASquare;
            patch('Faces',f,'Vertices',v,...
                'EdgeColor','black','FaceColor','black','LineWidth',1);
        end
        
        timeStart =  handles.files(idxFile).gpsTime(1);
        timeEnd = handles.files(idxFile).gpsTime(end);
        % Plot the square showing the whole "loading from" area.
        yBottom = yBottom+1;
        yTop = yTop-1;
        prepareToPatchASquare;
        patch('Faces',f,'Vertices',v,...
            'EdgeColor','black','FaceColor',COLOR_DEFAULT_BACKGROUND,'LineWidth',1, 'LineStyle', '--');
        % Plot each "loading from" square.
        for idxFileLoadFrom = handles.indicesActiveFiles'
            [indicesStarts, indicesEnds] = findConsecutiveSubSeq(handles.statesRef{idxFile}(:,1), idxFileLoadFrom);
            % Use the color representing the vehicle we loading from.
            colorUsed = colorsForAllElements(find(handles.indicesActiveFiles == idxFileLoadFrom)+1,:);
            for idxAlreadySet = 1:length(indicesStarts)
                timeStart = handles.files(idxFile).gpsTime(indicesStarts(idxAlreadySet));
                timeEnd = handles.files(idxFile).gpsTime(indicesEnds(idxAlreadySet));
                prepareToPatchASquare;
                patch('Faces',f,'Vertices',v,...
                    'EdgeColor',colorUsed,'FaceColor',colorUsed,'LineWidth',1);
            end
        end
        % Also for harvesting.
        [indicesStarts, indicesEnds] = findConsecutiveSubSeq(handles.statesRef{idxFile}(:,1), 0);
        % Use the color representing the vehicle we loading from.
        colorUsed = colorsForAllElements(end,:);
        for idxAlreadySet = 1:length(indicesStarts)
            timeStart = handles.files(idxFile).gpsTime(indicesStarts(idxAlreadySet));
            timeEnd = handles.files(idxFile).gpsTime(indicesEnds(idxAlreadySet));
            prepareToPatchASquare;
            patch('Faces',f,'Vertices',v,...
                'EdgeColor',colorUsed,'FaceColor',colorUsed,'LineWidth',1);
        end
        
        timeStart =  handles.files(idxFile).gpsTime(1);
        timeEnd = handles.files(idxFile).gpsTime(end);
        % Plot the square showing the whole "dumping to" area.
        yBottom = yBottom+1;
        yTop = yTop-1;
        prepareToPatchASquare;
        patch('Faces',f,'Vertices',v,...
            'EdgeColor','black','FaceColor',COLOR_DEFAULT_BACKGROUND,'LineWidth',1, 'LineStyle', ':');
        text(timeStart,yTop,'D','HorizontalAlignment','right', 'VerticalAlignment', 'top','FontSize',6);
        % Plot each "dumping to" square.
        for idxFileDumpTo = handles.indicesActiveFiles'
            [indicesStarts, indicesEnds] = findConsecutiveSubSeq(handles.statesRef{idxFile}(:,2), idxFileDumpTo);
            % Use the color representing the vehicle we dumping to.
            colorUsed = colorsForAllElements(find(handles.indicesActiveFiles == idxFileDumpTo)+1,:);
            for idxAlreadySet = 1:length(indicesStarts)
                timeStart = handles.files(idxFile).gpsTime(indicesStarts(idxAlreadySet));
                timeEnd = handles.files(idxFile).gpsTime(indicesEnds(idxAlreadySet));
                prepareToPatchASquare;
                patch('Faces',f,'Vertices',v,...
                    'EdgeColor',colorUsed,'FaceColor',colorUsed,'LineWidth',1);
            end
        end
        % Also for dumping to the factory.
        [indicesStarts, indicesEnds] = findConsecutiveSubSeq(handles.statesRef{idxFile}(:,2), inf);
        % Use the color representing the vehicle we dumping to.
        colorUsed = colorsForAllElements(1,:);
        for idxAlreadySet = 1:length(indicesStarts)
            timeStart = handles.files(idxFile).gpsTime(indicesStarts(idxAlreadySet));
            timeEnd = handles.files(idxFile).gpsTime(indicesEnds(idxAlreadySet));
            prepareToPatchASquare;
            patch('Faces',f,'Vertices',v,...
                'EdgeColor',colorUsed,'FaceColor',colorUsed,'LineWidth',1);
        end
        
        % Plot a line for each vehicle to identify them.
        timeStart = handles.files(idxFile).gpsTime(1);
        timeEnd = handles.files(idxFile).gpsTime(end);
        % Plot the square showing the whole "loading from" area.
        yBottom = yBottom+1;
        yTop = yTop-1; % Should be the same as yBottom now.
        colorUsed = colorsForAllElements(idxEle+1,:);
        prepareToPatchASquare;
        patch('Faces',f,'Vertices',v,...
            'EdgeColor',colorUsed,'FaceColor',colorUsed,'LineWidth',2, 'LineStyle', '-');
    end
    
    %     % Add a top x axis to show the movie time.
    %     ax1 = gca;
    %     ax1_pos = ax1.Position; % position of first axes
    %     ax2 = axes('Position',ax1_pos,...
    %         'XAxisLocation','top',...
    %         'YAxisLocation','left','YTick',[],...
    %         'Color','none');
    %     newAxisForAx2 = axis(ax1);
    %     newAxisForAx2 = [newAxisForAx2(1,1:2)-timeOffset newAxisForAx2(1,3:4)];
    %     axis(ax2,newAxisForAx2);
    %     xLimListener = addlistener( ax2, 'XLim', 'PostSet', @(src,evt) handleAxis(ax2,  0, 100, -1, 1, ax1, 0, 10, -1, 1) );
    %     yLimListener = addlistener( ax2, 'YLim', 'PostSet', @(src,evt) handleAxis(ax2,  0, 100, -1, 1, ax1, 0, 10, -1, 1) );
    
    disp(strcat(mfilename, ': State overview successfully updated!'));
else
    cla(handles.hAxesStateOverview);
    warning(strcat(mfilename, ': State overview cannot be updated!'));
end

% Always update the vertical lines for GPS start and end time.
plotGpsTimeVerLines;

% Set axis.
handles.AXIS = evalin('base', 'AXIS');
if ~isempty(handles.AXIS{handles.IDX_SELECTED_FILE})
    handles.AXIS = evalin('base', 'AXIS');
    xlim(handles.AXIS{handles.IDX_SELECTED_FILE}(1:2));
    guidata(hObject, handles);
end

% EOF