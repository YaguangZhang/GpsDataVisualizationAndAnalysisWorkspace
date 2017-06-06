% TESTINFIELDCLASSIFICATION Trials for training algorithm development. It
% will load JVK data set for testing.
%
% This script continues the work of testOnRoadClassification.m. Rule 0 (4
% m/s bounding and gap filling) is carried out first. Then the inline
% propagation is developed for better performance.
%
% Yaguang Zhang, Purdue, 03/01/2015

loadJvkData;

% For computing sample densities.
SQUARE_SIDE_LENGTH = 200; % In meter.

% This is the density in ms/m^2 for a inline route with a rather low speed.
% 1000/SQUARE_SIDE_LENGTH for route 2 (In this case the speed is 1 m/s).
THRESHOLD_REALLY_LOW_DENSITY = 1000/SQUARE_SIDE_LENGTH;

% Load the devIndSampleDensities computed by naiveTrain for this data set
% with specified SQUARE_SIDE_LENGTH.
loadDevIndSampleDensities;

%% Combines

type = 'Combine';

DEBUG = 1; % Remember to change indexFile, too.
% Controls whether to save the resulting plots.
SAVE_SOME_PLOTS = 1; % Plot: true or 1; Otherwise: false or 0
% Controls whether to pause after each route.
PAUSE_AFTER_EACH_ROUTE = 0;

% During debugging, no plot will be saved and it will always pause for each
% route.
if DEBUG
    SAVE_SOME_PLOTS = false;
    PAUSE_AFTER_EACH_ROUTE = true;
end

% Show routes on a map.
MAP = true;
% Control downloading map image from a WMS server or not. It can save some
% processing time if no image is downloaded. Also, the web map service is
% free and sometimes not working well. If that happens, you can set
% LOAD_WMS_MAP to be false and use the map without the actual map
% background.
LOAD_WMS_MAP = true;

% Location 2D. Used for inline propagation development.
TWO_D_LATLON_4MS_BOUND = false;

% Location and speed 3D after gap filling.
THREE_D_LATLON_SPEED_4MS_BOUND_GAP = false;

% Main test.
IN_THE_FIELD_CLASSIFICAITON = true;

if SAVE_SOME_PLOTS
    % The folder where the sample density results are saved.
    pathPlotsToSaveFilefolder = fullfile(...
        fileparts(which(mfilename)),...
        'testInFieldClassificationPlots',...
        type...
        );
    % Create directory if necessary.
    if ~exist(pathPlotsToSaveFilefolder,'dir')
        mkdir(pathPlotsToSaveFilefolder);
    end
end

% Load parameters set for the infield test of combines.
inFieldClassificationForCombinesParameters;

