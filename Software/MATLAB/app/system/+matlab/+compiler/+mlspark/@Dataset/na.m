function dfnf = na(obj)
    % na DataFrameNaFunctions object

    % Copyright 2022 MathWorks, Inc.


    dfnf = matlab.compiler.mlspark.DataFrameNaFunctions(obj.dataset.na());

end %function
