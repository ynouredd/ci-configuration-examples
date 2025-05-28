function anomalies = interpMethod(SatPositionHistory,SatPositionHistoryTraining)

SatPositionNorm = vecnorm(SatPositionHistoryTraining');
SatPositionNormHistory = vecnorm(SatPositionHistory');

x = 1:length(SatPositionNorm);

% Interpolate to create a smooth reference signal
% Use a subset of points for interpolation to avoid overfitting
num_points = 100;
x_interp = linspace(1, length(SatPositionNorm), num_points);
y_interp = interp1(x, SatPositionNorm, x_interp, 'spline');

% Interpolate back to the original x-axis to get the smooth reference
smooth_reference = interp1(x_interp, y_interp, x, 'spline');

% Calculate the residuals
residuals = SatPositionNormHistory - smooth_reference;

% Set a threshold for anomaly detection
threshold = 10; 

% Detect anomalies
anomalies = find(abs(residuals) > threshold);
end