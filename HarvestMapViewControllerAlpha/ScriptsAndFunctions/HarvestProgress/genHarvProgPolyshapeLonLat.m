function [harvProgPolyshpLonLat, newHarvProgAlphaShpInfo] ...
    = genHarvProgPolyshapeLonLat(lats, lons, ...
    alphaInM, halfHeaderWidthInM, curFieldPolyshpLonLat, ...
    harvProgAlphaShpInfo)
%GENHARVPROGPOLYSHAPELONLAT Generate harvest progress polyshape in (lon,
%lat).
%
% Inputs:
%   - lats, lons
%     The lagtitude and longitude values of the GPS points to use in
%     constructing the havest progress polyshape.
%   - alphaInM, halfHeaderWidthInM
%     To ensure a good output, we will construct the field in UTM using
%     alpha shape with the value for alpha being alphaInM, and the
%     resultent shape will be extended by halfHeaderWidthInM.
%   - curFieldPolyshpLonLat
%     Optional. The (lon, lat) polyshape for the current field that the
%     harvest progress polyshape is in. If presented, it will be used to
%     trim harvProgPolyshpLonLat.
%   - harvProgAlphaShpInfo
%     Optional. A struct with field harvProgPolyshpUtm and curZone, which
%     can be used as the input for this function to speed up the alpha
%     shape generation.
%
% Yaguang Zhang, Purdue, 11/02/2020

if ~exist('harvProgAlphaShpInfo', 'var')
    harvProgAlphaShpInfo = [];
end

if ~isempty(lats)
    % Construct an alpha shape to reflect the harvest progress.
    [xs, ys, curZone] = deg2utmForceOneZone(lats, lons);
    % We will duplicate the input points so that a single point would
    % generate a valid polyshape, too.
    [xs, ys] = duplicatePtsInEightDirs(xs, ys, halfHeaderWidthInM);
    if (~isempty(harvProgAlphaShpInfo))&& ...
            strcmp(harvProgAlphaShpInfo.curZone, curZone)
        harvProgPolyshpUtm = harvProgAlphaShpInfo.harvProgPolyshpUtm;
        harvProgPolyshpUtm.Points = [harvProgPolyshpUtm.Points; ...
            xs, ys];
    else
        harvProgPolyshpUtm = alphaShape(xs, ys);
        harvProgPolyshpUtm.Alpha = alphaInM;
    end    
    
    % Generate harvProgPolyshpLonLat accordingly.
    harvProgPolyshpLonLat = alphaShapeUtm2PolyshapeLonLat( ...
        harvProgPolyshpUtm, curZone);
    
    % Extend the shape by half of the header width.
    harvProgPolyshpLonLat = extendPolyshapeLonLatWithHoles( ...
        harvProgPolyshpLonLat, halfHeaderWidthInM);
    
    if exist('curFieldPolyshpLonLat', 'var')
        harvProgPolyshpLonLat = intersect(harvProgPolyshpLonLat, ...
            curFieldPolyshpLonLat);
    end
    
    newHarvProgAlphaShpInfo.harvProgPolyshpUtm = harvProgPolyshpUtm;
    newHarvProgAlphaShpInfo.curZone = curZone;
else
    harvProgPolyshpLonLat = polyshape();
    newHarvProgAlphaShpInfo = [];
end

end
% EOF