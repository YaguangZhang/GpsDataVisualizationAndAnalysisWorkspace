layer = info.Layer(1);

[A, R] = wmsread(layer, 'Latlim', currentWmLimits(1:2), 'Lonlim', currentWmLimits(3:4), ...
    'ImageHeight', IMAGE_HEIGHT, 'ImageWidth', IMAGE_WIDTH);

% For really large map view area, low resolution image may not be
% available. In this case, keep increasing the resolution and trying
% downloading the map image.
if A==0 | A == 255
    imageHeightTemp = IMAGE_HEIGHT;
    imageWidthTemp = IMAGE_WIDTH;
    while A==0 | A == 255
        imageHeightTemp = imageHeightTemp*1.5;
        imageWidthTemp = imageWidthTemp*1.5;
        [A, R] = wmsread(layer, 'Latlim', ...
            currentWmLimits(1:2), 'Lonlim', currentWmLimits(3:4), ...
            'ImageHeight', floor(imageHeightTemp), ...
            'ImageWidth', floor(imageWidthTemp));
    end
end