% COLLECTORGUI Create the GUI window for location info collection.
%
% This script will create the user interface for the location
% info collection. It's possible to use GUIDE to do the same job but
% geoshow doesn't work well there because it needs axesm instead of axes to
% work and there's no explicit way of implementing axesm using GUIDE.
%
% Yaguang Zhang, Purdue, 03/30/2015

%% Flags

flagCollectingInfo = true;

%% Figure for the Collector

% Create the window first. We will set the figure to be visible once the
% frame is ready to be shown.
hCollectorFig = figure(...
    'Name','Location Info Collector','NumberTitle','off',...
    'Units','normalized', ...
    'OuterPosition',[0 0 0.75 0.7], ...
    'ToolBar', 'figure', ...
    'Visible','off');

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

%% Show the Route

% First, show the whole route. (Grey)
hAxesCollectorMap = gca;
hRoute.wholeRoute = geoshow(routeInfo.lati, routeInfo.long, ...
    'DisplayType', 'line', ...
    'LineStyle', '-', ...
    'LineWidth', 1, ...
    'Color', [0.5 0.5 0.5]);

% Reset the visible area to be roughly a square. And move it to the left
% side of the figure.
lonLim = get(gca,'Xlim');
latLim = get(gca,'Ylim');

[latLim, lonLim] = adjustLatLonLim(latLim, lonLim);
set(gca, 'Xlim', lonLim, 'Ylim', latLim, 'Units','normalized');
axesPosition = get(gca,'Position');
axesPosition(1) = 0;
set(gca, 'Position', axesPosition);

hold on;

% Show the colored route pioints.
disp(' ');
disp('geoshowColoredByLocation: Plotting the route...');
tic;
% Infield: yellow. On the road: blue.
geoshowColoredByLocation;

% Add map background to the plot.
disp(' ');
disp('geoshowColoredByLocation: Downloading the satellite image...');
tic;

% The size of the satellite images to download.
IMAGE_HEIGHT = 480; %960;
IMAGE_WIDTH = 640; %1280;

try
    FLAG_USE_GOOGLE_MAPS = false;
    % Source recommanded by Andrew: http://services.arcgisonline.com
    info = wmsinfo('http://raster.nationalmap.gov/arcgis/rest/services/Orthoimagery/USGS_EROS_Ortho_SCALE/ImageServer/WMSServer?request=GetCapabilities&service=WMS','TimeoutInSeconds', 10);
    layer = info.Layer(1);
    
    flagValidImage = false;
    imageHeight = IMAGE_HEIGHT;
    imageWidth = IMAGE_WIDTH;
    while(~flagValidImage)
        [A, R] = wmsread(layer, 'Latlim', latLim, 'Lonlim', lonLim, ...
            'ImageHeight', imageHeight, 'ImageWidth', imageWidth, 'TimeoutInSeconds', 10);
        
        % Increase the image size if the image obtained is not valid.
        if ~(all(A(1:end)==0)||all(A(1:end)==255))
            flagValidImage = true;
        else
            imageHeight = imageHeight*2;
            imageWidth = imageWidth*2;
        end
    end
catch err1
    disp(err1.message);
    warning('Satellite image server we used is not working now. Will use Google Maps instead. Some of the functions provided may not work.');
    FLAG_USE_GOOGLE_MAPS = true;
end
toc;
disp('geoshowColoredByLocation: Done!');

disp(' ');
disp('geoshowColoredByLocation: Rendering the map...');
tic;

if FLAG_USE_GOOGLE_MAPS
    plot_google_map('MapType','satellite');
else
    numMapLayer = 1;
    % We store all the handles to the satellite images in a cell so that we can
    % ignore them when we want to select GPS points of the route.
    hMapUpdated = cell(1,1);
    hMapUpdated{numMapLayer} = geoshow(A,R);
    
    % Set the satellite image to be the background.
    uistack(hMapUpdated{numMapLayer}, 'bottom');
end
hold off;

toc;
disp('geoshowColoredByLocation: Done!');

%% Uicontrols

% Parameters of the uicontrols' appearance.
COLOR_BACKGROUND = get(hCollectorFig, 'Color');

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

% Move the window to the center of the screen.l
movegui(hCollectorFig,'center');

% Disable the property editor which would be shown if the user
% double-clicks the plots if it's enabled.
set(allchild(hAxesCollectorMap), ...
    'HandleVisibility','off','HitTest','off');

% Make the window visible.
set(hCollectorFig, 'Visible', 'on');

% Set zoom on for convenience.
zoom('on');

% Bring it to the user.
figure(hCollectorFig);

% EOF