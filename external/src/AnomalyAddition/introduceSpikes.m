function [SatPositionHistoryWithSpikes, spikeIndices] = introduceSpikes(SatPositionHistory)
    % Introduce spikes into the SatPositionHistory matrix
    % Inputs:
    % - SatPositionHistory: Original satellite position history matrix (4081x3)
    % Outputs:
    % - SatPositionHistoryWithSpikes: Matrix with spikes introduced
    % - spikeIndices: Indices of the introduced spikes

    % Parameters for spikes
    numSpikes = 10; % Number of spikes to introduce
    maxNormIncreaseFactor = 1.3; % Maximum allowable increase in norm (30%)

    % Copy the original data to avoid modifying it directly
    SatPositionHistoryWithSpikes = SatPositionHistory;

    % Initialize an array to store the indices of the spikes
    spikeIndices = zeros(numSpikes, 2);

    % Set random seed for reproducibility
    rng(0);

    % Calculate the original norm of the SatPositionHistory
    originalNorm = norm(SatPositionHistory, 'fro');

    % Calculate the maximum allowable norm after introducing spikes
    maxAllowableNorm = originalNorm * maxNormIncreaseFactor;

    % Calculate the standard deviation of the position history
    positionStdDev = std(SatPositionHistory(:));

    % Introduce Spikes
    for i = 1:numSpikes
        % Randomly select a row and column to introduce a spike
        rowIdx = randi(size(SatPositionHistory, 1));
        colIdx = randi(size(SatPositionHistory, 2));

        % Store the index of the spike
        spikeIndices(i, :) = [rowIdx, colIdx];

        % Calculate the spike magnitude
        spikeMagnitude = positionStdDev; % Base magnitude on standard deviation

        % Temporarily introduce the spike
        tempSatPositionHistory = SatPositionHistoryWithSpikes;
        tempSatPositionHistory(rowIdx, colIdx) = tempSatPositionHistory(rowIdx, colIdx) + spikeMagnitude;

        % Check if the new norm exceeds the maximum allowable norm
        if norm(tempSatPositionHistory, 'fro') <= maxAllowableNorm
            % If within limits, introduce the spike
            SatPositionHistoryWithSpikes(rowIdx, colIdx) = tempSatPositionHistory(rowIdx, colIdx);
        else
            % If not within limits, scale down the spike
            scaleFactor = (maxAllowableNorm - originalNorm) / (norm(tempSatPositionHistory, 'fro') - originalNorm);
            SatPositionHistoryWithSpikes(rowIdx, colIdx) = SatPositionHistoryWithSpikes(rowIdx, colIdx) + spikeMagnitude * scaleFactor;
        end
    end
end