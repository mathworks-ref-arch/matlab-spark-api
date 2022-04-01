function enc = getTypeEncoding(IN, OUT)
    % getTypeEncoding Helper function to get type encoding
    %
    % This function creates a string, that can be used for type encoding in
    % conjunction with the Compiler workflows for Apache Spark
    %
    % The function takes two arguments, each a cell array representing
    % typical input and output arguments of the function for which the
    % encoding is created.
    %
    % Example:
    % A function that takes 2 scalar double values, and returns another
    % double scalar
    % enc = getTypeEncoding({3, 4}, {5})
    %
    % A function that takes a table and a scalar, and returns another table
    % enc = getTypeEncoding({T_in, 4}, {T_out})

    % Copyright 2022 The MathWorks, Inc.


    S = struct();
    S.InTypes = getArray(cellify(IN));
    S.OutTypes = getArray(cellify(OUT));
    
    %     enc = sprintf('@SB-Start@\n%s\n@SB-End@\n', ...
    %         jsonencode(S, PrettyPrint=true) ...
    %         );
    enc = jsonencode(S, PrettyPrint=true);


end

function arr = getArray(C)
    N = length(C);
    arr = cell(1,N);
    for k=1:N
        E = C{k};
        classType = class(E);
        switch classType
            case 'table'
                arr{k} = {'table', getTableTypeArray(E)};
            case {...
                    'double', 'single', ...
                    'int64', 'int32', 'int16', 'int8', ...
                    'uint64', 'uint32', 'uint16', 'uint8', ...
                    'logical' ...
                    }
                arr{k} = classType;
        end
    end
end

function arr = getTableTypeArray(T)
    types = table2cell(varfun(@class, T));
    names = T.Properties.VariableNames;

    arr = cellfun(@(t,n) {t, [1,1], n}, types, names, 'UniformOutput', false);
end

function C = cellify(C)
    if ~iscell(C)
        C = {C};
    end
end
