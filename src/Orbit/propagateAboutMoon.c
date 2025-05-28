#include "mex.h"
#include <math.h>

// Gravitational constant times the mass of the Moon (in appropriate units)
#define GM_MOON 4902.800066 // km^3/s^2

// Gravitational constant times the mass of Earth (in appropriate units)
#define GM_EARTH 398600.4418 // km^3/s^2

void propagate(double *r, double *v, double dt, double *moon_pos, double *r_out, double *v_out) {
    double r_rel_moon[3];
    double r_mag_moon;
    double r_mag_earth;
    double a_moon[3], a_earth[3], a_total[3];

    // Calculate relative position vector to the Moon (r - moon_pos)
    for (int i = 0; i < 3; i++) {
        r_rel_moon[i] = r[i] - moon_pos[i];
    }

    r_mag_moon = sqrt(r_rel_moon[0]*r_rel_moon[0] + r_rel_moon[1]*r_rel_moon[1] + r_rel_moon[2]*r_rel_moon[2]);
    r_mag_earth = sqrt(r[0]*r[0] + r[1]*r[1] + r[2]*r[2]);

    // Check if r_mag is NaN or zero to avoid division by zero or undefined behavior
    if (isnan(r_mag_moon) || r_mag_moon == 0 || isnan(r_mag_earth) || r_mag_earth == 0) {
        mexErrMsgIdAndTxt("MATLAB:propagate:invalidMagnitude", "Position magnitude is NaN or zero, leading to undefined behavior.");
        return;
    }

    // Calculate acceleration due to the Moon
    for (int i = 0; i < 3; i++) {
        a_moon[i] = -GM_MOON * r_rel_moon[i] / (r_mag_moon * r_mag_moon * r_mag_moon);
    }

    // Calculate acceleration due to the Earth
    for (int i = 0; i < 3; i++) {
        a_earth[i] = -GM_EARTH * r[i] / (r_mag_earth * r_mag_earth * r_mag_earth);
    }

    // Combine accelerations
    for (int i = 0; i < 3; i++) {
        a_total[i] = a_moon[i] + a_earth[i];
    }
    
    // Update velocity
    for (int i = 0; i < 3; i++) {
        v_out[i] = v[i] + a_total[i] * dt;
    }
    
    // Update position
    for (int i = 0; i < 3; i++) {
        r_out[i] = r[i] + v_out[i] * dt;
    }
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    // Check for proper number of arguments
    if (nrhs != 4) {
        mexErrMsgIdAndTxt("MATLAB:propagate:invalidNumInputs", "Four input arguments required.");
    }
    if (nlhs != 2) {
        mexErrMsgIdAndTxt("MATLAB:propagate:invalidNumOutputs", "Two output arguments required.");
    }
    
    // Input arguments
    double *r = mxGetPr(prhs[0]);
    double *v = mxGetPr(prhs[1]);
    double dt = mxGetScalar(prhs[2]);
    double *moon_pos = mxGetPr(prhs[3]);
    
    // Output arguments
    plhs[0] = mxCreateDoubleMatrix(3, 1, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(3, 1, mxREAL);
    double *r_out = mxGetPr(plhs[0]);
    double *v_out = mxGetPr(plhs[1]);
    
    // Propagate the object
    propagate(r, v, dt, moon_pos, r_out, v_out);
}