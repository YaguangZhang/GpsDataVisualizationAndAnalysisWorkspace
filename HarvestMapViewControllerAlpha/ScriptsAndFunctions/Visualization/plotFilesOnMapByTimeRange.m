function [ hFig ] = plotFilesOnMapByTimeRange( files, gpsTimeRange, ...
    colorType )
%PLOTFILESONMAPBYTIMERANGE A helper to plot all the GPS samples within the
%time range specified on a map and color them according to the vehicle
%types/ids.
%
% gpsTimeRange is a 2-element vector for the start and end time of the
% range (including the end time points).
%
% colorType can be 'vehType' or 'vehId' (case insensitive).
%
% Yaguang Zhang, Purdue, 03/19/2018

vehTypes = {'Combine', 'Grain Kart', 'Truck'};
vehTypeMarkers = {'.y', '.b', '.k'};

hFig = nan;

switch lower(colorType)
    case 'vehtype'
        if ~isempty(files)
            hFig = figure; hold on;
            for idxType = 1:length(vehTypes)
                boolsCurFiles = strcmp({files.type}, vehTypes{idxType});
                numCurFiles = sum(boolsCurFiles);
                numGpsSamps = sum(arrayfun(@(f) length(f.lat), ...
                    files(boolsCurFiles)));
                [lats, lons] = deal(nan(numGpsSamps+numCurFiles, 1));
                countGpsSamp = 0;
                for idxFile = find(boolsCurFiles)
                    countSta = countGpsSamp+1;
                    
                    % New samples within the time range specified.
                    boolsNewSamps = files(idxFile).gpsTime>=gpsTimeRange(1) ...
                        & files(idxFile).gpsTime<=gpsTimeRange(2);
                    numCurSamps = sum(boolsNewSamps);
                    countEnd = countSta + numCurSamps - 1;
                    lats(countSta:countEnd) = files(idxFile).lat(boolsNewSamps);
                    lons(countSta:countEnd) = files(idxFile).lon(boolsNewSamps);
                    % Leave one nan at the end of the track.
                    countGpsSamp = countGpsSamp + numCurSamps + 1;
                end
                plot(lons, lats, vehTypeMarkers{idxType});
            end
            
            plot_google_map('MapType', 'satellite');
            xlabel('Lon'); ylabel('Lat');
            set(gca, 'xticklabel', []); set(gca, 'yticklabel', []);
            legend(vehTypes);
        end
    case 'vehid'
        if ~isempty(files)
            hFig = figure; hold on;
            uniqIds = unique({files.id});
            legendIds = {};
            numUniqIds = length(uniqIds);
            for idxId = 1:numUniqIds
                boolsCurFiles = strcmp({files.id}, uniqIds{idxId});
                numCurFiles = length(boolsCurFiles);
                numGpsSamps = sum(arrayfun(@(f) length(f.lat), ...
                    files(boolsCurFiles)));
                [lats, lons] = deal(nan(numGpsSamps+numCurFiles, 1));
                countGpsSamp = 0;
                for idxFile = find(boolsCurFiles)
                    countSta = countGpsSamp+1;
                    
                    % New samples within the time range specified.
                    boolsNewSamps = files(idxFile).gpsTime>=gpsTimeRange(1) ...
                        & files(idxFile).gpsTime<=gpsTimeRange(2);
                    numCurSamps = sum(boolsNewSamps);
                    countEnd = countSta + numCurSamps - 1;
                    lats(countSta:countEnd) = files(idxFile).lat(boolsNewSamps);
                    lons(countSta:countEnd) = files(idxFile).lon(boolsNewSamps);
                    % Leave one nan at the end of the track.
                    countGpsSamp = countGpsSamp + numCurSamps + 1;
                end
                if ~all(isnan(lons))
                    plot(lons, lats, '-', 'LineWidth', 1);
                    legendIds{end+1} = uniqIds{idxId};
                end
            end
            plot_google_map('MapType', 'satellite');
            xlabel('Lon'); ylabel('Lat');
            set(gca, 'xticklabel', []); set(gca, 'yticklabel', []);
            legend(legendIds);
        end
    otherwise
        error('Unsupported color type!')
end
end
% EOF