% Example:
%  Plot a set of points, then select some with the mouse using a
%  rectangular brush, return the indices of those points selected. (Note:
%  user interaction on the plot will be necessary.)

x = 0:.1:1;
y = x.^2;
plot(x,y,'o')
pl = selectdata('selectionmode','brush');

% Example:
%  Select a single point with the mouse, then delete that selected point
%  from the plot.

pl = selectdata('selectionmode','closest','action','delete');

% Example:
%  Select some points using a rect(rbbox) tool, also return the (x,y)
%  coordinates from multiple curves plotted. Use shortened versions of the
%  properties and values.

plot(rand(5,2),rand(5,2),'o')
[pl,xs,ys] = selectdata('sel','r');

% Example:
%  Plot a curve and some data points on one plot, select some points from
%  the data plotted, but ignore the smooth curve, even if the lasso passes
%  over it.
x = 0:.01:1;
y = exp(x);
ynoisy = y + randn(size(y))/2;
h1 = plot(x,y,'-');
hold on
h2 = plot(x,ynoisy,'o');
[pl,xs,ys] = selectdata('sel','lasso','ignore',h1);