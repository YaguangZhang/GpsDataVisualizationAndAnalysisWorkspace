%TESTALPHASHAPEBOUND Play with the boundaries of several alpha shapes to
%find a simple & unified way to represent complex polygons (for field
%shapes).
%
% Yaguang Zhang, Purdue, 08/23/2017

close all;
%% 
xv = [1 4 3.5 4 1 1 NaN 2 2 3 3 2 NaN 2.2 2.8 2.8 2.2 2.2];
yv = [1 1 2.5 4 4 1 NaN 2 3 3 2 2 NaN 2.2 2.2 2.8 2.8 2.2];

rng default
xq = rand(5000,1)*5;
yq = rand(5000,1)*5;

in = inpolygon(xq,yq,xv,yv);

figure

plot(xv,yv,'LineWidth',2) % polygon
axis equal

hold on
plot(xq(in),yq(in),'r+') % points inside
plot(xq(~in),yq(~in),'bo') % points outside
hold off
title('Field inside hole inside field')

%% 
xv = [1 4 3.5 4 1 1 NaN 2 3 3 2 2];
yv = [1 1 2.5 4 4 1 NaN 2 2 3 3 2];

rng default
xq = rand(5000,1)*5;
yq = rand(5000,1)*5;

in = inpolygon(xq,yq,xv,yv);

figure

plot(xv,yv,'LineWidth',2) % polygon
axis equal

hold on
plot(xq(in),yq(in),'r+') % points inside
plot(xq(~in),yq(~in),'bo') % points outside
hold off
title('Field inside field')


%% 
xv = [1 4 3.5 4 1 1 NaN 2 2 3 3 2 NaN 2.2 2.8 2.8 2.2 2.2];
yv = [1 1 2.5 4 4 1 NaN 2 5 3 2 2 NaN 2.2 2.2 2.8 2.8 2.2];

rng default
xq = rand(5000,1)*5;
yq = rand(5000,1)*5;

in = inpolygon(xq,yq,xv,yv);

figure

plot(xv,yv,'LineWidth',2) % polygon
axis equal

hold on
plot(xq(in),yq(in),'r+') % points inside
plot(xq(~in),yq(~in),'bo') % points outside
hold off
title('Field intersects with hole')

%%
xv = [2.2 2.8 2.8 2.2 2.2 NaN 2 2 3 3 2 NaN 1 4 3.5 4 1 1 ];
yv = [2.2 2.2 2.8 2.8 2.2 NaN 2 3 3 2 2 NaN 1 1 2.5 4 4 1 ];

rng default
xq = rand(5000,1)*5;
yq = rand(5000,1)*5;

in = inpolygon(xq,yq,xv,yv);

figure

plot(xv,yv,'LineWidth',2) % polygon
axis equal

hold on
plot(xq(in),yq(in),'r+') % points inside
plot(xq(~in),yq(~in),'bo') % points outside
hold off
title('Field inside hole inside field (Different order)')

%% 

xv = [0.5;0.2;1.0;0;0.8;0.5];
yv = [1.0;0.1;0.7;0.7;0.1;1];

rng default
xq = rand(5000,1)*2-0.5;
yq = rand(5000,1)*2-0.5;

in = inpolygon(xq,yq,xv,yv);

figure

plot(xv,yv,'LineWidth',2) % polygon
axis equal

hold on
plot(xq(in),yq(in),'r+') % points inside
plot(xq(~in),yq(~in),'bo') % points outside
hold off
title('Non-simple polygon')

%% 

xv = [0.5;0.2;1.0;0;0.8;0.5];
yv = [1.0;0.1;0.7;0.7;0.1;1];

xv = xv(end:-1:1);
yv = yv(end:-1:1);

rng default
xq = rand(5000,1)*2-0.5;
yq = rand(5000,1)*2-0.5;

in = inpolygon(xq,yq,xv,yv);

figure

plot(xv,yv,'LineWidth',2) % polygon
axis equal

hold on
plot(xq(in),yq(in),'r+') % points inside
plot(xq(~in),yq(~in),'bo') % points outside
hold off
title('Non-simple polygon (clockwise)')

%%

xv = [0.5;0.2;1.0;0;0.8;0.5]';
yv = [1.0;0.1;0.7;0.7;0.1;1]';

xv = xv+2;
yv = yv+2;

xv = [1 4 3.5 4 1 1 NaN xv];
yv = [1 1 2.5 4 4 1 NaN yv];

rng default
xq = rand(5000,1)*5;
yq = rand(5000,1)*5;

in = inpolygon(xq,yq,xv,yv);

figure

plot(xv,yv,'LineWidth',2) % polygon
axis equal

hold on
plot(xq(in),yq(in),'r+') % points inside
plot(xq(~in),yq(~in),'bo') % points outside
hold off

%%

xv = [0.5;0.2;1.0;0;0.8;0.5]';
yv = [1.0;0.1;0.7;0.7;0.1;1]';

xv = xv(end:-1:1)+2;
yv = yv(end:-1:1)+2;

xv = [1 4 3.5 4 1 1 NaN xv];
yv = [1 1 2.5 4 4 1 NaN yv];

rng default
xq = rand(5000,1)*5;
yq = rand(5000,1)*5;

in = inpolygon(xq,yq,xv,yv);

figure

plot(xv,yv,'LineWidth',2) % polygon
axis equal

hold on
plot(xq(in),yq(in),'r+') % points inside
plot(xq(~in),yq(~in),'bo') % points outside
hold off

% EOF