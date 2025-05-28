function [sun_latitude,sun_longitude,sun_altitude] = sunLLAHist()
% Function to find the sun's latitude, longitude and altitude history over
% the course of a day. It is assumed the pattern is repeated every day

% Define constants
tilt = 23.44; % Earth's axial tilt in degrees
num_samples = 24 * 60 * 60; % Number of samples (one per minute)
altitude = 150e6; % Altitude in kilometers (constant)
latitude_variation = tilt; % Maximum latitude variation due to Earth's tilt

% Preallocate arrays for results
sun_latitude = zeros(1, num_samples);
sun_longitude = linspace(0, 360, num_samples); % Longitude sweeps from 0 to 360 degrees
sun_altitude = altitude * ones(1, num_samples); % Altitude is constant

% Time vector (in hours)
time_vector = linspace(0, 24, num_samples);

% Calculate the sun's latitude over the course of the day
for i = 1:num_samples
    % Simple sinusoidal variation to simulate the effect of Earth's tilt
    sun_latitude(i) = latitude_variation * sind(360 * (time_vector(i) / 24));
end

end
