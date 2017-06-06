function varargout = collectorForStatesGuiByGuide(varargin)
%COLLECTORFORSTATESGUIBYGUIDE M-file for collectorForStatesGuiByGuide.fig
%      COLLECTORFORSTATESGUIBYGUIDE, by itself, creates a new COLLECTORFORSTATESGUIBYGUIDE or raises the existing
%      singleton*.
%
%      H = COLLECTORFORSTATESGUIBYGUIDE returns the handle to a new COLLECTORFORSTATESGUIBYGUIDE or the handle to
%      the existing singleton*.
%
%      COLLECTORFORSTATESGUIBYGUIDE('Property','Value',...) creates a new COLLECTORFORSTATESGUIBYGUIDE using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to collectorForStatesGuiByGuide_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      COLLECTORFORSTATESGUIBYGUIDE('CALLBACK') and COLLECTORFORSTATESGUIBYGUIDE('CALLBACK',hObject,...) call the
%      local function named CALLBACK in COLLECTORFORSTATESGUIBYGUIDE.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help collectorForStatesGuiByGuide

% Last Modified by GUIDE v2.5 14-Jun-2016 13:56:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @collectorForStatesGuiByGuide_OpeningFcn, ...
    'gui_OutputFcn',  @collectorForStatesGuiByGuide_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before collectorForStatesGuiByGuide is made visible.
function collectorForStatesGuiByGuide_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Load necessary parameters from the base workspace.
handles.files = evalin('base', 'files');
% GUI related info.
handles.statesRef = evalin('base', 'statesRef');
handles.statesRefSetFlag = evalin('base', 'statesRefSetFlag');
handles.IDX_SELECTED_FILE = evalin('base', 'IDX_SELECTED_FILE');
handles.MOVIE_GPS_TIME_START = evalin('base', 'MOVIE_GPS_TIME_START');
handles.MOVIE_GPS_TIME_END = evalin('base', 'MOVIE_GPS_TIME_END');

handles.timeRangeMovies = evalin('base', 'timeRangeMovies');
handles.indicesMovieToVeh = evalin('base', 'indicesMovieToVeh');
handles.GpsTimeOffset = handles.timeRangeMovies(handles.IDX_SELECTED_FILE, 1);

% Initiate a cell array to store the axis for each movie.
if evalin('base','exist(''AXIS'',''var'')')
    handles.AXIS = evalin('base', 'AXIS');
else
    handles.AXIS = cell(length(handles.files),1);
    assignin('base', 'AXIS', handles.AXIS);
end

% Find the handels to all items we need to update.
handles.hPopupMenuSelectedFile = findobj('Tag', 'popupmenu_selected_file');
% Note that we called the edit text boxes GPS time but in order to make the
% collection process easier, we actually use the MovieGpsTime in the video
% instead.
handles.hEditMovieGpsTimeStart = findobj('Tag', 'edit_gps_time_start');
handles.hEditMovieGpsTimeEnd = findobj('Tag', 'edit_gps_time_end');
handles.hPopupMenuLoadFrom = findobj('Tag', 'popupmenu_load_from');
handles.hPopupMenuDumpTo = findobj('Tag', 'popupmenu_dump_to');
handles.hAxesStateOverview = findobj('Tag', 'axes_state_overview');

% Populate popupmenu_selected_file accordingly.
newPopupMenuString = get(handles.hPopupMenuSelectedFile,'String');
for idxMovie = 1:length(handles.files)
    idxFile = handles.indicesMovieToVeh(idxMovie);
    fileInfo = strcat(num2str(idxMovie),': Veh #', num2str(idxFile), ' -', 32, ...
        handles.files(idxFile).type, '-', handles.files(idxFile).id);
    newPopupMenuString = strvcat(newPopupMenuString, fileInfo);
end
set(handles.hPopupMenuSelectedFile,'String', newPopupMenuString);
% Set the selected file.
set(handles.hPopupMenuSelectedFile,'Value', handles.IDX_SELECTED_FILE+1);

% Restore the start and end GPS time in the state setter.
restoreMovieGpsTimesEdits;

% Update the load_from and dump_to popup menus.
% Active files during the specified GPS time range.
handles.gpsTimeRangesForFiles = [inf(length(handles.files),1),  -inf(length(handles.files),1)];
% Retrieve time ranges for all the elements in vehFiles.
for idxFiles = 1:length(handles.files)
    % Start time.
    handles.gpsTimeRangesForFiles(idxFiles,1) = handles.files(idxFiles).gpsTime(1);
    % End time.
    handles.gpsTimeRangesForFiles(idxFiles,2) = handles.files(idxFiles).gpsTime(end);
end
updateLoadFromAndDumpToPopupMenus;

% Update the axes_state_overview.
updateAxesStateOverview;

% Gui title.
hObject.Name = 'StateCollector';
% Fix y axis limit.
pan off;
pan xon;
zoom off;
zoom xon;

handles.xLimListener = addlistener( gca, 'XLim', 'PostSet', @(src,evt) updateAxis(hObject, handles) );
handles.xLimListener.Enabled = true;

