% TRIAL7_SHAPEFILES Trial 7 - Try loading the shape files for the field
% boundaries and plotting things on a map.
%
% Yaguang Zhang, Purdue, 05/31/2017

% Load data and set the current Matlab directory.
cd(fileparts(mfilename('fullpath')));
prepareTrial;
cd(fileparts(mfilename('fullpath')));
REL_DIR_SHAPE_FILEFOLDER = ...
    fullfile('..', '..', '..', '..', '..', '..', ...
    'Harvest_Ballet_FieldBoundries', 'JIM BOUNDARIES');

%% Diplay Shapefile Info
disp('-------------------------');
for idxItem = 1:10
    fileName = ['ITEM ',num2str(idxItem)];
    shapeFilePath = fullfile(REL_DIR_SHAPE_FILEFOLDER, fileName);
    info = shapeinfo(shapeFilePath);
    
    disp(fileName);
    disp('');
    disp(info);
    disp('-------------------------');
end

%% Plot Each Shape on Map
close all;
for idxItem = 1:10
    fileName = ['ITEM ',num2str(idxItem)];
    shapeFilePath = fullfile(REL_DIR_SHAPE_FILEFOLDER, fileName);
    [S, Area] = shaperead(shapeFilePath);
    
    hFig = figure; plot([S.X],[S.Y],'-b', 'LineWidth',2); 
    plot_google_map('MapType', 'satellite', ...
        'APIKey', 'AIzaSyDiDNyWyPFc3Cn4L99uKfi_cQlPKHykVdU'); 
    legend(sprintf('%s\n%s', 'Boundary from','the Owner'));
    
    disp(fileName);
    disp('');
    disp(Area);
    disp('-------------------------');
end

% EOF