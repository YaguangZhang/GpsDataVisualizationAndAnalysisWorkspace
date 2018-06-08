function [ distSamps, hFig ] = sampleDistsToLineWith2dGausPts( z, s1, s2, ...
    sigma1, sigma2, sampleNum, flagPlotDist, saveasPrefix )
%SAMPLEDISTSTOLINEWITH2DGAUSPTS Samples possible distance values from point
%z to a line specified by two 2D gaussian points. (Matlab version>=2015b)
%
% Inputs:
%   - z
%     Point of interest. Should be a 2x1 vector.
%   - s1, s2, sigma1, sigma2
%     The 2D gaussian points have means s1 and s2 in R^2 (2x1 vectors). For
%     each point, the standard deviation sigma is the same for both axes.
%   - sampleNum
%     Number of samples to return.
%   - flagPlotDist
%     Set flagPlotDist to be true to generate figures for the results. 
%
% Yaguang Zhang, Purdue, 02/08/2018

% s1Samps =  [s1(1) + sigma1 .* randn(1, sampleNum); s1(2) + sigma1 .*
% randn(1, sampleNum)]; s2Samps =  [s2(1) + sigma2 .* randn(1, sampleNum),
% s2(2) + sigma2 .* randn(1, sampleNum)];
s1Samps = [normrnd(s1(1), sigma1, 1, sampleNum); ...
    normrnd(s1(2), sigma1, 1, sampleNum)];
s2Samps = [normrnd(s2(1), sigma2, 1, sampleNum); ...
    normrnd(s2(2), sigma2, 1, sampleNum)];

s1SampsC =  mat2cell(s1Samps, 2, ones(1, sampleNum));
s2SampsC =  mat2cell(s2Samps, 2, ones(1, sampleNum));

zSampsC = mat2cell(repmat(z, 1, sampleNum), 2, ones(1, sampleNum));

distFct = @(z,s1,s2) norm((z-s1)-((z-s1)'*(s2-s1)/((norm(s2-s1))^2))*(s2-s1));
distSamps = arrayfun(@(idx) distFct(zSampsC{idx}, s1SampsC{idx}, s2SampsC{idx}), 1:sampleNum);

hFig = nan;
if exist('flagPlotDist','var')&&flagPlotDist
    % Settings for the plot.
    figureWidth = 800;
    figureHeight = 600;
    markerSize = 10;
    scatterMarkerSize = 3;
    alphaValue = 1000/sampleNum;
    nbins = 100;
    num2strPre = 4;
    
    hFig = figure;
    set(hFig, 'Unit', 'pixel');
    curPos = get(hFig, 'Position');
    set(hFig, 'Position', [curPos(1), 0, figureWidth, figureHeight]);
    subplot(2,2,1);
    hold on;
    scatterS1 = scatter(s1Samps(1,:), s1Samps(2,:), scatterMarkerSize, ...
        'MarkerFaceColor','r', ...
        'MarkerEdgeColor','none', 'MarkerFaceAlpha', alphaValue);
    alpha(scatterS1, alphaValue);
    scatterS2 = scatter(s2Samps(1,:), s2Samps(2,:), scatterMarkerSize, ...
        'MarkerFaceColor','b', ...
        'MarkerEdgeColor','none', 'MarkerFaceAlpha', alphaValue);
    alpha(scatterS1, alphaValue);
    plot(z(1), z(2), 'kx', 'MarkerSize', markerSize, 'LineWidth', 3);
    scatter(s1(1), s1(2), 2*markerSize, 'MarkerFaceColor','r', 'MarkerEdgeColor','k');
    scatter(s2(1), s2(2), 2*markerSize, 'MarkerFaceColor','b', 'MarkerEdgeColor','k');
    hold off; axis equal;
    xlabel('x (m)'); ylabel('y (m)');
    title('Setup'); grid on;
    
    subplot(2,2,2);
    distSampsM = mean(distSamps);
    distSampsSigma = std(distSamps);
    hist(distSamps, nbins);
    refD = distFct(z,s1,s2);
    xlabel(['RefD: ', num2str(refD, num2strPre), ...
        ' Mean: ', num2str(distSampsM, num2strPre), ...
        ' Std: ', num2str(distSampsSigma, num2strPre)]);
    title('Histogram for dist. samples'); grid on;
    
    subplot(2,2,3);
    [ksF, ksXi] = ksdensity(distSamps,'Support','positive');
    % We propose to approximate the PDF with a Gaussian one:
    %   - mean
    %     The distance from z to line (s1, s2).
    %   - standard deviation
    %     Set the same as sigma2.
    normPdfXs = normpdf(ksXi,refD,sigma2);
    hold on;
    hKsDen = plot(ksXi, ksF, 'b-');
    hGauDen = plot(ksXi, normPdfXs, 'r-.');
    hold off; legend([hKsDen, hGauDen],'KsDen','GauDen')
    xlabel('x'); ylabel('f(x)');
    title('Estimated PDF for dist. samples vs. Simple Gaussian'); grid on;
    
    subplot(2,2,4);
    ecdf(distSamps);
    title('Empirical CDF for dist. samples'); grid on;
end

end
% EOF