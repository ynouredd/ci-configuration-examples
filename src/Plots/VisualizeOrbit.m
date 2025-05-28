function VisualizeOrbit(SatPositionHistory)
% Create a figure and plot the final positions
figure;
plot3(SatPositionHistory(:, 1), SatPositionHistory(:, 2), SatPositionHistory(:, 3), 'r', 'DisplayName', 'SatPosition');
title('Trajectory of Satellite');
maxR = max(vecnorm(SatPositionHistory'));
xlim([-maxR maxR])
ylim([-maxR maxR])
zlim([-maxR maxR])
end