% TESTONROADCLASSIFICATION Trails for training algorithm development. It
% will load JVK data set for testing.
%
% Aborted during development of tests THREE_D_LATLON_DIRECTION and
% THREE_D_LATLON_LINE_SEG.
%
% Key results summary: 
%
%   For combines, speed is useful to roughly segment the whole route. It
%   performs better than bearing for this task.
%
%   But both speed and bearing are not good enough for on-the-road /
%   in-the-field classification.
%
% Next, we will try developing algorithms to tell whether GPS data points
% are in the same line in testInFieldClassification.m.
%
% Yaguang Zhang, Purdue, 02/27/2015

loadJvkData;

%% Set which tests to run.

type = 'Combine'; % 'Grain Kart', 'Combine' or 'Truck'
%indexFile = 50; % 66 is a kart. 50 is a combine. 77 is a  truck

% Show routes on a map.
MAP = false;

% Location 2D.
TWO_D_LATLON_2MEANS = false;
TWO_D_LATLON_4MEANS = false;

% Location and speed 3D.
THREE_D_LATLON_SPEED_2MEANS = false;
THREE_D_LATLON_SPEED_4MEANS = false;

THREE_D_LATLON_SPEED_4MS_BOUND = false;

% Location and bearing. Bearing can't be used as directions. 
THREE_D_LATLON_BEARING = false;

TWO_D_TIME_ABS_BEARING_DIFF = false;

THREE_D_LATLON_ABS_BEARING_DIFF_LINE = false;
THREE_D_LATLON_ABS_BEARING_DIFF_5S = false;

THREE_D_LATLON_BEARING_AND_ABS_BEARING_DIFF_5S_LINE = false;

% Main test.
ON_THE_ROAD_CLASSIFICAITON = false;
% Rules to use in the classification. Rule 0 (4 m/s bound +
% gap filling) is always used.
RULE1 = false; % Extend on-road sequence by time (here 5s).
RULE2 = false; % Extend on-road sequence until speed (here 2m/s).
RULE3 = false; % Extend on-road sequence for dots in the same line.

% Location and line segmentation.
THREE_D_LATLON_LINE_SEG = true;

% Location and direction 3D. Note that our algorithm needs the results from
% Rule 0.
THREE_D_LATLON_DIRECTION = true;

