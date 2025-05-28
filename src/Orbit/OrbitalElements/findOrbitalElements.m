function [SMA,ECC,INC,RAAN,AOP,TA] = findOrbitalElements(position,velocity)

SMA = calculateSMA(position,velocity);
ECC = calculateEccentricity(position,velocity);

INC = calculateInc(position,velocity);
RAAN = calculateRAAN(position,velocity);

AOP = calculateAOP(position,velocity);
TA = calculateTA(position,velocity);
end