function hFig = resetFigWithHandleNameAndFigName(hFigName, figName)
%RESETFIGWITHHANDLENAMEANDFIGNAME Reset figure with handle and fig names.
%   RESETFIGWITHHANDLENAMEANDFIGNAME creates a new figure with the figure
%   name specified if the handle specified by "hFigName" doesn't exist or
%   it isn't a valid handle to existing graphic objects. Otherwise, it
%   clear the figure specified by "hFigName" and set that figure as the
%   current figure.
%
%   Inputs:
%
%       - hFigName
%       - figName
%
%       Strings specifying the handle name and the figure name
%       respectively.
%
%   Outpue:
%
%       - hFig
%
%       The handle to the figure. Normally it's hFigName without the
%       qutation marks.
%
%   Example:
%
%       hFigEx = resetFigWithHandleNameAndFigName('hFigEx', 'figEx');
%
%   Yaguang Zhang, Purdue, 02/12/2015

W = evalin('caller','whos'); 

% Type cell is required because we want to match a string using ismember.
if ismember({hFigName},{W(:).name})
    
    hFig = evalin('caller', hFigName);
    
    if ~ishghandle(hFig)
        hFig = figure('Name',figName,'NumberTitle','off');
    else
        clf(hFig, 'reset');
        set(0,'CurrentFigure',hFig);
    end
else
    hFig = figure('Name',figName,'NumberTitle','off');
end