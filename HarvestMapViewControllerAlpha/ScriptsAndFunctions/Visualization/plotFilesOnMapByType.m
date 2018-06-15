function [ hFig, hSepFigs ] = plotFilesOnMapByType( files )
%PLOTFILESONMAPBYTYPE A helper to plot all the GPS tracks on a map and
%color them according to the vehicle types.
%
% Yaguang Zhang, Purdue, 03/19/2018

vehTypes = {'Combine', 'Grain Kart', 'Truck'};
vehTypeLegends = {'Combine', 'Grain Cart', 'Truck'};
vehTypeMarkers = {'.y', '.b', '.k'};

numVehTypes = length(vehTypes);

hFig = nan;
[lats, lons, hSepFigs] = deal(cell(numVehTypes, 1));
if ~isempty(files)
    hFig = figure; hold on;
    for idxType = 1:numVehTypes
        boolsCurFiles = strcmp({files.type}, vehTypes{idxType});
        numCurFiles = sum(boolsCurFiles);
        numGpsSamps = sum(arrayfun(@(f) length(f.lat), ...
            files(boolsCurFiles)));
        [lats{idxType}, lons{idxType}] ...
            = deal(nan(numGpsSamps+numCurFiles, 1));
        countGpsSamp = 0;
        for idxFile = find(boolsCurFiles)
            countSta = countGpsSamp+1;
            numCurSamps = length(files(idxFile).lat);
            countEnd = countSta + numCurSamps - 1;
            lats{idxType}(countSta:countEnd) = files(idxFile).lat;
            lons{idxType}(countSta:countEnd) = files(idxFile).lon;
            % Leave one nan at the end of the track.
            countGpsSamp = countGpsSamp + numCurSamps + 1;
        end
        plot(lons{idxType}, lats{idxType}, vehTypeMarkers{idxType});
    end
    
    plot_google_map('MapType', 'satellite');
    xlabel('Longitude'); ylabel('Latitude');
    set(gca, 'xticklabel', []); set(gca, 'yticklabel', []);
    legend(vehTypeLegends); tightfig;
    
    for idxType = 1:numVehTypes
        hSepFigs{idxType} = figure;
        plot(lons{idxType}, lats{idxType}, vehTypeMarkers{idxType});
        
        plot_google_map('MapType', 'satellite');
        xlabel('Longitude'); ylabel('Latitude');
        set(gca, 'xticklabel', []); set(gca, 'yticklabel', []);
        legend(vehTypeLegends{idxType}); tightfig;
    end
    
end

end
% EOF