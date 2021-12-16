classdef testFunctions < matlab.unittest.TestCase
    % TESTFUNCTIONS Unit tests for the Spark SQL Functions
    
    % Copyright 2020 MathWorks, Inc.
    
    properties
        ds;
        dateDS;
        dateTable;
        numTable;
        numDS;
        trigDS;
        count;
        sparkSession;
        isDatabricks;
        dsNames;

    end
    
    methods (TestClassSetup)
        function testSetup(testCase)
            % Create a Spark configuration and shared Spark session
            import matlab.compiler.mlspark.*

            testCase.isDatabricks = exist('getDefaultDatabricksSession', 'file');
            
            appName = 'FunctionsUnitTests';
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
            sparkDataSet = spark.read.format('csv')...
                .option('header','true')...
                .option('inferSchema','true')...
                .load(inputLocation);
            
            tmpDS = sparkDataSet ...
                .withColumn("OutageDate", functions.to_date(sparkDataSet.col("OutageTime"))) ...
                .withColumn("OutageTimestamp", functions.to_timestamp(sparkDataSet.col("OutageTime"))) ...
                .withColumn("RestorationTime", functions.to_date(sparkDataSet.col("RestorationTime"))) ...
                ;
            
            testCase.ds = tmpDS;
            testCase.count = testCase.ds.count();
            
            old = cd(getSparkApiRoot('test', 'fixtures'));
            goBack = onCleanup(@() cd(old));
            
            testCase.dateTable = dateExamplesTable();
            testCase.dateDS = table2dataset(testCase.dateTable, spark);
            
            testCase.numTable = numExamplesTable();
            testCase.numDS = table2dataset(testCase.numTable, spark);
            testCase.trigDS = table2dataset(trigonometryTable(), spark);
            
            S = struct(...
                'Name', {"Alice", "Bob", "Céline", "Dimitri", "Esperanza", "Fredrik"}, ...
                'Age', {25, 35, 30, 40, 50, 20}, ...
                'FavColor', {"Blue", "Green", "Pink", "Tartufo", "Green", "Green"}, ...
                'Pet', {"Dog", "Cat", "Iguana", "Iguana", "Giraffe", "Cat"}, ...
                'Grade', {55, 35, 90, 88, 70, 77}...
                );
            T = struct2table(S);
                
            testCase.dsNames = table2dataset(T, spark);
        end
        
    end
    
    methods (TestClassTeardown)
        function testTearDown(testCase)
            
        end
    end
    
    methods (Test)
        
        function testYears(testCase)
            testTimeHelper(testCase, "OutageYears", 2000, 2016, ...
                @matlab.compiler.mlspark.functions.year);
        end
        
        function testMonths(testCase)
            testTimeHelper(testCase, "OutageMonths", 1, 12, ...
                @matlab.compiler.mlspark.functions.month);
        end
        
        function testHours(testCase)
            testTimeHelper(testCase, "OutageHours", 0, 24, ...
                @matlab.compiler.mlspark.functions.hour);
        end
        
        function testMinutes(testCase)
            testTimeHelper(testCase, "OutageMinutes", 0, 60, ...
                @matlab.compiler.mlspark.functions.minute);
        end
        
        function testSeconds(testCase)
            testTimeHelper(testCase, "OutageSeconds", 0, 60, ...
                @matlab.compiler.mlspark.functions.second);
        end
        
        function testDayOfYear(testCase)
            testTimeHelper(testCase, "OutageDayOfYear", 1, 366, ...
                @matlab.compiler.mlspark.functions.dayofyear);
        end
        
        function testDayOfMonth(testCase)
            testTimeHelper(testCase, "OutageDayOfMonth", 1, 32, ...
                @matlab.compiler.mlspark.functions.dayofmonth);
        end
        
        function testDayOfWeek(testCase)
            testTimeHelper(testCase, "OutageDayOfWeek", 1, 7, ...
                @matlab.compiler.mlspark.functions.dayofweek);
        end
        
        function testWeekOfYear(testCase)
            testTimeHelper(testCase, "OutageWeekOfYear", 1, 53, ...
                @matlab.compiler.mlspark.functions.weekofyear);
        end
        
        
        function testWindow(testCase)
            import matlab.compiler.mlspark.*
            
            outages = testCase.ds;
            
            rgds = outages.groupBy(functions.window(outages.col("OutageTime"), "1 week"));
            d2 = rgds.count();
            counts = table(d2.select("count"));
            testCase.verifyEqual(sum(counts.count), outages.count);
            
            rgds = outages.groupBy(functions.window(outages.col("OutageTime"), "1 week", "1 day"));
            d2 = rgds.count();
            counts = table(d2.select("count"));
            testCase.verifyGreaterThan(sum(counts.count), outages.count);
            
            rgds = outages.groupBy(...
                functions.window(outages.col("OutageTime"), "1 day"), ...
                outages.col("Loss"));
            
        end
        
        function testToDate(testCase)
            import matlab.compiler.mlspark.*
            DS = testCase.dateDS;
            NDS = DS ...
                .withColumn('C1', functions.to_date(DS.col("yyyyMMdd_HHmmssdotSSSS"))) ...
                .withColumn('C2', functions.to_date(DS.col("yyyyMMdd_HHmmss"))) ...
                .withColumn('C3', functions.to_date(DS.col("yyyyMMdd_HHmm"))) ...
                .withColumn('C4', functions.to_date(DS.col("yyyyMMdd"))) ...
                .withColumn('C5', functions.to_date(DS.col("ddMMyyyy"), "dd-MM-yyyy")) ...
                ;
            NT = table(NDS);
            testCase.verifyEqual(NT.C1, NT.C2);
            testCase.verifyEqual(NT.C1, NT.C3);
            testCase.verifyEqual(NT.C1, NT.C4);
            testCase.verifyEqual(NT.C1, NT.C5);
        end
        
        function testToTimestamp(testCase)
            import matlab.compiler.mlspark.*
            DS = testCase.dateDS;
            T = testCase.dateTable;
            NDS = DS ...
                .withColumn('C1', functions.to_timestamp(DS.col("yyyyMMdd_HHmmssdotSSSS"))) ...
                .withColumn('C2', functions.to_timestamp(DS.col("yyyyMMdd_HHmmss"))) ...
                .withColumn('C3', functions.to_timestamp(DS.col("yyyyMMdd_HHmm"))) ...
                .withColumn('C4', functions.to_timestamp(DS.col("yyyyMMdd"))) ...
                .withColumn('C5', functions.to_timestamp(DS.col("ddMMyyyy"), "dd-MM-yyyy")) ...
                ;
            NT = table(NDS);
            
            testCase.verifyEqual(NT.C4, NT.C5);
        end
        
        function testDateAdd(testCase)
            % Tests both date_add and date_sub
            import matlab.compiler.mlspark.*
            DS = testCase.ds;
            DSD = DS ...
                .withColumn("DatePlus5Days", functions.date_add(DS.col("OutageTime"), 5)) ...
                .withColumn("DateMinus10Days", functions.date_sub(DS.col("OutageTime"), 10)) ...
                ... Now just keep the columns we need
                .select("OutageDate", "DatePlus5Days", "DateMinus10Days");
            
            TD = table(DSD);
            OD = TD.OutageDate;
            testCase.verifyTrue(all(TD.DatePlus5Days-OD==days(5)));
            testCase.verifyTrue(all(OD-TD.DateMinus10Days==days(10)));
            
        end
        
        function testAddMonths(testCase)
            
            import matlab.compiler.mlspark.*
            DS = testCase.ds;
            DSD = DS ...
                .withColumn("DatePlus2Months", functions.add_months(DS.col("OutageTime"), 2)) ...
                .withColumn("DateMinus3Months", functions.add_months(DS.col("OutageTime"), -3)) ...
                ... Now just keep the columns we need
                .select("OutageDate", "DatePlus2Months", "DateMinus3Months");
            DSM = DSD ...
                .withColumn("M", functions.month(DSD.col("OutageDate"))) ...
                .withColumn("Mp2", functions.month(DSD.col("DatePlus2Months"))) ...
                .withColumn("Mm3", functions.month(DSD.col("DateMinus3Months"))) ...
                ... Now just keep the columns we need
                .select("OutageDate", "M", "Mp2", "Mm3");
            
            TD = table(DSM);
            Mp2D = TD.Mp2-TD.M;
            Mm3D = TD.M-TD.Mm3;
            
            Mp2DNegIdx = Mp2D<0;
            Mp2D(Mp2DNegIdx) = int32(12)+Mp2D(Mp2DNegIdx);
            
            testCase.verifyTrue(all(Mp2D==2));
            
            Mm3DNegIdx = Mm3D<0;
            Mm3D(Mm3DNegIdx) = int32(12)+Mm3D(Mm3DNegIdx);
            testCase.verifyTrue(all(Mm3D==3));
            
        end
        
        function testRound(testCase)
            
            import matlab.compiler.mlspark.*
            DS = testCase.numDS;
            numT = testCase.numTable;
            testCase.verifyEqual(DS.count(), height(numT));
            
            rDS = DS ...
                .withColumn("Round", functions.round(DS.col("X"))) ...
                .withColumn("Round2", functions.round(DS.col("X"), 2)) ...
                .withColumn("Round5", functions.round(DS.col("X"), 5)) ...
                ;
            
            TDS = table(rDS);
            testCase.verifyTrue(all(round(numT.X) == TDS.Round));
            testCase.verifyTrue(all(round(numT.X, 2) == TDS.Round2));
            testCase.verifyTrue(all(round(numT.X, 5) == TDS.Round5));
            
        end
        
        function testSum(testCase)
            
            import matlab.compiler.mlspark.*
            DS = testCase.ds;
            
            sDS = DS ...
                .groupBy(...
                functions.year(DS.col('OutageTime')), ...
                functions.month(DS.col('OutageTime')) ...
                );
            
            XDS = sDS ...
                .agg(functions.sum(DS.col("Customers"))) ...
                .sort("year(OutageTime)", "month(OutageTime)") ...
                ;
            TDS = table(XDS);
            
            TOrig = table(DS.select("Customers"));
            CustOrig = TOrig.Customers;
            SumOriginal = sum(CustOrig(~isnan(CustOrig)));
            CustAgg = TDS{:,"sum(Customers)"};
            SumAgg = sum(CustAgg(~isnan(CustAgg)));
            
            testCase.verifyLessThan(abs(SumAgg-SumOriginal),4e-3);
            
        end
        
        function testMean(testCase)
            
            import matlab.compiler.mlspark.*
            DS = testCase.ds;
            
            sDS = DS ...
                .groupBy(...
                functions.year(DS.col('OutageTime')));
            
            XDS = sDS ...
                .agg(functions.mean(DS.col("Customers"))) ...
                .sort("year(OutageTime)") ...
                ;
            TDS = table(XDS);
            
        end
        
        function testMin(testCase)
            
            import matlab.compiler.mlspark.*
            DS = testCase.ds;
            
            sDS = DS ...
                .groupBy(...
                functions.year(DS.col('OutageTime')));
            
            minDS = sDS ...
                .agg(functions.min(DS.col("Customers"))) ...
                .sort("year(OutageTime)") ...
                ;
            T= table(minDS);
            testCase.verifyClass(T, 'table');

        end            
        
        function testMax(testCase)
            
            import matlab.compiler.mlspark.*
            DS = testCase.ds;
            
            sDS = DS ...
                .groupBy(...
                functions.year(DS.col('OutageTime')));
            
            maxDS = sDS ...
                .agg(functions.max(DS.col("Customers"))) ...
                .sort("year(OutageTime)") ...
                ;
            T= table(maxDS);
            testCase.verifyClass(T, 'table');

        end            
        
        function testAbs(testCase)
            import matlab.compiler.mlspark.*
            DS = testCase.trigDS;
            DS2 = DS ...
                .withColumn("SparkAbsX", functions.abs(DS.col("X")));
            T = table(DS2.select(["AbsX", "SparkAbsX"]));
            testCase.assertEqual(T.AbsX, T.SparkAbsX);
        end
        
        function testAsin(testCase)
            import matlab.compiler.mlspark.*
            DS = testCase.trigDS;
            DS2 = DS ...
                .withColumn("SparkArcsine", functions.asin(DS.col("Sine")));
            T = table(DS2.select(["Arcsine", "SparkArcsine"]));
            testCase.assertEqual(T.Arcsine, T.SparkArcsine);
        end
        
        function testAcos(testCase)
            import matlab.compiler.mlspark.*
            DS = testCase.trigDS;
            DS2 = DS ...
                .withColumn("SparkArkTangent", functions.acos(DS.col("Cosine")));
            T = table(DS2.select(["Arccosine", "SparkArkTangent"]));
            testCase.assertEqual(T.Arccosine, T.SparkArkTangent);
        end
        
        function testAtan(testCase)
            import matlab.compiler.mlspark.*
            DS = testCase.trigDS;
            DS2 = DS ...
                .withColumn("SparkArkTangent", functions.atan(DS.col("Tangent")));
            T = table(DS2.select(["Arctangent", "SparkArkTangent"]));
            testCase.assertEqual(T.Arctangent, T.SparkArkTangent);
        end
        
        function testCurrentTimestamp(testCase)
            import matlab.compiler.mlspark.*
            
            DS = testCase.dateDS;
            
            DS2 = DS ...
                .withColumn("CleanTimestamp", functions.current_timestamp());
            T = table(DS2);
            testCase.verifyLength(unique(T.CleanTimestamp), 1);
            testCase.verifyClass(T.CleanTimestamp, 'datetime');
        end
        
        function testDateFormat(testCase)
            import matlab.compiler.mlspark.*
            
            DS = testCase.dateDS;
            
            DS2 = DS ...
                .withColumn("Timestamp", functions.to_timestamp(DS.col("yyyyMMdd_HHmmss")));
            DS3 = DS2 ...
                .withColumn("T1", functions.date_format(DS2.col("Timestamp"), "yyyy-MM-dd:HHmmss")) ...
                .withColumn("T2", functions.date_format(DS2.col("Timestamp"), "MM/dd/yyyy?HH-mm-ss")) ...
                .withColumn("T3", functions.date_format(DS2.col("Timestamp"), "dd-MM-yyyy @ HH.mm.ss")) ...
                .withColumn("T4", functions.date_format(DS2.col("Timestamp"), "y-M-d:Hms")) ...
                .withColumn("T5", functions.date_format(DS2.col("Timestamp"), "yy-MMM-dd HH:mm:ss")) ...
                ;
            T = table(DS3);
            testCase.verifyClass(T.Timestamp, 'datetime');
            testCase.verifyClass(T.T1, 'string');
            testCase.verifyClass(T.T2, 'string');
            testCase.verifyClass(T.T3, 'string');
            testCase.verifyClass(T.T4, 'string');
            testCase.verifyClass(T.T5, 'string');
        end
        
        
        function testUnixTime(testCase)
            % Test unix_timestamp and from_unixtime
            import matlab.compiler.mlspark.*
            
            DS = testCase.dateDS;
            
            DS2 = DS ...
                .withColumn("Timestamp", functions.to_timestamp(DS.col("yyyyMMdd_HHmmss")));
            
            DS3 = DS2 ...
                .withColumn("UT1", functions.unix_timestamp()) ...
                .withColumn("UT2", functions.unix_timestamp(DS2.col("Timestamp"))) ...
                .withColumn("UT3", functions.unix_timestamp(DS2.col("yyyyMMdd_HHmmss"), "yyyy-MM-dd HH:mm:ss")) ...
                ;

            DS4 = DS3 ...
                .withColumn("T1", functions.from_unixtime(DS3.col("UT2"), "yyyy-MM-dd:HHmmss")) ...
                .withColumn("T2", functions.from_unixtime(DS3.col("UT3"))) ...
                ;
            T = table(DS4);

            testCase.verifyClass(T.UT1 ,'int64');
            testCase.verifyClass(T.UT2 ,'int64');
            testCase.verifyClass(T.UT3 ,'int64');
            
            testCase.verifyClass(T.T1, 'string')
            testCase.verifyClass(T.T2, 'string')

        end
        
        function testUtcFunctions(testCase)
            % Testing to_utc_timestamp and from_utc_timestamp
            
            import matlab.compiler.mlspark.*
            
            DS = testCase.dateDS;
            DS2 = DS ...
                .withColumn("Timestamp", functions.to_timestamp(DS.col("yyyyMMdd_HHmmss")));

            tCol = DS2.col("yyyyMMdd_HHmmss");
            DS3 = DS2 ...
                .withColumn("GMT", functions.from_utc_timestamp(tCol, "GMT")) ...
                .withColumn("EST", functions.from_utc_timestamp(tCol, "EST")) ...
                .withColumn("Mixed", functions.from_utc_timestamp(tCol, DS2.col("TimeZone"))) ...
                ;

            tCol = DS3.col("yyyyMMdd_HHmmss");
            DS4 = DS3 ...
                .withColumn("UTC1", functions.to_utc_timestamp(tCol, "GMT")) ...
                .withColumn("UTC2", functions.to_utc_timestamp(tCol, "EST")) ...
                .withColumn("UTC3", functions.to_utc_timestamp(tCol, DS2.col("TimeZone"))) ...
                .select("yyyyMMdd_HHmmss", "GMT", "EST", "Mixed", "UTC1", "UTC2", "UTC3") ...
                ;

            T = table(DS4);
            testCase.verifyClass(T.GMT, 'datetime');
            testCase.verifyClass(T.EST, 'datetime');
            testCase.verifyClass(T.Mixed, 'datetime');
            testCase.verifyEqual(T.Mixed(1), T.GMT(1));
            testCase.verifyEqual(T.Mixed(2), T.EST(2));
            testCase.verifyNotEqual(T.Mixed(1), T.EST(1));
            testCase.verifyNotEqual(T.Mixed(2), T.GMT(2));

            testCase.verifyClass(T.UTC1, 'datetime');
            testCase.verifyClass(T.UTC2, 'datetime');
            testCase.verifyClass(T.UTC3, 'datetime');
            testCase.verifyEqual(T.UTC1(1), T.UTC3(1));
            testCase.verifyEqual(T.UTC2(2), T.UTC3(2));
            testCase.verifyNotEqual(T.UTC1(2), T.UTC3(2));
            testCase.verifyNotEqual(T.UTC2(1), T.UTC3(1));
        end
        
        function testLit(testCase)
            import matlab.compiler.mlspark.*
            
            % Add a column with a number
            dsN = testCase.dsNames.withColumn("litNumTest", ...
                                                functions.lit(1));
            % Add a column with a string
            dsN2 = dsN.withColumn("litStringTest", ...
                functions.lit("Hello"));
            
            colCount = dsN2.columns.size(1);
            t1 = table(dsN2);
            
            testCase.verifyEqual(colCount, 7);
            testCase.verifyTrue(strcmp("Hello", t1.litStringTest(4)));            
        end
        
        function testColumn(testCase)
            import matlab.compiler.mlspark.*
            
            % Add a column 
            
            dsN = testCase.dsNames.withColumn("testCol", functions.column("Age"));
            colCount = dsN.columns.size(1);
            
            testCase.verifyEqual(colCount, 6);
            testCase.verifyError(@()dsN.withColumn(...
                        functions.column(6)), 'SPARK:ERROR');            
        end
        
        function testWhen(testCase)
            import matlab.compiler.mlspark.*
            
            % Add a column based on a single column value 
            petCol = testCase.dsNames.col("Pet");
            dsN = testCase.dsNames.withColumn(...
                 "testCol", ...
                 functions.when(petCol, "Cat", "C")...
                 .when(petCol, "Giraffe", "G")...
                 .when(petCol, "Iguana", "I")...
                 .sparkOtherwise("F"));
                    
            colCount = dsN.columns.size(1);
            t1 = table(dsN);
            testColValF = t1.testCol(1);
            testColValC = t1.testCol(2);
            testColValI = t1.testCol(3);
            testColValG = t1.testCol(5);
            
            
            testCase.verifyEqual(colCount, 6);
            testCase.verifyTrue(strcmp("F", testColValF));
            testCase.verifyTrue(strcmp("C", testColValC));
            testCase.verifyTrue(strcmp("I", testColValI));
            testCase.verifyTrue(strcmp("G", testColValG));
            
            % Test multiple columns
            
        end
    end
end

function testTimeHelper(testCase, newColName, limitLow, limitHigh, sqlFunc)
    import matlab.compiler.mlspark.*
    
    outages = testCase.ds;
    dsh = outages ...
        .withColumn(newColName, sqlFunc(outages.col('OutageTime')));
    
    origColumns = outages.columns;
    newColumns = dsh.columns;
    
    diffCols = setdiff(newColumns, origColumns);
    testCase.verifyEqual(length(newColumns), length(origColumns)+1);
    testCase.verifyEqual(diffCols, newColName);
    
    dsOH = dsh.select(newColName);
    TOH = table(dsOH);
    OH = TOH.(newColName);
    
    testCase.verifyGreaterThanOrEqual(max(OH),limitLow)
    testCase.verifyLessThanOrEqual(max(OH),limitHigh);
end
