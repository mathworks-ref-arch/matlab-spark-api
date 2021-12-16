function show(obj, varargin)
    % SHOW Method to display the top part of a dataset in the console
    %
    % SHOW(obj) displays the top 20 Dataset rows in a tabular form. Strings
    % more than 20 characters are truncated, and all cells are right-aligned.
    %
    % SHOW(obj,truncate) is the same as SHOW(obj), with a logical (true/false)
    % flag to indicate whether or not to truncate strings longer than 20 chars
    % (default=true).
    %
    % SHOW(obj,numRows,truncate) is the same as SHOW(obj,truncate) with an
    % additional numeric input (numRows) specifying how many rows to display
    % (default=20). In this variant, the truncate value can be set to any
    % integer >=0 to specify the number of characters beyond which string
    % truncation will occur.
    %
    % SHOW(obj,numRows,truncate,vertical) is the same as 
    % SHOW(obj,numRows,truncate) with an additional input (vertical) of logical
    % data type (true/false) indicating whether to display the data in regular
    % tabular format (default=false) or in a verbose vertical format (true).
    % 
    % Example:
    %
    %     % Create a dataset
    %     myDataSet = spark...
    %         .read.format('parquet')...
    %         .option('header','true')...
    %         .option('inferSchema','true')...
    %         .load('/test/*.parquet');
    %
    %     % Display the top part of the dataset
    %     myDataSet.show();        %top 20 rows
    %     myDataSet.show(false);   %top 20 rows, no string truncation
    %     myDataSet.show(8,false); %top 8 rows, no string truncation
    %     myDataSet.show(8,15);    %top 8 rows, truncate strings after 15 chars
    %     myDataSet.show(8,5,true);%top 8 rows, truncate after 5 chars, vertical
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#show--

    % Copyright 2020-2021 MathWorks, Inc.

    try
        obj.dataset.show(varargin{:});
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end

end %function
