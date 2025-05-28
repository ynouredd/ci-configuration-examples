function [SatPositionHistoryWithDrift, driftStartIndex] = introduceDrift(SatPositionHistory)
    % Introduce an accumulating drift starting at a random point in the SatPositionHistory matrix
    % Inputs:
    % - SatPositionHistory: Original satellite position history matrix (4081x3)
    % Outputs:
    % - SatPositionHistoryWithDrift: Matrix with drift introduced
    % - driftStartIndex: Index where the drift starts

    % Copy the original data to avoid modifying it directly
    SatPositionHistoryWithDrift = SatPositionHistory;

    % Set random seed for reproducibility
    rng(0);

    % Randomly select a starting point for the drift
    driftStartIndex = floor((randi(size(SatPositionHistory, 1)) + size(SatPositionHistory, 1)) / 2);

    % Calculate the number of rows affected by the drift
    numRows = size(SatPositionHistory, 1) - driftStartIndex;

    % Apply a 1% incremental drift to each subsequent row
    for i = 1:numRows
        % Calculate the current norm of the position vector
        currentNorm = norm(SatPositionHistoryWithDrift(driftStartIndex + i, :));

        % Define the drift increment as 1% of the current norm
        driftIncrement = ones(1,1)*0.001 * currentNorm;

        % Calculate the drift vector in the direction of the current position
        driftVector = driftIncrement * (SatPositionHistoryWithDrift(driftStartIndex + i, :) / currentNorm);

        % Apply the drift to the current position
        SatPositionHistoryWithDrift(driftStartIndex + i, :) = SatPositionHistoryWithDrift(driftStartIndex + i, :) + driftVector*i;
    end
end