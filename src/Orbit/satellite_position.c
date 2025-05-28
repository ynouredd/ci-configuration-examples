#include "mex.h"
#include <math.h>
#include <time.h>

// Constants
#define PI 3.14159265358979323846
#define DEG_TO_RAD (PI / 180.0)
#define RAD_TO_DEG (180.0 / PI)
#define EARTH_RADIUS 6371.0  // Earth's radius in kilometers

// Function to calculate Greenwich Sidereal Time (GST)
double calculate_gst(time_t current_time) {
    struct tm *gmt = gmtime(&current_time);
    
    // Julian Date for J2000.0
    double JD_J2000 = 2451545.0;
    
    // Calculate Julian Date for the current time
    int year = gmt->tm_year + 1900;
    int month = gmt->tm_mon + 1;
    double day = gmt->tm_mday + (gmt->tm_hour + (gmt->tm_min + gmt->tm_sec / 60.0) / 60.0) / 24.0;
    
    if (month <= 2) {
        year -= 1;
        month += 12;
    }
    
    double A = floor(year / 100.0);
    double B = 2 - A + floor(A / 4.0);
    double JD = floor(365.25 * (year + 4716)) + floor(30.6001 * (month + 1)) + day + B - 1524.5;
    
    // Calculate GST in degrees
    double D = JD - JD_J2000;
    double GST = 280.46061837 + 360.98564736629 * D;
    GST = fmod(GST, 360.0);
    if (GST < 0) {
        GST += 360.0;
    }
    
    return GST * DEG_TO_RAD;
}

// Function to convert ECI to ECEF coordinates
void eci_to_ecef(double x_eci, double y_eci, double z_eci, double gst, double *x_ecef, double *y_ecef, double *z_ecef) {
    *x_ecef = x_eci * cos(gst) + y_eci * sin(gst);
    *y_ecef = -x_eci * sin(gst) + y_eci * cos(gst);
    *z_ecef = z_eci;
}

// Function to convert ECEF to Geodetic coordinates
void ecef_to_geodetic(double x_ecef, double y_ecef, double z_ecef, double *latitude, double *longitude, double *altitude) {
    *longitude = atan2(y_ecef, x_ecef);
    double hyp = sqrt(x_ecef * x_ecef + y_ecef * y_ecef);
    *latitude = atan2(z_ecef, hyp);
    *altitude = sqrt(x_ecef * x_ecef + y_ecef * y_ecef + z_ecef * z_ecef) - EARTH_RADIUS;
    *latitude *= RAD_TO_DEG;
    *longitude *= RAD_TO_DEG;
}

// Gateway function for MATLAB MEX
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    double x_eci, y_eci, z_eci;
    double latitude, longitude, altitude;
    
    // Get input arguments
    x_eci = mxGetScalar(prhs[0]);
    y_eci = mxGetScalar(prhs[1]);
    z_eci = mxGetScalar(prhs[2]);
    
    // Get current time
    time_t current_time = time(NULL);
    
    // Calculate GST
    double gst = calculate_gst(current_time);
    
    // Convert ECI to ECEF
    double x_ecef, y_ecef, z_ecef;
    eci_to_ecef(x_eci, y_eci, z_eci, gst, &x_ecef, &y_ecef, &z_ecef);
    
    // Convert ECEF to Geodetic coordinates
    ecef_to_geodetic(x_ecef, y_ecef, z_ecef, &latitude, &longitude, &altitude);
    
    // Create output arguments
    plhs[0] = mxCreateDoubleScalar(latitude);
    plhs[1] = mxCreateDoubleScalar(longitude);
    plhs[2] = mxCreateDoubleScalar(altitude);
} 