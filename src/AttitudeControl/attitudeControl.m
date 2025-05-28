function [orientation, controlEffort] = attitudeControl(initialOrientation, desiredOrientation, timeStep, inertiaMatrix, maxTorque, ControllerValues, maxIntegral)
% Function that finds the orientation and the required control effort from
% reactor wheels to maintain the desired orientation. 
% Inputs:
% 1. initialOrientation: [roll pitch yaw] in degrees
% 2. desiredOrientation: Nx[roll pitch yaw] where n is orientations at each
% time step
% 3. timeStep: the amount of time between each desired orientation in
% seconds
% 4. inertiaMatrix: 3x3 inertiaMatrix of the satellite in kg*m^2
% 5. maxTorque: max torque the reaction wheel can provide in any direction
% in N*m
% 6. ControllerValues: PID values used for controlling satellite
% orientation
% 7. maxIntegral: maximum integral component allowed by controller, set to
% inf if not desired
% Outputs:
% Orientation: time history of the orientation of the satellite
% controlEffort: time history of amount of torque reaction wheels applied and in what direction

kp = ControllerValues(1);
ki = ControllerValues(2);
kd = ControllerValues(3);

% Length of the moving window for integral calculation
integralWindowLength = floor(300/timeStep); % Number of time steps to consider for integral

% Initialize integral error buffer
integralErrorBuffer = zeros(integralWindowLength, 3);
previousError = [0, 0, 0];

% Determine the number of time steps based on desiredOrientation length
numSteps = size(desiredOrientation, 1);

% Preallocate arrays for orientation and control effort
orientation = zeros(numSteps, 3); % Assuming Euler angles for simplicity
controlEffort = zeros(numSteps, 3);

% Set initial orientation
orientation(1, :) = initialOrientation;

% Initialize angular velocity
angularVelocity = [0, 0, 0]; % Initial angular velocity (rad/s)

% Unwrap desired orientation when it crosses between -360 and 0 plane
desiredOrientation = unwrap(desiredOrientation,180);

for i = 2:numSteps
    % Calculate error
    error = desiredOrientation(i, :) - orientation(i-1, :);
    
    % Update integral error buffer
    integralErrorBuffer = [integralErrorBuffer(2:end, :); error];
    
    % Calculate integral error with a moving window
    integralError = sum(integralErrorBuffer, 1) * timeStep;
    
    % Clamp integral error to max value
    integralError = min(max(integralError, -maxIntegral), maxIntegral);
    
    int(i,:) = integralError;
    % Update derivative error
    derivativeError = (error - previousError) / timeStep;
    
    % Calculate control input using PID
    controlInput = kp * error + ki * integralError + kd * derivativeError;
    
    % Limit control input to max torque
    controlInput = min(max(controlInput, -maxTorque), maxTorque);
    
    % Calculate angular acceleration
    angularAcceleration = (inertiaMatrix \ controlInput')'; % Solve for angular acceleration
    
    % Update angular velocity
    angularVelocity = angularVelocity + angularAcceleration * timeStep;
    
    % Update orientation
    orientation(i, :) = orientation(i-1, :) + angularVelocity * timeStep;
    
    % Record control effort
    controlEffort(i, :) = controlInput;
    
    % Update previous error
    previousError = error;
end

orientation = mod(orientation+180,360)-180;
end