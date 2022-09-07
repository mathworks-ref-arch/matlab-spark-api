function rows = tableToRowInputs(T)
    % tableToRowInputs Internal helper function.
    %
    % This is an internal function, and not part of the API.

    % Copyright 2021-2022 MathWorks, Inc.

    % The function takes a table, as a normal MATLAB function would expect
    % it, and turns its inputs into rows, as they will be received in the
    % SparkBuilder interfaces. This is only used to facilitate development
    % and debugging.

    C = table2cell(T);
    N = size(C, 1);
    rows = cell(N, 1);
    for k=1:N
        rows{k} = C(k,:);
    end


end


