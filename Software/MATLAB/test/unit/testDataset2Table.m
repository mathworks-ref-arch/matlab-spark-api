classdef testDataset2Table < matlab.unittest.TestCase
    % testDataset2Table Unit tests for the Dataset table conversion

    % Copyright 2021 MathWorks, Inc.

    properties
        ds
        dsNames
        dsBinary
        count
        sparkSession
        table
        sparkMajorVersion
    end

    methods (TestClassSetup)
        function testSetup(testCase)
            %% Create a Spark configuration and shared Spark session
            isDatabricks = exist('getDefaultDatabricksSession', 'file');

            C=matlab.sparkutils.Config.getInMemoryConfig;
            testCase.sparkMajorVersion = C.getSparkMajorVersion;
            appName = 'DatasetUnitTests';
            binFile = getSparkApiRoot('test', 'fixtures', 'data3.orc');

            if isDatabricks
                spark = getDefaultDatabricksSession(appName);
                db = databricks.DBFS();
                dbDstFile = '/test/unit-test-data/data3.orc';
                db.upload(binFile, dbDstFile);
                testCase.dsBinary = spark.read.format("orc").load(dbDstFile);
            else
                spark = getDefaultSparkSession(appName);
                testCase.dsBinary = spark.read.format("orc").load(addFileProtocol(binFile));
            end

            testCase.sparkSession = spark;

            basicStruct = struct('a','qwerty', 'b',-pi);
            basicTable = struct2table(basicStruct);
            basicMap = containers.Map({'a','b'}, {123,-pi}); %Spark Maps only support a single key/value data type
            basicArray = num2cell(magic(3));

            dv = datetime;
            dv.Second = round(dv.Second, 3);
            dv = num2cell(dv + (1:8));

            % CalendarDuration is only supported in Spark 3.x
            if testCase.sparkMajorVersion < 3
                dur = num2cell(1:8);
            else
                dur = num2cell(duration + (1:8));
            end
            S = struct(...
                'String1',  {"Alice", "Bob", "Céline", "Dimitri", "Esperanza", "Fredrik", 'George', 'Helen'}, ...
                'String2',  {"Blue", "Green", "Pink", "Tartufo", "Green", "", "", missing}, ...
                'Double',   {25, 35, 30, 40, 50, pi, NaN, missing}, ...
                'Single',   num2cell(single([25, 35, 30, 40, 50, pi, NaN, missing])), ...
                'Int64',    num2cell(repmat(int64([intmax('int64'), intmin('int64'), 0, NaN]),1,2)), ...
                'Int32',    num2cell(repmat(int32([intmax('int32'), intmin('int32'), 0, NaN]),1,2)), ...
                'Int16',    num2cell(repmat(int16([intmax('int16'), intmin('int16'), 0, NaN]),1,2)), ...
                'Int8',     num2cell(repmat(int8( [intmax('int8'),  intmin('int8'),  0, NaN]),1,2)), ...
                'Logical',  num2cell(repmat([true,false],1,4)), ...
                'Date',     dv, ...
                'Duration', dur, ...
                'Struct',   repmat({basicStruct},1,8),  ...
             ...'Table',    repmat({basicTable}, 1,8),  ... %TODO: table is converted into a struct, so converting back will never match
                'Map',      repmat({basicMap},   1,8),  ...
                'Array',    repmat({basicArray}, 1,8)   ...
                );
            T = struct2table(S);
            testCase.table = T;

            if getSparkMajorVersion >= 3
                testCase.dsNames = table2dataset(T, spark);
            end
        end
    end

    methods (TestClassTeardown)
        function testTearDown(testCase)

        end
    end

    methods (Test)

        function testNameTable(testCase)
            if getSparkMajorVersion < 3
                % No support for CalendarInterval in Spark 2.x
                return;
            end
            DS = testCase.dsNames;

            T = DS.table();

            testCase.verifyEqual(DS.count, height(T));

            testCase.verifyEqual(T.String1, testCase.table.String1)
            testCase.verifyEqual(T.String2, testCase.table.String2)
            testCase.verifyEqual(T.Double, testCase.table.Double)
            testCase.verifyEqual(T.Single, testCase.table.Single)
            testCase.verifyEqual(T.Int64, testCase.table.Int64)
            testCase.verifyEqual(T.Int32, testCase.table.Int32)
            testCase.verifyEqual(T.Int16, testCase.table.Int16)
            testCase.verifyEqual(T.Int8, testCase.table.Int8)
            testCase.verifyEqual(T.Logical, testCase.table.Logical)
            testCase.verifyEqual(T.Date, testCase.table.Date, 'AbsTol', milliseconds(10))
            testCase.verifyEqual(T.Duration, testCase.table.Duration)
            testCase.verifyEqual(T.Struct, testCase.table.Struct)
            testCase.verifyEqual(T.Map, testCase.table.Map)
            testCase.verifyEqual(T.Array, testCase.table.Array)

            DS.show, disp(T)
        end

        function testBinaryData(testCase)
            if getSparkMajorVersion < 3
                % No support for CalendarInterval in Spark 2.x
                return;
            end
            
            DS = testCase.dsBinary;

            T = DS.table();

            testCase.verifyEqual(DS.count, height(T));
            testCase.verifyClass(T.bin, 'int8');
        end

    end
end
