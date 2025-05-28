function rho = atmospheric_density(h)
%ATMOSPHERIC_DENSITY Computes air density (kg/m^3) at altitude h (meters)
%   h must be >= 85,000 meters

    arguments
        h (1, :) double {mustBeReal, mustBeFinite, mustBeNonnegative, mustBeGreaterThanOrEqual(h, 85e3)}
    end

    % Atmospheric layers: [base_altitude (m), base_density (kg/m^3), scale_height (m)]
    layers = [
        85000,      1e-6,       9000;
        100000,     1e-7,       10500;
        500000,     1e-10,      11500
    ];

    % Preallocate output
    rho = zeros(size(h));

    % Loop over elements in h for flexibility
    for k = 1:numel(h)
        alt = h(k);
        idx = find(alt < layers(:, 1), 1) - 1;
        if isempty(idx), idx = size(layers, 1); end

        h0   = layers(idx, 1);
        rho0 = layers(idx, 2);
        H    = layers(idx, 3);

        rho(k) = rho0 * exp(-(alt - h0) / H);
    end
end
