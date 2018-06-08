function [ hFig ] = plotFilesOnMapByType( files )
%PLOTFILESONMAPBYTYPE A helper to plot all the GPS tracks on a map and color
%them according to the vehicle types.
%
% Yaguang Zhang, Purdue, 03/19/2018

vehTypes = {'Combine', 'Grain Kart', 'Truck'};
vehTypeMarkers = {'.y', '.b', '.k'};

hFig = nan;
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
           numCurSamps = length(files(idxFile).lat);
           countEnd = countSta + numCurSamps - 1;
           lats(countSta:countEnd) = files(idxFile).lat;
           lons(countSta:countEnd) = files(idxFile).lon;
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

end
% EOF