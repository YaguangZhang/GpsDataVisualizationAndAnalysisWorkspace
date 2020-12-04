function refinedlocs = refineLocationsByRoadPolyshape( ...
    locations, files, roadsPolyshapeLonLat)
%REFINELOCATIONSBYROADPOLYSHAPE Refine the on-the-road labels, locations,
%for the GPS records, files, according to the (lon, lat) polyshape for the
%roads.
%
% Yaguang Zhang, Purdue, 10/31/2020

disp('==============================')
disp('refineLocationsByRoadPolyshape')
disp('==============================')

MAX_NUM_PTS_TO_TEST = 3000;

refinedlocs = locations;
numOfFiles = length(files);
for idxFile = 1:numOfFiles
    disp([datestr(now, 'yyyy/mm/dd HH:MM:ss'), ' ', ...
        num2str(idxFile), '/', num2str(numOfFiles), '...']);
    % Note: 0 for "in field" and -100 for "on road".
    curFileLocs = locations{idxFile};
    
    numPts = length(curFileLocs);
    idxTest = 1;
    while (idxTest-1)*MAX_NUM_PTS_TO_TEST<numPts
        curRange ...
            = (((idxTest-1)*MAX_NUM_PTS_TO_TEST+1) ...
            :min(idxTest*MAX_NUM_PTS_TO_TEST, numPts));
        
        curFileLocs( ...
            isinterior(roadsPolyshapeLonLat, ...
            files(idxFile).lon(curRange), ...
            files(idxFile).lat(curRange))) = -100;
        
        idxTest = idxTest+1;
    end
    refinedlocs{idxFile} = curFileLocs;
end
disp([datestr(now, 'yyyy/mm/dd HH:MM:ss'), ' Done!']);
end
% EOF