function datasetArray = randomSplit(obj, weights)
    % randomSplit Make a random split of a dataset
    %
    % For example, split a dataset into four smaller ones.
    %
    %  sparkDataSet = spark.read.format('csv')...
    %                   .option('header','true')...
    %                   .option('inferSchema','true')...
    %                   .load(inputLocation);
    %
    %  datasetArray = sparkDataSet.randomSplit([.25,.25,.25,.25]);
    
    % Copyright 2020-2021 MathWorks, Inc.
    
    try
        jdsArray = obj.dataset.randomSplit(weights);
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    
    for k = numel(jdsArray) : -1 : 1
        datasetArray(k) = matlab.compiler.mlspark.Dataset(jdsArray(k));
    end
end %function
