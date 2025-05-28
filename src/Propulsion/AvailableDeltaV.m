function totalDeltaV = AvailableDeltaV(numStages, dryMasses, wetMasses, ISPs, printDeltaV)
    % Function to calculate total delta V for a multi-stage rocket
    % Inputs:
    %   numStages - Number of stages
    %   dryMasses - Array of dry masses for each stage (in kg)
    %   wetMasses - Array of wet masses for each stage (in kg)
    %   ISPs - Array of specific impulses for each stage (in seconds)
    % Output:
    %   totalDeltaV - Total delta V for the rocket (in km/s)

    % Check if input arrays have the correct length
    if length(dryMasses) ~= numStages || length(wetMasses) ~= numStages || length(ISPs) ~= numStages
        error('Length of dryMasses, wetMasses, and ISPs must match numStages.');
    end

    % Define the standard gravitational acceleration
    g0 = 9.81; % m/s^2

    % Initialize total delta V
    totalDeltaV = 0;

    % Calculate the delta V for each stage and sum them up
    for i = 1:numStages
        deltaV_stage = ISPs(i) * g0 * log(wetMasses(i) / dryMasses(i));
        totalDeltaV = totalDeltaV + deltaV_stage;
        if nargin == 5 && printDeltaV
            fprintf('Delta V for stage %d: %.2f m/s\n', i, deltaV_stage);
        end
    end

    % Convert total delta V to km/s
    totalDeltaV = totalDeltaV / 1000;

    % Display the total delta V
    if nargin == 5 && printDeltaV
        fprintf('Total Delta V: %.2f km/s\n', totalDeltaV);
    end
end