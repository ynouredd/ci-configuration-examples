function anomalies = OrbitParameterMethod(SMA, TA)
    % Initialize anomalies vector
    anomalies = false(size(SMA));
    
    % Detect anomalies in SMA
    for i = 2:length(SMA)
        validIndices = find(~anomalies(1:i-1));

        SMAdiff = abs(SMA(i) - SMA(validIndices(end)))/(i-validIndices(end));

        % Check for significant change in SMA
        if SMAdiff > SMA(i) * 1e-3
            anomalies(i) = true;
        end
    end
    
    TA = unwrap(TA*2*pi/180)*180/(2*pi);
    
    %Detect and correct anomalies in TA
    for i = 2:length(TA)
        % Find valid indices (non-anomalous) for moving average calculation
        validIndices = find(~anomalies(1:i-1));

        if length(validIndices) >= 10
            % Use the last 10 valid indices
            lastValidIndices = validIndices(end-9:end);
        else
            % Use all available valid indices if fewer than 10
            lastValidIndices = validIndices;
        end

        % Calculate the moving average of the differences at valid indices
        if ~isempty(lastValidIndices)
            MovingAvg10PtDiff = mean(diff(TA(lastValidIndices))./diff(lastValidIndices));
        else
            MovingAvg10PtDiff = 0; % Default value if no valid indices are found
        end

        % Calculate current difference
        TAdiff = (TA(i) - TA(lastValidIndices(end)))/(i-lastValidIndices(end));

        % Check if current TA deviates significantly from expected
        if abs(TAdiff) < MovingAvg10PtDiff * 0.9 || ...
           abs(TAdiff) > MovingAvg10PtDiff * 1.1
            anomalies(i) = true;

            % Interpolate the value using the previous two points
            if i > 2
                TA(i) = 2 * TA(i-1) - TA(i-2);
            end
        end
    end

    anomalies = find(anomalies);
end