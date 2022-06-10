function generateWrapperFile(obj)
    % generateWrapperFile Generate the wrapper file for the class
    %
    % The generated wrapper class will contain different methods that makes
    % it easier to call compiled MATLAB functions in a Spark context.

    % Copyright 2021 The MathWorks, Inc.

    old = cd(obj.outputFolder);
    goBack = onCleanup(@() cd(old));
    obj.buildFiles = string.empty;

    numClasses = length(obj.javaClasses);
    if numClasses > 0
        for k=1:numClasses
            JC = obj.javaClasses(k);
            baseClassName = JC.name;
            wrapperName = JC.WrapperName;
            JW = matlab.sparkutils.JavaWriter(obj.package, wrapperName);
            JW.addImport("java.io.Serializable");
            JW.addImport("com.mathworks.toolbox.javabuilder.MWException");
            JW.addImport("com.mathworks.toolbox.javabuilder.MWNumericArray");
            JW.addImport("com.mathworks.toolbox.javabuilder.MWLogicalArray");
            JW.addImport("com.mathworks.toolbox.javabuilder.MWCellArray");
            JW.addImport("com.mathworks.toolbox.javabuilder.MWCharArray");
            JW.addImport("com.mathworks.toolbox.javabuilder.MWApplication");
            JW.addImport("com.mathworks.toolbox.javabuilder.MWMCROption");

            if compiler.build.spark.internal.hasMWStringArray
                JW.addImport("com.mathworks.toolbox.javabuilder.MWStringArray");
            end
            JW.addImport("com.mathworks.toolbox.javabuilder.MWClassID");
            JW.addImport("java.util.concurrent.atomic.AtomicInteger");

            JW.addVariable("private static final AtomicInteger nextId = new AtomicInteger(0)");
            % JW.addVariable("private static %s instance = null", wrapperName);
            JW.addVariable("private %s baseClass = null", baseClassName);

            % Create row utility
            JW.addImport("java.util.List");
            JW.addImport("java.util.ArrayList");
            JW.addImport("org.apache.spark.sql.catalyst.expressions.GenericRowWithSchema");
            JW.addImport("org.apache.spark.sql.Row");
            JW.addImport("org.apache.spark.sql.SparkSession");

            JW.addImport("com.mathworks.scala.SparkUtilityHelper");

            addRuntimePool(JW, wrapperName, baseClassName, obj.Debug, obj.Metrics);

            addRowUtility(JW, "Row");
            % addRowUtility(JW, "GenericRowWithSchema");
            % if obj.Debug || obj.Metrics
            generateMetricUtils(JW);
            % end

            %             M = JW.newMethod();
            %             M.pf("/** %s\n", wrapperName);
            %             M.pf(" * A private constructor of this class.\n" + ...
            %                 " * Will create a reference to the base class,\n" + ...
            %                 " * containing the compiled methods\n");
            %             M.pf(" */\n");
            %             M.pf("private %s() throws MWException {\n", wrapperName);
            %             M.pf("    baseClass = new %s(); \n", baseClassName);
            %             M.pf("}\n");
            %             JW.addMethod(M);

            %             M = JW.newMethod();
            %             M.pf("public static %s getInstance() throws MWException {\n", wrapperName);
            %             M.pf("    if (instance == null) {\n");
            %             M.pf("        instance = new %s();\n", wrapperName);
            %             M.pf("    }\n");
            %             M.pf("    return instance;\n");
            %             M.pf("}\n");
            %             JW.addMethod(M);

            generateWrapperConstructor(JW, JC);

            %             M = JW.newMethod();
            %             M.pf("public static %s getBaseClass() throws MWException {\n", baseClassName);
            %             M.pf("    return getInstance().baseClass;\n");
            %             M.pf("}\n");
            %             JW.addMethod(M);

            genSparkWrappers(JC, JW);

            obj.buildFiles(end+1) = JW.FileName;

            % Explicitly delete JavaWriter, to avoid race condition
            % with delete of goBack.
            clear('JW');
        end
    end


end

function generateWrapperConstructor(JW, JC)
    baseClassName = JC.name;
    wrapperName = JC.WrapperName;

    JW.addImport("com.mathworks.toolbox.javabuilder.MWComponentOptions");
    JW.addImport("com.mathworks.toolbox.javabuilder.MWCtfExtractLocation");
    JW.addImport("com.mathworks.toolbox.javabuilder.MWCtfClassLoaderSource");

