%SETLOADFROMDUMPTO
%
% Yaguang Zhang, Purdue, 05/20/2016
validateTimes;

if FLAG_TIMES_ARE_VALID
    % Load from.
    indexFileLoadFrom = get(handles.hPopupMenuLoadFrom, 'Value');
    if indexFileLoadFrom==1
        % Instruction.
        indexFileLoadFrom = nan;
        warning(strcat(mfilename, ': Please select the Load From vehicle!'));
    elseif indexFileLoadFrom==2
        % Harvesting.
        indexFileLoadFrom = 0;
        disp(strcat(mfilename, ': Setting Harvesting...'));
    else
        indexFileLoadFrom = handles.indicesActiveFiles(indexFileLoadFrom-2);
        disp(strcat(mfilename, ': Setting Loading From as vehicle #', num2str(indexFileLoadFrom), '...'));
    end
    
    % Dump to.
    indexFileDumpTo = get(handles.hPopupMenuDumpTo, 'Value');
    if indexFileDumpTo==1
        % Instruction.ss
        indexFileDumpTo = nan;
        warning(strcat(mfilename, ': Please select the Dump To vehicle!'));
    elseif indexFileDumpTo==length(handles.indicesActiveFiles)+2
        % Factory.
        indexFileDumpTo = inf;
        disp(strcat(mfilename, ': Setting dumping to a factory...'));
    else
        indexFileDumpTo = handles.indicesActiveFiles(indexFileDumpTo-1);
        disp(strcat(mfilename, ': Setting Dumping To as vehicle #', num2str(indexFileDumpTo), '...'));
    end
    
    if exist('FLAG_CLEAR_LOAD_FROM_DUMP_TO','var')
        if FLAG_CLEAR_LOAD_FROM_DUMP_TO
            handles = clearTransferFromTo(indexFileLoadFrom, indexFileDumpTo, timeStart, timeEnd, handles);
            clear FLAG_CLEAR_LOAD_FROM_DUMP_TO;
        end
    else
        handles = setTransferFromTo(indexFileLoadFrom, indexFileDumpTo, timeStart, timeEnd, handles);
    end
    
    disp(strcat(mfilename, ': Dump to state successfully set.'));
    saveGuiStates;
end
% EOF