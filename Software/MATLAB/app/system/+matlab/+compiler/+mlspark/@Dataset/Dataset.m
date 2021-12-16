classdef Dataset < handle
    % DATASET Strongly typed collection of object that expose lazy operations
    % A Dataset is a strongly typed collection of domain-specific objects that
    % can be transformed in parallel using functional or relational operations.
    %
    % Each Dataset also has an untyped view called a DataFrame, which is a
    % Dataset of Row. Operations available on Datasets are divided into
    % transformations and actions. Transformations are the ones that produce
    % new Datasets, and actions are the ones that trigger computation and
    % return results.
    %
    % Example transformations include map, filter, select, and aggregate
    % (groupBy).
    %
    % Example actions count, show, or writing data out to file systems.
    %
    % Datasets are "lazy", i.e. computations are only triggered when an action
    % is invoked. Internally, a Dataset represents a logical plan that
    % describes the computation required to produce the data. When an action
    % is invoked, Spark's query optimizer optimizes the logical plan and
    % generates a physical plan for efficient execution in a parallel and
    % distributed manner. To explore the logical plan as well as optimized
    % physical plan, use the explain function.
    %
    % There are typically two ways to create a Dataset.
    % The most common way is by pointing Spark to some files on storage systems,
    % using the read function available on a SparkSession.
    %
    % For example:
    %
    %     sparkDataSet = spark.read.format('csv')...
    %         .option('header','true')...
    %         .option('inferSchema','true')...
    %         .load('/data/sample.csv');
    %
    % Datasets can also be created through transformations available on
    % existing Datasets.
    %
    % Reference:
    %     https://spark.apache.org/docs/latest/api/java/org/apache/spark/sql/Dataset.html
    
    % Copyright 2020-2021 MathWorks, Inc.
    
    properties (Hidden)
        dataset
    end
    
    methods
        %% Constructor
        function obj = Dataset(varargin)
            if nargin==1
                obj.dataset = varargin{1};
            end
        end

        %% Useful wrapper methods
        function str = char(obj)
            str = char(obj.dataset);
        end
        function str = string(obj)
            str = string(obj.dataset);
        end
    end
    
end %class