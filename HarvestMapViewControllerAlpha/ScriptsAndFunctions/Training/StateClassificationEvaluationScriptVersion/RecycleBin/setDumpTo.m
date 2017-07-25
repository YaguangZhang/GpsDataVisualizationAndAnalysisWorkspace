%SETDUMPTO
%
% Yaguang Zhang, Purdue, 05/19/2016
validateTimes;

if FLAG_TIMES_ARE_VALID
    setStatesRefSetFlag;
    updateIndicesForCurrentActiveFiles;
    
    indexFileDumpTo = get(handles.hPopupMenuLoadFrom, 'Value');
    if indexFileDumpTo==1
        warning(strcat(mfilename, ': Please select the Dump To vehicle!'));
    elseif indexFileDumpTo==length(handles.indicesActiveFiles)+2
        disp(strcat(mfilename, ': Setting dumping to a factory for',32, num2str(handles.IDX_SELECTED_FILE),'...'));
        handles = setTransferFromTo(handles.IDX_SELECTED_FILE, inf, timeStart, timeEnd, handles);        
    else
        indexFileDumpTo = indexFileDumpTo-2;
        disp(strcat(mfilename, ': Setting Loading From',32, num2str(indexFileDumpTo),' to',32, num2str(handles.IDX_SELECTED_FILE),'...'));
        handles = setTransferFromTo(handles.IDX_SELECTED_FILE, indexFileDumpTo, timeStart, timeEnd, handles);     
    end
    
    disp(strcat(mfilename, ': Dump to state successfully set.'));
    saveGuiStates;
end
% EOF