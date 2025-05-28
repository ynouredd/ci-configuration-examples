function desiredOrientation = calculateNadirOrientation(positionHistory, velocityHistory)
% This function finds the nadir orientation (orientation required to point
% at the surface directly below you). It uses a third-party anomaly
% detection technique to throw out any anomalous data and replace it with
% interpolated values
% Inputs:
% 1. positionHistory: The position history of the satellite
% 2. velocityHistory: The velocity history of the satellite
% Outputs:
% 1. desiredOrientation: the orientation desired to point Nadir

% Preallocate array for desired orientation
numPoints = size(positionHistory, 1);
desiredOrientation = zeros(numPoints, 3); % Roll, Pitch, Yaw in degrees

for i = 1:length(positionHistory)
    SMA(i) = calculateSMA(positionHistory(i,:), velocityHistory(i,:));
    TA(i) = calculateTA(positionHistory(i,:), velocityHistory(i,:));
end
anomaliesIndices = OrbitParameterMethod(SMA, TA);

% Interpolate anomalies in positionHistory using 'spline'
for idx = 1:size(positionHistory, 2) % Loop over each column (x, y, z)
    x = 1:numPoints;
    y = positionHistory(:, idx);
    
    % Mark anomalies as NaN for interpolation
    y(anomaliesIndices) = NaN;
    
    % Perform interpolation using 'spline'
    y = fillmissing(y, 'spline');
    
    % Update positionHistory with interpolated values
    positionHistory(:, idx) = y;
end

for i = 1:numPoints
    % Current position vector
    r = positionHistory(i, :);
    
    % Calculate nadir vector (pointing towards Earth's center)
    nadir = -r;
    
    % Normalize the nadir vector
    nadir = nadir / norm(nadir);
    
    % Calculate desired pitch and yaw angles
    pitch = asin(nadir(3)); % Pitch is the angle from the x-y plane
    yaw = atan2(nadir(2), nadir(1)); % Yaw is the angle in the x-y plane
    
    % Convert to degrees
    desiredOrientation(i, 2) = rad2deg(pitch);
    desiredOrientation(i, 3) = rad2deg(yaw);
    
    % Roll is typically zero for nadir pointing
    desiredOrientation(i, 1) = 0;
end
end