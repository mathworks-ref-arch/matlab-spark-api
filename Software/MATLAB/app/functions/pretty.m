function [outStr] = pretty(inStr)
    % PRETTY Function to prettify JSON using GSON

    % Copyright 2020 MathWorks, Inc.

    if isa(inStr,'sym')
        % Call the built-in
        outStr = builtin(@pretty,inStr);
    else
        % Consume the incoming JSON
        jElement = com.google.gson.JsonParser().parse(inStr);

        % Create a pretty printer
        prettyPrinter = com.google.gson.GsonBuilder().setPrettyPrinting().create();
        outStr = char(prettyPrinter.toJson(jElement));
    end

end %function
