function obj = obfuscateCode(obj)
    % obfuscateCode Use mcc obfuscation
    %
    % This method turns on mcc obfuscation, the "-s" option.
    %
    % Please note that this feature is only available starting in release
    % R2022b.

    % Copyright 2022 The MathWorks, Inc.

    if verLessThan('matlab', '9.13')
        error('SPARKAPI:obfuscation_not_available', ...
            "This feature is only available in release R2022b and later.")
    end

    obj.Obfuscate = true;

end
