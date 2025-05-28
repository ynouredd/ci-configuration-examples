function [azimuth, elevation, slantRange] = geodeticToaer(observerLat, observerLon, observerAlt, targetLat, targetLon, targetAlt)
    % Constants
    R_earth = 6378137; % Earth's radius in meters (WGS-84)
    f = 1 / 298.257223563; % Flattening factor
    
    % Convert geodetic to ECEF for observer
    [xObs, yObs, zObs] = geodeticToECEF(observerLat, observerLon, observerAlt, R_earth, f);
    
    % Convert geodetic to ECEF for target
    [xTgt, yTgt, zTgt] = geodeticToECEF(targetLat, targetLon, targetAlt, R_earth, f);
    
    % Calculate the vector from observer to target in ECEF
    dx = xTgt - xObs;
    dy = yTgt - yObs;
    dz = zTgt - zObs;
    
    % Calculate slant range
    slantRange = sqrt(dx^2 + dy^2 + dz^2);
    
    % Convert observer's position to ENU (East-North-Up) coordinates
    [east, north, up] = ecefToENU(dx, dy, dz, observerLat, observerLon);
    
    % Calculate azimuth and elevation
    azimuth = atan2d(east, north);
    elevation = atan2d(up, sqrt(east^2 + north^2));
    
    % Normalize azimuth to 0-360 degrees
    if azimuth < 0
        azimuth = azimuth + 360;
    end
end

function [x, y, z] = geodeticToECEF(lat, lon, alt, R_earth, f)
    % Convert latitude, longitude, altitude to ECEF coordinates
    lat = deg2rad(lat);
    lon = deg2rad(lon);
    
    % Calculate the prime vertical radius of curvature
    N = R_earth / sqrt(1 - f * (2 - f) * sin(lat)^2);
    
    % Calculate ECEF coordinates
    x = (N + alt) * cos(lat) * cos(lon);
    y = (N + alt) * cos(lat) * sin(lon);
    z = (N * (1 - f)^2 + alt) * sin(lat);
end

function [east, north, up] = ecefToENU(dx, dy, dz, lat, lon)
    % Convert ECEF vector to ENU coordinates
    lat = deg2rad(lat);
    lon = deg2rad(lon);
    
    % Transformation matrix from ECEF to ENU
    t = [-sin(lon), cos(lon), 0;
         -sin(lat)*cos(lon), -sin(lat)*sin(lon), cos(lat);
         cos(lat)*cos(lon), cos(lat)*sin(lon), sin(lat)];
    
    % Apply the transformation
    enu = t * [dx; dy; dz];
    
    east = enu(1);
    north = enu(2);
    up = enu(3);
end