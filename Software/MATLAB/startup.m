function startup(varargin)
    %% STARTUP - Script to add my paths to MATLAB path
    % This script will add the paths below the root directory into the MATLAB
    % path. It will omit the SVN and other crud.  You may modify undesired path
    % filter to your desire.
    
    % Copyright 2021 MathWorks, Inc.
    
    appStr = 'Adding Spark API Paths';
    disp(appStr);
    disp(repmat('-',1,numel(appStr)));
    
    %% Set up the paths to add to the MATLAB path
    % This should be the only section of the code that you need to modify
    % The second argument specifies whether the given directory should be
    % scanned recursively
    here = fileparts(mfilename('fullpath'));
    
    % Add the appropriate architecture binaries
    archDir = iGetArchSuffix(); %#ok<NASGU>
    
    rootDirs={...
        fullfile(here,'app', 'system'),false;...
        fullfile(here,'app', 'functions'),false;...
        fullfile(here,'app', 'mex'),false;...
        fullfile(here,'lib'),false;...
        fullfile(here,'config'),false;...
        fullfile(here,'script'),false;...
        ...fullfile(here,'sys','modules'),true;...
        fullfile(here,'public', 'templates'),false;...
        };
    
    %% Add the framework to the path
    iAddFilteredFolders(rootDirs);
    
    %% Handle the modules for the project.
    disp('Initializing all modules');
    modRoot = fullfile(here,'sys','modules');
    
    % Get a list of all modules
    mList = dir(fullfile(modRoot,'*.'));
    for mCount = 1:numel(mList)
        % Only add proper folders
        dName = mList(mCount).name;
        if ~strcmpi(dName(1),'.')
            % Valid Module name
            candidateStartup = fullfile(modRoot,dName,'startup.m');
            if exist(candidateStartup,'file')
                % We have a module with a startup
                run(candidateStartup);
            else
                % Create a cell and add it recursively to the path
                iAddFilteredFolders({fullfile(modRoot,dName), true});
            end
        end
        
    end

    %% Post path-setup operations
    % Add your post-setup operations here.
    disp('Running post setup operations');
    
end

%% iAddFilteredFolders Helper function to add all folders to the path
function iAddFilteredFolders(rootDirs)
    % Loop through the paths and add the necessary subfolders to the MATLAB path
    for pCount = 1:size(rootDirs,1)
        
        rootDir=rootDirs{pCount,1};
        if rootDirs{pCount,2}
            % recursively add all paths
            rawPath=genpath(rootDir);
            
            if ~isempty(rawPath)
                rawPathCell=textscan(rawPath,'%s','delimiter',pathsep);
                rawPathCell=rawPathCell{1};
            else
                rawPathCell = {rootDir};
            end
            
        else
            % Add only that particular directory
            rawPath = rootDir;
            rawPathCell = {rawPath};
        end
        
        % remove undesired paths
        svnFilteredPath=strfind(rawPathCell,'.svn');
        gitFilteredPath=strfind(rawPathCell,'.git');
        slprjFilteredPath=strfind(rawPathCell,'slprj');
        sfprjFilteredPath=strfind(rawPathCell,'sfprj');
        rtwFilteredPath=strfind(rawPathCell,'_ert_rtw');
        
        % loop through path and remove all the .svn entries
        if ~isempty(svnFilteredPath)
            for pCount=1:length(svnFilteredPath), %#ok<FXSET>
                filterCheck=[svnFilteredPath{pCount},...
                    gitFilteredPath{pCount},...
                    slprjFilteredPath{pCount},...
                    sfprjFilteredPath{pCount},...
                    rtwFilteredPath{pCount}];
                if isempty(filterCheck)
                    iSafeAddToPath(rawPathCell{pCount});
                else
                    % ignore
                end
            end
        else
            iSafeAddToPath(rawPathCell{pCount});
        end
        
    end
    
    %% Post path-setup operations
    
    % Example: Change to a particular directory
    % cd( fullfile( here, 'examples' ) );
    
    % Example: Setup Simulink code generation folders
    %myCacheFolder = fullfile('C:','cachefolder');
    %myCodeGenFolder = pwd;
    %Simulink.fileGenControl('set', 'CacheFolder', myCacheFolder, ...
    %   'CodeGenFolder', myCodeGenFolder);
    
    % Example: Setup Java dynamic path
    %iSafeAddToJavaPath(fullfile(spellroot,'lib','java','MATLABSpellCheck','dist','MATLABSpellCheck.jar'));
    
end

%% Helper function to add to MATLAB path.
function iSafeAddToPath(pathStr)
    
    % Add to path if the file exists
    if exist(pathStr,'dir')
        disp(['Adding ',pathStr]);
        addpath(pathStr); %#ok<MCAP>
    else
        disp(['Skipping ',pathStr]);
    end
    
end

%% Helper function to add to the Dynamic Java classpath
function iSafeAddToJavaPath(pathStr)
    
    % Check the current java path
    jPaths = string(javaclasspath('-dynamic'));
    pathStr = string(pathStr);    

    % Add to path if the file exists
    if exist(pathStr,'dir') || exist(pathStr,'file')
        if ~any(jPaths == pathStr)
            fprintf('Adding %s\n',pathStr);
            javaaddpath(pathStr);
        else
            fprintf('Skipping %s, already on path, \n', pathStr);
        end
    else
        warning('SparkAPI:Warning', 'Jar not found: %s. This may affect the functionality of this package.\n', pathStr);
    end    
    
end

%% Helper function to add arch specific suffix
function binDirName = iGetArchSuffix()
    
    switch computer
        case 'PCWIN'
            binDirName = 'win32';
        case 'PCWIN64'
            binDirName = 'win64';
        case 'GLNX86'
            binDirName = 'glnx86';
        case 'GLNXA64'
            binDirName = 'glnxa64';
        case 'MACI64'
            binDirName = 'maci64';
        otherwise
            error('FW:Unsupported','The framework is not supported on this platform');
    end
end
