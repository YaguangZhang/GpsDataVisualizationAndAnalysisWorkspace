% TESTPROPAGATIONDISTBOUND Plots distance between samples and the line
% fitted to them.
%
% Yaguang Zhang, Purdue, 03/01/2015

close all;

tic
% x
x0 = long(index4msRoadSequenceStart:index4msRoadSequenceEnd);
% y
y0 = lati(index4msRoadSequenceStart:index4msRoadSequenceEnd);

% Fitting.
f = fit(x0,y0,'poly1');
figure
plot(f,x0,y0)
axis equal

% Parameters needed for the line: ax + by + c = 0.
a = f.p1;
b = -1;
c = f.p2;

% Nearest points.
x = (b.*( b.*x0 - a.*y0) - a*c)./(a^2+b^2);
y = (a.*(-b.*x0 + a.*y0) - b*c)./(a^2+b^2);

% Distances in meter.
distance = -ones(length(x0),1);
for idxDist = 1:length(x0)
distance(idxDist) = lldistkm([y0(idxDist) x0(idxDist)],...
    [y(idxDist) x(idxDist)])*1000;
end

figure
plot(1:length(x0),distance)

pause;
toc
%location(indexBackwardProLimit:index4msRoadSequenceStart);

% EOF