function EbNoArray = findSignalToNoise(positionArray, startTime, groundStation, antenna, varargin)
% Find the signal to noise ratio between a transmitter and satellite. 
% The satellite is the transmitter and the antenna is the receiver. 
% If the satellite and ground station do not have direct line of sight, return a SNR of -inf
% Inputs:
% 1. positionArray (m) of the satellite for multiple time steps
% 2. startTime [year month day hour minute second] we would like to find EbNo
% 3. groundStation name defined as string to .MAT file
% 4. Satellite antenna to be used, defined as string to .txt
% 5. Optional: timeIncrement in seconds to increment time for each position
% Outputs:
% EbNoArray (Signal-to-noise) in dB for each time step
% Example:
% EbNoArray = findSignalToNoise([1000 700 -100000]*1e3,[2024, 7, 24, 11,20,0],"Canberra.mat","ISS.txt","WGS 84")

% Parse optional inputs
if isscalar(varargin)
    timeIncrement = varargin{1};
else
    timeIncrement = 0; % Default to 0 if not provided, implying single position
end

% Initialize the EbNoArray
numPositions = size(positionArray, 1);
EbNoArray = zeros(numPositions, 1);

% Load ground station data
GroundStation = load(groundStation);
GroundStation = GroundStation.GroundStation;

% Load satellite antenna data
fileID = fopen(antenna, 'r');
satelliteData = fread(fileID, '*char')';
fclose(fileID);
eval(satelliteData);

% Loop through each position
for i = 1:numPositions
    % Calculate the current time
    currentTime = datetime(startTime) + seconds((i-1) * timeIncrement);
    date = datevec(currentTime);

    % Convert ECI to LLA
    lla = eciTolla(positionArray(i, :), date);

    % Calculate the angles and range
    [~, elevation, slantRange] = geodeticToaer(GroundStation.Latitude, GroundStation.Longitude, GroundStation.Altitude, lla(1), lla(2), lla(3));

    % Calculate the signal to noise ratio
    BitRate = 10e7;
    AntGain = 10 * log10(Satellite.Efficiency * (4 * pi^2 * (Satellite.DishDiameter / 2)^2 * (3e8 / Satellite.Frequency)^(-2)));
    GSGain = 10 * log10(GroundStation.Efficiency * (4 * pi^2 * (GroundStation.Diameter / 2)^2 * (3e8 / GroundStation.Frequency)^(-2)));
    FSPL = 20 * log10(slantRange) + 20 * log10(Satellite.Frequency) + 20 * log10(4 * pi / 3e8);
    NPSD = 10 * log10(1.38e-23 * GroundStation.NoiseTemperature) + 30;
    NPBandwidth = NPSD + 10 * log10(BitRate);
    AMF = 0.1 / sind(elevation);

    if elevation > 0
        EbNoArray(i) = Satellite.Power + AntGain + GSGain - FSPL - NPBandwidth - AMF;
    else
        EbNoArray(i) = -inf;
    end
end

end