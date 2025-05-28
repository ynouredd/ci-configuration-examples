%% Initialize scenario
timeStart = [2024 1 1 0 0 0];
timeEnd = [2024 7 1 0 0 0];
SecondsToPropagate = seconds(datetime(timeEnd)-datetime(timeStart));

Pos = [20000 600000 143000];
Vel = [-0.7 -0.1 0.1];

InitialPeriod = calculatePeriod([20000 600000 143000],[-0.7 -0.1 0.1]);

% Propagate satellite over sim time and account for Lunar Gravity
[SatPositionHistory,SatVelocityHistory] = PropSat(Pos,Vel,SecondsToPropagate,timeStart,1,0);

figure;
plot3(SatPositionHistory(:, 1), SatPositionHistory(:, 2),SatPositionHistory(:, 3), 'b-'); % Plot the trajectory with a blue line
hold on;

% Indicate the first point with a green circle
plot3(SatPositionHistory(1, 1), SatPositionHistory(1, 2), SatPositionHistory(1, 3), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g');

% Indicate the last point with a red square
plot3(SatPositionHistory(end, 1), SatPositionHistory(end, 2), SatPositionHistory(end, 3), 'rs', 'MarkerSize', 8, 'MarkerFaceColor', 'r');

% Determine the maximum radius for axis limits
maxR = max(vecnorm(SatPositionHistory'));

% Set the limits and aspect ratio for the plot
xlim([-maxR maxR])
ylim([-maxR maxR])
axis equal

timeStart = [2024 1 1 0 0 0];
timeEnd = [2024 1 29 0 0 0];
MoonPos = [42027.66 360202.05 -21736];
MoonVel = [-1.06408 0.12848 0.07176];
MoonPositionHistory = PropSat(MoonPos,Vel,SecondsToPropagate,timeStart,0,0);

plot3(MoonPositionHistory(:, 1), MoonPositionHistory(:, 2),MoonPositionHistory(:, 3)); % Plot the trajectory with a blue line

% Add a legend to explain the markers
legend('Trajectory', 'Start Point', 'End Point', 'Moon Trajectory','Location', 'Best');
%%
FinalPeriod = calculatePeriod(SatPositionHistory(end, :),SatVelocityHistory(end, :));

% Assuming SatVelocityHistory and SatPositionHistory are matrices
% with the same number of rows
numEntries = length(SatVelocityHistory);

% Preallocate arrays for the orbital elements
SMA = zeros(1, numEntries);
ECC = zeros(1, numEntries);
INC = zeros(1, numEntries);
RAAN = zeros(1, numEntries);
AOP = zeros(1, numEntries);
TA = zeros(1, numEntries);

% Loop through each entry to calculate orbital elements
for i = 1:numEntries
    [SMA(i), ECC(i), INC(i), RAAN(i), AOP(i), TA(i)] = findOrbitalElements(SatPositionHistory(i, :), SatVelocityHistory(i, :));
end

% Create a figure with 6 subplots
figure;

% Subplot for SMA
subplot(3, 2, 1);
plot(SMA, 'b');
title('Semi-Major Axis (SMA)');
xlabel('Index');
ylabel('SMA');

% Subplot for ECC
subplot(3, 2, 2);
plot(ECC, 'r');
title('Eccentricity (ECC)');
xlabel('Index');
ylabel('ECC');

% Subplot for INC
subplot(3, 2, 3);
plot(INC, 'g');
title('Inclination (INC)');
xlabel('Index');
ylabel('INC');

% Subplot for RAAN
subplot(3, 2, 4);
plot(RAAN, 'c');
title('Right Ascension of Ascending Node (RAAN)');
xlabel('Index');
ylabel('RAAN');

% Subplot for AOP
subplot(3, 2, 5);
plot(AOP, 'm');
title('Argument of Periapsis (AOP)');
xlabel('Index');
ylabel('AOP');

% Subplot for TA
subplot(3, 2, 6);
plot(TA, 'k');
title('True Anomaly (TA)');
xlabel('Index');
ylabel('TA');

% Adjust layout for better viewing
sgtitle('Orbital Elements Over Time');