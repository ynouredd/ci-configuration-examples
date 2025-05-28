function Visible = SatVisibility(SatPosition,time,llaInterest)
% Function that finds if a given position is visible from a position of interest
% Inputs:
% 1. Satellite position [x y z] km
% 2. Current time [year month day hour minute second]
% 3. llaInterest [Latitude Longitude altitude] of point of interest
% Outputs:
% 1. Visible: boolean representing whether the satellite is visible

LatInt = llaInterest(1);
LonInt = llaInterest(2);
AltInt = llaInterest(3);
lla = eciTolla(1000*SatPosition,time);
[~,elevation,~] = geodeticToaer(LatInt,LonInt,AltInt,lla(1),lla(2),lla(3));

R = 6371; % Earth's radius in kilometers
theta_rad = acos(R / (R + AltInt/1000));
theta_deg = -rad2deg(theta_rad); % Convert radians to degrees

if elevation > theta_deg
    Visible = 1;
else
    Visible = 0;
end

end