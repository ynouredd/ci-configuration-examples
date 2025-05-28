%% Initialize scenario
timeStart = [2024 1 1 0 0 0];
timeEnd = [2024 1 8 0 0 0];
SecondsToPropagate = seconds(datetime(timeEnd)-datetime(timeStart));

Pos = [6520 0 0];
Vel = [0 8.3 0];

% Propagate satellite over duration of simulation, account for atmoshperic
% drag and using a 50 square meter cross sectional area
[SatPositionHistory,~,simDuration] = PropSat(Pos,Vel,SecondsToPropagate,timeStart,0,1,50);
timeEnd = datevec(datetime(timeStart)+seconds(simDuration));

Visible = VisibleToSun(SatPositionHistory,timeStart,SecondsToPropagate);

SPEfficiency = 0.3;
SPArea = 25;
Wh = PowerGenerated(Visible,SPEfficiency,SPArea,timeStart,timeEnd);
[percentilePower,totalPower] = PowerUsed("Satellite1.mat",0.9);
PowerNeeded = percentilePower * simDuration;
percentageMoreGenerated = ((Wh - PowerNeeded) / PowerNeeded) * 100;
fprintf('We have generated %.2f%% more Wh over the entire mission compared to power needed.\n', percentageMoreGenerated);

%% To help illustrate the passage of time, use a time-based colormap
% Create a colormap
numColors = 50;
cmap = jet(numColors);
numPoints = size(SatPositionHistory, 1);
stepSize = floor(numPoints / numColors);

% Plot each segment of the orbit with a color corresponding to its time step
hold on;
for colorIndex = 1:numColors
    % Determine the range of indices for this color
    startIndex = (colorIndex - 1) * stepSize + 1;
    endIndex = min(colorIndex * stepSize, numPoints - 1); % Ensure we don't exceed bounds

    startIndex = max(1,startIndex-1);
    % Plot the chunk with the current color
    plot(SatPositionHistory(startIndex:endIndex, 1), SatPositionHistory(startIndex:endIndex, 2), ...
         'Color', cmap(colorIndex, :), 'LineWidth', 2);
end
hold off;

maxR = max(vecnorm(SatPositionHistory'));
xlim([-maxR maxR]);
ylim([-maxR maxR]);
axis equal;

% Add a colorbar to indicate the progression of time
colormap(cmap);
colorbar;
caxis([1 numPoints]);
ylabel(colorbar, 'Time Step');
xlabel('X Position');
ylabel('Y Position');
title('Satellite Orbit with Time Progression');