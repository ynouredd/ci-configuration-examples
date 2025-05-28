#include "mex.h"
#include <math.h>
#include <time.h>

// Function to calculate Julian Date
double calculateJulianDate(struct tm *utc) {
    int year = utc->tm_year + 1900;
    int month = utc->tm_mon + 1;
    double day = utc->tm_mday + utc->tm_hour / 24.0 + utc->tm_min / 1440.0 + utc->tm_sec / 86400.0;

    if (month <= 2) {
        year -= 1;
        month += 12;
    }

    int A = year / 100;
    int B = 2 - A + A / 4;

    return (int)(365.25 * (year + 4716)) + (int)(30.6001 * (month + 1)) + day + B - 1524.5;
}

// Function to calculate GMST
double calculateGMST(double julianDate) {
    double jd2000 = 2451545.0; // Julian Date for J2000.0
    double t = (julianDate - jd2000) / 36525.0;
    double GMST = 280.46061837 + 360.98564736629 * (julianDate - jd2000) + t * t * (0.000387933 - t / 38710000.0);
    GMST = fmod(GMST, 360.0); // Normalize to [0, 360)
    if (GMST < 0) {
        GMST += 360.0;
    }
    return GMST;
}

// MEX gateway function
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    // Get the current UTC time
    time_t now;
    time(&now);
    struct tm *utc = gmtime(&now);

    // Calculate Julian Date
    double julianDate = calculateJulianDate(utc);

    // Calculate GMST
    double GMST = calculateGMST(julianDate);

    // Convert GMST from degrees to hours
    double GMST_hours = GMST / 15.0;

    // Set the output
    plhs[0] = mxCreateDoubleScalar(GMST_hours);
}