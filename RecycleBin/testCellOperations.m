indexVehicleUnloadedTo=3;
if isempty(products{indexVehicleUnloadedTo})
    % Create the cell array for the vehicle unloaded to if necessary.
    products{indexVehicleUnloadedTo} = cell(1,1);
    products{indexVehicleUnloadedTo}(1) = struct;
else
    % Extend the cell for the next product structure.
    products{indexVehicleUnloadedTo}...
        (length(products{indexVehicleUnloadedTo})+1)...
        = struct;
end