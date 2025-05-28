function visible = SatVisibilityHistory(SatPosition,timeStart,llaInterest,SecondsToPropagate)
% Function that finds percentage of the time a satellite is over a position of interest
% Inputs:
% 1. Satellite position history N-by-[x y z] km
% 2. Start time [year month day hour minute second]
% 3. llaInterest [Latitude Longitude altitude] of point of interest
% 4. Duration of the position history given in input 1
% Outputs:
% 1. visible: N-by-1 matrix representing when the satellite is visible with
% boolean
    dT = SecondsToPropagate/(length(SatPosition)-1);        
    index = 1;
    visible = 0;

    for NewTime = 0:dT:SecondsToPropagate
        CurrentTime = datetime(timeStart) + seconds(NewTime);
        CurrentTime = datevec(CurrentTime);
        visible(index) = SatVisibility(SatPosition(index,:),CurrentTime,llaInterest);
        index = index + 1;
    end
end