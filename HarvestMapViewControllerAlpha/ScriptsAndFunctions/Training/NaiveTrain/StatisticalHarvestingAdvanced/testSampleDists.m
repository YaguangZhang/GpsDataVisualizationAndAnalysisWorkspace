%TESTSAMPLEDIST Test sampleDistsToLineWith2dGausPts.m.
%
% Yaguang Zhang, Purdue, 02/08/2018

close all; clc;

cd(fileparts(which(mfilename)));

z = [0.5;1.5];
s1 = [-1;0];
s2 = [1,0];
sampleNum = 100000;
flagPlotDist = true;

% Move z up, each time by 1.
saveasPrefix = '1_equalSigmas_';
sigma1 = 1;
sigma2 = 1;
for deltaZ = 1:10
    newZy = z(2) + deltaZ;
[~, hFig] = sampleDistsToLineWith2dGausPts( ...
    [z(1); newZy], s1, s2, sigma1, sigma2, sampleNum, flagPlotDist, saveasPrefix );
saveas(hFig, [saveasPrefix, 'sampleDistsZy', num2str(newZy), '.png']);
end

% Change sigmas.
saveasPrefix = '2_largerSigma1_';
sigma1 = 1.5;
sigma2 = 0.5;
for deltaZ = 1:10
    newZy = z(2) + deltaZ;
[~, hFig] = sampleDistsToLineWith2dGausPts( ...
    [z(1); newZy], s1, s2, sigma1, sigma2, sampleNum, flagPlotDist, saveasPrefix );
saveas(hFig, [saveasPrefix, 'sampleDistsZy', num2str(newZy), '.png']);
end

% Change sigmas.
saveasPrefix = '3_largerSigma2_';
sigma1 = 0.5;
sigma2 = 1.5;
for deltaZ = 1:10
    newZy = z(2) + deltaZ;
[~, hFig] = sampleDistsToLineWith2dGausPts( ...
    [z(1); newZy], s1, s2, sigma1, sigma2, sampleNum, flagPlotDist, saveasPrefix );
saveas(hFig, [saveasPrefix, 'sampleDistsZy', num2str(newZy), '.png']);
end
% EOF