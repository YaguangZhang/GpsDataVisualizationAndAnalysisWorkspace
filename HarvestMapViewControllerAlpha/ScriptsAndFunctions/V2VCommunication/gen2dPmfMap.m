function [ hFig2dPmfMap, hFigTrack ] = gen2dPmfMap(xs, ys, gridSize)
%GEN2DPMFMAP Generate a 2D colored figure to illustrate the emperical
%probability mass function for [xs, ys].
%
% The input gridSize is the bin size, which is optional and default to 1 m.
%
% Yaguang Zhang, Purdue, 10/18/2018

if ~exist('gridSize', 'var')
    gridSize = 1;
end

% Count occurrences in bins.
nbinsx = ceil((max(xs)-min(xs))/gridSize);
nbinsy = ceil((max(ys)-min(ys))/gridSize);
[N, c] = hist3([xs, ys], 'CdataMode','auto', 'nbins', [nbinsx nbinsy], ...
    'EdgeColor', 'none');

[gridXs, gridYs] = meshgrid(c{1}, c{2});
% Note that the (m,n) element in N has bin coordinates (x_m, y_n). However,
% the outputs from meshgrid expect the (m,n) element has coordinates (x_n,
% y_m).
N = N';

% Normalization via changing the Z tick labels.
pmf = N./sum(N(:));

% Plot a debugging figure showing the cooresponding locations.
scatterMarkerArea = 1;
scatterMarkerColor = 'k';
scatterMarkerAlpha = 1/mean(N(:));

hFigTrack = figure;
scatter(xs, ys, scatterMarkerArea, ...
    'MarkerEdgeColor', 'none', 'MarkerFaceColor', scatterMarkerColor, ...
    'MarkerFaceAlpha', scatterMarkerAlpha);
xlabel('x (m)');
ylabel('y (m)');
view(2); axis equal; grid minor; 
title({'Overview for Input Locations'; ...
    ['(', num2str(length(xs(:))), ' Points)']});

% Plot.
hFig2dPmfMap = figure; hold on;
colormap('hot');

% [~, hAxis, hCb] = plot3k([gridXs(:), gridYs(:), pmf(:)]);
hMap = surf(gridXs, gridYs, pmf, 'EdgeColor', 'none');
uistack(hMap, 'bottom');
hCb=colorbar; hAxis=gca;

xlabel('x (m)');
ylabel('y (m)');
ylabel(hCb, 'Empirical PMF');
curDataAspRat = get(hAxis,'DataAspectRatio');
set(gca,'DataAspectRatio',[1 1 curDataAspRat(3)]);
view(2); axis tight;

% Highlight the axes.
curXLim = xlim;
curYLim = ylim;
plot([0 0], curYLim, 'g-');
plot(curXLim, [0 0], 'g-');

% Adjust the viewable region of the track plot accordingly.
axis(get(hFigTrack, 'CurrentAxes'), [curXLim, curYLim]);

end
% EOF