% Good examples from combine training set (to file 39, in total 19
% combines):
%
%       - 2 (Runs slowly on a road near a round field. Make
%       THRESHOLD_REALLY_LOW_DENSITY larger than 1000/SQUARE_SIDE_LENGTH.
%       Make INLINE_DISTANCE_BOUND larger than or equal to 7m.)
%
%       - 23 (Low-density inline...Should avoid in the field routes... Or
%       not? Confirmed: no! It's on the road.), 24
%
%       - 25 (One loop in field. Extended inline propagation and
%       inlineProForInlinePro implemented, make INLINE_DISTANCE_BOUND_FAR
%       3.95 or larger. Low-density marks points in field wrongly.)
%
%       - 26
%
%       - 29 (One loop in field.)
%
%       - 30 ("routes in the field is labeled on the road by extended pro"
%       fixed with Rule 5)
%
%       - 31 (Seems all on the road but not sure... Still, since no
%       harvesting, marked as on the road.)
%
%       - 33 (make INLINE_DISTANCE_BOUND 5.85 or larger to correctly mark
%       all points on the road)
%
%       - 34 (Low-density inline road, make
%       INLINE_DISTANCE_BOUND_LOW_DEN_SEQ larger than 4.5, and
%       INLINE_DISTANCE_BOUND_LOW_DENSITY larger than 13.7)
%
%       - 36 (several fields involved, make
%       INLINE_DISTANCE_BOUND_LOW_DENSITY 11.4 or larger to correctly mark
%       all points on a long road. zzzzzz inline pro not all).
%
%       - 37 (several fields involved and strangely shaped field, make
%       INLINE_DISTANCE_BOUND_LOW_DENSITY 11.4 or larger to correctly mark
%       all points on a long road).
%
%       - 38 (several fields involved and strange route).
%
%       - 39 (slow-on-the-road segment is correctly classfied)
%
% Good example from combine testing set (all the other files, in total 20
% combines):
%
flagFirstRoute = true;
for indexFile = 119:1:length(files)
    
    if strcmp(files(indexFile).type, type)
        
        if SAVE_SOME_PLOTS
            % The path to save those plots.
            pathMapToSaveFile = fullfile(...
                pathPlotsToSaveFilefolder, ...
                strcat('indexFile_',num2str(indexFile),'_Map')...
                ); % Map
            % Sample densities are not computed in this file, but we plot
            % it anyway here.
            path3dLatLonDenToSaveFile = fullfile(...
                pathPlotsToSaveFilefolder, ...
                strcat('indexFile_',num2str(indexFile),'_3dLatLonDen')...
                ); % 3D (lati+long+device independent densities).
            path3dLatLonSpeNaiveToSaveFile = fullfile(...
                pathPlotsToSaveFilefolder, ...
                strcat('indexFile_',num2str(indexFile),'_3dLatLonSpeNaive')...
                ); % 3D (lati+long+spee) with naive algorithm labels.
            path3dLatLonLocToSaveFile = fullfile(...
                pathPlotsToSaveFilefolder, ...
                strcat('indexFile_',num2str(indexFile),'_3dLatLonLoc')...
                ); % 3D (lati+long+location).
        end
        
        if flagFirstRoute
            flagFirstRoute = false;
        else
            % Pause the program accordingly.
            if PAUSE_AFTER_EACH_ROUTE
                % We put the pause here to make sure the program will just
                % exist instead of pausing for the last route.
                disp('Press any key to continue...');
                pause;
                % Bring commandwindow to front.
                commandwindow;
                disp('Loading next route. Please wait...')
            end
        end
        
        % Load data.
        lati = files(indexFile).lat;
        long = files(indexFile).lon;
        spee = files(indexFile).speed;
        time = files(indexFile).gpsTime;
        %         bear = files(indexFile).bearing;
        dens = devIndSampleDensities{indexFile};
        
        % According to testLatAndSpeedLength.m, files(50) misses a speed
        % sample. We need to discard the last sample if it's incomplete.
        if length(lati)~=length(spee)
            endIdx = min(length(lati),length(spee));
            lati = lati(1:endIdx);
            long = long(1:endIdx);
            spee = spee(1:endIdx);
            dens = dens(1:endIdx);
        end
        
        close all;
        
        %% Map
        if MAP
            disp('Map:');
            
            IMAGE_HEIGHT = 480;
            IMAGE_WIDTH = 640;
            
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
                    layers = wmsfind('aerial');
                    
                    layerCounter = 1;
                    success = false;
                    
                    while ~success
                        % Pause so that we can terminate the program by
                        % using control+c if the map server doesn't respond
                        % correctly.
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
                            if all(A(1:end)==0)||all(A(1:end)==255)
                                success = false;
                            end
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
            hold off; grid on;
            
            toc;
        end
        
        %% 2D (lat+lon) ONROAD_SPEED_BOUND m/s bound
        if TWO_D_LATLON_4MS_BOUND
            disp(strcat('2D (lat+lon)',23,23,num2str(ONROAD_SPEED_BOUND), ' m/s bound:'));
            tic;
            X2D4ms = [long lati];
            
            idx2D4ms = zeros(length(lati),1);
            idx2D4ms(spee>=4) = -100;
            
            figure;hold on;
            plot(X2D4ms(idx2D4ms<0,1),X2D4ms(idx2D4ms<0,2), 'rx','LineWidth',1);
            plot(X2D4ms(idx2D4ms>0,1),X2D4ms(idx2D4ms>0,2), 'bo','LineWidth',1);
            plot(X2D4ms(idx2D4ms==0,1),X2D4ms(idx2D4ms==0,2),'*','MarkerEdgeColor',[0.7 0.7 0.7],'LineWidth',1);
            axis equal;hold off; grid on;
            toc;
        end
        
        %% Gap filling (On the road testing)
        
        % Location labels: -100 (on the road) to 0 (in the field).
        location = zeros(length(lati),1);
        
        % Rule 0: ONROAD_SPEED_BOUND m/s bound + gap filling. This will
        % always be used.
        location(spee>= ONROAD_SPEED_BOUND) = -100;
        
        diffidx3D4msNa = diff([0;location;0]);
        indices4msRoadSequenceStart = find(diffidx3D4msNa==-100); % start
        indices4msRoadSequenceEnd = find(diffidx3D4msNa==100)-1; % end
        
        % Get rid of singular points (the vehicle may be on the road if it
        % runs at ONROAD_SPEED_BOUND m/s for only one sample). Also, we
        % need at least 2 point to fit a line.
        indicesSickPoints = (indices4msRoadSequenceStart==indices4msRoadSequenceEnd);
        indices4msRoadSequenceStart(indicesSickPoints) = [];
        indices4msRoadSequenceEnd(indicesSickPoints) = [];
        location(indicesSickPoints) = 0;
        
        % Fill gaps which last less than the time bound using -95.
        if ~isempty(indices4msRoadSequenceStart)
            % Use GAP_FILLING_TIME_THRESHOLD/2 as a bound to fill the start
            % if necessary.
            if indices4msRoadSequenceStart(1)>1
                timeBeforeRoadSeqs = ...
                    time(indices4msRoadSequenceStart(1)-1) - time(1);
                if timeBeforeRoadSeqs <= GAP_FILLING_TIME_THRESHOLD / 2
                    % Gap filling.
                    location(1:(indices4msRoadSequenceStart(1)-1)) = -95;
                end
            end
            
            % Take care of the gaps on the road.
            for indexSequence = 1:(length(indices4msRoadSequenceStart)-1)
                timeBetweenSeqs = ...
                    time(indices4msRoadSequenceStart(indexSequence+1)-1) - time(indices4msRoadSequenceEnd(indexSequence)+1);
                if timeBetweenSeqs <= GAP_FILLING_TIME_THRESHOLD
                    % Gap filling.
                    location((indices4msRoadSequenceEnd(indexSequence)+1):...
                        (indices4msRoadSequenceStart(indexSequence+1)-1)) = -95;
                end
            end
            
            % Also, use GAP_FILLING_TIME_THRESHOLD/2 as a bound to fill the
            % end if necessary.
            if indices4msRoadSequenceEnd(end)<length(location)
                timeBeforeRoadSeqs = ...
                    time(end)- time(indices4msRoadSequenceEnd(end)+1);
                if timeBeforeRoadSeqs <= GAP_FILLING_TIME_THRESHOLD / 2
                    % Gap filling.
                    location((indices4msRoadSequenceEnd(end)+1):end) = -95;
                end
            end
            
        end
        
        %% 3D (lat+lon+speed) ONROAD_SPEED_BOUND m/s bound with gap filling
        if THREE_D_LATLON_SPEED_4MS_BOUND_GAP
            disp(strcat('3D (lat+lon+speed)',23,23,num2str(ONROAD_SPEED_BOUND), ' m/s bound with gap filling:'));
            
            tic;
            X3D4ms = [long lati spee];
            
            figure('Name',strcat('lat+lon+speed,',23,23,num2str(ONROAD_SPEED_BOUND), ' m/s bound with gap filling'));hold on;
            plot3(X3D4ms(location<0,1),X3D4ms(location<0,2),X3D4ms(location<0,3), 'rx','LineWidth',1);
            plot3(X3D4ms(location>0,1),X3D4ms(location>0,2),X3D4ms(location>0,3), 'bo','LineWidth',1);
            plot3(X3D4ms(location==0,1),X3D4ms(location==0,2),X3D4ms(location==0,3),'*','MarkerEdgeColor',[0.7 0.7 0.7],'LineWidth',1);
            hold off; grid on;
            view(3);
            toc;
        end
        
        %% In the field testing
        % This test is based on the "on the road testing".
        
        if IN_THE_FIELD_CLASSIFICAITON
            
            disp(strcat('3D (lat+lon+speed)',23,23,num2str(ONROAD_SPEED_BOUND), ' m/s bound and naiveInField:'));
            
            tic;
            % Original data (won't be changed).
            X3D4msNa = [long lati spee];
            
            % Quasi-colinear road extension.
            if ~isempty(indices4msRoadSequenceStart)
                % Always compute the limits for extended propatation.
                if indexSequence == 1
                    indexBackwardProLimitEx = 1;
                else
                    indexBackwardProLimitEx = indices4msRoadSequenceEnd(indexSequence-1)+1;
                end
                
                if indexSequence == length(indices4msRoadSequenceStart)
                    indexForwardProLimitEx = length(location);
                else
                    indexForwardProLimitEx = indices4msRoadSequenceStart(indexSequence+1)-1;
                end
                
                if length(indices4msRoadSequenceStart) > 1
                    % Take care of the start.
                    if indices4msRoadSequenceStart(1)>1
                        % Case indexSequence == 1.
                        index4msRoadSequenceStart = indices4msRoadSequenceStart(1);
                        index4msRoadSequenceEnd = indices4msRoadSequenceEnd(1);
                        
                        BACKWARD_PROPAGATION = true;
                        FORWARD_PROPAGATION = false;
                        
                        if location(index4msRoadSequenceEnd+1) == 0
                            % The forward direction isn't filled by gap
                            % filling.
                            indexForwardProLimit = indices4msRoadSequenceStart(indexSequence+1)-1;
                            FORWARD_PROPAGATION = true;
                        end
                        
                        indexBackwardProLimit = 1;
                        % Label GPS points in the same road (line) as -100;
                        inlinePropagation;
                    end
                    
                    % Take care of the middle part.
                    for indexSequence = 2:(length(indices4msRoadSequenceStart)-1)
                        
                        index4msRoadSequenceStart = indices4msRoadSequenceStart(indexSequence);
                        index4msRoadSequenceEnd = indices4msRoadSequenceEnd(indexSequence);
                        BACKWARD_PROPAGATION = false;
                        FORWARD_PROPAGATION = false;
                        
                        if location(index4msRoadSequenceStart-1) == 0
                            % The backward direction isn't filled by gap
                            % filling.
                            indexBackwardProLimit = indices4msRoadSequenceEnd(indexSequence-1)+1;
                            BACKWARD_PROPAGATION = true;
                        end
                        
                        if location(index4msRoadSequenceEnd+1) == 0
                            % The forward direction isn't filled by gap
                            % filling.
                            indexForwardProLimit = indices4msRoadSequenceStart(indexSequence+1)-1;
                            FORWARD_PROPAGATION = true;
                        end
                        
                        inlinePropagation;
                    end
                    
                    % Take care of the end.
                    if indices4msRoadSequenceEnd(end)<length(location)
                        % Case indexSequence equals to
                        % length(indices4msRoadSequenceStart).
                        index4msRoadSequenceStart = indices4msRoadSequenceStart(end);
                        index4msRoadSequenceEnd = indices4msRoadSequenceEnd(end);
                        
                        BACKWARD_PROPAGATION = false;
                        FORWARD_PROPAGATION = true;
                        
                        if location(index4msRoadSequenceStart-1) == 0
                            % The backward direction isn't filled by gap
                            % filling.
                            indexBackwardProLimit = indices4msRoadSequenceEnd(indexSequence-1)+1;
                            BACKWARD_PROPAGATION = true;
                        end
                        
                        indexForwardProLimit = length(location);
                        inlinePropagation;
                        
                    else
                        % Only one sequence is found. The start is also the
                        % end.
                        index4msRoadSequenceStart = indices4msRoadSequenceStart(1);
                        index4msRoadSequenceEnd = indices4msRoadSequenceEnd(1);
                        
                        BACKWARD_PROPAGATION = true;
                        FORWARD_PROPAGATION = true;
                        
                        indexForwardProLimit = length(lati);
                        indexBackwardProLimit = 1;
                        
                        % Label GPS points in the same road (line) as -100;
                        inlinePropagation;
                    end
                end
            end
            
            % RULE 6. Find the long-enough low-density colinear sequences
            % from currently zero-labeled points
            lowDensityColinearSeqProp;
            
            % Find field polygons. Update sequences which are still not
            % labeled (location is 0). We will use the same code for
            % finding -100 sequences before. In order to do that, we need
            % to change 0 to -100 and all other labels (so far only
            % negative ones) to 0.
            diffLocation = -100*ones(length(location),1);
            diffLocation(location<0) = 0;
            diffLocation = diff([0;diffLocation;0]);
            
            indicesUnlabeledSequenceStart = find(diffLocation==-100); % start
            indicesUnlabeledSequenceEnd = find(diffLocation==100)-1; % end
            
            if any(location<0)
                % Last check: check whether there are enough points
                % available in each "field" sequence. If not, mark those
                % points to be -30.
                indicesUnlabeledSequenceLength = ...
                    indicesUnlabeledSequenceEnd-indicesUnlabeledSequenceStart;
                if any(indicesUnlabeledSequenceLength<MIN_NUM_FIELD_SEQ)
                    indicesUnlabeledSequenceStartDiscarded = ...
                        indicesUnlabeledSequenceStart(indicesUnlabeledSequenceLength<MIN_NUM_FIELD_SEQ);
                    indicesUnlabeledSequenceEndDiscarded = ...
                        indicesUnlabeledSequenceEnd(indicesUnlabeledSequenceLength<MIN_NUM_FIELD_SEQ);
                    indicesUnlabeledSequenceStart(indicesUnlabeledSequenceLength<MIN_NUM_FIELD_SEQ)=[];
                    indicesUnlabeledSequenceEnd(indicesUnlabeledSequenceLength<MIN_NUM_FIELD_SEQ)=[];
                    
                    % Mark these discarded points in the variable
                    % "location".
                    for idxUnlabeledSequenceDiscarded = 1:length(indicesUnlabeledSequenceStartDiscarded)
                        location(...
                            indicesUnlabeledSequenceStartDiscarded(idxUnlabeledSequenceDiscarded):...
                            indicesUnlabeledSequenceEndDiscarded(idxUnlabeledSequenceDiscarded)...
                            ) = -30;
                    end
                end
                
                % Also check whether the "field" is large enough. Note that
                % the length has already been checked.
                indicesFieldDeleted = [];
                for idxField = 1:length(indicesUnlabeledSequenceStart)
                    indicesFieldSeq = indicesUnlabeledSequenceStart(idxField):...
                        indicesUnlabeledSequenceEnd(idxField);
                    if fieldDiameter(lati(indicesFieldSeq),long(indicesFieldSeq))...
                            < MIN_FIELD_DIAMETER;
                        % Not large enough.
                        location(indicesFieldSeq) = -30;
                        indicesFieldDeleted = [indicesFieldDeleted;idxField];
                    end
                end
                
                indicesUnlabeledSequenceStart(indicesFieldDeleted) = [];
                indicesUnlabeledSequenceEnd(indicesFieldDeleted) = [];
            end
            
            % Compute the convex polygons which can contain all points of
            % each unlabeled sequence.
            fieldPolygons = cell(length(indicesUnlabeledSequenceStart),1);
            for indexPolygon = 1:length(indicesUnlabeledSequenceStart)
                % X: long. Y: lati.
                longInField = long(indicesUnlabeledSequenceStart(indexPolygon):...
                    indicesUnlabeledSequenceEnd(indexPolygon));
                latiInField = lati(indicesUnlabeledSequenceStart(indexPolygon):...
                    indicesUnlabeledSequenceEnd(indexPolygon));
                
                % Compute the boudaries of the field.
                if exist('alphaShape','file')
                    % Alpha shape function is available (require 2014b or
                    % newer). We'll remove duplicated coordinates first.
                    uniqueCoorTemp = unique([latiInField,longInField],'rows');
                    latiInField = uniqueCoorTemp(:,1);
                    longInField = uniqueCoorTemp(:,2);
                    
                    alphaShapeTemp = alphaShape(longInField, latiInField);
                    % Increase alpha a little bit to avoid unecessary small
                    % holes in the field.
                    alphaShapeTemp.Alpha = alphaShapeTemp.Alpha*2;
                    
                    indicesFieldPolygonsTemp = boundaryFacets(alphaShapeTemp);
                    indicesFieldPolygonsTemp = indicesFieldPolygonsTemp(:,1);
                    
                    % Record the coordinates of the field polygon.
                    fieldPolygons{indexPolygon} = ...
                        [latiInField(indicesFieldPolygonsTemp), ...
                        longInField(indicesFieldPolygonsTemp)];
                else
                    % Alpha shape function is not available. We will use
                    % convex hull instead.
                    disp('Alpha shape is not available...');
                    disp('Will use convex hull instead.');
                    warning('The function alphaShape isn''t available! It requires Matlab 2014b or newer.');
                    indicesFieldPolygonsTemp = ...
                        convhull(longInField, latiInField);
                    
                    % Record the coordinates of the field polygon.
                    fieldPolygons{indexPolygon} = ...
                        [lati(indicesFieldPolygonsTemp+indicesUnlabeledSequenceStart(indexPolygon)-1), ...
                        long(indicesFieldPolygonsTemp+indicesUnlabeledSequenceStart(indexPolygon)-1)];
                end
                
                % Plot the polygon on the map if possible.
                if MAP
                    set(0,'CurrentFigure', hFigureMapInField);
                    hold on;
                    
                    % Grey dotted line.
                    geoshow(...
                        fieldPolygons{indexPolygon}(:,1), ...
                        fieldPolygons{indexPolygon}(:,2), ...
                        'Color', 'yellow', 'LineWidth', 3, 'LineStyle', '-.');
                    hold off;
                end
            end
            
            % Show the results in a 3D plot of lat+lon+speed.
            hFigure3DLatLonSpeNaive = figure('Name','lat+lon+speed, naive labeling');hold on;
            % Debug points.
            plot3(X3D4msNa(location==-200,1),X3D4msNa(location==-200,2),X3D4msNa(location==-200,3), 'rp','LineWidth',3);
            % ONROAD_SPEED_BOUND m/s bound.
            plot3(X3D4msNa(location==-100,1),X3D4msNa(location==-100,2),X3D4msNa(location==-100,3), 'rx','LineWidth',1);
            % Gap filling.
            plot3(X3D4msNa(location==-95,1),X3D4msNa(location==-95,2),X3D4msNa(location==-95,3), 'bo','LineWidth',1);
            % In line propagation.
            plot3(X3D4msNa(location==-80,1),X3D4msNa(location==-80,2),X3D4msNa(location==-80,3), 'g+','LineWidth',1);
            % In line propagation for low-density area. (Dark green)
            plot3(X3D4msNa(location==-70,1),X3D4msNa(location==-70,2),X3D4msNa(location==-70,3), 's','Color', [0.2, 0.8, 0.2],'LineWidth',1);
            % Low-density unlabeled sequence inline test. (Pink)
            plot3(X3D4msNa(location==-60,1),X3D4msNa(location==-60,2),X3D4msNa(location==-60,3), 'd','Color', [1, 0.36, 0.8],'LineWidth',1);
            % Inline propagation for low-density unlabeled sequences.
            % (Light hot pink)
            plot3(X3D4msNa(location==-55,1),X3D4msNa(location==-55,2),X3D4msNa(location==-55,3), '<','Color', [1, 0.7, 0.87],'LineWidth',1);
            % Extended in line propagation. (Magnet)
            plot3(X3D4msNa(location==-50,1),X3D4msNa(location==-50,2),X3D4msNa(location==-50,3), 'm>','LineWidth',1);
            % In line propagation for extended line propagation. (Orange)
            plot3(X3D4msNa(location==-45,1),X3D4msNa(location==-45,2),X3D4msNa(location==-45,3), 'v','Color', [1, 0.5, 0],'LineWidth',1);
            % Field point sequences not long / large enough. (black)
            plot3(X3D4msNa(location==-30,1),X3D4msNa(location==-30,2),X3D4msNa(location==-30,3), '*','MarkerEdgeColor','black','LineWidth',1);
            % Points not being labeled yet. (Light grey)
            plot3(X3D4msNa(location==0,1),X3D4msNa(location==0,2),X3D4msNa(location==0,3), '*','MarkerEdgeColor',[0.75 0.75 0.75],'LineWidth',1);
            hold off; grid on;
            title(strcat('indexFile:', 23, num2str(indexFile)));
            view(3);
            % Adjust axes x and y to match the 2D plot.
            daspect3dOld = daspect;
            daspect([max(daspect3dOld(1:2))*[1 1] daspect3dOld(3)]);
            % Add labels.
            xlabel('Longitude');ylabel('Latitude');zlabel('Speed (m/s)');
            toc;
            
            % Show the results in a 2D plot of lat+lon for the paper.
            hFigure2DLatLonNaive = figure('Name','lat+lon, naive labeling');hold on;
            % Debug points.
            plot(X3D4msNa(location==-200,1),X3D4msNa(location==-200,2), 'rp','LineWidth',3);
            % ONROAD_SPEED_BOUND m/s bound.
            plot(X3D4msNa(location==-100,1),X3D4msNa(location==-100,2), 'rx','LineWidth',1);
            % Gap filling.
            plot(X3D4msNa(location==-95,1),X3D4msNa(location==-95,2), 'bo','LineWidth',1);
            % In line propagation.
            plot(X3D4msNa(location==-80,1),X3D4msNa(location==-80,2), 'g+','LineWidth',1);
            % In line propagation for low-density area. (Dark green)
            plot(X3D4msNa(location==-70,1),X3D4msNa(location==-70,2), 's','Color', [0.2, 0.8, 0.2],'LineWidth',1);
            % Low-density unlabeled sequence inline test. (Pink)
            plot(X3D4msNa(location==-60,1),X3D4msNa(location==-60,2), 'd','Color', [1, 0.36, 0.8],'LineWidth',1);
            % Inline propagation for low-density unlabeled sequences.
            % (Light hot pink)
            plot(X3D4msNa(location==-55,1),X3D4msNa(location==-55,2), '<','Color', [1, 0.7, 0.87],'LineWidth',1);
            % Extended in line propagation. (Magnet)
            plot(X3D4msNa(location==-50,1),X3D4msNa(location==-50,2), 'm>','LineWidth',1);
            % In line propagation for extended line propagation. (Orange)
            plot(X3D4msNa(location==-45,1),X3D4msNa(location==-45,2), 'v','Color', [1, 0.5, 0],'LineWidth',1);
            % Field point sequences not long / large enough. (black)
            plot(X3D4msNa(location==-30,1),X3D4msNa(location==-30,2), '*','MarkerEdgeColor','black','LineWidth',1);
            % Points not being labeled yet. (Yellow)
            plot(X3D4msNa(location==0,1),X3D4msNa(location==0,2), '*','MarkerEdgeColor','yellow','LineWidth',1);
            hold off; grid on;
            title(strcat('indexFile:', 23, num2str(indexFile)));
            % Adjust axes x and y to match the 2D plot.
            axis equal;
            % Add labels.
            xlabel('Longitude');ylabel('Latitude');
            
            % Save plots as both .fig and .png.
            if SAVE_SOME_PLOTS
                % Hints for the user.
                disp(strcat('Plotting and saving', 23, 23, ...
                    num2str(indexFile),'/',num2str(length(files)),'.'));
                
                % Map.
                %
                %  Colors of the lines shown on the map:
                %
                %   Basic InlinePro: Red.
                %
                %   Re-fitted line for basic InlinePro: Maroon ([0.5,0,0]);
                %
                %   InlinePro for Extended InlinePro: Turquoise
                %   ([0.25,0.88,0.82]);
                %
                %   InlinePro for Low-density Inline: Yellow green
                %   ([0.6,0.8,0.2]);
                %
                %   Rule 6 (Low-density inline): Light grey ([0.75,0.75,
                %   0.75]);
                %
                %   Re-fitted line for Rule 6: Grey ([0.5,0.5,0.5]);
                %
                % Shapes of the key points shown on the map:
                %
                %   Start point of basic backpropagation: Magenta ^.
                %
                %   Start point of extended backpropagation: Plum
                %   ([0.87,0.63,0.87]) pentagram.
                %
                %   Start point of basic forwardpropagation: Green ^.
                %
                %   Start point of extended forwardpropagation: Yellow
                %   green ([0.6,0.8,0.2]) pentagram.
                
                figure(hFigureMapInField);
                
                frameFigureMapInField = getframe(hFigureMapInField);
                imwrite(frameFigureMapInField.cdata, [pathMapToSaveFile, '.png']);
                savefig(hFigureMapInField,pathMapToSaveFile);
                
                % 3D (lati+long+device independent densities). Note that
                % the sample densiteis are pre-computed already.
                hFigure3dLatLonDen = figure('Name','lat+lon+device independent sample density');hold on;
                plot3k([long,lati,dens]);
                hold off; grid on;
                title(strcat('Square side length:',23,num2str(SQUARE_SIDE_LENGTH),...
                    ' m, indexFile:', 23, num2str(indexFile)));
                view(3);
                % Adjust axes x and y to match the 2D plot.
                daspect3dOld = daspect;
                daspect([max(daspect3dOld(1:2))*[1 1] daspect3dOld(3)]);
                % Set labels.
                xlabel('Longitude');ylabel('Latitude');zlabel('Sample density (ms/m^2)');
                
                frameFigure3dLatLonDen = getframe(hFigure3dLatLonDen);
                imwrite(frameFigure3dLatLonDen.cdata, [path3dLatLonDenToSaveFile, '.png']);
                savefig(hFigure3dLatLonDen,path3dLatLonDenToSaveFile);
                
                % 3D (lati+long+spee) with naive algorithm labels.
                figure(hFigure3DLatLonSpeNaive);
                
                frameFigure3DLatLonSpeNaive = getframe(hFigure3DLatLonSpeNaive);
                imwrite(frameFigure3DLatLonSpeNaive.cdata, [path3dLatLonSpeNaiveToSaveFile, '.png']);
                savefig(hFigure3DLatLonSpeNaive,path3dLatLonSpeNaiveToSaveFile);
                
                % 3D (lati+long+location).
                hFigure3dLatLonLoc = figure('Name','lat+lon+location labels');hold on;
                plot3k([long,lati,location]);
                hold off; grid on;
                title(strcat('indexFile:', 23, num2str(indexFile)));
                view(3);
                % Adjust axes x and y to match the 2D plot.
                daspect3dOld = daspect;
                daspect([max(daspect3dOld(1:2))*[1 1] daspect3dOld(3)]);
                % Set labels.
                xlabel('Longitude');ylabel('Latitude');zlabel('Location label');
                
                frameFigure3DLatLonLoc = getframe(hFigure3dLatLonLoc);
                imwrite(frameFigure3DLatLonLoc.cdata, [path3dLatLonLocToSaveFile, '.png']);
                savefig(hFigure3dLatLonLoc,path3dLatLonLocToSaveFile);
                
            end
            
        end
        
    end
end

% EOF