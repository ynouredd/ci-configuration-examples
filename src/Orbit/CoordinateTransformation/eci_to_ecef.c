#include "mex.h"
#include <math.h>
#include <time.h>

#define PI 3.14159265358979323846

void eci_to_ecef(double *Reci, double *Veci, double *Recef, double *Vecef) {
    // Get the current time
    time_t t = time(NULL);
    struct tm *tm_info = gmtime(&t);
    
    // Calculate the number of seconds since J2000.0
    int year = tm_info->tm_year + 1900;
    int month = tm_info->tm_mon + 1;
    int day = tm_info->tm_mday;
    int hour = tm_info->tm_hour;
    int minute = tm_info->tm_min;
    int second = tm_info->tm_sec;

    double jd = 367.0 * year - floor((7 * (year + floor((month + 9) / 12.0))) / 4.0) + floor((275 * month) / 9.0) + day + 1721013.5 + ((second / 60.0 + minute) / 60.0 + hour) / 24.0;
    double T = (jd - 2451545.0) / 36525.0;

    // Calculate the Greenwich Mean Sidereal Time (GMST)
    double GMST = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + T * T * (0.000387933 - T / 38710000.0);
    GMST = fmod(GMST, 360.0);
    if (GMST < 0) {
        GMST += 360.0;
    }
    double theta = GMST * PI / 180.0;

    // Rotation matrix for ECI to ECEF
    double R[3][3] = {
        { cos(theta), sin(theta), 0 },
        {-sin(theta), cos(theta), 0 },
        {          0,         0, 1 }
    };

    // Convert position
    Recef[0] = R[0][0] * Reci[0] + R[0][1] * Reci[1] + R[0][2] * Reci[2];
    Recef[1] = R[1][0] * Reci[0] + R[1][1] * Reci[1] + R[1][2] * Reci[2];
    Recef[2] = R[2][0] * Reci[0] + R[2][1] * Reci[1] + R[2][2] * Reci[2];

    // Convert velocity
    Vecef[0] = R[0][0] * Veci[0] + R[0][1] * Veci[1] + R[0][2] * Veci[2];
    Vecef[1] = R[1][0] * Veci[0] + R[1][1] * Veci[1] + R[1][2] * Veci[2];
    Vecef[2] = R[2][0] * Veci[0] + R[2][1] * Veci[1] + R[2][2] * Veci[2];
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    if (nrhs != 2) {
        mexErrMsgIdAndTxt("eci_to_ecef:nrhs", "Two inputs required.");
    }
    if (nlhs != 2) {
        mexErrMsgIdAndTxt("eci_to_ecef:nlhs", "Two outputs required.");
    }

    double *Reci = mxGetPr(prhs[0]);
    double *Veci = mxGetPr(prhs[1]);

    plhs[0] = mxCreateDoubleMatrix(3, 1, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(3, 1, mxREAL);

    double *Recef = mxGetPr(plhs[0]);
    double *Vecef = mxGetPr(plhs[1]);

    eci_to_ecef(Reci, Veci, Recef, Vecef);
}