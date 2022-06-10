function use = useMetrics(obj, fileObj)
    % useMetrics Helper method to decide if to use Metrics
    %
    % This is an internal function

    % Copyright 2022 The MathWorks, Inc.

    use = false;
    
    if obj.Metrics
        if fileObj.TableAggregate
            use = true;
        end
    end
end
