tic
a= zeros(5);
b= zeros(5);
for i = 1:5
    for j = 1:5
        if i~=j
%         [a(i,j), b(i,j)] = lldistkm([dotsToPlotLat(i) dotsToPlotLon(i)],...
% [dotsToPlotLat(j) dotsToPlotLon(j)]);
a(i,j) = lldistkm([dotsToPlotLat(i) dotsToPlotLon(i)],...
[dotsToPlotLat(j) dotsToPlotLon(j)]);
        end
    end
end
a
b
toc

tic
a= zeros(5);
b= zeros(5);
for i = 1:5
    for j = 1:5
        if i~=j
%         [a(i,j), b(i,j)] = lldistkm([dotsToPlotLat(i) dotsToPlotLon(i)],...
% [dotsToPlotLat(j) dotsToPlotLon(j)]);
a(i,j) = distance([dotsToPlotLat(i) dotsToPlotLon(i)],...
[dotsToPlotLat(j) dotsToPlotLon(j)],'degree');
        end
    end
end
a
b
toc
