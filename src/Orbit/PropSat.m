function [SatPositionHistory,SatVelocityHistory,NewTime] = PropSat(SatPos,SatVel,SecondsToPropagate,StartTime,MoonEffect,DragEffect,A,Cd,mass,escapedPrint)
% Propagate the satellite through it's start position, velocity and time
% for the duration of SecondsToPropagate.

% Example
% SatPos = PropSat([27840 37120 18560],[0, 1.262, -2.527] ,13223220,[2024, 1, 1, 0,0,0],1,0,1,25000,10)
% SatPos = PropSat([50000 0 0],[0 2.823 0],13223220,[2024, 1, 1, 0,0,0],1,0,1,25000,10)

period = calculatePeriod(SatPos,SatVel);

if ~exist('escapedPrint','var')
    escapedPrint = false;
end

if isnan(period)
    dT = 30;
else
    a = calculateSMA(SatPos,SatVel);
    e = calculateEccentricity(SatPos,SatVel);
    rp = a * (1 - e);
    vp = sqrt(3.986e5 * (2/rp - 1/a));
    dT = 10/vp;
end

Msize = floor(SecondsToPropagate/dT);
SatPositionHistory = zeros(Msize, 3); % Assuming 3D position
SatVelocityHistory = zeros(Msize, 3); % Assuming 3D position

index = 1;
if MoonEffect
    [MoonPos,MoonVel] = SyncMoon(StartTime);
end

for NewTime = 0:dT:SecondsToPropagate
    if MoonEffect
        [MoonPos,MoonVel] = propagateAboutEarth(MoonPos,MoonVel,dT);
        [SatPos,SatVel] = propagateAboutMoon(SatPos,SatVel,dT,MoonPos);
    else
        [SatPos,SatVel] = propagateAboutEarth(SatPos,SatVel,dT);
    end
    
    if norm(SatPos) < (6371+85)
        if escapedPrint
            fprintf('Satellite deorbited in %d seconds\n', NewTime);
        end
        break
    end
    
    if DragEffect
        if ~exist('A','var')
            A = 10;
        end
        
        if ~exist('Cd','var')
            Cd = 2.2;
        end
        
        if ~exist('mass','var')
            mass = 100;
        end
        SatVel = computeVelocityWithDrag(SatPos,SatVel,A,Cd,mass,dT);
    end
    
    if norm(SatPos) > (1000000)
        if escapedPrint
            fprintf('Satellite escape Earth Orbit in %d seconds\n', NewTime);
        end
        break
    end
    
    SatVelocityHistory(index, :) = SatVel;
    SatPositionHistory(index, :) = SatPos;
    index = index + 1;
end

SatPositionHistory = SatPositionHistory(1:index-1, :);
SatVelocityHistory = SatVelocityHistory(1:index-1, :);

n = size(SatPositionHistory, 1);
originalTime = (0:n-1) * dT;
newTimeStep = dT*25;
newTime = originalTime(1):newTimeStep:originalTime(end);

% Interpolate the entire matrix in one go
SatPositionHistory = interp1(originalTime, SatPositionHistory, newTime, 'spline');
SatVelocityHistory = interp1(originalTime, SatVelocityHistory, newTime, 'spline');

end

function SatVel = computeVelocityWithDrag(SatPos,SatVel,A,Cd,mass,dT)
drag_force = calculate_drag(SatPos, SatVel, A, Cd);
acceleration_drag = drag_force / mass;
direction_drag = -SatVel / norm(SatVel);
acceleration_vector = acceleration_drag * direction_drag;
SatVel = SatVel + acceleration_vector * dT;
end