function [SatPositionHistoryWithNoise, chainIndices] = introduceNoise(SatPositionHistory)
    % Introduce noise and a small chain anomaly into the SatPositionHistory matrix
    % Inputs:
    % - SatPositionHistory: Original satellite position history matrix (4081x3)
    % Outputs:
    % - SatPositionHistoryWithNoise: Matrix with noise and chain anomaly introduced
    % - chainIndices: Indices of the chain where the anomaly was introduced

    % Parameters for noise and anomaly
    chainLength = 50; % Length of the anomaly chain
    chainMagnitudeFactor = 0.2; % Percentage of the value for the chain

    % Copy the original data to avoid modifying it directly
    SatPositionHistoryWithNoise = SatPositionHistory;

    % Randomly select a starting point for the chain anomaly
    startIdx = randi(size(SatPositionHistory, 1) - chainLength + 1);
    chainIndices = startIdx:(startIdx + chainLength - 1);

    % Calculate the magnitude of each column at the starting index
    magnitudes = abs(SatPositionHistory(startIdx, :));

    % Find the column with the largest magnitude
    [~, maxColIdx] = max(magnitudes);

    % Calculate the anomaly as a fixed percentage of the starting value
    chainDeviation = chainMagnitudeFactor * SatPositionHistory(startIdx, maxColIdx);

    % Introduce the deviation in the chain for the column with the largest magnitude
    SatPositionHistoryWithNoise(chainIndices, maxColIdx) = SatPositionHistoryWithNoise(chainIndices, maxColIdx) + chainDeviation;
end