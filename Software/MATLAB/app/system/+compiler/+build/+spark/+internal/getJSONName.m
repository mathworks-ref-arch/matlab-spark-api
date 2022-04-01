function jsonName = getJSONName(funcName)
    % getJSONName Get the JSON name for a helper file

    % Copyright 2022 The MathWorks, Inc.

    fullFuncName = which(funcName);
    [p,n] = fileparts(fullFuncName);
    jsonName = fullfile(p, sprintf('%s_signature.json', n));
end