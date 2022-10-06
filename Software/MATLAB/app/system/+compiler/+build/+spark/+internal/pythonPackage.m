function buildResults = pythonPackage(opts)
    % compiler.build.spark.internal.pythonPackage Spark builder for Python
    %
    % This is an internal helper function that supports building of Python
    % Spark packages for older releases.
    
    % Copyright 2022 MathWorks, Inc.
    
    if opts.Verbose
        verboseFlag = {'-v'};
    else
        verboseFlag = {};
    end
    additionalFiles = getAdditionalFilesArgs(opts.AdditionalFiles);
    mccArgs = [...
        '-W', sprintf('python:%s', opts.PackageName), ...
        '-T', 'link:lib', ...
        '-d', opts.OutputDir, ...
        verboseFlag, ...
        additionalFiles, ...
        ... '-Z', opts.SupportPackages, ...Ignoring unsuported option
        opts.FunctionFiles, ...
        ];
    
    mcc(mccArgs{:})
  
    buildResults = struct(...
        'BuildType', 'pythonPackge', ...
        'Files', {opts.FunctionFiles}, ...
        'IncludedSupportPackage', {{}}, ...
        'Options', opts ...
        );
    
end

function cellAppends = getAdditionalFilesArgs(additionalFiles)
   N = length(additionalFiles);
   cellAppends = cell(1,N*2);
   idx = 1;
   for k=1:N
       cellAppends{idx} = '-a';
       cellAppends{idx+1} = additionalFiles{k};
       idx = idx + 2;
   end
end
