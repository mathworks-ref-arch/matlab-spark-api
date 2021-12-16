function ds = sample(obj, fraction)
    % Sample Returns a new Dataset by sampling a fraction of the number of rows in the dataset.  
    % Fraction must be a number in the range between 0.0 and 1.0.

    % Copyright 2021 MathWorks, Inc.

    if nargin > 1 && isnumeric(fraction) && isscalar(fraction) && fraction >= 0 && fraction <= 1
        try
            ds = matlab.compiler.mlspark.Dataset(obj.dataset.sample(fraction));
        catch err
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end
    else
        error('SPARK:ERROR', ...
            'Sample seed must be a number between 0.0 and 1.0');
    end

end %function