% Choose default command line output for collectorForStatesGuiByGuide
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes collectorForStatesGuiByGuide wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = collectorForStatesGuiByGuide_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected object is changed in unitgroup.
function unitgroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in unitgroup
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu_selected_file.
function popupmenu_selected_file_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_selected_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Stop updating axis for now.
handles.xLimListener.Enabled = false;

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_selected_file contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_selected_file
selectedIdx = get(hObject,'Value');
% Update the GUI only if a valid file is selected.
if selectedIdx>1
    handles.IDX_SELECTED_FILE = get(hObject,'Value')-1;
else
    handles.IDX_SELECTED_FILE = 1;
    set(hObject,'Value', 2);
end
restoreMovieGpsTimesEdits;
updateLoadFromAndDumpToPopupMenus;

% Update handles structure
guidata(hObject, handles);

% Save the GUI states
saveGuiStates;

handles.xLimListener.Enabled = true;

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_selected_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_selected_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_load_from.
function popupmenu_load_from_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_load_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_load_from contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_load_from


% --- Executes during object creation, after setting all properties.
function popupmenu_load_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_load_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on selection change in popupmenu_dump_to.
function popupmenu_dump_to_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_dump_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_dump_to contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_dump_to


% --- Executes during object creation, after setting all properties.
function popupmenu_dump_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_dump_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_gps_time_start_Callback(hObject, eventdata, handles)
% hObject    handle to edit_gps_time_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_gps_time_start as text
%        str2double(get(hObject,'String')) returns contents of edit_gps_time_start as a double
handles.MOVIE_GPS_TIME_START(handles.IDX_SELECTED_FILE) = str2num(get(handles.hEditMovieGpsTimeStart,'String'));
saveGuiStates;

% --- Executes during object creation, after setting all properties.
function edit_gps_time_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_gps_time_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_gps_time_end_Callback(hObject, eventdata, handles)
% hObject    handle to edit_gps_time_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_gps_time_end as text
%        str2double(get(hObject,'String')) returns contents of edit_gps_time_end as a double
handles.MOVIE_GPS_TIME_END(handles.IDX_SELECTED_FILE) = str2num(get(handles.hEditMovieGpsTimeEnd,'String'));
saveGuiStates;

% --- Executes during object creation, after setting all properties.
function edit_gps_time_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_gps_time_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_clear.
function pb_clear_Callback(hObject, eventdata, handles)
% hObject    handle to pb_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FLAG_CLEAR_LOAD_FROM_DUMP_TO = true;
setLoadFromDumpTo;

% --- Executes on button press in pb_set.
function pb_set_Callback(hObject, eventdata, handles)
% hObject    handle to pb_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setLoadFromDumpTo;


% --- Executes on button press in pb_reset_visible_area.
function pb_reset_visible_area_Callback(hObject, eventdata, handles)
% hObject    handle to pb_reset_visible_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.xLimListener.Enabled = false;
handles.AXIS{handles.IDX_SELECTED_FILE} = [];
assignin('base','AXIS',handles.AXIS);
saveGuiStates;
handles.xLimListener.Enabled = true;

% --------------------------------------------------------------------
function get_movie_time_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to get_movie_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[absoluteMovieTime,~] = ginput(1);
clipboard('copy',floor(absoluteMovieTime-handles.GpsTimeOffset));

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('Collector: Saving results to files...');

saveGuiStates;

evalin('base', 'save(pathStateClassificationFile, ''statesRef'', ''statesRefSetFlag'', ''IDX_SELECTED_FILE'', ''MOVIE_GPS_TIME_START'', ''MOVIE_GPS_TIME_END'', ''AXIS'')');
evalin('base', 'save(pathBackupStatesRefFile, ''statesRef'', ''statesRefSetFlag'', ''IDX_SELECTED_FILE'', ''MOVIE_GPS_TIME_START'', ''MOVIE_GPS_TIME_END'', ''AXIS'')');

disp('Collector: Done!');
disp('-------------------------------------------------------------');

% Hint: delete(hObject) closes the figure
delete(hObject);

% --------------------------------------------------------------------
function toggle_pan_OnCallback(hObject, eventdata, handles)
% hObject    handle to toggle_pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'xLimListener')
    handles.xLimListener.Enabled = false;
    guidata(hObject, handles);
end

% --------------------------------------------------------------------
function toggle_pan_OffCallback(hObject, eventdata, handles)
% hObject    handle to toggle_pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'xLimListener')
    updateAxis(hObject, handles);
    handles.xLimListener.Enabled = true;
    guidata(hObject, handles);
end

% --- Executes on button press in pb_back_up.
function pb_back_up_Callback(hObject, eventdata, handles)
% hObject    handle to pb_back_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Make sure everything is up-to-date.
saveGuiStates;
% Update the backup file name and save.
evalin('base', 'pathBackupStatesRefFile = fullfile(pathBackupFileFolder,strcat(''filesLoadedStates_'', datestr(now,''mm_dd_yyyy_HH_MM_SS''), ''.mat''));');
evalin('base', 'save(pathBackupStatesRefFile, ''statesRef'', ''statesRefSetFlag'', ''IDX_SELECTED_FILE'', ''MOVIE_GPS_TIME_START'', ''MOVIE_GPS_TIME_END'', ''AXIS'')');

% EOF