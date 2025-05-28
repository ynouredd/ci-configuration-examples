function [SatPositionHistoryWithMissing, SatPositionVelocityWithMissing, missingIndices] = introduceMissingData(SatPositionHistory,SatVelocityHistory)
    % Introduce missing data by removing a consecutive block of rows from the SatPositionHistory matrix
    % Inputs:
    % - SatPositionHistory: Original satellite position history matrix (4081x3)
    % Outputs:
    % - SatPositionHistoryWithMissing: Matrix with missing data (rows removed)
    % - missingIndices: Indices of the rows that were removed

    % Parameters for missing data
    blockLength = 100; % Number of consecutive rows to remove

    % Set random seed for reproducibility
    rng(0);

    % Randomly select a starting index for the block of missing rows
    totalRows = size(SatPositionHistory, 1);
    startIdx = randi([1, totalRows - blockLength + 1]);

    % Define the indices of the rows to be removed
    missingIndices = startIdx:(startIdx + blockLength - 1);

    % Remove the selected block of rows
    SatPositionHistoryWithMissing = SatPositionHistory;
    SatPositionHistoryWithMissing(missingIndices, :) = [];

    % Remove the selected block of rows
    SatPositionVelocityWithMissing = SatVelocityHistory;
    SatPositionVelocityWithMissing(missingIndices, :) = [];
end