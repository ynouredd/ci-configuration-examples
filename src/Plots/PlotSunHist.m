function PlotSunHist()
% Function that plots the sun's latitude, longitude and altitude over the
% course of a day

[sun_latitude,sun_longitude,sun_altitude] = sunLLAHist();
num_samples = 24*60*60;
time_vector = linspace(0, 24, num_samples);

% Plot the results
figure;
subplot(3, 1, 1);
plot(time_vector, sun_latitude);
title('Sun Latitude Over 24 Hours');
xlabel('Time (hours)');
ylabel('Latitude (degrees)');

subplot(3, 1, 2);
plot(time_vector, sun_longitude);
title('Sun Longitude Over 24 Hours');
xlabel('Time (hours)');
ylabel('Longitude (degrees)');

subplot(3, 1, 3);
plot(time_vector, sun_altitude);
title('Sun Altitude Over 24 Hours');
xlabel('Time (hours)');
ylabel('Altitude (km)');

sgtitle('Sun Position Over 24 Hours');
end