%     SW = JW.newMethod();
%     SW.pf("private static final ThreadLocal<%s> tlWrapper = new ThreadLocal<%s>() {\n", ...
%         wrapperName, wrapperName);
%     SW.indent();
%     SW.pf("@Override\n");
%     SW.pf("protected %s initialValue() {\n", wrapperName);
%     SW.indent();
%     SW.pf("try {\n");
%     SW.indent();
%     SW.pf("int id = nextId.getAndIncrement();\n");
%     SW.pf("System.out.println(""initialValue(): Have threadID == "" + id);\n");
%     SW.pf("String home = System.getProperty(""user.home"");\n");
%     SW.pf("String ctfRoot = home + ""/ctfroot_"" + id;\n");
%     SW.pf("%s theWrapper = new %s(id, ctfRoot);\n", wrapperName, wrapperName);
%     SW.pf("return theWrapper;\n");
%     SW.unindent();
%     SW.pf("} catch (MWException mwex) {\n");
%     SW.indent();
%     SW.pf("System.out.println(mwex.getMessage());\n");
%     SW.pf("mwex.printStackTrace();\n");
%     SW.unindent();
%     SW.pf("}\n");
%     SW.pf("return null;\n");
%     SW.unindent();
%     SW.pf("}\n");
%     SW.unindent();
%     SW.pf("};\n");
%     JW.addMethod(SW);

%     SW = JW.newMethod();
%     SW.pf("private %s(int id, String ctfRoot ) throws MWException {\n", wrapperName);
%     SW.indent();
%     SW.pf("wrapperId = id;\n");
%     SW.pf("threadStr = "" Thread["" + wrapperId + ""] %s "";\n", JW.ClassName);
% 
%     SW.pf("sdf = new SimpleDateFormat(""yyyy-MM-dd HH:mm:ss,SSS"");\n");
%     SW.pf("System.out.println(""Creating new MATLABWrapper - "" + wrapperId);\n");
%     SW.pf("MWCtfExtractLocation mwctfExt = new MWCtfExtractLocation(ctfRoot);\n");
%     SW.pf("MWComponentOptions mwCompOpts = new MWComponentOptions(mwctfExt, new MWCtfClassLoaderSource(%s.class));\n", JW.getMCRFactoryName);
%     SW.pf("baseClass = new %s(mwCompOpts);\n", baseClassName);
%     SW.pf("int baseHash = baseClass.hashCode();\n");
%     SW.pf("String hashHex = Integer.toHexString(baseHash);\n");
%     SW.pf("System.out.println(""Created baseclass in wrapper "" + wrapperId + "". baseClass hash == "" + hashHex);\n");
%     SW.unindent();
%     SW.pf("}\n");
%     JW.addMethod(SW);

    SW = JW.newMethod();
    SW.pf("public static synchronized RuntimeQueue getRuntimeQueue(){\n");
    SW.indent();
    SW.pf("if (queue == null) {\n");
    SW.indent();
    SW.pf("queue = new RuntimeQueue();\n");
    SW.unindent();
    SW.pf("}\n");
    SW.pf("return queue;\n");
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);


    SW = JW.newMethod();
    SW.pf("public static %s getInstance() throws MWException {\n", baseClassName);
    SW.indent();
    SW.pf("return getRuntimeQueue().getInstance();\n");
    SW.unindent();
    SW.pf("}\n");

    SW.pf("public static void releaseInstance(%s inst) {\n", baseClassName);
    SW.indent();
    SW.pf("getRuntimeQueue().releaseInstance(inst);\n");
    SW.unindent();
    SW.pf("}\n");

    JW.addMethod(SW);

%     SW = JW.newMethod();
%     SW.pf("public static %s getBaseClass() throws MWException {\n", baseClassName);
%     SW.indent();
%     %SW.pf("// System.out.println(""getBaseClass(): Have threadID == "" + getThreadID());\n");
%     SW.pf("%s bc = getInstance().baseClass;\n", baseClassName);
%     SW.pf("int baseHash = bc.hashCode();\n");
%     SW.pf("String hashHex = Integer.toHexString(baseHash);\n");
%     SW.pf("System.out.println(""#### Retrieving baseClass "" + hashHex);\n");
%     SW.pf("return bc;\n");
%     SW.unindent();
%     SW.pf("}\n");
% 
%     JW.addMethod(SW);

end

