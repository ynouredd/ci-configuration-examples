function [percentilePower,totalPower] = PowerUsed(satDataSheet,percentile)
% PowerUsed computes the average amount of power used by a satellite based
% on it's instrumentation's power consumption, and average time on during
% the mission
% Inputs:
% satDataSheet: A string pointing to the name of a data sheet on path containing
% two columns representing a range of typical power consumption and average time spent on
% percentile: The % highest value we can expect to see based on the ranges
% selected
% Outputs:
% percentilePower: power consumed at the percentile specified in W
% totalPower: 50th percentile power consumed in W

% Define the number of Monte Carlo simulations
numSimulations = 10000;
load(satDataSheet)

% Initialize arrays to store the results
totalPower = zeros(numSimulations, 1);

for i = 1:numSimulations
    % Generate random values within the specified ranges
    powerComm = randi(powerCommRange);
    powerAttCtrl = randi(powerAttCtrlRange);
    powerComp = randi(powerCompRange);
    powerThermal = randi(powerThermalRange);
    powerPayload = randi(powerPayloadRange);
    powerPowerSys = randi(powerPowerSysRange);
    powerPropulsion = randi(powerPropulsionRange);
    
    activeComm = randi(activeCommRange) / 100;
    activeAttCtrl = randi(activeAttCtrlRange) / 100;
    activeComp = randi(activeCompRange) / 100;
    activeThermal = randi(activeThermalRange) / 100;
    activePayload = randi(activePayloadRange) / 100;
    activePowerSys = randi(activePowerSysRange) / 100;
    activePropulsion = randi(activePropulsionRange) / 100;
    
    % Calculate the total power consumption
    totalPower(i) = powerComm * activeComm + ...
        powerAttCtrl * activeAttCtrl + ...
        powerComp * activeComp + ...
        powerThermal * activeThermal + ...
        powerPayload * activePayload + ...
        powerPowerSys * activePowerSys + ...
        powerPropulsion * activePropulsion;
end

% Calculate mean and standard deviation of the total power consumption
meanPower = mean(totalPower);
stdPower = std(totalPower);
percentilePower = prctile(totalPower, percentile);
end