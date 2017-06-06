% TESTDEVINDSAMPLEDENSITY Tests the algorithm to compute the device
% independent sample density.
%
% This script computes the device independent sample density defined by
%
%   Device independent sample density
%     = Sample number in a square / sample rate / square area
%
% And it's unit is 1000 samples / Hz / m^2 or samples * second / m^2.
%
% Also, the results will be plotted if it is set so. 
%
% If the png files are not saved correctly, please turn to
% convertFigToPng.m for remediation.
%
% Result: Algorithm 1 is chosen. Furthermore, exlcuding adjacent points are
% not needed if the side length of the square is large enough (e.g. 200m).
%
% Yaguang Zhang, Purdue, 03/05/2015

loadJvkData;

%% Settings

% Which type of vehicle to test.
type = 'Combine'; % 'Grain Kart', 'Combine' or 'Truck'

% For algorithm 3, points within this excluded square will not count. This
% is used for the case where the vehicle is stopped and the sample density
% can be really high.
SQUARE_SIDE_LENGTH_EXCLUDED = 5;

% The estimated radius of earth in meter.
radius=6371000;

% Show routes on a map.
MAP = true;
% Control downloading map image from a WMS server or not. It can save some
% processing time if no image is downloaded. Also, the web map service is
% free and sometimes not working well. If that happens, you can set
% LOAD_WMS_MAP to be false and use the map without the actual map
% background.
LOAD_WMS_MAP = false;
% We will show the current sample and its square on the map once for
% NUM_OF_SAMPLES_TO_UPDATE_MAP of samples. It will significantly slow down
% the computation process if it's set to update the figure very often. You
% can set it to be inf for the fastest computation.
NUM_OF_SAMPLES_TO_UPDATE_MAP = inf;

% Whether to save the sample density plot.
SAVE_SAMPLE_DENSITY_PLOT_AS_FIG = true;
SAVE_SAMPLE_DENSITY_PLOT_AS_PNG = true;

% Which algorithm to use for finding sample points within the area of
% interest. Algorithms 1 (with ALG1_EXCLUDE_ADJACENT_POINTS = false), 2 and
% 3 serve the same purpose: find points within the square. After testing,
% algorithm 1 is faster.
ALGORITHM_TO_USE = 1; % 1, 2 or 3.

% With ALG1_EXCLUDE_ADJACENT_POINTS being true, algorithm 1 finds points
% within the larger square but outside of the smaller square.
ALG1_EXCLUDE_ADJACENT_POINTS = false;

% Estimate the required differences of latitude and longitude in degree for
% SQUARE_SIDE_LENGTH_EXCLUDED according to the Haversine formula.
deltaLatiHalfExcluded = SQUARE_SIDE_LENGTH_EXCLUDED/radius*90/pi; % Sample independent.

%% Pre-processing

