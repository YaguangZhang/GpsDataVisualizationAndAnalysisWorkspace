function [ hFig ] = plotFilesOnMapById( files )
%PLOTFILESONMAPBYID A helper to plot all the GPS tracks on a map and color
%them according to the vehicle ids.
%
% Yaguang Zhang, Purdue, 11/08/2017

hFig = nan;
if ~isempty(files)
   hFig = figure; hold on;
   uniqIds = unique({files.id});
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
           numCurSamps = length(files(idxFile).lat);
           countEnd = countSta + numCurSamps - 1;
           lats(countSta:countEnd) = files(idxFile).lat;
           lons(countSta:countEnd) = files(idxFile).lon;
           % Leave one nan at the end of the track.
           countGpsSamp = countGpsSamp + numCurSamps + 1;
       end
       plot(lons, lats, '.-');
   end
   plot_google_map('MapType', 'satellite');
   xlabel('Lon'); ylabel('Lat'); 
   set(gca, 'xticklabel', []); set(gca, 'yticklabel', []);
   legend(uniqIds);
end

end
% EOF