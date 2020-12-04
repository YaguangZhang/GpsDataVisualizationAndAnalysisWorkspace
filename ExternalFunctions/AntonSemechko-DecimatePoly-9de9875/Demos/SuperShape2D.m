function C=SuperShape2D(N,p,vis)
% Generate contour of a 2D shape using the super formula
% R(t,p)=(abs(cos(m*t/4)/a).^qa + abs(sin(m*t/4)/b).^qb).^(-1/q)
% parameterized by t and p.
%
% INPUT:
%   - N     : number of points. N=100 is default.
%   - p     : shape parameters, p=[a b m q qa qb]. Default setting is 
%             p=[1 1 0 1 1 1], which corresponds to a circle.
%   - vis   : set vis=true to visualise the contour. vis=false is the
%             default setting.
%
% OUTPUT:
%   - C     : (N+1)-by-2 array of point coordinates sampled along the 
%             contour in couterclockwise direction. The first and last
%             points in C are identical.
%
% AUTHOR: Anton Semechko (a.semechko@gmail.com)
%



if nargin<1 || isempty(N), N=100; end
if nargin<2 || isempty(p), p=[1 1 0 1 1 1]; end
if nargin<3 || isempty(vis), vis=false; end

a=p(1); b=p(2); r=p(3); q=p(4); qa=p(5); qb=p(6);

t=linspace(0,2*pi,(N+1))';
t(end)=0;
r=(abs(cos(r*t/4)/a).^qa + abs(sin(r*t/4)/b).^qb).^(-1/q);
r=real(r);

C=bsxfun(@times,r,[cos(t) sin(t)]);

if ~vis, return; end

figure('color','w')
plot(C(:,1),C(:,2),'-b','LineWidth',2)
hold on
axis equal

if nargout<1, clear C; end