function generateMetricUtils(JW)

    JW.addImport("java.text.SimpleDateFormat");
    JW.addImport("java.util.Date");

    % JW.addVariable("private int wrapperId");
    % JW.addVariable("private String threadStr");

    % JW.addVariable("private long lastTic;");
    JW.addVariable('private static SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss,SSS")');

    SW = JW.newMethod();

    SW.pf("public static void log(String msg) {\n");
    SW.indent();
    SW.pf("long now = System.currentTimeMillis();\n");
    SW.pf("String nowDateStr = sdf.format(new Date(now));\n");
    SW.pf("String hostInfo;\n")
    SW.pf("try {\n");
    SW.indent();
    SW.pf("hostInfo = java.net.InetAddress.getLocalHost().toString();\n")
    SW.unindent();
    SW.pf("} catch (java.net.UnknownHostException uhex) {\n");
    SW.indent();
    SW.pf('hostInfo = "UNKNOWN_HOST_ISSUE";\n');
    SW.unindent();
    SW.pf('}\n');
    SW.pf('System.out.println(nowDateStr + " " + hostInfo + " " + msg);\n');
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);

    SW = JW.newMethod();
    SW.pf("public static long tic(String msg) {\n");
    SW.indent();
    SW.pf('log("Starting " + msg);\n');
    SW.pf("long lastTic = System.currentTimeMillis();\n");
    SW.pf("return lastTic;\n");
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);

    SW = JW.newMethod();
    SW.pf("public static void toc(String msg, long lastTic) {\n");
    SW.indent();
    SW.pf("long now = System.currentTimeMillis();\n");
    SW.pf("long elapsedL = now-lastTic;\n");
    SW.pf("double elapsed = (double)elapsedL / 1000.0;\n");
    SW.pf('log("Finished " + msg + " " + elapsed + " sec");\n');
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);

end

function addRowUtility(JW, typeName)
    SW = JW.newMethod();
    SW.pf("public static List<Object> rowToJavaList(%s row)  {\n", typeName);
    SW.indent();
    SW.pf("int N = row.size();\n");
    SW.pf("ArrayList<Object> list = new ArrayList<Object>(N);\n");
    SW.pf("for (int k=0; k<N; k++) {\n");
    SW.pf("list.add(row.get(k));\n");
    SW.pf("}\n");
    SW.pf("return list;\n");
    SW.unindent();
    SW.pf("}\n");
    JW.addMethod(SW);

end

function addRuntimePool(JW, wrapperName, baseClassName, debugOn, metricsOn)
    JW.addVariable('private static transient RuntimeQueue queue = null');
    JW.addImport('java.util.concurrent.ArrayBlockingQueue');
    % JW.addImport("java.util.LinkedList");
    SW = JW.newMethod();
    SW.pf('class RuntimeQueue {\n');
    SW.indent();
    SW.pf('int poolSize = 0;\n');
    SW.pf('ArrayBlockingQueue<%s> pool = null;\n', baseClassName);
    SW.pf('public RuntimeQueue() {\n');
    SW.indent();
    SW.pf('// The next call changes a setting that will make the Runtime be created out of\n');
    SW.pf('// process. It must be the\n');
    SW.pf('// first call to the runtime, before any application is initialized.\n');
    SW.pf('if (!MWApplication.isMCRInitialized()) {\n')
    SW.indent();
    SW.pf('MWApplication.initialize(MWMCROption.OUTPROC);\n');
    SW.unindent();
    SW.pf('}\n');
    SW.pf('poolSize = Runtime.getRuntime().availableProcessors();\n');
    if debugOn
        SW.pf('%s.log("poolSize is set to " + poolSize);\n', wrapperName);
    end
    if metricsOn
        SW.pf("long lastTic;\n");
    end
    SW.pf('pool = new ArrayBlockingQueue<%s>(poolSize);\n', baseClassName);
    SW.pf('for (int id = 0; id < poolSize; id++) {\n');
    SW.indent();
    SW.pf('try {\n');
    SW.indent();
    if metricsOn
    SW.pf('lastTic = %s.tic("Initializing MATLAB Runtime # " + id);\n', wrapperName);
    end
    SW.pf('String uuid = java.util.UUID.randomUUID().toString();\n');
    SW.pf('String ctfRoot = "/tmp/ctfroot_" + uuid;\n');
    SW.pf("MWCtfExtractLocation mwctfExt = new MWCtfExtractLocation(ctfRoot);\n");
    SW.pf("MWComponentOptions mwCompOpts = new MWComponentOptions(mwctfExt, new MWCtfClassLoaderSource(%s.class));\n", JW.getMCRFactoryName);
    SW.pf("%s elem = new %s(mwCompOpts);\n", baseClassName, baseClassName);
    if metricsOn
        SW.pf('%s.toc("Initializing MATLAB Runtime # " + id, lastTic);\n', wrapperName)
    end
    %     SW.pf('%s elem = new %s();\n', baseClassName, baseClassName);
    SW.pf('pool.put(elem);\n');

    if debugOn
        SW.pf('showStatus();\n');
    end
    
    SW.unindent();
    SW.pf('} catch (MWException mwex) {\n');
    SW.indent();
    SW.pf("// Consider what to do here.\n");
    SW.pf('mwex.printStackTrace();\n');
    SW.unindent();
    SW.pf('} catch (InterruptedException iex) {\n');
    SW.indent();
    SW.pf('iex.printStackTrace();\n');
    SW.pf('System.err.println("Problem with Runtime Queue: " + iex.toString());\n');
    SW.unindent();
    SW.pf('}\n')

