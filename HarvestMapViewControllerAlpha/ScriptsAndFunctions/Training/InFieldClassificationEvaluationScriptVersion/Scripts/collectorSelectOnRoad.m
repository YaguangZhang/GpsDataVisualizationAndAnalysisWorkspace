%COLLECTORSELECTONROAD Let the user select the GPS points which are on the
%road.
%
% Yaguang Zhang, Purdue, 03/31/2015

set(0, 'CurrentFigure', hCollectorFig);

% Disable the figure tools just to be safe.
zoom('off');
pan('off');
rotate3d('off');

% Enable these for now. Otherwise the selectdata function won't work.
set(hRoute.inField, ...
    'HandleVisibility','on');

% We only make the hRoute.inField selectable.
pl = selectdata('Axes', hAxesCollectorMap, ...
    'SelectionMode', ...
    get(get(uipanelSelectionTools,'SelectedObject'),'String'), ...
    'Ignore', ...
    [hRoute.wholeRoute, hRoute.onRoad, hMapUpdated{1:end}]);

if ~isempty(pl)
    % Update locationsRef accordingly.
    indicesSamplesInField = find(boolsSamplesInField);
    locationsRef{indexFile}(indicesSamplesInField(pl)) = -100;
    
    % And also update routeInfo and the plot.
    routeInfo.locationsRef = locationsRef{indexFile};
    delete([hRoute.inField;hRoute.onRoad]);
    % Infield: yellow. On the road: blue.
    geoshowColoredByLocation;
    
    % We will save the result every time locationRef is updated since it's
    % rather fast to do so (usually less than 0.5s).
    save(pathInFieldClassificationFile, 'locationsRef');

end

% Disable these to avoid property editor.
set(allchild(hAxesCollectorMap), ...
    'HandleVisibility','on');

% Set zoom on for convenience.
zoom('on');

% EOF