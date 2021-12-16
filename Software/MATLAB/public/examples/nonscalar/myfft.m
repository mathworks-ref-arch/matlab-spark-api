function Y = myfft(data)
    % myfft Example for SparkBuilder

    % Copyright 2021 The MathWorks, Inc.
    
    N = length(data);
    out = fft(data);
    out2 = abs(out/N);
    out1 = out2(1:N/2+1);
    out1(2:end-1) = 2*out1(2:end-1);
    Y = out1;
    
end


    