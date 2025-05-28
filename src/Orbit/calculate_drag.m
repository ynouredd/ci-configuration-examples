function drag_force = calculate_drag(position, velocity, A, Cd)
% This function calculates drag caused by Earth's atmosphere in N based on
% the satellite's position, velocity, area and coefficienct of drag
% Inputs: 
% 1. Position [x y z] in km
% 2. Velocity [x y z] in km/s
% 3. Exposed area of satellite (m^2)
% 4. Coefficient of drag of satellite
% Outputs:
% Drag in Newtons
    % Constants
    R_earth = 6371e3; % Earth's radius in meters

    position = position*1000;
    velocity = velocity*1000;
    
    % Default values for optional inputs
    if nargin < 3
        A = 10; % Default cross-sectional area in m^2
    end
    if nargin < 4
        Cd = 2.2; % Default drag coefficient
    end
    
    % Calculate altitude from position
    altitude = norm(position) - R_earth;
    
    % Get atmospheric density at the given altitude
    rho = atmospheric_density(altitude);
    
    % Calculate relative velocity (magnitude)
    v = norm(velocity);
    
    % Calculate drag force
    drag_force = 0.5 * rho * v^2 * Cd * A/1000;
end