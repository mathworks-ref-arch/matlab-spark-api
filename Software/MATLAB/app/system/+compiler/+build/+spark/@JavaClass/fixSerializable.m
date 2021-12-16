function fixSerializable(obj)
    % fixSerializable Add Serializable to classes
    %
    % This adds a implements java.io.Serializable to certain classes, in
    % the releases of MATLAB where it wouldn't be present.
    
    % Copyright 2021 MathWorks, Inc.
    
    if verLessThan('matlab', '9.10')
        % This only needed for releases of MATLAB prior to R2021a
        compiler.build.spark.internal.addSerializable(obj.parent.outputFolder);
    end
    
end


