function [ gpsSegs ] = fetchGpsTrackSegsForNodes( traceTree, files, ...
    nodeIndices)
%FETCHGPSTRACKSEGSFORNODES Fetch the unloading (or harvesting for swaths
%nodes) GPS segments for nodes.
%
% Output:
%   - gpsSegs
%     A cell array for [lats lons] of all the nodes. And
%     gpsSegs{nodeIndices} will be the GPS segments needed. For indices not
%     specified in the input nodeIndices, gpsSegs does not gurantee to have
%     valid cell elements for them.
%
% Yaguang Zhang, Purdue, 03/12/2018

if ~isempty(nodeIndices)
    CACHE_FOR_GPS_SEGS = 'unloadingGpsSegsForAllNodes';
    if evalin('base', ['exist(''', CACHE_FOR_GPS_SEGS,''')'])
        gpsSegs = evalin('base', CACHE_FOR_GPS_SEGS);
    else
        gpsSegs = cell(length(traceTree), 1);
    end
    
    nodeIndicesNotCovered = nodeIndices(cellfun('isempty', gpsSegs(nodeIndices)));
    
    if ~isempty(nodeIndicesNotCovered)
        for nodeIdx = nodeIndicesNotCovered
            fIdx = traceTree(nodeIdx).fileIdx;
            if ~isnan(fIdx)
                nodeFile = files(fIdx);
                gpsTimeStart = [traceTree(nodeIdx).estiGpsTimeStartUnloading];
                gpsTimeEnd = [traceTree(nodeIdx).estiGpsTimeEndUnloading];

                boolsGpsSampsToFetch = nodeFile.gpsTime>=gpsTimeStart & ...
                    nodeFile.gpsTime<=gpsTimeEnd;

                gpsSegs{nodeIdx} = [nodeFile.lat(boolsGpsSampsToFetch), ...
                    nodeFile.lon(boolsGpsSampsToFetch)];
            end
        end
        
        assignin('base', CACHE_FOR_GPS_SEGS, gpsSegs);
    end
else
    gpsSegs = cell(length(traceTree), 1);
end

end
% EOF