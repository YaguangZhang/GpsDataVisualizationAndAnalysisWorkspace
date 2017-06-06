%SETLOADFROM
%
% Yaguang Zhang, Purdue, 05/19/2016
validateTimes;

if FLAG_TIMES_ARE_VALID
    setStatesRefSetFlag;
    
    indexFileLoadFrom = get(handles.hPopupMenuLoadFrom, 'Value');
    if indexFileLoadFrom==1
        warning(strcat(mfilename, ': Please select the Load From vehicle!'));
    elseif indexFileLoadFrom==2
        disp(strcat(mfilename, ': Setting Harvesting for',32, num2str(handles.IDX_SELECTED_FILE),'...'));
        handles = setTransferFromTo(0, handles.IDX_SELECTED_FILE, timeStart, timeEnd, handles);        
    elseif indexFileLoadFrom==3
        disp(strcat(mfilename, ': Setting Harvesting for',32, num2str(handles.IDX_SELECTED_FILE),'...'));
        handles = setTransferFromTo(-1, handles.IDX_SELECTED_FILE, timeStart, timeEnd, handles); 
    else
        indexFileLoadFrom = indexFileLoadFrom-2;
        disp(strcat(mfilename, ': Setting Loading From',32, num2str(indexFileLoadFrom),' to',32, num2str(handles.IDX_SELECTED_FILE),'...'));
        handles = setTransferFromTo(indexFileLoadFrom, handles.IDX_SELECTED_FILE, timeStart, timeEnd, handles);     
    end
    
    disp(strcat(mfilename, ': Load from state successfully set.'));
    saveGuiStates;
end

% EOF