classdef testTable2Dataset < matlab.unittest.TestCase
    % TESTSPARKUTILITY Unit tests for the Spark Dataset abstraction
    
    % Copyright 2020 MathWorks, Inc.
    
    properties
        sparkSession;
        isDatabricks;
        TUniform
        TNonuniform
    end
    
    methods (TestClassSetup)
        function testSetup(testCase)
            % Create a Spark configuration and shared Spark session
            
            import matlab.compiler.mlspark.*
            
            testCase.isDatabricks = exist('getDefaultDatabricksSession', 'file');
            
            appName = 'Table2DatasetUnitTests';
            if testCase.isDatabricks
                spark = getDefaultDatabricksSession(appName);
            else
                spark = getDefaultSparkSession(appName);
            end
            testCase.sparkSession = spark;
            
            S = struct('Name', {"A", "B"}, 'C', {1:3,4:6});
            testCase.TUniform = struct2table(S);
            
            S = struct('Name', {"A", "B"}, 'C', {1:3,4:7});
            testCase.TNonuniform = struct2table(S);

            
            if testCase.isDatabricks
                inputLocation = '/test/unit-test-data/outages.csv';
            else
                inputLocation = addFileProtocol(which('outages.csv'));
            end            
            
        end
    end
    
    methods (TestClassTeardown)
        function testTearDown(testCase)
            
        end
    end
    
    methods (Test)
        function testConvertUniformArray(testCase)
            T = testCase.TUniform;
            spark = testCase.sparkSession;
            DS = table2dataset(T, spark);
            testCase.verifyClass(DS, 'matlab.compiler.mlspark.Dataset');
            testCase.verifyEqual(DS.count, height(T));
            testCase.verifyEqual(length(DS.columns), width(T));
        end
        
        function testConvertNonuniformArray(testCase)
            T = testCase.TNonuniform;
            spark = testCase.sparkSession;
            DS = table2dataset(T, spark);
            testCase.verifyClass(DS, 'matlab.compiler.mlspark.Dataset');
            testCase.verifyEqual(DS.count, height(T));
            testCase.verifyEqual(length(DS.columns), width(T));
        end
    end
end

