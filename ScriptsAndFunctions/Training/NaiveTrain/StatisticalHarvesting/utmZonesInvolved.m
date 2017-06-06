function [ zonesInvolved ] = utmZonesInvolved( utmZones )
%UTMZONESINVOLVED Get the distinct zones listed in utmZones.
%
% Input:
%   - utmZones
%     4-column char Matrix. Each row is a UTM zone.
%
% Output:
%   - zonesInvolved
%     4-column char Matrix. Each row is a distinct UTM zone shown in utmZones.
%
% Yaguang Zhang, Purdue, 05/18/2017

[numUtmZones, ~] = size(utmZones);
utmZonesCell = mat2cell(utmZones, ones(1, numUtmZones)); zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
utmZonesInvolved = utmZonesCell(1);

for idxZone = 2:length(utmZonesCell)
    zone = utmZonesCell(idxZone);
    if(~ismember(zone,utmZonesInvolved))
        utmZonesInvolved(end+1) = zone; %#ok<AGROW>
    end
end

% EOF