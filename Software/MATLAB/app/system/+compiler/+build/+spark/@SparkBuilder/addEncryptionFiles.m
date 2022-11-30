function obj = addEncryptionFiles(obj, encKeyFile, encMexFile)
    % addEncryptionFiles Add encryption files (key + mex)
    %
    % This method allows specifying the files needed for custom encryption
    % of the generated artifacts, as described in the documentation of the
    % "-k" option for mcc.
    %
    % Please note that this feature is only available starting in release
    % R2022b.

    % Copyright 2022 The MathWorks, Inc.

    if verLessThan('matlab', '9.13')
        error('SPARKAPI:encryption_not_available', ...
            "This feature is only available in release R2022b and later.")
    end
    
    if ~isfile(encKeyFile)
        error('SPARKAPI:enckeyfile_must_exist', ...
            "The file %s does not seem to exist.", encKeyFile);
    end
    if ~isfile(encMexFile)
        error('SPARKAPI:encmexfile_must_exist', ...
            "The file %s does not seem to exist.", encMexFile);
    end

    obj.EncryptionKeyFile = encKeyFile;
    obj.EncryptionMexFile = encMexFile;

end
