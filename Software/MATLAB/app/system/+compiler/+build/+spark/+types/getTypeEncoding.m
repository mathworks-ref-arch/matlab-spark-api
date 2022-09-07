function enc = getTypeEncoding(IN, OUT, inArgNames, outArgNames)
    % getTypeEncoding Helper function to get type encoding
    %
    % This function creates a string, that can be used for type encoding in
    % conjunction with the Compiler workflows for Apache Spark
    %
    % The function takes two arguments, each a cell array representing
    % typical input and output arguments of the function for which the
    % encoding is created.
    % It can furthermore take two additional arguments providing names for
    % the input and output arguments.
    %
    % Example:
    % A function that takes 2 scalar double values, and returns another
    % double scalar
    % enc = getTypeEncoding({3, 4}, {5})
    %
    % A function that takes a table and a scalar, and returns another table
    % enc = getTypeEncoding({T_in, 4}, {T_out})

    % Copyright 2022 The MathWorks, Inc.


    if nargin < 3
        inArgNames = "in_" + (1:numel(IN));
    end
    if nargin < 4
        outArgNames = "out_" + (1:numel(OUT));
    end
    S = struct();
    S.InTypes = getArray(cellify(IN), inArgNames);
    S.OutTypes = getArray(cellify(OUT), outArgNames);
    
    %     enc = sprintf('@SB-Start@\n%s\n@SB-End@\n', ...
    %         jsonencode(S, PrettyPrint=true) ...
    %         );
    
    enc = pretty(jsonencode(S));


end

function arr = getArray(C, argNames)
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
                arr{k} = {classType, getInputSize(E), argNames{k}};
            case {'char', 'string'}
                arr{k} = {"string", getInputSize(E), argNames{k}};
            otherwise
                error('SPARK:ERROR', 'Unsupported datatype: %s', classType);
        end
    end
end

function arr = getInputSize(value)
    arr = size(value);
end


function arr = getTableTypeArray(T)
    types = table2cell(varfun(@class, T));
    names = T.Properties.VariableNames;
    sizes = table2cell(varfun(@size, T(1,:)));

    arr = cellfun(@(t,n,s) {t, s, n}, types, names, sizes, ...
        'UniformOutput', false);
end

function C = cellify(C)
    if ~iscell(C)
        C = {C};
    end
end
