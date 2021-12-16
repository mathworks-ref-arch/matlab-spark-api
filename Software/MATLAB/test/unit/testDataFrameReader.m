classdef testDataFrameReader < matlab.unittest.TestCase
    % TESTDATAFRAMEREADER Unit tests for the dataframe reader
    
    % Copyright 2019 MathWorks, Inc.
    
    properties
        sparkSession;
        isDatabricks;
    end
    
    methods (TestClassSetup)
        function testSetup(testCase)
            % Create a singleton SparkSession using the getOrCreate() method
            testCase.isDatabricks = exist('getDefaultDatabricksSession', 'file');
            
            appName = 'DataFrameReaderUnitTests';
            if testCase.isDatabricks
                spark = getDefaultDatabricksSession(appName);
            else
                spark = getDefaultSparkSession(appName);
            end
            testCase.sparkSession = spark;
            
        end
    end
    
    methods (TestClassTeardown)
        function testTearDown(testCase)
            
        end
    end
    
    methods (Test)
        function testConstructor(testCase)
            dfr = matlab.compiler.mlspark.DataFrameReader();
            testCase.verifyClass(dfr,'matlab.compiler.mlspark.DataFrameReader');
        end
        
        function testConstructorWithArgs(testCase)
            dfr = matlab.compiler.mlspark.DataFrameReader(1);
            testCase.verifyClass(dfr,'matlab.compiler.mlspark.DataFrameReader');
            testCase.verifyNotEmpty(dfr.dataFrameReader);
        end
        
        function testFormat(testCase)
            % Set the format to CSV
            myDataSet = testCase.sparkSession.read.format('csv');
            
            % Check that it was successful
            testCase.verifyClass(myDataSet, 'matlab.compiler.mlspark.DataFrameReader');
        end
        
        function testOption(testCase)
            % Create a dataset
            myDataSet = testCase.sparkSession...
                .read.format('csv')...
                .option('header','true')...
                .option('inferSchema','true');
            
            % Check that it was successful
            testCase.verifyClass(myDataSet, 'matlab.compiler.mlspark.DataFrameReader');
        end
        
        function testLoad(testCase)
            % Read a slice of data
            if testCase.isDatabricks
                % Testcase databricks
                inputLocation = '/data/airlinedelay/2008.csv';
            else
                % Testcase Spark
                inputLocation = addFileProtocol(which('airlinesmall.csv'));
            end
            % Create a dataset
            myDataSet = testCase.sparkSession...
                .read.format('csv')...
                .option('header','true')...
                .option('inferSchema','true')...
                .load(inputLocation);
            
            % Check that it was successful
            testCase.verifyClass(myDataSet, 'matlab.compiler.mlspark.Dataset');
        end
        
    end
    
end

