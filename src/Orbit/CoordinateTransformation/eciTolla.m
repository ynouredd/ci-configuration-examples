function lla = eciTolla(eci, dateVec)
    % eciTolla Converts ECI coordinates to LLA (Latitude, Longitude, Altitude)
    %   eci: 1x3 vector containing ECI coordinates [x, y, z] in meters
    %   dateVec: 1x6 vector containing date and time [yyyy, mm, dd, hh, mm, ss]

    % Constants
    a = 6378137; % Semi-major axis of the Earth in meters
    f = 1 / 298.257223563; % Flattening
    e2 = f * (2 - f); % Square of eccentricity

    % Extract the ECI coordinates
    x = eci(1);
    y = eci(2);
    z = eci(3);

    % Convert date vector to Julian date
    jd = computeJulianDate(dateVec);

    % Convert ECI to ECEF
    ecef = eci2ecef([x, y, z], jd);

    % Extract ECEF coordinates
    x_ecef = ecef(1);
    y_ecef = ecef(2);
    z_ecef = ecef(3);

    % Longitude calculation
    lon = atan2(y_ecef, x_ecef);

    % Iterative Latitude and Altitude calculation
    p = sqrt(x_ecef^2 + y_ecef^2);
    lat = atan2(z_ecef, p * (1 - e2)); % Initial guess
    N = a / sqrt(1 - e2 * sin(lat)^2);
    alt = p / cos(lat) - N;

    for i = 1:5 % Iterative improvement
        N = a / sqrt(1 - e2 * sin(lat)^2);
        alt = p / cos(lat) - N;
        lat = atan2(z_ecef, p * (1 - e2 * N / (N + alt)));
    end

    % Convert radians to degrees
    lat = rad2deg(lat);
    lon = rad2deg(lon);

    % Output LLA
    lla = [lat, lon, alt];
end

function ecef = eci2ecef(eci, jd)
    % Calculate the Greenwich Mean Sidereal Time (GMST)
    gmst = siderealTime(jd);

    % Rotation matrix for ECI to ECEF
    R = [cosd(gmst), sind(gmst), 0; ...
        -sind(gmst), cosd(gmst), 0; ...
         0, 0, 1];

    % Apply the rotation
    ecef = (R * eci')';
end

function gmst = siderealTime(jd)
    % Calculate the Greenwich Mean Sidereal Time in degrees
    T = (jd - 2451545.0) / 36525.0;
    gmst = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + T^2 * (0.000387933 - T / 38710000.0);
    gmst = mod(gmst, 360); % Ensure GMST is within 0-360 degrees
end

function jd = computeJulianDate(dateVec)
    % computeJulianDate Converts a date vector to Julian Date
    %   dateVec: 1x6 vector containing date and time [yyyy, mm, dd, hh, mm, ss]

    % Extract date components
    year = dateVec(1);
    month = dateVec(2);
    day = dateVec(3);
    hour = dateVec(4);
    minute = dateVec(5);
    second = dateVec(6);

    % If month is January or February, adjust year and month
    if month <= 2
        year = year - 1;
        month = month + 12;
    end

    % Calculate the Julian Date
    A = floor(year / 100);
    B = 2 - A + floor(A / 4);
    jd = floor(365.25 * (year + 4716)) + floor(30.6001 * (month + 1)) + day + B - 1524.5;
    jd = jd + (hour + minute / 60 + second / 3600) / 24;
end