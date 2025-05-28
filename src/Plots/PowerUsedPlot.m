[percentilePower,totalPower] = PowerUsed("Satellite1.mat",95);

% Plot the histogram of the total power consumption
figure;
histogram(totalPower, 'Normalization', 'pdf');
title('Monte Carlo Simulation of Satellite Power Consumption');
xlabel('Total Power Consumption (Watts)');
ylabel('Probability Density');
grid on;