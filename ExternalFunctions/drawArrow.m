function [ h ] = drawArrow( x,y,props,xlimits,ylimits )
%DRAWARROW
%   http://stackoverflow.com/questions/25729784/how-to-draw-an-arrow-in-matlab

if nargin > 3
    xlim(xlimits);
    ylim(ylimits);
end

h = annotation('arrow');
set(h,'parent', gca, ...
    'position', [x(1),y(1),x(2)-x(1),y(2)-y(1)], ...
    'HeadLength', 10, 'HeadWidth', 10, 'HeadStyle', 'cback1', ...
    props{:} );

end

% EOF