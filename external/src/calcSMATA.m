function [SMA, TA] = calcSMATA(r_vec, v_vec)
    % Constants
    mu = 398600.4418; % Earth's gravitational parameter in km^3/s^2

    % Magnitudes of position and velocity
    r = norm(r_vec);
    v = norm(v_vec);

    % Specific angular momentum
    h_vec = cross(r_vec, v_vec);
    h = norm(h_vec);

    % Eccentricity vector
    e_vec = (1/mu) * ((v^2 - mu/r) * r_vec - dot(r_vec, v_vec) * v_vec);
    e = norm(e_vec);

    % Semi-Major Axis (SMA)
    SMA = 1 / ((2/r) - (v^2/mu));

    % True Anomaly (TA)
    % Ensure e is not zero to avoid division by zero
    if e ~= 0
        cos_TA = dot(e_vec, r_vec) / (e * r);
        % Correctly determine the sine of the true anomaly
        sin_TA = dot(cross(e_vec, r_vec), h_vec) / (e * h * r);
        TA = atan2(sin_TA, cos_TA);
    else
        % For circular orbits, TA is undefined; set to zero or another convention
        TA = 0;
    end

    % Convert TA from radians to degrees
    TA = rad2deg(TA);
end