% The length of the side of the square by meters.
for SQUARE_SIDE_LENGTH = 200%50:10:1500
    
    disp('-----------');
    disp(strcat('SQUARE_SIDE_LENGTH:', 23, num2str(SQUARE_SIDE_LENGTH)));
    
    close all;
    
    % Estimate the required differences of latitude and longitude in degree
    % for SQUARE_SIDE_LENGTH according to the Haversine formula.
    deltaLatiHalf = SQUARE_SIDE_LENGTH/radius*90/pi; % Sample independent.
    
    for indexFile = 30 %30:1:length(files)zzzzz
        if strcmp(files(indexFile).type, type)
            
            if SAVE_SAMPLE_DENSITY_PLOT_AS_FIG || SAVE_SAMPLE_DENSITY_PLOT_AS_PNG
                path3dLatLonDevIndSamDenFilefolder = ...
                    fullfile('Training', 'NaiveTrain', ...
                    'testDevIndSampleDensityPlots', ...
                    strcat('indexFile_',num2str(indexFile)));
                
                if ~exist(strcat('indexFile_',num2str(indexFile)),'dir')
                    mkdir(path3dLatLonDevIndSamDenFilefolder);
                end
            end
            
            % Load data.
            lati = files(indexFile).lat;
            long = files(indexFile).lon;
            time = files(indexFile).gpsTime;
            spee = files(indexFile).speed;
            
            if ALGORITHM_TO_USE == 2
                % The first column are the indices and the second column
                % are the corresponding sorted lati's.
                sampleIndicesSortedByLati = ...
                    sortrows([(1:length(lati))' lati],2);
                sampleIndicesSortedByLong = ...
                    sortrows([(1:length(long))' long],2);
            end
            
            % Compute device sample rate in kHz.
            deviceSampleRate = length(time)/(time(end)-time(1));
            % Then we can compute the denominator part for computer the
            % sample density.
            denominatorForSampleDensity = deviceSampleRate * (SQUARE_SIDE_LENGTH^2);
            
            %% Map
            if MAP
                
                % Used for counting samples. We will update the square
                % location for every NUM_OF_SAMPLES_TO_UPDATE_MAP samples.
                counterOfSamplesToUpdateMap = NUM_OF_SAMPLES_TO_UPDATE_MAP;
                
                disp('Map:');
                
                IMAGE_HEIGHT = 480;
                IMAGE_WIDTH = 640;
                
                disp(' ');
                disp('Start timing for 2D map.');
                tic;
                
                hFigureMapInField = figure;
                
                if LOAD_WMS_MAP
                    uicontrol('Style', 'pushbutton', ...
                        'String', 'Update Map',...
                        'FontSize', 11, ...
                        'Position', [10 10 140 30],...
                        'Callback', 'testUpdateMapArea');
                end
                
                set(hFigureMapInField, 'ToolBar', 'figure');
                
                set(0, 'CurrentFigure', hFigureMapInField);hold on;
                % Make the 2D map the same as the 3D plots.
                axis equal;
                geoshow(lati, long);
                
                if LOAD_WMS_MAP
                    hAxes = get(hFigureMapInField, 'CurrentAxes');
                    lonLim = get(hAxes,'Xlim');
                    latLim = get(hAxes,'Ylim');
                    
                    try
                        info = wmsinfo('http://raster.nationalmap.gov/arcgis/services/Orthoimagery/USGS_EROS_Ortho_SCALE/ImageServer/WMSServer?request=GetCapabilities&service=WMS','TimeoutInSeconds', 10);
                        layer = info.Layer(1);
                        
                        [A, R] = wmsread(layer, 'Latlim', latLim, 'Lonlim', lonLim, ...
                            'ImageHeight', IMAGE_HEIGHT, 'ImageWidth', IMAGE_WIDTH, 'TimeoutInSeconds', 10);
                    catch err1
                        disp(err1.message);
                        
                        % Search and refine the search.
                        layers = wmsfind('satellite');
                        layers = layers.refine('global');
                        
                        layerCounter = 1;
                        success = false;
                        
                        while ~success
                            % Pause so that we can terminate the program by
                            % using control+c if the map server doesn't
                            % respond correctly.
                            disp('Loading map server info failed. Press any key to try again.');
                            pause;
                            layer = layers(layerCounter);
                            disp(layer);
                            try
                                info = wmsinfo(layer.ServerURL, 'TimeoutInSeconds', 10);
                                layer = info.Layer(1);
                                
                                [A, R] = wmsread(layer, 'Latlim', latLim, 'Lonlim', lonLim, ...
                                    'ImageHeight', IMAGE_HEIGHT, 'ImageWidth', IMAGE_WIDTH, 'TimeoutInSeconds', 10);
                                
                                success = true;
                            catch err2
                                disp(err2.message);
                                success = false;
                            end
                        end
                        
                    end
                    
                    hMapUpdated = geoshow(A,R);
                    
                    uistack(hMapUpdated, 'bottom');
                    numMapLayer = 1;
                    
                    set(hAxes,'Xlim',lonLim);
                    set(hAxes,'Ylim',latLim);
                end
                hold off; grid on; drawnow;
                disp('Finished loading 2D map.');
                disp(' ');
                toc;
            end
            
            %% Algorithm
            
            % For each sample, compute and record how many sample points
            % are in its square area.
            numSamplesInSquare = -ones(length(lati),1);
            % Device independent sample density to be computed.
            devIndSampleDensity = numSamplesInSquare;
            
            disp(' ');
            disp('Start timing for algorithm.');
            tic;
            for indexSample = 1:length(devIndSampleDensity)
                
                % Delta longitude is depending on the latitude of the
                % sample. Vecotorization is not OK since Matlab will give
                % us zeros because the vaule is really small.
                deltaLongHalf = abs(asind(sin(SQUARE_SIDE_LENGTH/2/radius)/cos(lati(indexSample))));
                deltaLongHalfExcluded = abs(asind(sin(SQUARE_SIDE_LENGTH_EXCLUDED/2/radius)/cos(lati(indexSample))));
                
                % Compute the coordinates of the square sides.
                currentSquareSouthSideLati = lati(indexSample)-deltaLatiHalf;
                currentSquareNorthSideLati = lati(indexSample)+deltaLatiHalf;
                currentSquareWestSideLong = long(indexSample)-deltaLongHalf;
                currentSquareEastSideLong = long(indexSample)+deltaLongHalf;
                
                % Compute the coordinates of the sides of the square to be
                % excluded.
                currentSquareSouthSideLatiExcluded = lati(indexSample)-deltaLatiHalfExcluded;
                currentSquareNorthSideLatiExcluded = lati(indexSample)+deltaLatiHalfExcluded;
                currentSquareWestSideLongExcluded = long(indexSample)-deltaLongHalfExcluded;
                currentSquareEastSideLongExcluded = long(indexSample)+deltaLongHalfExcluded;
                
                if ALGORITHM_TO_USE == 3
                    % Too slow compared to algorithm 1.
                    
                    % Polygon for the square.
                    currentSquareBoundryLati = [currentSquareNorthSideLati,...
                        currentSquareNorthSideLati,...
                        currentSquareSouthSideLati,...
                        currentSquareSouthSideLati,...
                        currentSquareNorthSideLati];
                    currentSquareBoundryLong = [currentSquareWestSideLong,...
                        currentSquareEastSideLong,...
                        currentSquareEastSideLong,...
                        currentSquareWestSideLong,...
                        currentSquareWestSideLong];
                    
                    in = inpolygon(long,lati,currentSquareBoundryLong,currentSquareBoundryLati);
                    
                    if MAP && counterOfSamplesToUpdateMap == NUM_OF_SAMPLES_TO_UPDATE_MAP
                        allPossibleIndices = 1:length(lati);
                        indicesSamplesInSquare = allPossibleIndices(in);
                        numSamplesInSquare(indexSample) = numel(long(in));
                    else
                        numSamplesInSquare(indexSample) = numel(long(in));
                    end
                    
                elseif ALGORITHM_TO_USE == 2
                    idxByLatiMin = find(sampleIndicesSortedByLati(:,2)>=currentSquareSouthSideLati, 1, 'first');
                    idxByLatiMax = find(sampleIndicesSortedByLati(idxByLatiMin:end,2)<=currentSquareNorthSideLati, 1, 'last')+idxByLatiMin-1;
                    
                    idxByLongMin = find(sampleIndicesSortedByLong(:,2)>=currentSquareWestSideLong, 1, 'first');
                    idxByLongMax = find(sampleIndicesSortedByLong(idxByLongMin:end,2)<=currentSquareEastSideLong, 1, 'last')+idxByLongMin-1;
                    
                    indicesSamplesInSquare = intersect(...
                        sampleIndicesSortedByLati(idxByLatiMin:idxByLatiMax,1), ...
                        sampleIndicesSortedByLong(idxByLongMin:idxByLongMax,1)...
                        );
                    
                    numSamplesInSquare(indexSample) = length(indicesSamplesInSquare);
                    
                elseif ALGORITHM_TO_USE == 1
                    if MAP && counterOfSamplesToUpdateMap == NUM_OF_SAMPLES_TO_UPDATE_MAP
                        % Find the samples of the same route which are in
                        % the square.
                        indicesSamplesInSquare = find(...
                            lati<=currentSquareNorthSideLati ...
                            & lati>=currentSquareSouthSideLati ...
                            & long<=currentSquareEastSideLong ...
                            & long>=currentSquareWestSideLong);
                        
                        if ALG1_EXCLUDE_ADJACENT_POINTS
                            % Exclude the points in the smaller square.
                            indicesSamplesInSquare = setdiff(indicesSamplesInSquare, ...
                                indicesSamplesInSquare(lati(indicesSamplesInSquare)<=currentSquareNorthSideLatiExcluded ...
                                & lati(indicesSamplesInSquare)>=currentSquareSouthSideLatiExcluded ...
                                & long(indicesSamplesInSquare)<=currentSquareEastSideLongExcluded ...
                                & long(indicesSamplesInSquare)>=currentSquareWestSideLongExcluded)...
                                );
                        end
                        
                        % Record the number of it.
                        numSamplesInSquare(indexSample) = length(indicesSamplesInSquare);
                    else
                        % If it's not necessary to show these in-square
                        % samples, we can use sum instead to speed up a
                        % little bit.
                        if ALG1_EXCLUDE_ADJACENT_POINTS
                            numSamplesInSquare(indexSample) = sum(...
                                (lati<=currentSquareNorthSideLati & lati>=currentSquareNorthSideLatiExcluded)...
                                | (lati>=currentSquareSouthSideLati & lati<=currentSquareSouthSideLatiExcluded)...
                                | (long<=currentSquareEastSideLong & long>=currentSquareEastSideLongExcluded)...
                                | (long>=currentSquareWestSideLong & long<=currentSquareWestSideLongExcluded)...
                                );
                        else
                            numSamplesInSquare(indexSample) = sum(...
                                lati<=currentSquareNorthSideLati ...
                                & lati>=currentSquareSouthSideLati ...
                                & long<=currentSquareEastSideLong ...
                                & long>=currentSquareWestSideLong);
                        end
                    end
                else
                    error('Unkown algorithm for finding adjacent sample points!');
                end
                
                if MAP
                    if counterOfSamplesToUpdateMap == NUM_OF_SAMPLES_TO_UPDATE_MAP
                        if exist('hCurrentSample','var')
                            % Remove plots of the last sample.
                            removeGraphicObject(hCurrentSample);
                            removeGraphicObject(hCurrentSquare);
                            removeGraphicObject(hCurrentSamplesInSquare);
                        end
                        % Plot current sample.
                        set(0,'CurrentFigure', hFigureMapInField);
                        hold on;
                        hCurrentSample = geoshow(lati(indexSample), long(indexSample), ...
                            'DisplayType', 'point', 'Marker', '*',...
                            'LineWidth', 2, 'MarkerSize', 10, ...
                            'MarkerEdgeColor', 'red');
                        
                        % Arrange the coordinates of the square's
                        % endpoints: clock-wise start from northwest.
                        currentSquareBoundryLati = [currentSquareNorthSideLati,...
                            currentSquareNorthSideLati,...
                            currentSquareSouthSideLati,...
                            currentSquareSouthSideLati,...
                            currentSquareNorthSideLati];
                        currentSquareBoundryLong = [currentSquareWestSideLong,...
                            currentSquareEastSideLong,...
                            currentSquareEastSideLong,...
                            currentSquareWestSideLong,...
                            currentSquareWestSideLong];
                        
                        % Plot the square.
                        hCurrentSquare = geoshow(currentSquareBoundryLati, ...
                            currentSquareBoundryLong, ...
                            'Color', 'red', 'LineWidth', 2, 'LineStyle', '--');
                        % Sample points in the square.
                        hCurrentSamplesInSquare = geoshow(lati(indicesSamplesInSquare), long(indicesSamplesInSquare), ...
                            'DisplayType', 'point', 'Marker', '.',...
                            'LineWidth', 2, 'MarkerSize', 5, ...
                            'MarkerEdgeColor', 'magenta');
                        hold off;
                        % Update the figure.
                        drawnow;
                        
                        counterOfSamplesToUpdateMap = 1;
                    else
                        counterOfSamplesToUpdateMap = counterOfSamplesToUpdateMap+1;
                    end
                    
                end
                
            end
            disp('Finished scanning the number of points in the quare.')
            disp(' ');
            toc;
            
            % Compute the device independent sample density.
            devIndSampleDensity = numSamplesInSquare./denominatorForSampleDensity;
            
            % Show the results in a 3D plot of lat+lon+sample density.
            h3dLatLonDevIndSamDen = figure('Name','lat+lon+device independent sample density');hold on;
            plot3k([long,lati,devIndSampleDensity]);
            hold off; grid on;
            title(strcat('Square side length:',23,num2str(SQUARE_SIDE_LENGTH),...
                ' m, indexFile:', 23, num2str(indexFile)));
            view(3);
            % Adjust axes x and y to match the 2D plot.
            daspect3dOld = daspect;
            daspect([max(daspect3dOld(1:2))*[1 1] daspect3dOld(3)]);
            
            % Save plot. Save both as fig and png.
            if SAVE_SAMPLE_DENSITY_PLOT_AS_FIG || SAVE_SAMPLE_DENSITY_PLOT_AS_PNG
                path3dLatLonDevIndSamDen = ...
                    fullfile(path3dLatLonDevIndSamDenFilefolder, ...
                    strcat('3dLatLonDevIndSamDen','_SQUARE_SIDE_LENGTH_',num2str(SQUARE_SIDE_LENGTH)));
                frame3dLatLonDevIndSamDen = getframe(h3dLatLonDevIndSamDen);
                
                if SAVE_SAMPLE_DENSITY_PLOT_AS_FIG
                    savefig(h3dLatLonDevIndSamDen,path3dLatLonDevIndSamDen);
                end
                
                if SAVE_SAMPLE_DENSITY_PLOT_AS_PNG
                    imwrite(frame3dLatLonDevIndSamDen.cdata, [path3dLatLonDevIndSamDen, '.png']);
                end
            end
            
            % Show the results in a 3D plot of lat+lon+speed.
            figure('Name','lat+lon+speed');hold on;
            plot3k([long,lati,spee]);
            hold off; grid on;
            view(3);
            % Adjust axes x and y to match the 2D plot.
            daspect3dOld = daspect;
            daspect([max(daspect3dOld(1:2))*[1 1] daspect3dOld(3)]);
            disp('Finished plotting.')
            disp(' ');
            toc;
            
        end
    end
end