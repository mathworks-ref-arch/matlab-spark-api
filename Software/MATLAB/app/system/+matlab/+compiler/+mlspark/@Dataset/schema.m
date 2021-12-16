function sch = schema(obj)
    % SCHEMA Retrieve Java schema object from dataset
    %   
    
    % Copyright 2021 MathWorks, Inc.
    
    try
        sch = obj.dataset.schema();
    catch err
        error('SPARK:ERROR', 'Spark error: %s', stripJavaError(err.message));
    end
    
end 
