%CLEARVEHICLEDISTANCES
% Remove the links and texts plotted by "showVehicleDistancesAndStates".
%
% Yaguang Zhang, Purdue, 02/06/2015

pairCounterClear = 0;

% Only when the plots have been created for at least once, it will be
% necessary to clear them.
if exist('hHintVehicleDistsText','var')
    
    % Clear hint.
    if ishghandle(hHintVehicleDistsText)
        delete(hHintVehicleDistsText);
    end
    
    for kClear=1:1:vehicleNum
        
        % Clear number labels on the vehicles.
        if ishghandle(hMapVehicleText(kClear))
            delete(hMapVehicleText(kClear));
        end
        
        for lClear = 1:1:vehicleNum
            if kClear < lClear
                
                pairCounterClear = pairCounterClear + 1;
                
                % Clear links between vehicles.
                if ishghandle(hMapVehicleDistsLinks(pairCounterClear))
                    delete(hMapVehicleDistsLinks(pairCounterClear));
                end
                
                % Clear distance labels between vehicles.
                if ishghandle(hMapVehicleDistsText(pairCounterClear))
                    delete(hMapVehicleDistsText(pairCounterClear));
                end
                
                % Clear labels on the right side.
                if ishghandle(hVehicleDistsText(pairCounterClear))
                    delete(hVehicleDistsText(pairCounterClear));
                end
            end
        end
    end
    
end

% EOF
