classdef testNaMethods < matlab.unittest.TestCase
    % testNaMethods Unit tests for the Spark DataFrameNaFunctions class
    
    % Copyright 2020 MathWorks, Inc.
    
    properties
        ds
        count
        sparkSession
        cols
    end
    
    methods (TestClassSetup)
        function testSetup(testCase)
            %% Create a Spark configuration and shared Spark session

            isDatabricks = exist('getDefaultDatabricksSession', 'file');
            
            appName = 'DataFrameNaFunctionsUnitTest';
            if isDatabricks
                spark = getDefaultDatabricksSession(appName);
            else
                spark = getDefaultSparkSession(appName);
            end
            testCase.sparkSession = spark;
            
            if isDatabricks
                % Use a test file - this needs to exists on the cluster for
                % tests to pass
                inputLocation = '/data/airlinedelay/2008.csv';
            else
                % inputLocation = addFileProtocol(which('airlinesmall.csv'));
                inputLocation = addFileProtocol(getSparkApiRoot('test', 'fixtures', '2008_small.csv'));
            end
            
            % Create a dataset by pointing to all the CSV content
            sparkDataSet = spark.read.format('csv')...
                .option('header','true')...
                .option('inferSchema','true')...
                .load(inputLocation);
            
            cleanedDS = sparkDataSet ...
                .withColumn('CarrierDelay', sparkDataSet.col('CarrierDelay').cast('int')) ...
                .withColumn('WeatherDelay', sparkDataSet.col('WeatherDelay').cast('int')) ...
                .withColumn('NASDelay', sparkDataSet.col('NASDelay').cast('int')) ...
                .withColumn('SecurityDelay', sparkDataSet.col('SecurityDelay').cast('int')) ...
                .withColumn('LateAircraftDelay', sparkDataSet.col('LateAircraftDelay').cast('int'));
            
            testCase.ds = cleanedDS;
            testCase.count = testCase.ds.count();            
            testCase.cols = ["CarrierDelay", "WeatherDelay", "NASDelay", "SecurityDelay", "LateAircraftDelay"];
        end
    end
    
    methods (TestClassTeardown)
        function testTearDown(testCase)
            
        end
    end
    
    methods (Test)
        function testNA(testCase)

            DS = testCase.ds;
            NA = DS.na;
            testCase.assertClass(NA, 'matlab.compiler.mlspark.DataFrameNaFunctions')
            testCase.assertClass(NA.na, 'org.apache.spark.sql.DataFrameNaFunctions')

        end

        function testDropNoArg(testCase)
            DS = testCase.ds;
            DS2 = DS.na.drop();
            numElms = DS2.count();
            testCase.assertGreaterThanOrEqual(testCase.count, numElms);
        end

        function testDropLimit(testCase)
            DS = testCase.ds;
            DS2 = DS.na.drop(5);
            numElms = DS2.count();
            testCase.assertGreaterThanOrEqual(testCase.count, numElms);
        end

        function testDropLimitCols(testCase)
            DS = testCase.ds;
            DS2 = DS.na.drop(5, testCase.cols);
            numElms = DS2.count();
            testCase.assertGreaterThanOrEqual(testCase.count, numElms);
        end

        function testDropCols(testCase)
            DS = testCase.ds;
            DS2 = DS.na.drop(testCase.cols);
            numElms = DS2.count();
            testCase.assertGreaterThanOrEqual(testCase.count, numElms);
        end
        
        function testDropHow(testCase)
            DS = testCase.ds;
            DS2 = DS.na.drop("any");
            numElms = DS2.count();
            testCase.assertGreaterThanOrEqual(testCase.count, numElms);
        end

        function testDropHowCols(testCase)
            DS = testCase.ds;
            DS2 = DS.na.drop("any", testCase.cols);
            numElms = DS2.count();
            testCase.assertGreaterThanOrEqual(testCase.count, numElms);
        end

    end
end
