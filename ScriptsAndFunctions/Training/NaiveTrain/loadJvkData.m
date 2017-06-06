%LOADJVKDATA
% This script loads GPS data from JVK data set. It is mainly used for
% testing.
%
% Yaguang Zhang, Purdue, 02/29/2015

%% User specified parameters

% Please refer to mapViewController for more infomation.
fileFolder = fullfile('..', '..', '..',  'Harvest_Ballet_2015');
IS_RELATIVE_PATH = true;
MIN_SAMPLE_NUM_TO_IGNORE = 20;

% If the GPS data has already loaded, you can set this flag to be true and
% skip loading the variables for the data again. Just please make sure the
% variables in the current workspace are indeed corresponding to the files
% specified by "fileFolder".
USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE = true;

%% Set matlab path.

% Clear command window. Close all plot & web map display windows.
clc;close all;wmclose all;

% Changed folder to "ScriptsAndFunctions" first.
cd(fullfile(fileparts(which(mfilename)),'..', '..'));
% Set path.
setMatlabPath;

%% Load GPS data

% Clear variables.
if exist('files', 'var') && USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE
    disp('Pre-processing: Reuse GPS data variables in the current workspace.');
    % Reuse GPS data variables in current workspace.
    clearvars -except fileFolder fileFolderSet IS_RELATIVE_PATH ...
        USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE ...
        MIN_SAMPLE_NUM_TO_IGNORE ...
        files fileIndicesCombines fileIndicesTrucks ...
        fileIndicesGrainKarts ...
        fileIndicesSortedByStartRecordingGpsTime ...
        fileIndicesSortedByEndRecordingGpsTime;
else
    clearvars -except fileFolder IS_RELATIVE_PATH ...
        MIN_SAMPLE_NUM_TO_IGNORE ...
        USE_GPS_DATA_VARIABLES_IN_CURRENT_WORKSPACE; 
    loadGpsData;
end

% EOF