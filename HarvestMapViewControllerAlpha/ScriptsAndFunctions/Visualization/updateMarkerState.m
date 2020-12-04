function updateMarkerState(src, evnt)
%UPDATEMARKERSATE Add a new marker to markLocs and update the overview
%figure accordingly.
%
% For simplisity, we will just modify variables in the base workspace.
%
% Inputs:
%   - src, evnt
%     The source and event which triggers this callback function.
%
% Yaguang Zhang, Purdue, 05/29/2018

try
    markLocs = evalin('base', 'markLocs');
catch
    markLocs = nan(0,2); 
end

hOverviewFig = evalin('base', 'hFigOverview');
try
    hMarkLocs = evalin('base', 'hMarkLocs');
catch
    hMarkLocs = [];
end

% (lon, lat).
ptOnClick = evnt.IntersectionPoint(1:2);
% Save (lat, lon).
markLocs = [markLocs; ptOnClick(2) ptOnClick(1)];
disp('updateMarkerState: New markLoc added!');
disp(['                       (Lat, Lon) = (', num2str(ptOnClick(2)), ...
    ', ', num2str(ptOnClick(1)), ')']);

% Update the markLocs on the figure.
deleteHandles(hMarkLocs);
[numMarks, ~] = size(markLocs);
hMarkerAxes = findall(hOverviewFig, 'type', 'axes');
hMarkLocs = plot3(hMarkerAxes, ...
    markLocs(:, 2), markLocs(:, 1), ones(numMarks,1), ...
    'rx', 'LineWidth', 2);

% Save the results to the base workspace.
assignin('base', 'markLocs', markLocs);
assignin('base', 'hMarkLocs', hMarkLocs);

end
% EOF