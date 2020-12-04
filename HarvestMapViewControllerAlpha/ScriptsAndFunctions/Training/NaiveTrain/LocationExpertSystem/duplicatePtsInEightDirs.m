function [xsNew, ysNew] = duplicatePtsInEightDirs(xs, ys, dist)
%DUPLICATEPTSINEIGHTDIRS For each input point, make eight copies of it, at
%eight directions around that point with a constant distance.
%
% Yaguang Zhang, Purdue, 11/03/2020

ratio45deg = cosd(45);

xsNew = [xs; ... Original
    xs; ... Up
    xs+dist.*ratio45deg;... Upper right
    xs+dist; ... Right
    xs+dist.*ratio45deg; ... Lower right
    xs; ... Down
    xs-dist.*ratio45deg; ... Lower left
    xs-dist; ... Left
    xs-dist.*ratio45deg ... Upper left
    ];
ysNew = [ys;  ... Original
    ys+dist; ... Up
    ys+dist.*ratio45deg;... Upper right
    ys; ... Right
    ys-dist.*ratio45deg; ... Lower right
    ys-dist; ... Down
    ys-dist.*ratio45deg; ... Lower left
    ys; ... Left
    ys+dist.*ratio45deg ... Upper left
    ];

end
% EOF