function fillEmptyNames(obj)
    % fillEmptyNames Set names for arguments that weren't given any

    % Copyright 2022 The MathWorks, Inc.

    try
        [inArgCandidates, outArgCandidates] = getArgs(obj.name);
    catch ME
        % If this fails, just don't use it.
        inArgCandidates = "in_" + (1:obj.nArgIn);
        outArgCandidates = "out_" + (1:obj.nArgOut);
    end

    for k=1:length(obj.InTypes)
        if isempty(obj.InTypes(k).Name)
            obj.InTypes(k).Name = inArgCandidates(k);
        end
    end

    for k=1:length(obj.OutTypes)
        if isempty(obj.OutTypes(k).Name)
            obj.OutTypes(k).Name = outArgCandidates(k);
        end
    end
end

function [inArgs, outArgs] = getArgs(fileName)
    % Parse file
    t = mtree(fileName, '-file');
    % Get inputs
    inArgs = string.empty;
    outArgs = string.empty;
    ins = t.Ins;
    while ~ins.isempty
        inArgs(end+1) = ins.string; %#ok<AGROW>
        ins = ins.Next;
    end
    % Get outputs
    outs = t.Outs;
    while ~outs.isempty
        outArgs(end+1) = outs.string; %#ok<AGROW>
        outs = outs.Next;
    end
end