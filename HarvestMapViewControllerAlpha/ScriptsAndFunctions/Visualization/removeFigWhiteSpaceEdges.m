% REMOVEFIGWHITESPACEEDGES A helper snippet to remove the white space
% around the plot in current figure.
%
% Ref:
% https://www.mathworks.com/help/matlab/creating_plots/save-figure-with-minimal-white-space.html
%
% Note: tightfig may work better.
%
% Yaguang Zhang, Purdue, 06/11/2018

ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];

% EOF