for indexFile = 33:1:length(files)
    if strcmp(files(indexFile).type, type)
        
        % Load data.
        lati = files(indexFile).lat;
        long = files(indexFile).lon;
        spee = files(indexFile).speed;
        time = files(indexFile).gpsTime;
        bear = files(indexFile).bearing;
        
        % According to testLatAndSpeedLength.m, files(50) misses a speed
        % sample.
        if length(lati)~=length(spee)
            endIdx = min(length(lati),length(spee));
            lati = lati(1:length(spee));
            long = long(1:length(spee));
            spee = spee(1:length(spee));
        end
        
        close all;
        
        %% Map
        if MAP
            disp('Map:');
            
            IMAGE_HEIGHT = 480;
            IMAGE_WIDTH = 640;
            
            try
                info = wmsinfo('http://raster.nationalmap.gov/arcgis/services/Orthoimagery/USGS_EROS_Ortho_SCALE/ImageServer/WMSServer?request=GetCapabilities&service=WMS');
                layer = info.Layer(1);
            catch err1
                disp(err1.message);
                
                % Search and refine the search.
                layers = wmsfind('satellite');
                layers = layers.refine('global');
                
                layerCounter = 1;
                success = false;
                
                while ~success
                    layer = layers(layerCounter);
                    disp(layer);
                    try
                        info = wmsinfo(layer.ServerURL);
                        success = true;
                    catch err2
                        disp(err2.message);
                        success = false;
                    end
                end
                layer = info.Layer(1);
            end
            
            tic;
            
            hFigure = figure;
            uicontrol('Style', 'pushbutton', ...
                'String', 'Update Map',...
                'FontSize', 11, ...
                'Position', [10 10 140 30],...
                'Callback', 'testUpdateMapArea');
            set(hFigure, 'ToolBar', 'figure');
            % Can copy and modify this part to update the map area. See
            % testUpdateMapArea.m.
            set(0, 'CurrentFigure', hFigure);hold on;
            axis equal;
            hRoute = geoshow(lati, long);
            hAxes = get(hFigure, 'CurrentAxes');
            lonLim = get(hAxes,'Xlim');
            latLim = get(hAxes,'Ylim');
            
            [A, R] = wmsread(layer, 'Latlim', latLim, 'Lonlim', lonLim, ...
                'ImageHeight', IMAGE_HEIGHT, 'ImageWidth', IMAGE_WIDTH);
            geoshow(A,R);uistack(hRoute, 'top');
            set(hAxes,'Xlim',lonLim);
            set(hAxes,'Ylim',latLim);
            hold off; grid on;
            % End of copy.
            toc;
        end
        
        %% 2D (lat+lon) 2-means
        if TWO_D_LATLON_2MEANS
            disp('2D (lat+lon) 2-means:');
            tic;
            X2D = [long lati];
            
            k=2;
            [idx2D,C2D] = kmeans(X2D,k);
            
            figure;hold on;
            plot(X2D(idx2D==1,1),X2D(idx2D==1,2), 'rx','LineWidth',1);
            plot(X2D(idx2D==2,1),X2D(idx2D==2,2), 'bo','LineWidth',1);
            plot(C2D(:,1),C2D(:,2),'*','MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',3);
            axis equal;hold off; grid on;
            toc;
        end
        
        %% 2D (lat+lon) 4-means
        if TWO_D_LATLON_4MEANS
            disp('2D (lat+lon) 4-means:');
            tic;
            X2D4k = [long lati];
            
            k=4;
            [idx2D4k,C2D4k] = kmeans(X2D4k,k);
            
            figure;hold on;
            plot(X2D4k(idx2D4k==1,1),X2D4k(idx2D4k==1,2), 'rx','LineWidth',1);
            plot(X2D4k(idx2D4k==2,1),X2D4k(idx2D4k==2,2), 'bo','LineWidth',1);
            plot(X2D4k(idx2D4k==3,1),X2D4k(idx2D4k==3,2), 'g+','LineWidth',1);
            plot(X2D4k(idx2D4k==4,1),X2D4k(idx2D4k==4,2), 'k*','LineWidth',1);
            plot(C2D4k(:,1),C2D4k(:,2),'*','MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',3);
            axis equal;hold off; grid on;
            toc;
        end
        
        %% 3D (lat+lon+speed) 2-means
        
        if THREE_D_LATLON_SPEED_2MEANS
            % Shouldn't do axis equal for 3D plot.
            disp('3D (lat+lon+speed) 2-means:');
            tic;
            X3D = [long lati spee];
            
            k=2;
            [idx3D, C3D] = kmeans(X3D,k);
            
            figure;hold on;
            plot3(X3D(idx3D==1,1),X3D(idx3D==1,2),X3D(idx3D==1,3), 'rx','LineWidth',1);
            plot3(X3D(idx3D==2,1),X3D(idx3D==2,2),X3D(idx3D==2,3), 'bo','LineWidth',1);
            plot3(C3D(:,1),C3D(:,2),C3D(:,3),'k*','MarkerSize',10,'MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',3);
            hold off; grid on;
            view(3);
            toc;
        end
        
        %% 3D (lat+lon+speed) 4-means
        
        if THREE_D_LATLON_SPEED_4MEANS
            disp('3D (lat+lon+speed) 4-means:');
            
            tic;
            X3D4k = [long lati spee];
            
            k=4;
            [idx3D4k,C3D4k] = kmeans(X3D4k,k);
            figure;hold on;
            plot3(X3D4k(idx3D4k==1,1),X3D4k(idx3D4k==1,2),X3D4k(idx3D4k==1,3), 'rx','LineWidth',1);
            plot3(X3D4k(idx3D4k==2,1),X3D4k(idx3D4k==2,2),X3D4k(idx3D4k==2,3), 'bo','LineWidth',1);
            plot3(X3D4k(idx3D4k==3,1),X3D4k(idx3D4k==3,2),X3D4k(idx3D4k==3,3), 'g+','LineWidth',1);
            plot3(X3D4k(idx3D4k==4,1),X3D4k(idx3D4k==4,2),X3D4k(idx3D4k==4,3), 'k*','LineWidth',1);
            plot3(C3D4k(:,1),C3D4k(:,2),C3D4k(:,3),'k*','MarkerSize',10,'MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',3);
            hold off; grid on;
            view(3);
            toc;
        end
        
        %% 3D (lat+lon+speed) 4 m/s bound
        if THREE_D_LATLON_SPEED_4MS_BOUND
            disp('3D (lat+lon+speed) 4 m/s bound:');
            
            tic;
            X3D4ms = [long lati spee];
            
            idx3D4ms = zeros(length(lati),1);
            idx3D4ms(spee>=4) = -100;
            figure('Name','lat+lon+speed, 4 m/s bound');hold on;
            plot3(X3D4ms(idx3D4ms<0,1),X3D4ms(idx3D4ms<0,2),X3D4ms(idx3D4ms<0,3), 'rx','LineWidth',1);
            plot3(X3D4ms(idx3D4ms>0,1),X3D4ms(idx3D4ms>0,2),X3D4ms(idx3D4ms>0,3), 'bo','LineWidth',1);
            plot3(X3D4ms(idx3D4ms==0,1),X3D4ms(idx3D4ms==0,2),X3D4ms(idx3D4ms==0,3),'*','MarkerEdgeColor',[0.5 0.5 0.5],'LineWidth',3);
            hold off; grid on;
            view(3);
            toc;
        end
        
        %% 3D (lat+lon+bearing)
        
        if THREE_D_LATLON_BEARING
            
            disp('3D (lat+lon+bearing):');
            
            tic;
            X3DB5s4ms = [long lati bear];
            
            figure('Name','lat+lon+bearing');hold on;
            plot3(X3DB5s4ms(:,1),X3DB5s4ms(:,2),X3DB5s4ms(:,3), 'rx','LineWidth',1);
            hold off; grid on;
            view(3);
            toc;
        end
        
        %% 2D (time+abs bearing diff)
        if TWO_D_TIME_ABS_BEARING_DIFF
            disp('2D (time+abs bearing diff):');
            
            tic;
            bearDiff = diff([bear(1);bear]);
            bearDiff(bearDiff<0) = bearDiff(bearDiff<0)+360;
            bearDiff(bearDiff>=180) = 360 - bearDiff(bearDiff>=180);
            
            figure('Name','time+abs bearing diff');hold on;
            plot(time,bearDiff, 'rx','LineWidth',1);
            hold off; grid on;
            toc;
        end
        
        %% 3D (lat+lon+abs bearing diff) line
        if THREE_D_LATLON_ABS_BEARING_DIFF_LINE
            disp('3D (lat+lon+abs bearing diff) line:');
            
            tic;
            bearDiff = diff([bear(1);bear]);
            bearDiff(bearDiff<0) = bearDiff(bearDiff<0)+360;
            bearDiff(bearDiff>=180) = 360 - bearDiff(bearDiff>=180);
            X3DB4ms = [long lati bearDiff];
            
            figure('Name','lat+lon+abs bearing diff');hold on;
            plot3(X3DB4ms(:,1),X3DB4ms(:,2),X3DB4ms(:,3), 'r-','LineWidth',1);
            hold off; grid on;
            view(3);
            toc;
        end
        
        %% 3D (lat+lon+abs bearing 5s diff)
        
        % Instead of showing bearing samples, we show the bearing diff
        % between samples of 5s interval.
        if THREE_D_LATLON_ABS_BEARING_DIFF_5S
            disp('3D (lat+lon+abs bearing 5s diff):');
            BEARING_DIFF_TIME_INTERVAL = 5000;
            
            tic;
            
            CORRESPONDING_SAMPLE_INTERVAL = BEARING_DIFF_TIME_INTERVAL/((time(MIN_SAMPLE_NUM_TO_IGNORE) - time(1)) / MIN_SAMPLE_NUM_TO_IGNORE);
            CORRESPONDING_SAMPLE_INTERVAL = max(floor(CORRESPONDING_SAMPLE_INTERVAL),1);
            
            bearDiff5S = diff([bear(1)*ones(CORRESPONDING_SAMPLE_INTERVAL,1);bear(1:(end-CORRESPONDING_SAMPLE_INTERVAL+1))]);
            bearDiff5S(bearDiff5S<0) = bearDiff5S(bearDiff5S<0)+360;
            bearDiff5S(bearDiff5S>=180) = 360 - bearDiff5S(bearDiff5S>=180);
            X3DB5s4ms = [long lati bearDiff5S];
            
            figure('Name','lat+lon+abs bearing 5s diff');hold on;
            plot3(X3DB5s4ms(:,1),X3DB5s4ms(:,2),X3DB5s4ms(:,3), 'rx','LineWidth',1);
            hold off; grid on;
            view(3);
            toc;
        end
        
        %% 3D (lat+lon+bearing and abs bearing diff 5s)
        
        if THREE_D_LATLON_BEARING_AND_ABS_BEARING_DIFF_5S_LINE
            disp('3D (lat+lon+bearing and abs bearing diff 5s):');
            BEARING_DIFF_TIME_INTERVAL = 5000;
            
            tic;
            
            CORRESPONDING_SAMPLE_INTERVAL = BEARING_DIFF_TIME_INTERVAL/((time(MIN_SAMPLE_NUM_TO_IGNORE) - time(1)) / MIN_SAMPLE_NUM_TO_IGNORE);
            CORRESPONDING_SAMPLE_INTERVAL = max(floor(CORRESPONDING_SAMPLE_INTERVAL),1);
            
            bearDiff5S = diff([bear(1)*ones(CORRESPONDING_SAMPLE_INTERVAL,1);bear(1:(end-CORRESPONDING_SAMPLE_INTERVAL+1))]);
            bearDiff5S(bearDiff5S<0) = bearDiff5S(bearDiff5S<0)+360;
            bearDiff5S(bearDiff5S>=180) = 360 - bearDiff5S(bearDiff5S>=180);
            X3DB5s4ms = [long lati bearDiff5S];
            
            bearDiff = diff([bear(1);bear]);
            bearDiff(bearDiff<0) = bearDiff(bearDiff<0)+360;
            bearDiff(bearDiff>=180) = 360 - bearDiff(bearDiff>=180);
            X3DB4ms = [long lati bearDiff];
            
            figure('Name','lat+lon+abs bearing diff');hold on;
            plot3(X3DB5s4ms(:,1),X3DB5s4ms(:,2),X3DB5s4ms(:,3), 'r-','LineWidth',1);
            plot3(X3DB4ms(:,1),X3DB4ms(:,2),X3DB4ms(:,3), 'b-.','LineWidth',1);
            legend('Bearing with 5s interval','Sample bearing')
            hold off; grid on;
            view(3);
            toc;
        end
        
        %% On the road testing
        
        if ON_THE_ROAD_CLASSIFICAITON
            disp('3D (lat+lon+speed) 4 m/s bound and naiveOnRoad:');
            
            tic;
            X3D4msNa = [long lati spee];
            
            % Location labels: -100 (on the road) to 0 (in the field).
            location = zeros(length(lati),1);
            
            % Rule 0: 4 m/s bound + gap filling. This will always be used.
            location(spee>=4) = -100;
            
            diffidx3D4msNa = diff([0;location;0]);
            indices4msRoadSequenceStart = find(diffidx3D4msNa==-100); % start
            indices4msRoadSequenceEnd = find(diffidx3D4msNa==100)-1; % end
            
            % Take care of the gaps on the road. Furthermore, it also group
            % sequences between fields.
            TIME_THRESHOLD = 20000; % 20s. In our case, around 20 samples.
            
            % Final road sequences.
            indicesRoadSequenceStart = zeros(length(indices4msRoadSequenceStart),1);
            indicesRoadSequenceEnd = zeros(length(indices4msRoadSequenceStart),1);
            % Possible field sequences between road sequences.
            indicesMiddleFieldSequenceStart = zeros(length(indices4msRoadSequenceStart)-1,1);
            indicesMiddleFieldSequenceEnd = zeros(length(indices4msRoadSequenceStart)-1,1);
            
            for indexSequence = 1:(length(indices4msRoadSequenceStart)-1)
                timeBetweenSeqs = ...
                    time(indices4msRoadSequenceStart(indexSequence+1)) - time(indices4msRoadSequenceEnd(indexSequence)+1);
                if timeBetweenSeqs <= TIME_THRESHOLD
                    % Gap filling.
                    location((indices4msRoadSequenceEnd(indexSequence)+1):...
                        indices4msRoadSequenceStart(indexSequence+1)) = -100;
                else
                    % Last too long to be filled. zzzzzz Make sure it's not
                    % a stop on the road by checking direction.
                    indicesMiddleFieldSequenceStart(indexSequence) = indices4msRoadSequenceEnd(indexSequence)+1;
                    indicesMiddleFieldSequenceEnd(indexSequence) = indices4msRoadSequenceStart(indexSequence+1)-1;
                end
            end
            indicesMiddleFieldSequenceStart = indicesMiddleFieldSequenceStart(indicesMiddleFieldSequenceStart>0);
            indicesMiddleFieldSequenceEnd = indicesMiddleFieldSequenceEnd(indicesMiddleFieldSequenceEnd>0);
            
            %% 3D (lat+lon+line segmentation)
            
            % We will segment points (roughly) in a same line using our own
            % algorithm.
            if THREE_D_LATLON_LINE_SEG
                
            end
            
            %% 3D (lat+lon+direction)
            
            % We will estimate the direction using our own algorithm.
            if THREE_D_LATLON_DIRECTION
                
            end
            
            %% Continue the main test.
            
            
            
            % Take care of the start.
            if ~isempty(indices4msRoadSequenceStart)
                % Rule 1
                if RULE1
                    TIME_TO_SPEED_UP_VEHICLE = 5000; % Rule 1: 5s.
                    if indices4msRoadSequenceStart(1)>1
                        location(time(1:(indices4msRoadSequenceStart(1)-1))>=time(indices4msRoadSequenceStart(1))-TIME_TO_SPEED_UP_VEHICLE) = -100;
                    end
                end
                
                % Rule 2
                if RULE2
                    START_SPEED = 2; % Rule 2: 2m/s
                    reverseIndexStartOnRoad = find(spee((indices4msRoadSequenceStart(1)-1):-1:1)<=START_SPEED,1,'first');
                    if ~isempty(reverseIndexStartOnRoad)
                        location(...
                            (indices4msRoadSequenceStart(1)- reverseIndexStartOnRoad):...
                            (indices4msRoadSequenceStart(1)-1)...
                            ) = -100;
                    end
                end
            end
            
            % Take care of the end.
            if ~isempty(indices4msRoadSequenceEnd)
                % Rule 1
                if RULE1
                    TIME_TO_SLOW_DOWN_VEHICLE = 5000; % Rule 1: 5s.
                    
                    if indices4msRoadSequenceEnd(end)<length(time)
                        location(time((indices4msRoadSequenceEnd(end)+1):end)<=time(indices4msRoadSequenceEnd(end))+TIME_TO_SLOW_DOWN_VEHICLE) = -100;
                    end
                end
                
                % Rule 2
                if RULE2
                    END_SPEED = 2; % Rule 2: 2m/s
                    
                    reverseIndexStopOnRoad = find(spee((indices4msRoadSequenceEnd(end)+1):end)<=END_SPEED,1,'first');
                    if ~isempty(reverseIndexStopOnRoad)
                        location(...
                            (indices4msRoadSequenceEnd(end)+1):...
                            (indices4msRoadSequenceEnd(end)+reverseIndexStopOnRoad)...
                            ) = -100;
                    end
                end
                % Rule 3
                
                
            end
            
            figure('Name','lat+lon+speed, naive labeling');hold on;
            plot3(X3D4msNa(location<0,1),X3D4msNa(location<0,2),X3D4msNa(location<0,3), 'rx','LineWidth',1);
            plot3(X3D4msNa(location>0,1),X3D4msNa(location>0,2),X3D4msNa(location>0,3), 'bo','LineWidth',1);
            plot3(X3D4msNa(location==0,1),X3D4msNa(location==0,2),X3D4msNa(location==0,3), 'g+','LineWidth',1);
            hold off; grid on;
            view(3);
            toc;
            
        end
        
        %% Next route.
        
        disp('Press any key to continue...');
        pause;
        
    end
end

% EOF