%% Initialize scenario
timeStart = [2024 1 1 0 0 0];
timeEnd = [2024 1 2 0 0 0];
SecondsToPropagate = seconds(datetime(timeEnd)-datetime(timeStart));

Pos = [-7254 -910 667];
Vel = [-1.203 -3.76 -8.042];

% Propagate satellite over sim time and account for Lunar Gravity
[SatPositionHistory,SatVelocityHistory] = PropSat(Pos,Vel,SecondsToPropagate,timeStart,1,0);

% Add some anomalies
[SatPositionHistory,DriftIndices] = introduceDrift(SatPositionHistory);
[SatPositionHistory,NoiseIndices] = introduceNoise(SatPositionHistory);
[SatPositionHistory,SpikesIndices] = introduceSpikes(SatPositionHistory);

for i = 1:length(SatPositionHistory)
    SMA(i) = calculateSMA(SatPositionHistory(i,:), SatVelocityHistory(i,:));
    TA(i) = calculateTA(SatPositionHistory(i,:), SatVelocityHistory(i,:));
end

% Use a third-party anomaly detection Technique to find the indices
anomalyIndices = OrbitParameterMethod(SMA,TA);

figure;
plot3(SatPositionHistory(:, 1), SatPositionHistory(:, 2),SatPositionHistory(:, 3),'.'); % Plot the trajectory with a blue line
hold on;

% Highlight anomalous points with red circles
scatter3(SatPositionHistory(anomalyIndices,1), SatPositionHistory(anomalyIndices,2), SatPositionHistory(anomalyIndices,3), 'ro', 'LineWidth', 1.5);

% Find desired orientation, assuming you would like to point in a Nadir
% direction
desiredOrientation = calculateNadirOrientation(SatPositionHistory,SatVelocityHistory);
initialOrientation = [0 0 0];
%% 
% Spacecraft inertia matrix (kg*m^2)
inertiaMatrix = [120000, 90000, 1000; 
                90000, 120000, 75000; 
                1000, 75000, 120000]; % Example values

% Maximum torque that reaction wheels can apply (N*m)
maxTorque = [25, 25, 25]; % Example values

% Initialize parameters for PID control
ControllerValues = [8 0.1 40]; % [kp ki kd]
maxIntegral = 1; % Maximum allowed integral component

dT = SecondsToPropagate/(length(SatPositionHistory));   
[orientation, controlEffort] = attitudeControl(initialOrientation, desiredOrientation, dT, inertiaMatrix, maxTorque, ControllerValues, maxIntegral);

% Number of data points
N = size(orientation, 1);

% Plot orientation
figure;
subplot(3, 3, 1);
plot(1:N, orientation(:, 1), 'r');
title('Orientation X');
xlabel('Sample');
ylabel('Value');

subplot(3, 3, 4);
plot(1:N, orientation(:, 2), 'g');
title('Orientation Y');
xlabel('Sample');
ylabel('Value');

subplot(3, 3, 7);
plot(1:N, orientation(:, 3), 'b');
title('Orientation Z');
xlabel('Sample');
ylabel('Value');

% Plot desiredOrientation
subplot(3, 3, 2);
plot(1:N, desiredOrientation(:, 1), 'r');
title('Desired Orientation X');
xlabel('Sample');
ylabel('Value');

subplot(3, 3, 5);
plot(1:N, desiredOrientation(:, 2), 'g');
title('Desired Orientation Y');
xlabel('Sample');
ylabel('Value');

subplot(3, 3, 8);
plot(1:N, desiredOrientation(:, 3), 'b');
title('Desired Orientation Z');
xlabel('Sample');
ylabel('Value');

% Plot controlEffort
subplot(3, 3, 3);
plot(1:N, controlEffort(:, 1), 'r');
title('Control Effect X');
xlabel('Sample');
ylabel('Value');

subplot(3, 3, 6);
plot(1:N, controlEffort(:, 2), 'g');
title('Control Effect Y');
xlabel('Sample');
ylabel('Value');

subplot(3, 3, 9);
plot(1:N, controlEffort(:, 3), 'b');
title('Control Effect Z');
xlabel('Sample');
ylabel('Value');
sgtitle('Orientation, Desired Orientation, and Control Effect');
%% 
figure
llaInterest = [42.3 -122.3 50];
visible = SatVisibilityHistory(SatPositionHistory,timeStart,llaInterest,SecondsToPropagate);
plot(1:dT:dT*length(visible),visible)

percent = sum(visible) * 100 / length(visible);
title(sprintf('The satellite is visible %.1f%% of the time from the coordinates specified', percent));

%% 
EbNo = findSignalToNoise(SatPositionHistory*1e3,timeStart,"Canberra.mat","ISS.txt",dT);
figure
plot(1:dT:dT*length(EbNo),EbNo)