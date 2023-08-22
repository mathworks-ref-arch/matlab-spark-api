function genPythonSetup(obj)
    % genPythonSetup Create new setup.py file for install/dist/etc.

    % Copyright 2022 The MathWorks, Inc.

    outFolder = obj.BuildResults.Options.OutputDir;
    setupFile = fullfile(outFolder, 'setup.py');
    if isfile(setupFile)
        % Delete old version of file, don't care about backup
        delete(setupFile);
    end
    SW = matlab.sparkutils.StringWriter(setupFile);

    pkgName = string(obj.BuildResults.Options.PackageName);

    yearStr = datestr(now, 'YYYY');
    SW.pf("# Copyright 2015-%s The MathWorks, Inc.\n\n", yearStr);
    SW.pf("from setuptools import setup\n\n");
    SW.pf("if __name__ == '__main__':\n\n");
    SW.indent();
    SW.pf("setup(\n");
    SW.indent();
    SW.pf("name='%s',\n", pkgName);
    SW.pf("version='%s',\n", getRelease());
    SW.pf("description='A Python interface to %s',\n", obj.BuildResults.Options.PackageName);
    SW.pf("author='MathWorks',\n");
    SW.pf("url='https://www.mathworks.com/',\n");
    SW.pf("platforms=['Linux', 'Windows', 'MacOS'],\n");
    SW.pf("packages=[\n");
    pkgParts = split(pkgName, ".");
    numPkgParts = length(pkgParts);
    SW.indent();
    for k=1:numPkgParts
        if k==numPkgParts
            delim = '';
        else
            delim = ',';
        end
        SW.pf("'%s'%s\n", join(pkgParts(1:k), "."), delim);
    end
    SW.unindent();
    SW.pf("],\n");
    SW.pf("package_data={'%s': ['*.ctf']}\n", pkgName);
    SW.unindent();

    SW.pf(")\n\n");

    SW.unindent();
    SW.pf("# End of file\n");

end

function R = getRelease()
    v = version;
    T = regexp(v, '(\d+\.\d+\.\d+)', 'tokens', 'once');
    R = T{1};
end