%PLOTDEVINDSAMPLEDENSITIES
% This file will load from its current filefolder the device independent
% sample densities generated by naiveTrain, plot them and save the plots if
% necessary.
%
% Just copy this file to the filefolder where the history
% devIndSampleDensities files are kept (normally in the data set file
% folder under _AUTOGEN_IMPORTANT/naiveTrain/), set variables as you like,
% and run it. Please make sure the corresponding variable "files" is
% already loaded in the Matlab workspace (by running mapViewController.m or
% nariveTrain.m).
%
% If the png files are not saved correctly, please turn to
% convertFigToPng.m for remediation.
%
% Yaguang Zhang, Purdue, 03/08/2015

%% User specified parameters

% The side length of the square you used to compute the sample densities.
% This indicates for which file you'd like to generate plots.
SQUARE_SIDE_LENGTH = 200;

% Whether to save the sample density plots.
SAVE_SAMPLE_DENSITY_PLOT_AS_FIG = true;
SAVE_SAMPLE_DENSITY_PLOT_AS_PNG = true;

%% Load devIndSampleDensities from history file

disp('Loading devIndSampleDensities from history file...');
disp(' ');

% The folder where the sample density results are saved.
pathDevIndSampleDensitiesFilefolder = fullfile(fileparts(which(mfilename)));
% The history file.
pathDevIndSampleDensitiesFile = fullfile(...
    pathDevIndSampleDensitiesFilefolder, ...
    strcat('DevIndSampleDensities_SQUARE_SIDE_LENGTH_',num2str(SQUARE_SIDE_LENGTH),'.mat')...
    );

% The folder to save plots.
pathFilefolderToSavePlots = fullfile(...
    pathDevIndSampleDensitiesFilefolder, ...
    strcat('Plots_devIndSampleDensities_SQUARE_SIDE_LENGTH_',num2str(SQUARE_SIDE_LENGTH)));

% Change current Matlab directory to this script's filefolder.
cd(pathDevIndSampleDensitiesFilefolder);
if exist(pathDevIndSampleDensitiesFile, 'file')
    load(pathDevIndSampleDensitiesFile);
else
    disp('Couldn''t find the corresponding history file for devIndSampleDensities...');
    disp('Please make sure you''ve already generated it using the naiveTrain script ')
    disp('with the same SQUARE_SIDE_LENGTH and you''re running this script in the');
    disp('file''s filefolder.');
    disp(' ');
    
    error('Failed in loading the specified history sample densities!');
end

% Make the directory if necessary.
if SAVE_SAMPLE_DENSITY_PLOT_AS_FIG||SAVE_SAMPLE_DENSITY_PLOT_AS_FIG
    if ~exist(pathFilefolderToSavePlots,'dir')
        mkdir(pathFilefolderToSavePlots);
    end
end

%% Generate and save plots

for indexPlot = 1:length(devIndSampleDensities)
    
    disp(strcat('Plotting', 23, 23, ...
        num2str(indexPlot),'/',num2str(length(devIndSampleDensities)),'.'));
    
    close all;
    % Show the results in a 3D plot of lat+lon+sample density.
    h3dLatLonDevIndSamDen = figure('Name','lat+lon+device independent sample density');hold on;
    plot3k([files(indexPlot).lon,files(indexPlot).lat,devIndSampleDensities(indexPlot)]);
    hold off; grid on;
    title(strcat('Square side length:',23,num2str(SQUARE_SIDE_LENGTH),...
        ' m, indexFile:', 23, num2str(indexPlot)));
    view(3);
    % Adjust axes x and y to match the 2D plot.
    daspect3dOld = daspect;
    daspect([max(daspect3dOld(1:2))*[1 1] daspect3dOld(3)]);
    
    if SAVE_SAMPLE_DENSITY_PLOT_AS_FIG || SAVE_SAMPLE_DENSITY_PLOT_AS_PNG
        path3dLatLonDevIndSamDen = ...
            fullfile(pathFilefolderToSavePlots, ...
            strcat('3dLatLonDevIndSamDen','indexFile',num2str(indexPlot)));
        frame3dLatLonDevIndSamDen = getframe(h3dLatLonDevIndSamDen);
        
        if SAVE_SAMPLE_DENSITY_PLOT_AS_FIG
            savefig(h3dLatLonDevIndSamDen,path3dLatLonDevIndSamDen);
        end
        
        if SAVE_SAMPLE_DENSITY_PLOT_AS_PNG
            imwrite(frame3dLatLonDevIndSamDen.cdata, [path3dLatLonDevIndSamDen, '.png']);
        end
    end
    
end

close all;

disp(' ');
disp('Done.')

% EOF