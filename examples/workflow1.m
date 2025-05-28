%% Initialize scenario
StartDate = [2024 1 1 0 0 0];
SecondsToPropagate = 100000;

InitialSatPosition = [7543, 11760, 515];
InitialSatVelocity = [-3.211, 0.459, 4.643];

%% Determine we have the required Propellent to get us into desired orbit
% Figure out how much Delta V you have at your disposal
numStages = 3;
dryMasses = [25000, 5000, 1000]; % kg
wetMasses = [50000, 20000, 4000]; % kg
ISPs = [300, 350, 400]; % seconds
totalDeltaV = AvailableDeltaV(numStages, dryMasses, wetMasses, ISPs);

% Required Delta V for you position and history, accounting for Earth's
% spin
SafetyMargin = 10; % 10% buffer
latitude = 5; % 5 degrees North
deltaV = RequiredDeltaV(InitialSatPosition, InitialSatVelocity, SafetyMargin, latitude);

% Print only if we have enough delta V to complete the mission
if deltaV < totalDeltaV
    fprintf('You have %.2f km/s but only need %.2f km/s, enough to complete the mission.\n', totalDeltaV,deltaV);
end

%% Simulate Orbit and add anomalies
% Propagate to obtain position and velocity history of the satellite,
% neglecting lunar and atmospheric effects
[SatPositionHistory,SatVelocityHistory] = PropSat(InitialSatPosition,InitialSatVelocity,SecondsToPropagate,StartDate,0,0);

% Simulate different kind of anomalous data in position history
[SatPositionHistory,SpikeIndex] = introduceSpikes(SatPositionHistory);
[SatPositionHistory,NoiseIndex] = introduceNoise(SatPositionHistory);

% Use a third-party anomaly detection Technique to find the indices
[anomalyIndices,satpos1] = movingWindowMethod(SatPositionHistory);

%% Viusalize results and confirm anomaly indices visually correct
% Create a 3D scatter plot
figure;
plot3(SatPositionHistory(:,1), SatPositionHistory(:,2), SatPositionHistory(:,3), 'b.');
hold on;

% Highlight anomalous points with red circles
scatter3(SatPositionHistory(anomalyIndices,1), SatPositionHistory(anomalyIndices,2), SatPositionHistory(anomalyIndices,3), 'ro', 'LineWidth', 1.5);

xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('3D Scatter Plot with Anomalous Points');
grid on;
hold off;
legend('Normal Data', 'Anomalies');
