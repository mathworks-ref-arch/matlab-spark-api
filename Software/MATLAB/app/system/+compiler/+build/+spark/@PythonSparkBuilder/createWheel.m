function createWheel(obj)
    % createWheel Create a wheel for the Python package

    % Copyright 2022-2023 The MathWorks, Inc.

    % TODO revise to better use pyrun/pyrunfile when legacy version support permits

    old = cd(obj.OutputDir);
    goBack = onCleanup(@() cd(old));

    pyPath = getPython3Path();
    if strlength(pyPath) ~= 0
        if checkPyVersion(pyPath)
            if checkPipInstalled(pyPath)
                if checkSetupToolsInstalled(pyPath)
                    if checkWheelInstalled(pyPath)
                        command = [char(pyPath), ' setup.py bdist_wheel'];
                        [status, cmdout] = system(command);
                        if status == 0
                            wheel = obj.getWheelFile();
                            fprintf("Created .whl file: %s\n", wheel);
                        else
                            error('SPARK_API:createWheel','Error building .whl file: %s', cmdout);
                        end
                    else
                        error('SPARK_API:createWheel','Error building .whl file');
                    end
                else
                    if checkDistutilsInstalled(pyPath)
                        error('SPARK_API:createWheel','Error building .whl file');
                    else
                        warning('SPARK_API:createWheel', "The distutils Python package is not installed and is required on some systems");
                        error('SPARK_API:createWheel','Error building .whl file');
                    end
                end
            else
                error('SPARK_API:createWheel','Error building .whl file');
            end
        else
            error('SPARK_API:createWheel','Error building .whl file');
        end
    else
        error('SPARK_API:createWheel','Error building .whl file');
    end
end


function pyPath = getPython3Path()
    % Returns the path to a Python 3 interpreter
    % If not found or otherwise invalid and empty character vector is returned

    pyPath = '';
    pe = pyenv();

    if strlength(pe.Version) == 0
        warning('SPARK_API:getPython3Path', "Python environment not found by pyenv, Python may not be installed");
    else
        if startsWith(pe.Version, '3')
            if isfile(pe.Executable)
                pyPath = char(pe.Executable);
                % pyPath may have spaces or stray ", remove 1 level if present and add " on both sides
                pyPath = ['"', strip(pyPath, 'both', '"'), '"'];
            else
                warning('SPARK_API:getPython3Path', "Python executable not found: %s", pe.Executable);
            end
        else
            warning('SPARK_API:getPython3Path', "Only Python 3 is supported, found: %s", pe.Version);
        end
    end
end


function tf = checkWheelInstalled(pyPath)
    % Returns true if wheel is installed otherwise false
    tf = false;
    command = [char(pyPath), ' -m pip show wheel'];
    [status, cmdout] = system(command);
    if status ~= 0
        warning('SPARK_API:checkWheelInstalled', "System command: %s failed, returned: %d, %s", command, status, cmdout);
        warning('SPARK_API:checkWheelInstalled', "The wheel Python package is not installed, to install: %s pip install wheel", pyPath);
    else
        cmdout = strip(cmdout);
        if startsWith(cmdout, 'Name: wheel')
            tf = true;
        else
            warning('SPARK_API:checkWheelInstalled', "The wheel Python package is not installed, to install: %s pip install wheel", pyPath);
        end
    end
end


function tf = checkSetupToolsInstalled(pyPath)
    % Returns true if setupTools is installed otherwise false
    tf = false;

    command = [char(pyPath), ' -m pip show setuptools'];
    [status, cmdout] = system(command);

    if status ~= 0
        warning('SPARK_API:checkSetupToolsInstalled', "System command: %s failed, returned: %d, %s", command, status, cmdout);
    else
        cmdout = strip(cmdout);
        if startsWith(cmdout, 'Name: setuptools')
            tf = true;
        else
            warning('SPARK_API:checkSetupToolsInstalled', "The setuptools Python package is not installed, to install: %s pip install setuptools", pyPath);
        end
    end
end


function tf = checkDistutilsInstalled(pyPath)
    % Returns true if pip is installed otherwise false
    tf = false;

    % TODO determine a cleaner cross platform way to check
    command = [char(pyPath), ' -m distutils --version'];
    [~, cmdout] = system(command);

    cmdout = strip(cmdout);
    if endsWith(cmdout, "'distutils' is a package and cannot be directly executed")
        % Result e.g.: /usr/bin/python: No module named distutils.__main__; 'distutils' is a package and cannot be directly executed
        tf = true;
    else
        % Result e.g.: /usr/bin/python: No module named distutils123
        warning('SPARK_API:checkDistutilsInstalled', "The distutils Python package is not installed");
    end
end


function tf = checkPipInstalled(pyPath)
    % Returns true if pip is installed otherwise false
    tf = false;

    command = [char(pyPath), ' -m pip --version'];
    [status, cmdout] = system(command);

    if status ~= 0
        warning('SPARK_API:checkPipInstalled', "System command: %s failed, returned: %d, %s", command, status, cmdout);
    else
        cmdout = strip(cmdout);
        if startsWith(cmdout, 'pip')
            % Result e.g.: pip 20.0.2 from /usr/lib/python3/dist-packages/pip (python 3.8)
            tf = true;
        else
            % Result e.g.: /usr/bin/python: No module named pip123
            warning('SPARK_API:checkPipInstalled', "The Python pip package manager is not installed, to install pip: %s install pip", pyPath);
        end
    end
end


function tf = checkPyVersion(pyPath)
    % Check the version returned by a system call to Python is greater than a minimum
    tf = false;

    command = [char(pyPath), ' --version'];
    [status, cmdout] = system(command);
    if status ~= 0
        warning('SPARK_API:checkPyVersion', "System command: %s failed, returned: %d, %s", command, status, cmdout);
    else
        % Expecting cmdout to be of the form: Python 3.8.10
        cmdout = strip(cmdout);
        fields = split(cmdout, ' ');
        if numel(fields) ~= 2
            warning('SPARK_API:checkPyVersion', "Expected only 2 fields of the form 'Python' & '3.8.10'");
        else
            if ~startsWith(fields{2}, '3')
                warning("SPARK_API:checkPyVersion", "Only Python 3 is supported, found: %s", fields{2});
            else
                tf = true;
            end
        end
    end
end
