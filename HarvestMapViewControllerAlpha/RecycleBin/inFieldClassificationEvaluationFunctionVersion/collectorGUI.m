function varargout = collectorGUI(varargin)
% COLLECTORGUI MATLAB code for collectorGUI.fig
%      COLLECTORGUI, by itself, creates a new COLLECTORGUI or raises the
%      existing singleton*.
%
%      H = COLLECTORGUI returns the handle to a new COLLECTORGUI or the
%      handle to the existing singleton*.
%
%      COLLECTORGUI('CALLBACK',hObject,eventData,handles,...) calls the
%      local function named CALLBACK in COLLECTORGUI.M with the given input
%      arguments.
%
%      COLLECTORGUI('Property','Value',...) creates a new COLLECTORGUI or
%      raises the existing singleton*.  Starting from the left, property
%      value pairs are applied to the GUI before collectorGUI_OpeningFcn
%      gets called.  An unrecognized property name or invalid value makes
%      property application stop.  All inputs are passed to
%      collectorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help collectorGUI

% Last Modified by GUIDE v2.5 30-Mar-2015 23:41:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @collectorGUI_OpeningFcn, ...
    'gui_OutputFcn',  @collectorGUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before collectorGUI is made visible.
function collectorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
%   hObject
%       handle to figure
%   eventdata
%       reserved - to be defined in a future version of MATLAB
%   handles
%       structure with handles and user data (see GUIDATA)
%   varargin
%       command line arguments to collectorGUI (see VARARGIN)

% Choose default command line output for collectorGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial map - only do when we are invisible so window
% can get raised using collectorGUI.
if strcmp(get(hObject,'Visible'),'off')
    
    % Show the route.
    axes(handles.map) %make these the current axes
    
    
    handles.mapaxes=axesm('MapProjection','mercator',...
        'MapLatLimit',[10 65], 'MapLonLimit',[-150 -42]); %convert to map axes
    
    %draw a map:
    set(gca,'xlim',[-.35 .32])
    set(gca,'ylim',[.4 .9])
    setm(gca,'FFaceColor',[0 0 .3]); %ocean
    
    load conus.mat
    handles.usmap=geoshow(uslat,uslon, ...
        'DisplayType','polygon','FaceColor',[0 0 0], 'EdgeColor',[.8 .8 .8]);
    geoshow(statelat,statelon,'DisplayType','line','Color',[.5 .5 .5]);
    geoshow(gtlakelat,gtlakelon, 'DisplayType','polygon','FaceColor',[0 0 .3], ...
        'EdgeColor',[.8 .8 .8]);
    %     hold on;
    %     geoshow(routeInfo.lati, routeInfo.long, ...
    %     'DisplayType', 'line', ...
    %     'LineStyle', '--', ...
    %     'LineWidth', 2, ...
    %     'Color', 'k');
    % %     geoshowColoredByLocation(handles,varargin{1});
end

% UIWAIT makes collectorGUI wait for user response (see UIRESUME)
% uiwait(handles.collectorFig);


% --- Outputs from this function are returned to the command line.
function varargout = collectorGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT); hObject
% handle to figure eventdata  reserved - to be defined in a future version
% of MATLAB handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)
printdlg(handles.collectorFig)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.collectorFig,'Name') '?'],...
    ['Close ' get(handles.collectorFig,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.collectorFig)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    structure with handles
% and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as
% cell array
%        contents{get(hObject,'Value')} returns selected item from
%        popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO) eventdata  reserved - to be
% defined in a future version of MATLAB handles    empty - handles not
% created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on button press in pushbuttonSelectOnRoad.
function pushbuttonSelectOnRoad_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSelectOnRoad (see GCBO) eventdata reserved
% - to be defined in a future version of MATLAB handles structure with
% handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttonSelectInField.
function pushbuttonSelectInField_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonSelectInField (see GCBO) eventdata
% reserved - to be defined in a future version of MATLAB handles structure
% with handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttonUpdateMap.
function pushbuttonUpdateMap_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonUpdateMap (see GCBO) eventdata  reserved -
% to be defined in a future version of MATLAB handles    structure with
% handles and user data (see GUIDATA)


% --- Executes on button press in pushbuttonDone.
function pushbuttonDone_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonDone (see GCBO) eventdata  reserved - to
% be defined in a future version of MATLAB handles    structure with
% handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function map_CreateFcn(hObject, eventdata, handles)
% hObject    handle to map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate map
