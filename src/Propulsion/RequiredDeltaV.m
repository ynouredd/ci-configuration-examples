function deltaV = RequiredDeltaV(r_target, v_target, SafetyMargin, latitude, printDeltaV)
% RequiredDeltaV calculates the amount of propellent needed to reach a
% desired position and velocity in an orbit.
% Inputs:
% 1. r_target: Target position desired [x y z] km
% 2. v_target: Target velocity desired [vx vy vz] km/s
% 3. SafetyMargin: percentage safety margin required by mission
% 4. Latitude: Launch location Latitude, used to compute deltaV provided by
% the rotation of the Earth
% Outputs:
% deltaV: required deltaV required to reach given orbit from launch
% location

% Constants
mu = 3.986004418e5; % Earth's gravitational parameter in km^3/s^2
R_earth = 6371; % Earth's radius in kilometers
omega_earth = 7.2921159e-5; % Earth's rotation rate in rad/s

% Initial specific orbital energy at Earth's surface
E_initial = -mu / R_earth;

% Specific orbital energy of the target orbit
E_target = (norm(v_target)^2 / 2) - (mu / norm(r_target));

% Change in specific orbital energy
deltaE = E_target - E_initial;

% Calculate the delta-V required to achieve the target energy
deltaV = sqrt(2 * deltaE);

% Calculate the rotational speed contribution at the given latitude
if nargin > 3
    % Earth's rotational speed at the given latitude in km/s
    v_spin = omega_earth * R_earth * cosd(latitude);
    Inc = calculateInc(r_target, v_target);
    
    v_effective_spin = v_spin * cosd(Inc);
    deltaV = deltaV - v_effective_spin;
end

% Apply safety margin if specified
if nargin > 2
    deltaV = deltaV * (100+SafetyMargin)/100;
end

if nargin == 5 && printDeltaV
    fprintf('Total delta-V required: %.2f km/s\n', deltaV);
end

end
