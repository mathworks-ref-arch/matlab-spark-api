function parseCommands(obj, mccOutput)
    % parseCommand Parse output of mcc command

    % Copyright 2021-2022 The MathWorks, Inc.

    toks = regexp(mccOutput, 'Executing command: ([^\n]+)', 'tokens');
    toks = [toks{:}];

    obj.compileCmd = stripQuotes(toks{1});
    obj.jarCmd = stripQuotes(toks{2});
    obj.docCmd = stripQuotes(toks{3});

end

function str = stripQuotes(str)
    if ispc
        str = regexprep(str, '^\s*"(.*)"\s*', '$1');
    end
end