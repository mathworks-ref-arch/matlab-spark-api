function T = make_test_data(N)
    % make_test_data

    % Copyright 2021 The MathWorks, Inc.
    
    cols = ["id", "doubledata","floatdata", "longdata", "intdata", "shortdata", "booleandata", "description"];
    
    C = cell(N, 8);
    
    t = linspace(0,2*pi,64);
    for k=1:N
        trigData = sin(k*t+pi/8) + 1.5*cos(k*2*t);
        intData = k:(k*3);
        boolData = rem(k:(k+10),3);
        C{k,1} = k;
        C{k,2} = trigData;
        C{k,3} = single(trigData);
        C{k,4} = int64(intData);
        C{k,5} = int32(intData);
        C{k,6} = int16(intData);
        C{k,7} = logical(boolData);
        C{k,8} = sprintf("k is %d", k);
    end
    T = cell2table(C, "VariableNames", cols);
    
end