%     SW.pf('Test2Wrapper.log("Instantiated " + pool.size() + " runtimes.");\n');
    SW.unindent();

    SW.pf('}\n');
    SW.unindent();
    SW.pf('}\n');
    SW.pf('public %s getInstance() {\n', baseClassName);
    SW.indent();
    SW.pf("%s inst = null;\n", baseClassName)
    SW.pf('try {\n');
    SW.indent();
    SW.pf("inst = pool.take();\n")
    SW.unindent();
    SW.pf('} catch (InterruptedException iex) {\n');
    SW.indent();
    SW.pf('iex.printStackTrace();\n');
    SW.pf('System.err.println("Problem with Runtime Queue: " + iex.toString());\n');
    SW.unindent();
    SW.pf('}\n')
    if debugOn
        SW.pf('%s.log("After taking element");\n', wrapperName)
        SW.pf('showStatus();\n');
    end
    SW.pf('return inst;\n');
    SW.unindent();
    SW.pf('} /* getInstance */\n\n');
    
    SW.pf('public void releaseInstance(%s inst) {\n', baseClassName);
    SW.indent();
    SW.pf("if (inst != null) {\n")
    SW.indent();
    SW.pf('try {\n');
    SW.indent();
    SW.pf('pool.put(inst);\n');
    SW.unindent();
    SW.pf('} catch (InterruptedException iex) {\n');
    SW.indent();
    SW.pf('iex.printStackTrace();\n');
    SW.pf('System.err.println("Problem with Runtime Queue: " + iex.toString());\n');
    SW.unindent();
    SW.pf('}\n')
    
    SW.unindent();
    SW.pf('}\n')
    if debugOn
        SW.pf('%s.log("After returning element");\n', wrapperName)
        SW.pf('showStatus();\n');
    end
    SW.unindent();
    SW.pf('} /* releaseInstance */\n\n');

    SW.pf('public void showStatus() {\n');
    SW.indent();
    SW.pf(['%s.log("MATLAB-PoolSize: (size+remainingCapacity==poolSize) " + ', ...
        'pool.size() + " + " + ', ...
        'pool.remainingCapacity() + " = " + poolSize);\n'], wrapperName);
    SW.pf('%s.log("ctfserver on this node: " + getRuntimesCountOnNode());\n', wrapperName);
    SW.unindent();
    SW.pf('} /* showStatus */\n\n');
   
    SW.pf('public long getRuntimesCountOnNode() {\n');
    SW.indent();
    SW.pf('long count = -1L;\n');
    SW.pf('String[] commands = {"/bin/sh", "-c", "ps -ef | grep \\"[c]tfserver\\""};\n');
    SW.pf('try {\n');
    SW.indent();
    SW.pf('Process proc = Runtime.getRuntime().exec(commands);\n');
    SW.pf('java.io.BufferedReader br = new java.io.BufferedReader( new java.io.InputStreamReader(proc.getInputStream()));\n');
    SW.pf('count = br.lines().count();\n');
    SW.unindent();
    SW.pf('} catch (java.io.IOException ioex) {\n');
    SW.indent();
    SW.pf('ioex.printStackTrace();\n');
    SW.unindent();
    SW.pf('}\n');
    SW.pf('return count;        \n');
    SW.unindent();
    SW.pf('}\n');


    SW.unindent();
    SW.pf('} /* class RuntimeQueue */\n');
    JW.addPostClass(SW);

end
