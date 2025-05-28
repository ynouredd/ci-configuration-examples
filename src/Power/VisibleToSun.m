function Visible = VisibleToSun(SatPosition,StartTime,SecondsToPropagate)
%% Find the time history of when a specific satellite is not being eclipsed by Earth
% Inputs: 
% 1. SatPosition: Satellite position history N-by-[x y z] km
% 2. StartTime: mission Start time [year month day hour minute second]
% 3. SecondsToPropagate: Seconds to propagate sim for

% Outputs
% Visible: 1xn matrix with the time history of the visibility of the
% satellite with the sun

[sun_latitude,sun_longitude,sun_altitude] = sunLLAHist();
Visible = zeros(1,length(SatPosition));

for index = 1:length(SatPosition)
    date = datevec(datetime(StartTime) + seconds(SecondsToPropagate*index/11800));
    lla = eciTolla(1000*SatPosition(index,:),date);

    dayFrac = date(4)/24+date(5)/(24*60)+date(6)/(24*60*60);
    indexSun = floor(dayFrac*length(sun_altitude))+1;
    
    [~, elevation, ~] = geodeticToaer(lla(1),lla(2),lla(3),sun_latitude(indexSun),sun_longitude(indexSun),sun_altitude(indexSun));
    EarthCone = asind(6371e3 / (lla(3)+6371e3));
    if elevation > (EarthCone-90)
        Visible(index) = 1;
    else
        Visible(index) = 0;
    end
end

end