function [raw, args]  = getFileArgumentInfo(file)
    % getFileArgumentInfo Try to retrieve argument info

    % Copyright 2022 The MathWorks, Inc.

    raw = struct.empty;
    args = {};
    helpText = help(file);
    tok=regexp(helpText, '@SB-Start@(.+)@SB-End@', 'tokens', 'once');
    if ~isempty(tok)
        % First try JSON
        try
            raw = jsondecode(tok{1});
        catch ex
            % Evidently, this isn't JSON
        end
        if isempty(raw) && hasYAMLParser()
            try
                raw = yamldecode('string', tok{1});
            catch ex
                % Evidently, this isn't YAML
            end
        end
        if isfield(raw, 'InTypes') && isfield(raw, 'OutTypes')
            args = {raw.InTypes, raw.OutTypes};
        end
    end
    if isempty(raw)
        % If datatype information is not in the comments, it may be
        % in an external JSON file
        jsonFileName = compiler.build.spark.internal.getJSONName(file);
        if isfile(jsonFileName)
            raw = jsondecode(fileread(jsonFileName));
            args = {raw.InTypes, raw.OutTypes};
        end

    end

end
