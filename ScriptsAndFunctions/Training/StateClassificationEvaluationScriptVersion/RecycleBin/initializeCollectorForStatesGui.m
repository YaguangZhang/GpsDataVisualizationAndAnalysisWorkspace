% INITIALIZECOLLECTORFORSTATESGUI Create the GUI window for state info
% collection.
%
% This script will create the user interface for the state info collection.
%
% Yaguang Zhang, Purdue, 05/09/2016

%% Figure for the Collector

% Create the window first. We will set the figure to be visible once the
% frame is ready to be shown.
% Create the figure.
LENGTH_UNIT = 'centimeters';
FIG_WIDTH = 20;
FIG_HEIGHT = 10;
hFig = figure('Name', 'State Info Collector', ...
    'NumberTitle', 'off', 'ToolBar', 'figure', ...
    'Units', LENGTH_UNIT, ...
    'OuterPosition',[1 1 FIG_WIDTH FIG_HEIGHT], ...
     'Visible','on'); %zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
set(gca,'FontSize',12);

% Customize the toolbar.
hToolbar = findall(gcf,'tag','FigureToolBar');
hTools = findall(hToolbar);

% Tags to these tools.
%     'FigureToolBar'
%     'Plottools.PlottoolsOn'
%     'Plottools.PlottoolsOff'
%     'Annotation.InsertLegend'
%     'Annotation.InsertColorbar'
%     'DataManager.Linking'
%     'Exploration.Brushing'
%     'Exploration.DataCursor'
%     'Exploration.Rotate'
%     'Exploration.Pan'
%     'Exploration.ZoomOut'
%     'Exploration.ZoomIn'
%     'Standard.EditPlot'
%     'Standard.PrintFigure'
%     'Standard.SaveFigure'
%     'Standard.FileOpen'
%     'Standard.NewFigure'
% Make all buttons invisible.
set(hTools(2:end),'Visible','off');
% Only make buttons we need visible.
set(findall(gcf,'tag','Standard.SaveFigure'),'Visible','on');
set(findall(gcf,'tag','Exploration.ZoomIn'),'Visible','on');
set(findall(gcf,'tag','Exploration.ZoomOut'),'Visible','on');
set(findall(gcf,'tag','Exploration.Pan'),'Visible','on');

%% Plot the Route State Info



%% Uicontrols

% Parameters of the uicontrols' appearance.
COLOR_BACKGROUND = get(hFig, 'Color');

POSITION_SELECTION_TOOLS_BUTTONGROUP = [0.8 0.7 0.15 0.26];

HEIGHT_BOTTOM = 0.09;
HEIGHT_EDGE = 0.22;
POSITION_SELECTION_TOOLS_RECT   = [0.15 HEIGHT_BOTTOM+HEIGHT_EDGE*3 ...
    0.60 0.2];
POSITION_SELECTION_TOOLS_BRUSH   = [0.15 HEIGHT_BOTTOM+HEIGHT_EDGE*2 ...
    0.60 0.2];
POSITION_SELECTION_TOOLS_LASSO    = [0.15 HEIGHT_BOTTOM+HEIGHT_EDGE ...
    0.60 0.2];
POSITION_SELECTION_TOOLS_CLOSEST = [0.15 HEIGHT_BOTTOM ...
    0.60 0.2];

SIZE_PB = [0.15 0.06];
POSITION_PB_SELECT_ON_ROAD      = [0.8 0.55 SIZE_PB];
POSITION_PB_SELECT_IN_FIELD     = [0.8 0.48 SIZE_PB];

POSITION_PB_RECREATE_GUI        = [0.8 0.32 SIZE_PB];

POSITION_PB_SELECT_UPDATE_MAP   = [0.8 0.18 SIZE_PB];
POSITION_PB_SELECT_DONE         = [0.8 0.11 SIZE_PB];

% Available tools for GPS sample points selection.
uipanelSelectionTools = uibuttongroup(...
    'Title','Selection Tools', ...
    'FontSize',12,...
    'BackgroundColor',COLOR_BACKGROUND, ...
    'Units','normalized', ...
    'Position',POSITION_SELECTION_TOOLS_BUTTONGROUP);

rbRect = uicontrol(uipanelSelectionTools, ...
    'Style', 'radiobutton', ...
    'String', 'Rect', ...
    'FontSize', 12, ...
    'BackgroundColor',COLOR_BACKGROUND, ...
    'Units','normalized', ...
    'Position', POSITION_SELECTION_TOOLS_RECT);

rbBrush = uicontrol(uipanelSelectionTools, ...
    'Style', 'radiobutton', ...
    'String', 'Brush', ...
    'FontSize', 12, ...
    'BackgroundColor',COLOR_BACKGROUND, ...
    'Units','normalized', ...
    'Position', POSITION_SELECTION_TOOLS_BRUSH);

rbLasso = uicontrol(uipanelSelectionTools, ...
    'Style', 'radiobutton', ...
    'String', 'Lasso', ...
    'FontSize', 12, ...
    'BackgroundColor',COLOR_BACKGROUND, ...
    'Units','normalized', ...
    'Position', POSITION_SELECTION_TOOLS_LASSO);

rbClosest = uicontrol(uipanelSelectionTools, ...
    'Style', 'radiobutton', ...
    'String', 'Closest', ...
    'FontSize', 12, ...
    'BackgroundColor',COLOR_BACKGROUND, ...
    'Units','normalized', ...
    'Position', POSITION_SELECTION_TOOLS_CLOSEST);

% Pushbuttons.
pbSelectOnRoad = uicontrol( ...
    'Style', 'pushbutton', ...
    'String', 'Select On-Road Points', ...
    'FontSize', 12, ...
    'Units','normalized', ...
    'Position', POSITION_PB_SELECT_ON_ROAD, ...
    'CallBack', 'collectorSelectOnRoad', ...
    'BusyAction', 'cancel');

pbSelectInField = uicontrol( ...
    'Style', 'pushbutton', ...
    'String', 'Select In-Field Points', ...
    'FontSize', 12, ...
    'Units','normalized', ...
    'Position', POSITION_PB_SELECT_IN_FIELD, ...
    'CallBack', 'collectorSelectInField', ...
    'BusyAction', 'cancel');

pbRecreateGui = uicontrol( ...
    'Style', 'pushbutton', ...
    'String', 'Recreate GUI', ...
    'FontSize', 12, ...
    'Units','normalized', ...
    'Position', POSITION_PB_RECREATE_GUI, ...
    'CallBack', 'recreateGui', ...
    'BusyAction', 'cancel');

pbUpdateMap = uicontrol( ...
    'Style', 'pushbutton', ...
    'String', 'Update Map', ...
    'FontSize', 12, ...
    'Units','normalized', ...
    'Position', POSITION_PB_SELECT_UPDATE_MAP, ...
    'CallBack', 'updateCollectorMap', ...
    'BusyAction', 'cancel');

pbDone = uicontrol( ...
    'Style', 'pushbutton', ...
    'String', 'Done', ...
    'FontSize', 12, ...
    'Units','normalized', ...
    'Position', POSITION_PB_SELECT_DONE, ...
    'CallBack', 'collectorDone', ...
    'BusyAction', 'cancel');

% Move the window to the center of the screen.
movegui(hFig,'center');

% Disable the property editor which would be shown if the user
% double-clicks the plots if it's enabled.
set(allchild(hAxesCollectorMap), ...
    'HandleVisibility','off','HitTest','off');

% Make the window visible.
set(hFig, 'Visible', 'on');

% Set zoom on for convenience.
zoom('on');

% Bring it to the user.
figure(hFig);

% EOF