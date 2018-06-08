% TRIAL1_VEHICELEVENTS Trial 1 - Convert files and states
%
% Yaguang Zhang, Purdue, 11/14/2017

format long;

% Load data and set the current Matlab directory.
cd(fileparts(mfilename('fullpath')));
prepareTrial;
cd(fileparts(mfilename('fullpath')));

vehicleEvents = convertStatesToVehEvents(files, statesByDist);

% Save the result to a csv file for andrew.
allEvents = combineEvents([vehicleEvents{:,2}]');
struct2csv(allEvents,'allEvents.csv');

% And add two more fields: eventStartLat, eventStartLon.
allEventsWithGeo = allEvents;
numEvents = length(allEventsWithGeo.vehId);
[allEventsWithGeo.eventStartLat, allEventsWithGeo.eventStartLon] ...
    = deal(nan(numEvents,1));
for idxE = 1:numEvents
    % Load the file index.
    curVehFileIdx = allEventsWithGeo.vehFileIdx(idxE);
    % Find the sample index when the event starts.
    curEventGpsTimeStart = allEventsWithGeo.estiGpsTimeStart(idxE);
    sampIdx = find(files(curVehFileIdx).gpsTime>=curEventGpsTimeStart, 1);
    startGpsTime = files(curVehFileIdx).gpsTime(sampIdx);
    if startGpsTime~=curEventGpsTimeStart
        warning(['There is a ', num2str(startGpsTime-curEventGpsTimeStart), ...
            ' ms difference between the GPS time for the sample located and that for the start of the event!'])
        disp(fetchEventByIdx(allEventsWithGeo, idxE))
    end
    
    allEventsWithGeo.eventStartLat(idxE) = files(curVehFileIdx).lat(sampIdx);
    allEventsWithGeo.eventStartLon(idxE) = files(curVehFileIdx).lon(sampIdx);
end

% Keep unloading events with 5 fields: event, idFrom, idTo, estiTimeStart,
% estiTimeEnd.
unloadingEventsMinWithGeo = rmfield(allEventsWithGeo, {'vehId','vehFileIdx','type', ...
    'fileIdxFrom','fileIdxTo','estiGpsTimeStart','estiGpsTimeEnd'});
% Remove 'h' events.
fields = fieldnames(unloadingEventsMinWithGeo);
boolsIsH = strcmp(unloadingEventsMinWithGeo.event,'h');
for idxF = 1:numel(fields)
    unloadingEventsMinWithGeo.(fields{idxF})(boolsIsH) = [];
end
struct2csvFormattedNonIntReal(unloadingEventsMinWithGeo, ...
    'unloadingEventsMinWithGeo.csv', '%.8f');

% EOF