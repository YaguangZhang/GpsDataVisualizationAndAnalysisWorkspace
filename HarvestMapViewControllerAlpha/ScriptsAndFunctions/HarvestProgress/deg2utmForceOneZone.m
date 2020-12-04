function [xs, ys, curZone] = deg2utmForceOneZone(lats, lons)
%DEG2UTMFORCEONEZONE Similar to deg2utm, but the output points are forced
%to be in the same zone.
%
% Yaguang Zhang, Purdue, 11/02/2020

[xs, ys] = deal(nan(size(lats)));

% deg2utm does not support nan inputs.
boolsIsNan = isnan(lats); boolsNotNan = ~boolsIsNan;
assert(all(boolsIsNan==isnan(lons)), ...
    'Input lats and lons do not have nan values at the same locations!');

[xs(boolsNotNan), ys(boolsNotNan), zones] ...
    = deg2utm(lats(boolsNotNan), lons(boolsNotNan));
curZone = zones(1, :);

% Find the zone with most GPS samples of interest in it.
uniqueZones = unique(zones, 'rows');
numUniqueZones = size(uniqueZones, 1);
if numUniqueZones>1
    numSamplesInEachZone = zeros(numUniqueZones, 1);
    for idxUniqueZone = 1:size(uniqueZones, 1)
        curZone = uniqueZones(idxUniqueZone, :);
        numSamplesInEachZone(idxUniqueZone) ...
            = sum(ismember(zones, curZone, 'rows'));
    end
    [~, idxZoneWithMaxSamps] = max(numSamplesInEachZone);
    curZone = uniqueZones(idxZoneWithMaxSamps, :);
    
    % Force conversion in the UTM zone with most samples.
    dczone = curZone(~isspace(curZone));
    utmstruct = defaultm('utm');
    utmstruct.zone = dczone;
    utmstruct.geoid = wgs84Ellipsoid;
    utmstruct = defaultm(utmstruct);
    
    [xs(boolsNotNan), ys(boolsNotNan)] = mfwdtran(utmstruct, ...
        lats(boolsNotNan), lons(boolsNotNan));
end

end
% EOF