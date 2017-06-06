function [a,b,c] = fitPoly1(x0,y0,GRADIENT_BOUND_G_TO_DISCARD_F, hFigureMapInField, color)
%FITPOLY1 Fit data set to a line.
%
% This function uses Matlab function fit to fit the data set (x0, y0) to a
% line ax + by + c = 0, with hopefully better performance for
% vertical-line-like data set.
%
% Inputs:
%
%   - x0,y0
%
%   Coordinates for the data set.
%
%   - GRADIENT_BOUND_G_TO_DISCARD_F
%
%   Determines when the data set is too "vertical" and we will use "inverse
%   fitting" instead.
%
%   - hFigureMapInField
%
%   If a map is available and you want to plot the lines on it, this is the
%   handle to the map you need to specify.
%
%   - color
%
%   The color for the line shown on the map, eg, 'red' or [1, 0, 0] for
%   red.
%
% Outputs:
%
%   - a,b,c
%
%   Represents the line by ax + by + c = 0.
%
% Yaguang Zhang, Purdue, 03/10/2015

f = fit(x0,y0,'poly1');
% Fit may not work well for "vertical-like" data set. So we also get the
% "inverse fitting".
g = fit(y0,x0,'poly1');

if abs(g.p1) >= GRADIENT_BOUND_G_TO_DISCARD_F
    % The gradient of g is of large absolutely value so f should be far
    % away from "vertical-like". So we use f.
    if nargin > 3
        % Plot the road line on the map.
        set(0,'CurrentFigure', hFigureMapInField);
        hold on;
        % Extend the line for plotting.
        xSmall = min(x0);
        xLarge = max(x0);
        xDiff = xLarge - xSmall;
        xSmall = xSmall - 5*xDiff;
        xLarge = xLarge + 5*xDiff;
        geoshow([f(xSmall), f(xLarge)], [xSmall, xLarge], ...
            'Color', color, 'LineWidth', 2, 'LineStyle', '--');
        geoshow([f(x0(1)), f(x0(end))], [x0(1), x0(end)], ...
            'DisplayType', 'point', 'Marker', 'o',...
            'LineWidth', 2, 'MarkerSize', 10, 'MarkerEdgeColor', color);
        hold off;
    end
    
    % Parameters needed for the line: ax + by + c = 0.
    a = f.p1;
    b = -1;
    c = f.p2;
else
    if nargin > 3
        % Discard f and use g instead.
        set(0,'CurrentFigure', hFigureMapInField);
        hold on;
        % Extend the line for plotting.
        ySmall = min(y0);
        yLarge = max(y0);
        yDiff = yLarge - ySmall;
        ySmall = ySmall - 5*yDiff;
        yLarge = yLarge + 5*yDiff;
        geoshow([ySmall,yLarge], [g(ySmall), g(yLarge)], ...
            'Color', color, 'LineWidth', 2, 'LineStyle', '--');
        geoshow([y0(1), y0(end)], [g(y0(1)), g(y0(end))], ...
            'DisplayType', 'point', 'Marker', 'o',...
            'LineWidth', 2, 'MarkerSize', 10, 'MarkerEdgeColor', color);
        hold off;
    end
    
    % Parameters needed for the line: ax + by + c = 0.
    a = 1;
    b = -g.p1;
    c = -g.p2;
end

end

% EOF