function generateWrapper(obj)
    % generateWrapper Wrapper for easier handling of Python library

    % Copyright 2022 The MathWorks, Inc.

    wrapperName = "wrapper.py";
    wrapperFile = fullfile(obj.SrcDir, wrapperName);
    obj.WrapperClassName = "Wrapper";
    wrapperInstance = "instance";
    wrapperInstanceFullName = obj.WrapperClassName + "." + wrapperInstance;

    SW = matlab.sparkutils.StringWriter(wrapperFile);

    SW.pf("# Wrapper file for %s package\n\n", obj.PkgName);

    SW.pf("import %s\n", obj.PkgName);
    SW.pf("import numpy as np\n\n");


    SW.pf("class %s:\n", obj.WrapperClassName);
    SW.indent();
    SW.pf("# Static variables\n")
    SW.pf("# Class instance\n");
    SW.pf("%s = None\n", wrapperInstance);
    SW.pf("# MATLAB Runtime\n");
    SW.pf("RT = None\n\n");

    SW.pf("def __init__(self):\n");
    SW.indent();
    SW.pf("super().__init__()\n");
    SW.pf("self.something = 'hello' # Remove this later\n");
    SW.pf("self.__setMATLABRuntime()\n\n");
    SW.unindent();

    SW.pf("@staticmethod\n");
    SW.pf("def getInstance():\n");
    SW.indent();
    SW.pf("if %s is None:\n", wrapperInstanceFullName);
    SW.indent();
    SW.pf("%s = %s()\n", wrapperInstanceFullName, obj.WrapperClassName);
    SW.unindent();
    SW.pf("return %s\n\n", wrapperInstanceFullName);
    SW.unindent();

    for k=1:length(obj.Files)
        obj.generateFunctionWrapper(SW, obj.Files(k));
    end

    %     SW.pf("# Functions from parent package\n");
    %     SW.pf("def plusOne_class(self, value):\n");
    %     SW.indent();
    %     SW.pf("return self.RT.plusOne(value)\n\n");
    %     SW.unindent();
    %
    %     SW.pf("@staticmethod\n");
    %     SW.pf("def plusOne(value):\n");
    %     SW.indent();
    %     SW.pf("instance = %s.getInstance()\n", obj.WrapperClassName);
    %     SW.pf("return instance.plusOne_class(value)\n\n");
    %     SW.unindent();


    SW.pf("# Methods for pickling:\n");
    SW.pf("def __getstate__(self):\n");
    SW.indent();
    SW.pf("state = self.__dict__.copy()\n");
    SW.pf("del state['RT']\n");
    SW.pf("del state['instance']\n");
    SW.pf("return state\n\n");
    SW.unindent();

    SW.pf("def __setstate__(self, state):\n");
    SW.indent();
    SW.pf("self.__dict__.update(state)\n");
    SW.pf("self.__setMATLABRuntime()\n\n");
    SW.unindent();

    SW.pf("def __setMATLABRuntime(self):\n");
    SW.indent();
    SW.pf("if %s.RT is None:\n", obj.WrapperClassName);
    SW.indent();
    SW.pf("print('### Initializing MATLAB Runtime')\n");
    SW.pf("%s.RT = %s.initialize()\n", obj.WrapperClassName, obj.PkgName);
    SW.unindent();
    SW.pf("else:\n");
    SW.indent();
    SW.pf("print('### MATLAB Runtime alread initialized')\n");
    SW.unindent();
    SW.pf("self.RT = %s.RT\n\n", obj.WrapperClassName);

    SW.unindent();
    SW.unindent();
    SW.pf("# End of file\n")


end

