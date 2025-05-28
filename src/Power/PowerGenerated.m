function Wh = PowerGenerated(VisibleToSun,SPEfficiency,SPArea,StartTime,EndTime)
% PowerGenerated calculates the amount of power generated over the duration
% of a mission.
% Inputs:
% VisibleToSun: time history of whether the satellite has line-of-sight
% with the Sun
% SPEfficiency: Solar panel efficiency as a decimal (between 0 and 1)
% SPArea: Solar panel area in square kilometers
% StartTime: Mission start time
% EndTime: Mission end time
% Output:
% Wh: Watt-hour of energy produced by the solar panel over the course of
% the mission
dT = seconds(datetime(EndTime)-datetime(StartTime))/length(VisibleToSun);
tSinceStart = (dT * (1:length(VisibleToSun))) / 31557600;
PowerGen = VisibleToSun .* SPEfficiency .* SPArea .* 1367 .* (0.975 .^ tSinceStart);

Wh = sum(PowerGen);
end