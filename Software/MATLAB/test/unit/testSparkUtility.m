classdef testSparkUtility < matlab.unittest.TestCase
    % TESTSPARKUTILITY Unit tests for the Spark Dataset abstraction
    
    % Copyright 2020 MathWorks, Inc.
    
    properties
        ds;
        count;
        sparkSession;
        isDatabricks;
    end
    
    methods (TestClassSetup)
        function testSetup(testCase)
            % Create a Spark configuration and shared Spark session
            
            import matlab.compiler.mlspark.*
            
            testCase.isDatabricks = exist('getDefaultDatabricksSession', 'file');
            
            appName = 'SparkUtilityUnitTests';
            if testCase.isDatabricks
                spark = getDefaultDatabricksSession(appName);
            else
                spark = getDefaultSparkSession(appName);
            end
            testCase.sparkSession = spark;
            
            if testCase.isDatabricks
                inputLocation = '/test/unit-test-data/outages.csv';
            else
                inputLocation = addFileProtocol(which('outages.csv'));
            end
            
            % Create a dataset by pointing to all the CSV content
            outages = spark.read.format('csv')...
                .option('header','true')...
                .option('inferSchema','true')...
                .load(inputLocation);
            
            ODS = outages ...
                .withColumn("OutageDate", functions.to_date(outages.col("OutageTime")));
            
            
            testCase.ds = ODS;
            testCase.count = testCase.ds.count();
            
        end
    end
    
    methods (TestClassTeardown)
        function testTearDown(testCase)
            
        end
    end
    
    methods (Test)
        function testConvertDateTable(testCase)
            ODS = testCase.ds;
            T = table(ODS.limit(20));
            testCase.verifyClass(T, 'table');
            testCase.verifyClass(T.OutageDate, 'datetime');
        end
        
        function testConvertBooleanTable(testCase)
            spark = testCase.sparkSession;
            S = struct('Name', {"Alice", "Bob"}, 'Female', {true, false}, 'Male', {false, true});
            T = struct2table(S);
            DS = table2dataset(T, spark);
            T2 = table(DS);
            testCase.verifyEqual(T, T2);
        end
        
        function testWrappedArray(testCase)
            spark = testCase.sparkSession;
            if testCase.isDatabricks
                fileName = '/test/unit-test-data/wrapperarray.parquet';
            else
                fileName = addFileProtocol(getSparkApiRoot('test', 'fixtures', 'wrapperarray.parquet'));
            end
            DS = spark.read.format("parquet") ...
                .load(fileName);
            T = table(DS);
            testCase.verifyClass(T, 'table');
            col_fail = T.col_fail;
            testCase.verifyClass(col_fail, 'cell');
            testCase.verifySize(col_fail, [5,3]);
            testCase.verifyClass(col_fail{1,1}, 'double');
            testCase.verifySize(col_fail{1,1}, [1,1]);
            
        end
        
        function testStructArray(testCase)
            spark = testCase.sparkSession;
            if testCase.isDatabricks
                fileName = '/test/unit-test-data/nested1.parquet';
            else
                fileName = addFileProtocol(getSparkApiRoot('test', 'fixtures', 'nested1'));
            end
            DS = spark.read.format("parquet") ...
                .load(fileName);
            T = table(DS);
            testCase.verifyEqual(height(T), 3);
            testCase.verifyClass(T.animal_interpretation, 'struct');
        end
        
        function testNestedStructArray(testCase)
            spark = testCase.sparkSession;
            if testCase.isDatabricks
                fileName = '/test/unit-test-data/nested2.parquet';
            else
                fileName = addFileProtocol(getSparkApiRoot('test', 'fixtures', 'nested2'));
            end
            DS = spark.read.format("parquet") ...
                .load(fileName);
            T = table(DS);
            testCase.verifyEqual(height(T), 3);
            testCase.verifyClass(T.animal_interpretation, 'struct');
            Tai = T.animal_interpretation;
            testCase.verifyClass(Tai(1).deep, 'struct');
            
        end
        
        function testWindowedDataset(testCase)
            import matlab.compiler.mlspark.*
            
            outages = testCase.ds;
            
            rgds = outages.groupBy(functions.window(outages.col("OutageTime"), "1 week"));
            d2 = rgds.count();
            try
                counts = table(d2.limit(100));
            catch ME %#ok<NASGU>
                testCase.assertTrue(false, ...
                    'It should be possible to create a table from data with Window Structs');
            end
            cw = counts.window;
            testCase.verifyClass([cw.start], 'datetime');
            testCase.verifyClass([cw.end], 'datetime');
            
        end
        
        function testLongSupport(testCase)
            
            % Fetch the spark session
            spark = testCase.sparkSession;
            
            % Create a range of 10 long integers
            myDS = spark.range(0,10);
            testCase.verifyClass(myDS,'matlab.compiler.mlspark.Dataset');
            
            % Cast into a MATLAB table
            matlabTable = table(myDS);
            testCase.verifyClass(matlabTable,'table');
            
            % Check for the right types
            testCase.verifyClass(matlabTable.id, 'int64');
            
        end
        
        function testMissingInts(testCase)
            if testCase.isDatabricks
                return;
            end
            
            % Fetch the spark session
            spark = testCase.sparkSession;
            
            flightsCSV = which('airlinesmall.csv');
            flights = spark.read.format("csv") ...
                .option("header", "true") ...
                .option("inferSchema", "true") ...
                .load(addFileProtocol(flightsCSV));

            cleanFlights = flights ...
                .withColumn('ArrDelay', flights.col('ArrDelay').cast('int')) ...
                .withColumn('DepDelay', flights.col('DepDelay').cast('int'));

            AAflights = cleanFlights.filter("UniqueCarrier LIKE 'AA' AND DayOfWeek = 3") ...
                .select('ArrDelay', 'DepDelay');
    
            AAT = table(AAflights);
            testCase.assertClass(AAT, 'table');
            
        end
        
        
        
    end
end

