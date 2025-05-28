function [MoonPos,MoonVel] = SyncMoon(StartTime)
% Propagate the moon to the correct starting position based on the start
% time selected by the user
% Input:
% 1. Date to find moon position at [year month day hour minute second]
% Output:
% 1. Moon position [x y z] km
% 2. Moon velocity [x y z] km/s
date = datetime([1900, 1, 1, 0,0,0]);
StartDate= datetime(StartTime);

% Calculate the difference
timeDifference = seconds(StartDate-date);

MoonPos = [42027.66 360202.05 -21736];
MoonVel = [-1.06408 0.12848 0.07176];

period = calculatePeriod(MoonPos,MoonVel);

OrbFrac = mod(timeDifference, period);
dT = 60*10; % 10 minute time steps
for NewTime = 0:dT:OrbFrac
    [MoonPos,MoonVel] = propagateAboutEarth(MoonPos,MoonVel,dT);
end

end