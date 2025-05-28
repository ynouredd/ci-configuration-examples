function [anomalyIndices, SatPositionHistoryCorrected] = movingWindowMethod(SatPositionHistory)
    % Hardcoded parameters
    threshold = 700.0;
    windowSize = 5;
    
    % Initialize variables
    [numRows, numCols] = size(SatPositionHistory);
    SatPositionHistoryCorrected = SatPositionHistory;
    anomalyIndices = [];
    
    % Iterate over each dimension (x, y, z)
    for dim = 1:numCols
        % Iterate over each point to check for anomalies
        for i = windowSize+1:numRows
            % Calculate the moving average using the corrected data
            movingAvg = mean(SatPositionHistoryCorrected(i-windowSize:i-1, dim));
            
            % Calculate the deviation from the moving average
            deviation = abs(SatPositionHistory(i, dim) - movingAvg);
            
            % Check if the current deviation is an anomaly
            if deviation > threshold
                anomalyIndices(end+1) = i; % 1-based indexing
                
                % Use all previous points in SatPositionHistoryCorrected for spline interpolation
                x = 1:i-1;
                y = SatPositionHistoryCorrected(1:i-1, dim);
                
                % Perform spline interpolation using all previous corrected points
                SatPositionHistoryCorrected(i, dim) = spline(x, y, i);
            end
        end
    end
end