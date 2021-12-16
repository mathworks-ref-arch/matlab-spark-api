function ds = joinWith(obj, dsToJoin, joinCriteria, joinType)
    % JOINWITH Performs a join method on two datasets and returns a new Dataset with internal nesting
    %
    % JOINWITH is functionally similar to the join() method, except that the
    % resulting Dataset is represented not as a unified table but rather as a
    % two-column Dataset, where each column contains a tuple of the left and
    % right Dataset rows respectively. Also, not all input variants that join()
    % accepts are also accepted by JOINWITH.
    %
    % JOINWITH(dsToJoin,joinCriteria) performs an inner-join between this
    % Dataset and dsToJoin using the specified join criteria. joinCriteria must
    % be a Column object of boolean (logical true/false) data type. Unlike the
    % join() method, joinCriteria may not be a string.
    %
    % JOINWITH(dsToJoin,joinCriteria,joinType) performs the join operation
    % specified by joinType between this Dataset and dsToJoin, using the
    % specified join criteria. joinType must be a string with one of the
    % following values (only): inner (default), cross, outer, full, fullouter, 
    % full_outer, left, leftouter, left_outer, right, rightouter, right_outer.
    % Unlike the join() method, joinType cannot be semi, leftsemi, left_semi, 
    % anti, leftanti, or left_anti.
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
    %     dataset1.joinWith(dataset2, dataset2.col("col2")>=25)
    %
    %     dataset1.joinWith(dataset2, dataset2.col("col2")>=25, 'semi') %joinType
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html#joinWith-org.apache.spark.sql.Dataset-org.apache.spark.sql.Column-

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
                errMsg = 'The Spark joinWith() function requires specifying a join criteria';

            % If a MATLAB or Java Column object was specified
            elseif isa(joinCriteria, 'matlab.compiler.mlspark.Column') || ...
                   isa(joinCriteria, 'org.apache.spark.sql.Column')

                % first get the underlying Java Column object
                try joinCriteria = joinCriteria.column; catch, end

                % pass the column directly to the API, without checking anything
                if nargin > 3
                    % joinType was specified: pass it to API if it's a string
                    if isString(joinType)
                        jDataset = jThisDs.joinWith(jThatDs, joinCriteria, joinType);
                    else
                        errMsg = ['join type input must be a string value, ' ...
                                  'but a ' class(joinType) ' value was specified'];
                    end
                else  % joinType was not specified (API will assume 'inner')
                    jDataset = jThisDs.joinWith(jThatDs, joinCriteria);
                end

            % Otherwise, raise an error (invalid input column arg was specified)
            else
                errMsg = 'The joinWith() function expects join criteria to be a Column object of boolean (logical true/false) data type';
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
