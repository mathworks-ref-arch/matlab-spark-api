function row = head(obj, varargin)
    % HEAD Fetch the head of the given dataset
    % Returns a single GenericRowWithSchema
    % 
    % Example:
    %     
    %     % Create a dataset 
    %     myLocation = '/test/*.parquet');
    %     myDataSet = spark...
    %         .read.format('parquet')...
    %         .option('header','true')...
    %         .option('inferSchema','true')...
    %         .load(myLocation);
    %   
    %      % Read a single row
    %      singleRow = myDataSet.head();  
    % 
    % To read multiple rows, specify the number of rows to read.

    % Copyright 2020-2021 MathWorks, Inc.

    if nargin == 2

        % Check if the input number of rows
        numRows = varargin{1};
        if isnumeric(numRows)
            try
                row = obj.dataset.head(numRows);
            catch err
                error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
            end
        else
            % Specify a number of rows to read
            error('DATABRICKS:Invalid','Please specify the number of rows to read');
        end

    else
        % Read a single row
        try
            row = obj.dataset.head();
        catch err
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end
    end

end %function
