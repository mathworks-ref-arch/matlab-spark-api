function ds = join(obj, dsToJoin, joinCriteria, joinType)
    % JOIN Performs a join method on two datasets and returns the new Dataset.
    %
    % JOIN(dsToJoin) performs a join between this Dataset and dsToJoin (which
    % must also be a Dataset object), and returns a new Dataset of the result.
    % An inner-join is used for the join, but since no join condition is
    % specified, the result is the same as a full cross-join, containing a full
    % cartesian product of the rows in both datasets (i.e. N1 x N2). Subsequent
    % filtering (using the filter() or where() methods) should be performed to
    % reduce the resulting dataset size.
    %
    % JOIN(dsToJoin,joinCriteria) performs an inner-join between this Dataset
    % and dsToJoin using the specified join criteria. joinCriteria may be either
    % a column name (string) that exists in both datasets, or a string that
    % evaluates as a SQL expression that results in a boolean (logical true/
    % false) data type, or a Column object of boolean data type.
    %
    % JOIN(dsToJoin,joinCriteria,joinType) performs the join operation specified
    % by joinType between this Dataset and dsToJoin, using the specified
    % join criteria. The joinCriteria in this variant must be a Column object
    % of boolean (logical true/false) data type; it cannot be a string.
    % joinType must be a string with one of the following values (only):
    % inner (default), cross, outer, full, fullouter, full_outer, left,
    % leftouter, left_outer, right, rightouter, right_outer, semi, leftsemi,
    % left_semi, anti, leftanti, left_anti.
    %
    % Note: If you perform a join without aliasing the input datasets (using
    % the alias() or as() methods), you will only be able to reference columns
    % that exist in only one of the datasets but not both, since there is no way
    % to disambiguate which side of the join the columns reference. To reference
    % common columns that exist in both datasets, you must alias the datasets.
    %
    % Examples:
    %
    %     dataset1 = spark.read.format('csv')...
    %         .option('header','true')...
    %         .option('inferSchema','true')...
    %         .load('/data/sample1.csv')...
    %         .as('t1');  % note the aliasing as: "t1"
    %
    %     dataset2 = spark.read.format('csv')...
    %         .option('header','true')...
    %         .option('inferSchema','true')...
    %         .load('/data/sample2.csv')...
    %         .as('t2');  % note the aliasing as: "t2"
    %
    %     dataset1.join(dataset2, "sameColumn");  % column name variant
    %
    %     dataset1.join(dataset2), 't1.col1===t2.col2')       % SQL expr variant
    %     dataset1.join(dataset2).where('t1.col1===t2.col2')  % equivalent
    %
    %     dataset1.join(dataset2, dataset2.col("col2")>=25)   % Column variant
    %
    %     dataset1.join(dataset2, dataset2.col("col2")>=25, 'semi')  % joinType
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#join-org.apache.spark.sql.Dataset-

    % Copyright 2021 MathWorks, Inc.

    % Ensure that the first input arg is a MATLAB Dataset object
    dsFQCN = class(obj);
    if isa(dsToJoin, dsFQCN)
        errMsg = '';
        jThisDs = obj.dataset;
        jThatDs = dsToJoin.dataset;
        try
            % If no joinCriteria was specified
            if nargin < 3

                % join without a joinCriteria (this results in a full CROSS JOIN)
                jDataset = jThisDs.join(jThatDs);

            % If a string joinCriteria was specified
            elseif isString(joinCriteria)

                % Ignore the joinType, if specified using a string joinCriteria
                if nargin > 3
                    warning('SPARK:ERROR', ...
                            'join type can only be specified with a Column object, not a string');
                end

                % If the specified joinCriteria is a valid column name in both
                % datasets (case-insensitive)
                thisCols = obj.columns();
                thatCols = dsToJoin.columns();
                if sum(strcmpi(thisCols, joinCriteria)) && ...
                   sum(strcmpi(thatCols, joinCriteria))
                    % use the API's join(Dataset,string) variant
                    jDataset = jThisDs.join(jThatDs, joinCriteria);
                else
                    % Otherwise, treat joinCriteria as an SQL join expression
                    % For example: 
                    %    leftDs  = dataset1.as('t1');
                    %    rightDs = dataset2.as('t2');
                    %    joinCriteria = 't1.col1==t2.col2';
                    %    newDs = leftDs.join(rightDs, joinCriteria)
                    % Instead of converting the join expression into a Column
                    % object, we use the equivalent .where() syntax:
                    jDataset = jThisDs.join(jThatDs).where(joinCriteria);
                end

            % If a MATLAB or Java Column object was specified
            elseif isa(joinCriteria, 'matlab.compiler.mlspark.Column') || ...
                   isa(joinCriteria, 'org.apache.spark.sql.Column')

                % first get the underlying Java Column object
                try joinCriteria = joinCriteria.column; catch, end

                % pass the column directly to the API, without checking anything
                if nargin > 3
                    % joinType was specified: pass it to API if it's a string
                    if isString(joinType)
                        jDataset = jThisDs.join(jThatDs, joinCriteria, joinType);
                    else
                        errMsg = ['join type input must be a string value, ' ...
                                  'but a ' class(joinType) ' value was specified'];
                    end
                else  % joinType was not specified (API will assume 'inner')
                    jDataset = jThisDs.join(jThatDs, joinCriteria);
                end

            % Otherwise, raise an error (invalid input column arg was specified)
            else
                errMsg = 'The joinWith() function expects join criteria to be a valid column name, boolean SQL expression, or a boolean Column object';
            end

        catch err
            error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
        end

        if ~isempty(errMsg)
            error('SPARK:ERROR', errMsg);
        end

        % No error so far - return a new MATLAB Dataset object with the results
        ds = matlab.compiler.mlspark.Dataset(jDataset);

    else
        % Raise error - a MATLAB Dataset object was expected
        error('SPARK:ERROR', ...
              ['This function is only supported for input arguments of type ' ...
               dsFQCN]);
    end

end

function flag = isString(value)
    flag = isa(value,'char') || isa(value,'string');
end
