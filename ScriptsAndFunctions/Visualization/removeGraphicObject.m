function removeGraphicObject (handle)

%REMOVEGRAPHICOBJECT Utility function to remove plots of the last sample.
%
% This function will check the validity of the handle and remove it using
% delete if it's valid.
%
% Yaguang Zhang, Purdue, 03/06/2015

if ishghandle(handle)
    delete(handle);
end

end

% EOF