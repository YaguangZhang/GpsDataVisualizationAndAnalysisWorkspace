hWebMap = webmap;
for ind = 1:100
    h = wmmarker(hWebMap, ...
        markerLat, markerLon, 'FeatureName', 'Vehicle', ...
        'Color', color, 'Autofit', false, ...
        'Description', ...
        strcat(currentFile.type, ':', {' '}, currentFile.id, {' '}, currentFile.type), ...
        'OverlayName', ...
        strcat('Vehicle', {' '}, currentFile.type, ':', {' '}, currentFile.id));
    wmremove(h);
end