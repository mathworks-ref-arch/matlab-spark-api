function explanationStr = explain(obj, extended)
    % EXPLAIN Returns a string explanation of the column, or prints it to console for debugging
    %
    % explain(obj) displays a string explanation of the column in the console.
    %
    % explain(obj, extended) enables display of extended debugging information,
    % if the optional extended input is set to true (default=false).
    %
    % explanationStr = explain(_) returns the explanation as a string instead of
    % displaying it in the console;
    %
    % Example:
    %     % DS is a dataset
    %     % C1 is a column
    %
    %     % Return an explanation of a column
    %     C1 = DS.col("columnName");
    %     explanation = C1.explain(true)    % => "columnName#307375"
    %
    %     % Return an explanation of a modified column
    %     explanation = explain(C1 + 1.5);  % => "(`columnName` + 1.5D)"

    % Copyright 2021 MathWorks, Inc.

    try
        extended = nargin > 1 && extended;
        if nargout
            explanationStr = string(strtrim(evalc('obj.column.explain(extended)')));
        else
            obj.column.explain(extended);
        end
    catch
        error('SPARK:ERROR', 'The explain function requires an input argument of type logical (true/false)');
    end
end
