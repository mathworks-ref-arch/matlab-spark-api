function Delta = deltaArrivalByDistance(ActualElapsedTime, CRSElapsedTime, Distance)
    % deltaArrivalByDistance Check delay by distance
    %
    % The delay will be in minutes per 100km

    % Copyright 2021 The MathWorks, Inc.

    Delta = 100 * double((double(ActualElapsedTime) - double(CRSElapsedTime))/double(Distance));

end