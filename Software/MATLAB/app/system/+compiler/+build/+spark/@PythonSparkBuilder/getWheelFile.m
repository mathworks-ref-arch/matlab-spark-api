function [wheelFile, wheelName] = getWheelFile(obj)
    % getWheelFile Return name of wheel file
    %

    % Copyright 2022 The MathWorks, Inc.


    wheel = dir(fullfile(obj.OutputDir, "dist", "*.whl"));
    if isempty(wheel)
        error('Databricks:Error', 'No wheel file found. Consider running the method createWheel first');
    elseif length(wheel) > 1
        error('Databricks:Error', 'There were several wheel files in the dist folder. There should be only one');
    end

    
    wheelFile = fullfile(wheel.folder, wheel.name);
    wheelName = wheel.name;
end
